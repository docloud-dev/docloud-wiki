# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

The content source for the Docloud / DoFramework documentation site (**dev.docloud.lk**). It holds Markdown only. There is no website code, no `package.json`, and no build, lint or test commands here.

The site itself is a **Docusaurus** project in a separate repo, `docloud-dev/docloud-docs-public`. Publishing works like this:

1. A push to `main` (or `master`) runs `.github/workflows/deploy.yml`.
2. That workflow only sends a `repository_dispatch` (`event_type: wiki_updated`) to `docloud-docs-public`, using the `PAT_TOKEN` secret.
3. The site repo pulls this content, builds and deploys it. Changes go live in about 60–90 seconds.

Day-to-day work happens on `dev`. Merging or pushing to `main` **publishes to the live site**, so do it only when the user asks. A Docusaurus build failure (for example an MDX parse error) shows up in the `docloud-docs-public` repo's Actions, not here, so check locally first.

## Previewing

`./preview.sh` copies `docs/` and `blog/` into a local clone of the site repo (`../docloud-docs-public`, cloned and installed on first run; override with `SITE_DIR`) the same way the deploy does, then starts the dev server at `http://localhost:3000` and keeps copying edits every second. `./preview.sh build` runs the production build instead. Run it before merging to `main`, because it catches the MDX errors that would otherwise break the deploy. The copied content shows up as changes in the site repo's `git status`; never commit it there.

The repo root is also an **Obsidian vault** (`.obsidian/`). Contributors edit in Obsidian or VS Code. The shared vault config (`app.json`, `appearance.json`, `core-plugins.json`) is tracked. Per-user state such as `workspace.json` is gitignored.

## Layout

- `docs/`: technical guides. Everything lives under `docs/framework/`, apart from `docs/Home.md`, the landing page served at `/docs/` (`slug: /`).
- A section of `docs/framework/` is a **folder with an overview page of the same name inside it**: `Essentials/Essentials.md`, `Modules/Modules.md`, `Modules/Util/Util.md`. Docusaurus makes that page the folder's sidebar entry, at the folder's URL. Don't put an overview page next to its folder (`Modules.md` beside `Modules/`), or the sidebar lists the section twice. When you add a child page, also add a short `##` section with a one-paragraph summary to the overview page, as `Modules/Modules.md` and `Essentials/Essentials.md` already do.
- The sidebar is generated from the folders. Order comes from `sidebar_position` in front matter, and from `position` in a folder's `_category_.json`. `docs/framework/_category_.json` also sets the "Framework" label. Top-level framework pages use positions with gaps (Get Started 10, Docloud 20, Core Classes 30, Essentials 40, Modules 50, Vue DC UI KIT 60, Admin Panel 70, Todo App 80), so a new page can slot in between. Without a position, a page sorts alphabetically after the numbered ones.
- Filenames are Title Case with spaces and match the page's H1 (`Date And Time Manager.md`, `Scheduler (Heartbeat).md`).
- `blog/`: posts named `YYYY-MM-DD-title.md`. Authors are defined in `blog/authors.yml`.
- The root `README.md` mentions an `/api` folder for API references. It doesn't exist yet. Create it only if the user asks for API-reference content.

## Page conventions

### Docs

Most existing pages were **exported from Notion**. That's why they have no front matter and start like this:

```markdown
# Page Title

Owner: Nuwan Danushka
```

The README says every doc must start with front matter. For **new** pages, follow that:

```markdown
---
title: My Page Title
sidebar_label: Short Title
---
```

Then keep the house structure: an `# Introduction` section, then task-oriented `# How to …` sections, then a methods reference. Separate major sections with `---`.

Method reference entries follow this shape (see `Modules/Util/Validation.md` and `Modules/Curl.md`):

````markdown
### methodName

Description:

The **`methodName`** method …

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

Callouts use Notion's `<aside>` block, with the emoji on the first line and a blank line before the closing tag:

```markdown
<aside>
💡 Note text here.

</aside>
```

### Code samples

- Backend code is **PHP** (` ```php `, the vast majority of samples). Frontend code is **Vue 3 components written as JS modules** (` ```jsx `), which import UI kit components from the registry in the framework's `xp_system` directory (e.g. `import { DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js"`). The folder really is spelled `dc_ui_kit_componenets`, and the kit's rules forbid importing a component's own file.
- Docusaurus parses Markdown as MDX. Keep anything that contains `{`, `}` or `<Tag>` (Vue templates, `{{ mustache }}`, JSX, HTML) **inside code fences or inline code**. In prose, those characters can break the site build.
- Notion export artifacts you'll find: URLs wrapped as `"<https://example.com>"` inside code, a stray blank line before a closing fence, and a leftover `chat.openai.com` link in `Todo App.md`. Clean them up in any section you edit, and don't copy them into new content.

### Blog posts

Front matter needs `slug`, `title`, `authors` and `tags`. `authors` must be a key that exists in `blog/authors.yml` (several past commits were fixes for unknown authors). Add a new author entry there before using them.

```markdown
---
slug: framework-update-v2
title: We released our Documentation
authors: thilina
tags: [update]
---
```

## Terminology

The product name is spelled several ways across pages: "DoFramework", "Do Framework", "DoCloud", "Docloud". Match the spelling already used on the page you're editing. Platform requirements (PHP 8.1+, 128 MB memory limit, Apache 2.4+/OpenLiteSpeed/LSWS, `.htaccess` support) are in `docs/Home.md` and `docs/framework/Get Started.md`. Keep the two consistent if either changes.

## Known gaps

- `docs/framework/Essentials/Scheduler (Heartbeat).md` is an empty stub.
- No existing doc page has front matter yet. Adding it is a welcome cleanup, but keep it out of unrelated edits.
