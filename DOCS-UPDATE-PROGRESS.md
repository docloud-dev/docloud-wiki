# Docs update for framework 0.0.42: progress

This note tracks the rewrite of this wiki against DoFramework 0.0.42 so the work can continue on another machine. Only `docs/` and `blog/` are copied to the site, so this file is never published. Delete it when the update is merged.

**Source of truth:** the framework repo (`docloud-dev/docloud-framework`, the `dev-nipun` branch, at 0.0.42 plus unreleased migrations). Every claim on a page was checked against its code. The framework README and CHANGELOG were used only as leads, because parts of the README are out of date.

## Status

| Phase | What | State |
| --- | --- | --- |
| Tooling | `preview.sh` local preview and build | Done (`8c07a0c`) |
| 1 | Fix code samples that no longer matched the framework | Done (`4a4fdf9`) |
| 2 | Rewrite Authentication, App Manager, Config Handlers, App Options, Notification, Scheduler; new Roles And Permissions, Configuration Files | Done (`6f37945`) |
| Sidebar | Overview pages moved inside their folders, Home at `/docs/`, sidebar order | Done (`2b71386`) |
| 3 | New Architecture, Frontend Runtime (XP) and the Building Apps section; Todo App tutorial rewritten | Done (`e2553a4`) |
| 4 | Get Started, Docloud, Core Classes, Admin Panel, the remaining Essentials and Modules pages; new Custom Fields, Image Manager | Done (`4edd12c`) |
| 5 | UI kit: split `Vue DC UI KIT` into a section that covers all 68 components | Done |
| 6 | Blog post and publishing | Post written (`blog/2026-10-05-docs-for-framework-0-0-42.md`, author `nipun` added); its truncate marker is `{/* truncate */}`, because the site parses `.md` as MDX and rejects `<!-- -->`. `./preview.sh build` passes. **Merging `dev` into `main` publishes the site; the maintainer does this by hand.** |

## Phase 5: notes

The section is `docs/framework/Vue DC UI KIT/`: the overview page `Vue DC UI KIT.md` plus nine category pages (Buttons And Links, Form Fields, Selects And Pickers, Data Display, Navigation And Layout, Feedback And Overlays, Media, Dashboard Components, Framework Screens). Every registry export has exactly one `##` entry, and the overview's 68-row index links to each.

Corrections to the earlier notes, found while checking the code at tag `v0.0.42`:
- `DcImageUploader`'s `selected` is an event, not a prop.
- The `dcui-*` utility classes are in `assets/libs/dc-ui-kit/0.0.2/dc-ui-kit.css`, not `base_components.css`.
- The UI Kit demo app wasn't available, so the framework's own code was the only source.

Writers found a few security issues in kit components. They were kept off the site, as the conventions require, and passed to the maintainer to report to the framework team.

## Finishing up

1. ~~Finish Phase 5 and update "Known gaps" in `CLAUDE.md`.~~ Done.
2. ~~Run `./preview.sh build` and fix MDX errors, broken links and anchors.~~ Done. Rerun it after any further edit. Docusaurus gives no anchor to H1 sections after the title, and the anchor checker rejects anchors into pages with parentheses in their names.
3. ~~Reread the blog post.~~ Done: its "68 components" line is now true.
4. Leave out unreleased database migrations (`Migrator`, `php api/migrate.php`) until the framework release that ships them is tagged.
5. Push `dev`. The maintainer merges into `main`, which publishes the site.
6. Delete this file.

## Conventions used in this update

- **Audience:** external developers. Keep out internal apps (inventory, La Vivente / PMS), the internal test harness and agent tooling.
- **New and rewritten pages:** front matter (`title`, `sidebar_label`), the existing `Owner:` line kept, then `# Introduction`, `# How to …` sections, then a methods reference.
- **Framework bugs:** when a reader would hit one, say what actually happens in a short `<aside>`. Never describe a security weakness on the site; report it to the framework team instead.
- Relative links encode spaces as `%20`. Link only to anchors on `##` or deeper headings.
