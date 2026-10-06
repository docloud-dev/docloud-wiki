---
sidebar_position: 3
title: Contributing To The Docs
sidebar_label: Contributing To The Docs
---

# Contributing To The Docs

# Introduction

This site is built from two repositories:

| Repository | What it holds |
| --- | --- |
| `docloud-dev/docloud-wiki` | The content: Markdown pages in `docs/` and blog posts in `blog/`. This is where you edit. |
| `docloud-dev/docloud-docs-public` | The Docusaurus site that turns the content into pages. You rarely change it. |

Only `docs/` and `blog/` are published. Anything else in `docloud-wiki`, such as its `README.md`, stays in the repository.

This page covers editing, previewing and publishing a change, the conventions every page follows, and the mistakes that break the site build.

---

# How publishing works

1. A push to `main` in `docloud-wiki` runs its `deploy.yml` workflow.
2. The workflow sends a `wiki_updated` event to `docloud-docs-public`. It doesn't build anything itself.
3. The site repository copies `docs/` and `blog/` from the wiki, builds the site and deploys it. The change is live at [dev.docloud.lk](https://dev.docloud.lk) in about 60 to 90 seconds.

A build failure, such as an MDX parse error, shows up in the **Actions** tab of `docloud-docs-public`, not in the wiki, and the live site keeps the previous version. Preview your change locally first so this doesn't happen.

If the wiki's **Trigger Website Build** run fails, the site wasn't told to rebuild. The usual cause is an expired `PAT_TOKEN` secret, which GitHub answers with `401 Bad credentials`. Renew the token, then rerun the failed run.

Because a push to `main` publishes, everyday work happens on the `dev` branch.

---

# How to make a change

1. Clone the wiki and switch to `dev`:

   ```bash
   git clone git@github.com:docloud-dev/docloud-wiki.git
   cd docloud-wiki
   git checkout dev
   git pull
   ```

2. Edit in any Markdown editor. The repository root is also an Obsidian vault, so you can open the folder in Obsidian. VS Code works just as well.
3. Preview the change (next section) and fix anything that looks wrong.
4. Commit with a short sentence in the imperative that says what changed, such as `Add the developer workflow section` or `Fix docs samples that no longer match the framework`, and push `dev`.
5. When the change is ready to go live, merge `dev` into `main` and push `main`. The maintainer usually does this step.

---

# How to preview locally

`./preview.sh` copies `docs/` and `blog/` into a local clone of the site repository, the same way the deploy does, and runs Docusaurus. You need Node.js, npm and `rsync`.

```bash
./preview.sh          # dev server at http://localhost:3000, re-copies your edits every second
./preview.sh build    # one production build, the same one the deploy runs
```

- On the first run it clones `docloud-docs-public` next to the wiki, at `../docloud-docs-public`, and runs `npm install`. Set `SITE_DIR` to use a clone somewhere else.
- **Run `./preview.sh build` before you merge to `main`.** The dev server forgives errors that fail the production build, such as broken links and anchors.
- The copied content shows up as changes in the site repository's `git status`. Never commit it there.

---

# How to add a page

1. **Pick the folder.** Framework pages live under `docs/framework/`. A section is a folder with an overview page of the same name inside it, such as `Essentials/Essentials.md` or `Developer Workflow/Developer Workflow.md`. The overview page becomes the section's sidebar entry.
2. **Name the file in Title Case with spaces,** matching the page's H1: `Date And Time Manager.md`, `Scheduler (Heartbeat).md`.
3. **Start with front matter:**

   ```markdown
   ---
   title: My Page Title
   sidebar_label: Short Title
   sidebar_position: 3
   ---
   ```

4. **Set the order.** The sidebar is generated from the folders. `sidebar_position` orders pages within a folder, and `position` in a folder's `_category_.json` orders the folder. A page without a position sorts alphabetically after the numbered ones. The top-level framework pages use positions with gaps (10, 20, 25, 30 …) so a new page can slot in between.
5. **Add a summary to the overview page.** Add a `##` section with one paragraph about the new page to the section's overview page, as the existing overview pages do.

Don't put an overview page next to its folder, such as `Modules.md` beside `Modules/`. The sidebar then lists the section twice.

---

# How to structure a page

Use this order, with `---` between major sections:

1. `# Introduction`: what the feature is and when you'd use it.
2. `# How to …` sections, one per task.
3. A methods reference, when the page documents a class.

A method entry looks like this:

````markdown
### methodName

Description:

The **`methodName`** method does one thing, described in a sentence.

Syntax:

```php
$obj = Util::Validation();
$result = $obj->methodName($arg);
```

**Parameters:**

- **`$arg`**: What it is.

**Return Value:**

- **`Boolean`**: What it returns.

---
````

Callouts use an `aside` block, with the emoji on the first line and a blank line before the closing tag:

```markdown
<aside>
💡 Note text here.

</aside>
```

Use 💡 for a tip and ⚠️ for something that can go wrong.

---

# How to keep the build working

Docusaurus reads every `.md` file as MDX, which is stricter than Markdown.

- **Keep `{`, `}` and anything that looks like an HTML tag inside code.** A Vue template, a `{{ mustache }}` expression, JSX or an HTML tag in normal text can fail the build. Put it in a code fence or in inline code.
- **No HTML comments.** MDX rejects `<!-- -->`. In a blog post, the truncate marker is `{/* truncate */}`.
- **Encode spaces in links as `%20`:** `[Dev Workspace](../framework/Building%20Apps/Dev%20Workspace.md)`.
- **Link to anchors on `##` or deeper headings only.** H1 sections after the page title get no anchor. The anchor checker also rejects anchors into pages with parentheses in their file names. Link to the page instead.
- **Tag code fences** with their language: `php` for backend code and `jsx` for Vue components written as JS modules.

---

# How to write a blog post

1. Name the file `blog/YYYY-MM-DD-title.md`.
2. Start with front matter. `authors` must be a key in `blog/authors.yml`, or the build fails:

   ```markdown
   ---
   slug: framework-update-v2
   title: We released our Documentation
   authors: thilina
   tags: [update]
   ---
   ```

3. Writing your first post? Add yourself to `blog/authors.yml` first:

   ```yaml
   yourname:
     name: Your Name
     url: https://dev.docloud.lk
     image_url: https://github.com/docloud-dev.png
   ```

4. Put `{/* truncate */}` after the opening paragraphs. The blog list shows everything above it.

---

# What to check before you publish

- **Every claim matches the framework.** Check behaviour against the framework's code at the release you're documenting, not against its README or an older page. If the code does something surprising that a reader would run into, say what actually happens in a short callout.
- **The page is for external developers.** Leave out internal apps, internal servers and internal tooling.
- **No security weaknesses.** If you find one while writing, report it to the framework team. Don't describe it on the site.
- **Product names match the page.** Pages use "DoFramework", "Do Framework", "DoCloud" and "Docloud". Keep the spelling the page already uses.
- **`./preview.sh build` passes.**

---
