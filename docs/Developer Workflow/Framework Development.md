---
sidebar_position: 2
title: Framework Development
sidebar_label: Framework Development
---

# Framework Development

# Introduction

This page is for people who change the framework itself, in the `docloud-dev/docloud-framework` repository. It covers how the team uses branches and commits, which files stay out of git, how to run the tests, and how a framework version is released.

If you build apps on the framework, you don't need this page. Read [App Development](./App%20Development.md) instead.

A few facts shape the whole workflow:

- **There is no build step.** The backend is PHP and the frontend is plain ES-module `.js` files. The framework bundles resources on each request. Don't add a Node build pipeline for framework or app code.
- **Apps are separate repositories.** `dev/` is ignored by the framework repository. An app you test the framework with lives in its own repository under `dev/`, and its changes are committed there, never in the framework.
- **Live config files aren't tracked.** Each install writes its own `api/config.xml` and `xp-config.json` files from tracked templates (see How to change config files below).

---

# How to set up a checkout

1. Clone the repository and serve it over HTTPS from the web root of a development host. The requirements are in [Get Started](../framework/Get%20Started.md).
2. Load a page in the browser before you run anything on the command line. The first request creates `api/config.xml`, `xp-config.json` and `api/admin/xp-config.json` from their `.dist` templates, and the web server then owns the files it created.
3. Run the installer, then make sure `<system_environment>` in `api/config.xml` is `development` and a `dev/` folder exists. See [Dev Workspace](../framework/Building%20Apps/Dev%20Workspace.md).
4. To test against apps, clone their repositories into `dev/`.

<aside>
💡 A checkout from before 0.0.41 still tracks the live config files. Git refuses the pull that untracks them while any of them has local changes. Back each changed file up, run `git checkout -- <file>`, pull, and copy your backup back.

</aside>

---

# How to use branches

| Branch | What it's for |
| --- | --- |
| `master` | The released framework. Every release is a commit on `master` with a `vX.Y.Z` tag. |
| `dev-<name>` | Each developer's own working branch, such as `dev-nipun` or `dev-thilina`. |

- **Work on your own branch.** Create `dev-<name>` from `master` and commit there. Don't commit to another developer's branch.
- **Keep it current.** Merge `master` into your branch after each release, so you build on what shipped:

  ```bash
  git fetch origin
  git merge origin/master
  ```

- **Take a teammate's work by merging their branch** into yours, for example when your change depends on theirs. Merge instead of cherry-picking, so the history shows where the change came from.
- **Get your change into `master` with a pull request** from your branch, so someone else reviews it before it's released.
- **Don't rewrite shared history.** No force-pushes to `master` or to a branch someone else has merged from, and never move or delete a release tag.

There is no CI on `master` yet. Nothing runs the tests for you, so run them before you push (see How to run the tests).

---

# How to write commits

Use a conventional subject with no scope:

```text
feat: the Log Viewer has an Admin activity tab
fix: the retention setting reports a failed save
refactor: add types and asserts
docs: changelog entries for the uploader fixes
test: bump-version refuses a lower version
chore: bump framework version to 0.0.44
```

- **Types:** `feat` for new behaviour, `fix` for a bug, `refactor` for a change that keeps behaviour the same, `test` for tests, `docs` for documentation and the changelog, `chore` for version bumps and housekeeping.
- **No app scope.** Write `fix: …`, not `fix(xp_users): …`. The only scopes in use are framework components, such as `feat(dc_ui_kit): …` for the UI kit.
- **Say what changed, as a fact about the code.** "the setup endpoint's install check fails closed" tells a reader more than "fix setup".
- **One logical change per commit.** Don't fold an unrelated fix into a feature commit. Use the body to explain why, when the subject can't.

---

# What never to commit

Most of these are in `.gitignore` already. Don't force-add them.

- **Live config files:** `api/config.xml`, `xp-config.json`, `api/admin/xp-config.json` and every `api/config.<environment>.xml` overlay. They hold an install's database settings and token.
- **Runtime data:** `api/db/do.db`, `api/logs/`, `storage/`.
- **Generated bundles:** `assets/app-scripts.js`, `assets/lib-scripts.js`, `assets/app-styles.css`, `assets/lib-styles.css` and their copies under `api/admin/assets/`. The framework rebuilds them on every request.
- **Anything in `dev/`.** App code belongs to the app's own repository.
- **Anything else in `apps/`, `api/apps/` and `api/admin/apps/`.** `.gitignore` ignores those folders except for the system apps that ship with the framework, so dev links and locally installed apps stay out of git. Only a new app that ships with the framework needs a `!/<folder>/<app>` line, in each of the three folders it uses.
- **Secrets:** `.env` files, tokens, private keys and zip exports.

Check `git status` before every commit. If a file you never meant to touch shows up, find out why before you commit it.

---

# How to change config files

`api/config.xml`, `xp-config.json` and `api/admin/xp-config.json` are live copies of tracked templates: `api/config.xml.dist`, `xp-config.json.dist` and `api/admin/xp-config.json.dist`. On every request and command-line run, `ConfigTemplates` creates a missing live copy from its template and carries new template keys onto it.

