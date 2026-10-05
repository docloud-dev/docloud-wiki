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
| 5 | UI kit: split `Vue DC UI KIT` into a section that covers all 68 components | **In progress** (see below) |
| 6 | Blog post and publishing | Post drafted (`blog/2026-10-05-docs-for-framework-0-0-42.md`, author `nipun` added). **Merging `dev` into `main` publishes the site; the maintainer does this by hand.** |

## Phase 5: what's left

The kit page moved to `docs/framework/Vue DC UI KIT/Vue DC UI KIT.md` (the section's overview page). `_category_.json` puts the section at position 60. One page per category goes in that folder:

| Page | Components |
| --- | --- |
| `Buttons And Links.md` | DcButton, DcIconButton, DcSplitButton, DcLink, DcBoxIcon |
| `Form Fields.md` | DcInputField, DcTextField, DcPasswordField, DcPasswordGenerator, DcSearchField, DcFormGroup, DcCheckbox, DcCheckboxGroup, DcRadioGroup, DcToggleSwitch, DcTagInput |
| `Selects And Pickers.md` | DcSelect, DcDropdown, DcAutoComplete, DcSearchDropdown, DcTagDropdown, DcDatepicker, DcNativeDatePicker, DcDateRangePicker, DcCalendarRangePicker, DcFontAwesomeIconPicker |
| `Data Display.md` | DcTable, DcPagination, DcLoadMore, DcCard, DcCardPlain, DcInfoPanel, DcPointList, DcBubbleAvatar, DcEmptyState, DcActivityFeed, DcCommentFeed |
| `Navigation And Layout.md` | DcTabs, DcCategoryTabs, DcNavigationDrawer, DcBreadcrumbs, DcTreeNavigation, DcPageHeader, DcCollapsibleSidePanel, DcBlueHeaderBar, DcCardBlueContainer |
| `Feedback And Overlays.md` | DcPopup, DcLoaderBar, DcProgressBar, DcAjaxLoader, DcAjaxNotice |
| `Media.md` | DcImageUploader, DcImageUploaderMini, DcMediaViewer |
| `Dashboard Components.md` | DcDashboardWidget, DcAppTiles, DcQuickLinks, DcStatGroup (link to Building Apps/Dashboard Widgets) |
| `Framework Screens.md` | DcConfLogo, DcConfDevLogo, DcConfFooter, DcConfCard, DcConfTimeline, DcConfCheckList, DcConfCheckListItem, DcConfNeedSupport, DcDoCloudLogo, DcAuthFooter |

Check which of these files exist and are complete. Then finish the rest.

**The overview page** is still the old 2024 page until it's rewritten. The rewrite covers:
- that the kit is already loaded (the old "Install" section is wrong);
- importing only from `dc_ui_kit_registry.js`;
- the UI rules from the registry header;
- `base_components.css` and the `dcui-*` classes;
- theming variables;
- what the admin panel's smaller registry lacks;
- a 68-row component index linking to the category pages;
- one `##` summary per category page.

**Component entry format:**
- One `##` per component, using its exact export name.
- One or two sentences on what it's for.
- A minimal `jsx` example importing from the registry.
- A **Props** table (name, type, default, description).
- An **Events** table.
- **Slots** and exposed methods, when there are any.
- A note when the admin-panel registry doesn't export the component.
- Separate entries with `---`.

**Sources:**
- The framework's kit is in `apps/xp_system/components/dc_ui_kit_componenets/` (the folder name really is misspelled). Its `dc_ui_kit_registry.js` lists all 68 exports.
- The admin copy is in `api/admin/apps/xp_system/components/dc_ui_kit_componenets/`.
- The team's UI Kit demo app has per-component examples. Check its props against the framework's copy, because the demo may be newer than 0.0.42.

**Known errors in the old page:**
- `DcCheckbox`: it's `no_label`, not `nod_label`.
- `DcTextField`: `readlonly` is a typo.
- `DcInputField` is missing `icon`, `iconPosition`, `iconFilled` and the `icon-click` event.
- `DcTable` is missing `container_class`, `disabled_checkbox_title`, `selected_items`, `clear_checkboxes()` and the `custom-table-row` slot.
- `DcPopup` is missing `dismiss_on_overlay_click`, `closed`/`before-close` and the `title` slot.
- `DcImageUploader` is missing `id` and `selected`.
- `DcLoadMore` is missing `scroll-to-bottom`.
- `DcPasswordGenerator`'s `length` is a Number.
- Its examples use `lv-*` classes that belong to another app; never use them.

**Pages that link to the section:** Building Apps/Admin Pages, Building Apps/Dashboard Widgets, Todo App and the blog post. They already point at `Vue%20DC%20UI%20KIT/Vue%20DC%20UI%20KIT.md` or `/docs/framework/Vue%20DC%20UI%20KIT/`.

## Finishing up

1. Finish Phase 5. Then remove the UI kit line from "Known gaps" in `CLAUDE.md`.
2. Run `./preview.sh build`. Fix any MDX errors, broken links or broken anchors. Docusaurus gives no anchor to H1 sections after the title, and the anchor checker rejects anchors into pages with parentheses in their names.
3. Reread the blog post. Its "68 components" line depends on Phase 5.
4. Leave out unreleased database migrations (`Migrator`, `php api/migrate.php`) until the framework release that ships them is tagged.
5. Push `dev`. The maintainer merges into `main`, which publishes the site.
6. Delete this file.

## Conventions used in this update

- **Audience:** external developers. Keep out internal apps (inventory, La Vivente / PMS), the internal test harness and agent tooling.
- **New and rewritten pages:** front matter (`title`, `sidebar_label`), the existing `Owner:` line kept, then `# Introduction`, `# How to …` sections, then a methods reference.
- **Framework bugs:** when a reader would hit one, say what actually happens in a short `<aside>`. Never describe a security weakness on the site; report it to the framework team instead.
- Relative links encode spaces as `%20`. Link only to anchors on `##` or deeper headings.