- **To change what ships to every install,** edit the `.dist` template and commit it.
- **To change your own install,** edit the live copy. It stays out of git.
- **Never edit version fields by hand.** `version`, `release_date`, `res_version` and `resources` in the xp-config files, and `api_version`, `modules` and `app_modules` in `config.xml`, are always taken from the template and are reset on the next request. `./bump-version` sets the versions (see How to release a version).

[Configuration Files](../framework/Essentials/Configuration%20Files.md) describes every setting.

---

# How to run the tests

Run the tests from the repository root.

**PHP.** Each file in `tests/php/` is a standalone script:

```bash
for t in tests/php/*.test.php; do php "$t" || echo "FAILED: $t"; done
```

A file prints `ok` or `FAIL` for each test, then a count, and exits with `1` if any test failed.

**JavaScript.** The dashboard widget tests use Node's built-in test runner:

```bash
node --test "tests/js/*.test.mjs"
```

**By hand.** Most of the framework has no automated tests. For a change to the admin panel, the web app or an install step, try it on your development install. Do an install or update from a zip when the change touches packaging, and log in as a user without `system_admin` when it touches permissions.

## Add a PHP test

Framework code that has no test suite uses the small runner in `tests/php/harness.php`. Register tests with `test()`, check results with `assert_same()` and `assert_true()`, and call `run_tests()` at the end:

```php
<?php
require __DIR__ . '/harness.php';
require REPO_ROOT . '/api/core/ConfigTemplates.php';

test('a missing live copy is created from its template', function () {
    $root = scratch_root();
    $template = "$root/xp-config.json.dist";
    $live = "$root/xp-config.json";
    file_put_contents($template, ConfigTemplates::encode_json(['version' => '0.0.44']));

    assert_same(true, ConfigTemplates::sync_json($template, $live));
    assert_same(file_get_contents($template), file_get_contents($live));
});

run_tests();
```

`scratch_root()` gives you a temporary folder with `api/` and `api/admin/` inside, which is deleted when the script ends. `logged()` returns what `error_log()` wrote since the last call. Name the file `tests/php/<topic>.test.php`.

---

# How to write the changelog

Add an entry to `CHANGELOG.md` with the change itself, in the same branch. Write it under `## [Unreleased]`, in one of these sections:

- **`### Added`**: new features, classes, actions or kit components.
- **`### Changed`**: behaviour that works differently now.
- **`### Fixed`**: bugs, described by what the user saw.
- **`### Upgrade`**: anything an existing install must do by hand, such as reinitializing an app, copying a file or logging in again.

Write for the people who run installs. Say what changed and what they need to do, and name settings, actions and files exactly. Lead with a short bold phrase when the entry is long.

<aside>
⚠️ The release's changelog is uploaded to DoCloud with the framework, and DoCloud can store only Windows-1252 characters there. Write `>` instead of an arrow and spell out symbols such as Σ. Em dashes and ellipses are fine.

</aside>

---

# How to release a version

Release from `master`, with everything for the release merged.

1. **Check the system apps.** For each system app (`api/apps/<app>/` with `<app_type>system_app</app_type>`) whose files changed since the last `v*` tag, raise `<app_version>` and `<release_date>` in its manifest, and set the same values in `apps/<app>/app-config.json` and `api/admin/apps/<app>/app-config.json`. Commit this as `chore: bump system app versions and release dates`.
2. **Bump the framework version:**

   ```bash
   ./bump-version 0.0.45
   ```

   It sets the version in the three `.dist` templates, their live copies, the "Current version" line in `README.md`, and turns `## [Unreleased]` in `CHANGELOG.md` into `## [0.0.45] - <today>`. Pass `--date=YYYY-MM-DD` for another date. It writes nothing, and says why, if the version isn't higher than the current one, if `README.md` or `CHANGELOG.md` lacks the line it edits, or if a system app from step 1 is wrong: changed since the last `v*` tag but still at that tag's `<app_version>`, or with an `app-config.json` whose `version` or `release_date` disagrees with its manifest. It lists each app to fix.

3. **Review and commit:**

   ```bash
   git diff
   git add README.md CHANGELOG.md xp-config.json.dist api/admin/xp-config.json.dist api/config.xml.dist
   git commit -m "chore: bump framework version to 0.0.45"
   git tag v0.0.45
   git push origin master v0.0.45
   ```

   `bump-version` doesn't commit or tag. The live copies it also changed stay out of git.

4. **Publish the release to DoCloud,** with this version's changelog section as its description, so installs can update.
5. **Update the docs.** Check the pages the release affects on this site, and write a blog post for a notable release (see [Contributing To The Docs](./Contributing%20To%20The%20Docs.md)). Once the pages match the new version, change the "These docs cover DoFramework x.y.z" line at the top of the [Home](../Home.md) page, and point its link to the newest docs update post.

After the release, everyone merges `master` into their `dev-<name>` branch.

---
