---
title: Vue DC UI KIT
sidebar_label: Vue DC UI KIT
sidebar_position: 60
---

# Vue DC UI KIT

Owner: Thilina Deepal

# Introduction

The DC UI kit is the set of Vue 3 components and CSS classes that DoFramework screens are built from. The framework's own pages use it, and your app's pages should too, so that every app looks and behaves the same: the same buttons, fields, tables, popups and loaders, the same spacing and the same colours.

The kit has two parts:

- **68 components**, exported from one registry file, `dc_ui_kit_registry.js`. You import them into your page components like any ES module.
- **CSS classes** with the `dcui-` prefix (and a few `dc-` ones): the components' own styles, plus utility classes for spacing, layout, sizes and text.

This page explains how the kit is loaded, how to import and use a component, the rules for building screens with it, the utility classes and the theming variables, and how the admin panel's copy differs. The components themselves are documented on one page per category. The [component index](#component-index) below lists all 68 with a link to each.

---

# How the kit is loaded

There is nothing to install. The framework loads the kit on every page, for every app. Don't add its files to `xp-config.json` or copy them into your app.

`index.php` builds two bundles of scripts and two of styles on each request (see [App Frontend Config](../Building%20Apps/App%20Frontend%20Config.md)):

| Bundle | Built from | What it brings for the kit |
| --- | --- | --- |
| `assets/lib-scripts.js` | `resources.scripts` in `xp-config.json` | Vue 3.2.45 (the global build, which compiles `template` strings in the browser), Vue Router, Vuex 4 and jQuery. Then `assets/libs/dc-ui-kit/0.0.2/dc-ui-kit.js`, whose jQuery handlers open and close `DcDropdown` panels and switch basic tabs, and `dc-script.js`, which opens the side navigation's sub-menus. |
| `assets/lib-styles.css` | `resources.styles` in `xp-config.json` | Font Awesome 6 Pro, then `assets/libs/dc-ui-kit/0.0.2/dc-ui-kit.css` (the Lato font, the core theming variables, the base styles of fields, buttons, checkboxes, tables and tabs, and the utility classes) and `dc-style.css` (the `dc-*` styles of the framework shell, such as the side navigation and `dc-content-card`). |
| `assets/app-styles.css` | `resources.styles` of every active app's `app-config.json` | From `xp_system`: `normalize.css`, `base_components.css` (the styles of the newer components, such as the date pickers, `DcSearchDropdown`, `DcSplitButton`, `DcPageHeader` and the dashboard pieces), `styles.css` and `tooltip.css`. |

The component files are not in any bundle. They are ES modules under `apps/xp_system/components/dc_ui_kit_componenets/`, and the browser fetches them when your component imports the registry. The import map that `index.php` prints versions their URLs, so keep imports bare, without `?v=`.

<aside>
⚠️ `resources` in `xp-config.json` is release-owned: the framework puts the template's list back on the next request, so an edit there doesn't last (see [Configuration Files](../Essentials/Configuration%20Files.md)). To load your own scripts or styles, list them in your app's `app-config.json`.

</aside>

---

# How to use a component

## Import from the registry

Import components only from `dc_ui_kit_registry.js`, never from a component's own file. The registry is the kit's public list: some components live in subfolders (`containers/`, `layouts/`, `panels/`, `DcDatepicker/`), and three come from the framework's `helpers.js`, so the file paths are not something to rely on.

From a component in `apps/myapp/components/`, the path is:

```jsx
import { DcCard, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

From a deeper folder, such as `apps/myapp/components/orders/`, add one `../` per extra level.

<aside>
💡 The folder name is spelled `dc_ui_kit_componenets` in the framework. Copy it exactly, or the import fails with a 404.

</aside>

## Register it and use its tag

List each imported component in the `components` option, then write it in the template as a kebab-case tag: `DcButton` becomes `dc-button`, `DcBoxIcon` becomes `dc-box-icon`, `DcAjaxLoader` becomes `dc-ajax-loader`.

```jsx
import { DcCard, DcBoxIcon, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcCard, DcBoxIcon, DcButton },
    data() {
        return {
            saving: false,
        };
    },
    template: `
<dc-card>
    <div class="dcui-flex-item dcui-align-center dcui-flex-gap-15 dcui-m-b-20">
        <dc-box-icon icon="fa-regular fa-file-invoice"></dc-box-icon>
        <h2 class="dcui-m-0">Invoices</h2>
    </div>
    <dc-button :disabled="saving" @click="save">Save</dc-button>
</dc-card>`,
    methods: {
        save() {
            this.saving = true;
            // call your service here
        },
    },
};
```

`DcAjaxLoader`, `DcAjaxNotice` and `DcPagination` are the framework helpers `Ajax_Loader`, `Ajax_Notice` and `Pagination` under kit names. Import the kit names from the registry: they work as ordinary kebab-case tags, which the underscore names don't.

---

# How to follow the UI rules

The registry starts with the kit's rules for anyone building screens on the framework. In short:

- **Build screens from the kit.** Use the exported components and the framework's `dcui-*` and `dc-*` classes. Don't write your own button, input, dropdown, table, tabs, popup, loader or empty state.
- **Import from the registry**, never from a component's own file.
- **The registry is the full list.** Check it, or the [component index](#component-index) below, before deciding a component doesn't exist.
- **No inline styles and no new design values.** Don't write `style="..."`, and don't add colours, fonts, font sizes, shadows or CSS variables. Use the utility classes and the existing [theming variables](#core-variables).
- **Confirm every delete** in a `DcPopup` that names the item and says what will happen.
- **Don't invent a component.** If nothing in the kit fits, build the screen from what is there, and ask the DoCloud team before writing a new component.

A delete confirmation that follows these rules:

```jsx
import { DcButton, DcPopup } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcButton, DcPopup },
    data() {
        return {
            customer: { id: 7, name: "Sam Perera" },
        };
    },
    template: `
<dc-button @click="$refs.confirm_delete.show()">Delete customer</dc-button>

<dc-popup ref="confirm_delete" title="Delete customer?">
    <template #content>
        <p>{{ customer.name }} and their order history will be deleted. This can't be undone.</p>
        <div class="dcui-flex-item dcui-justify-flex-end dcui-flex-gap-10">
            <dc-button class="dcui-button-no-fill" @click="$refs.confirm_delete.hide()">Cancel</dc-button>
            <dc-button @click="delete_customer">Delete</dc-button>
        </div>
    </template>
</dc-popup>`,
    methods: {
        async delete_customer() {
            // call your service, then close the popup
            this.$refs.confirm_delete.hide();
        },
    },
};
```

See [Feedback And Overlays](./Feedback%20And%20Overlays.md#dcpopup) for everything `DcPopup` can do.

---

# How to style with dcui classes

The utility classes are in `dc-ui-kit.css` (in `assets/libs/dc-ui-kit/0.0.2/`). `base_components.css` (in `apps/xp_system/assets/`) holds the styles of the components themselves, named after them (`dcui-page-header`, `dcui-stat-group__value`, `dcui-calendar`), so you don't normally write those by hand.

| Family | Classes | Examples |
| --- | --- | --- |
| Margin | `dcui-m-`, then a side and a size. Sides: none (all), `t`, `b`, `l`, `r`, `tb`, `lr`. Sizes: `0`, `5`, `10`, `15`, `20`, `25`, `30` (px). | `dcui-m-b-15`, `dcui-m-r-10`, `dcui-m-tb-5`, `dcui-m-0` |
| Padding | `dcui-p-`, with the same sides and sizes. There is no `dcui-p-lr-0`. | `dcui-p-20`, `dcui-p-lr-15`, `dcui-p-t-0` |
| Flex layout | `dcui-flex-item` (a flex row), `dcui-flex-directions-column`, `dcui-flex-directions-row`, `dcui-flex-wrap`, `dcui-flex-nowrap`, `dcui-flex-wrap-reverse`, `dcui-flex-1`, `dcui-flex-grow`, `dcui-flex-shrink` | `dcui-flex-item dcui-flex-directions-column` |
| Alignment | `dcui-align-center`, `dcui-align-flex-start`, `dcui-align-flex-end`, `dcui-justify-center`, `dcui-justify-space-between`, `dcui-justify-space-around`, `dcui-justify-flex-start`, `dcui-justify-flex-end` | `dcui-flex-item dcui-align-center dcui-justify-space-between` |
| Gap | `dcui-flex-gap-5` to `dcui-flex-gap-30`, in steps of 5 | `dcui-flex-gap-15` |
| Grid | `dcui-container-fluid`, `dcui-row`, and `dcui-col-xs-1` to `dcui-col-xs-12`. The `sm`, `md`, `lg` and `xl` columns apply from 768, 992, 1200 and 1400 px wide. | `dcui-col-xs-12 dcui-col-md-6` |
| Width and height | `dcui-w-` and `dcui-h-` in pixels (`10` to `90` in steps of 10, then `100` to `1000` in steps of 50) or percent (`10p`, `15p`, `25p` … `95p`), plus `dcui-w-full`, `dcui-h-full`, `dcui-w-0`, `dcui-full-width` and `dcui-full-height`. There is no `20p` or `55p`. | `dcui-w-300`, `dcui-w-50p`, `dcui-h-full` |
| Display | `dcui-block`, `dcui-inline-block` | `dcui-inline-block` |
| Text | Alignment: `dcui-text-left`, `dcui-text-center`, `dcui-text-right`. Weight: `dcui-text-light`, `dcui-text-regular`, `dcui-text-medium`, `dcui-text-semibold`, `dcui-text-bold`. Colour: `dcui-text-success`, `dcui-text-danger`, `dcui-text-warning`. Wrapping: `dcui-text-nowrap`, `dcui-text-break-all`. Links: `dcui-text-link`. | `dcui-text-right dcui-text-semibold` |
| Scrolling | `dcui-scroll-container` (vertical, slim scrollbar), `dcui-horizontal-scrollable`, `dcui-no-scrollbar` | `dcui-scroll-container dcui-h-400` |
| Forms | `dcui-form-group`, `dcui-fld-label`, `dcui-form-control`, `dcui-f-l-required` (a red required marker), `dcui-checkbox-radio-inline` | `dcui-fld-label` |
| Modifiers | `dcui-button-no-fill` (an outlined button), `dcui-large` (a taller button or field) | `class="dcui-button-no-fill"` on a `dc-button` |

A summary row built only from kit classes:

```jsx
template: `
<div class="dcui-row">
    <div class="dcui-col-xs-12 dcui-col-md-6 dcui-m-b-15">
        <div class="dcui-flex-item dcui-justify-space-between dcui-align-center">
            <span class="dcui-text-semibold">Outstanding</span>
            <span class="dcui-text-danger dcui-text-bold dcui-text-nowrap">LKR 42,500.00</span>
        </div>
    </div>
</div>`,
```

<aside>
⚠️ `dcui-flex-gap-5` sets a 10px gap, the same as `dcui-flex-gap-10`. For a 5px gap between two items, use a margin class such as `dcui-m-r-5` instead.

</aside>

Only use classes that exist in the framework's stylesheets. Classes copied from other apps (for example an app's own prefixed classes) are not loaded for yours and render unstyled.

---

# Theming variables

The kit takes its colours and sizes from CSS custom properties. This section lists the ones that are available. The kit's rules forbid adding new ones, so build with these rather than hard-coded values.

## Core variables

`dc-ui-kit.css` defines these on `:root`. They are in the library bundle, which loads before every app's styles.

| Variable | Default | Used for |
| --- | --- | --- |
| `--dcui-font-family` | `'Lato', Helvetica Neue, helvetica, arial, sans-serif` | The page font. |
| `--dcui-regular-font-size` | `14px` | Text in buttons, fields, checkboxes and tables. |
| `--dcui-body-color` | `#5f6368` | Body text. |
| `--dcui-primary-color` | `#0097ff` | Buttons, outlined buttons, active and focused states. |
| `--dcui-secondary-color` | `#0670b9` | Button hover, the active tab's underline, the loading dots. |
| `--dcui-line-color` | `#c8c8c8` | Borders of fields, icon fields and dropdown panels. |
| `--dcui-grid-gutter` | `15px` | Column padding in `dcui-row` and `dcui-col-*`. |
| `--dcui-field-radius` | `5px` | Corner radius of fields, buttons and `dc-content-card`. |
| `--dcui-field-height` | `35px` | Height of fields and buttons. `dcui-large` adds 5px. |
| `--dcui-photo-bubble-size` | `35px` | The size of `DcBubbleAvatar`'s round photo. |
| `--dcui-success-color` | `#65d353` | `dcui-text-success`, a field in its success state, success notices. |
| `--dcui-danger-color` | `#cf4747` | `dcui-text-danger`, a field in its error state, error notices. |
| `--dcui-warning-color` | `#ffa434` | `dcui-text-warning`. |

`dc-style.css` adds a few `--dc-*` variables for the framework shell, such as `--dc-headings-color` (`#202124`), `--dc-regular-panel-radius` (`10px`) and `--dc-app-container-padding` (`20px`).

## Component variables

- **Date pickers.** `base_components.css` sets about 55 `--dcui-calendar-*` variables on `:root` (colours, sizes and weights of the calendar's days, months, years and input). `DcDatepicker`, `DcDateRangePicker` and `DcCalendarRangePicker` use them.
- **Dashboard.** `--dcui-dashboard-greeting-color`, `--dcui-dashboard-heading-color`, `--dcui-dashboard-avatar-border`, `--dcui-dashboard-tile-1` to `-3` and `--dcui-dashboard-backdrop` have no `:root` value: each rule uses a `var()` fallback. They are the framework's supported way to brand the dashboard. See [Dashboard Widgets](../Building%20Apps/Dashboard%20Widgets.md#theming-variables).

## How they apply

Use the variables in your own CSS with `var()`, so your few custom rules match the kit:

```css
/* apps/myapp/assets/styles.css, listed in resources.styles of app-config.json */
.myapp-order-summary {
    border-top: 1px solid var(--dcui-line-color);
    color: var(--dcui-body-color);
}
```

Every app's stylesheet goes into the one shared `assets/app-styles.css`, so CSS in your app applies to every page of the system. A `:root` value that you set for a core variable changes every app, not only yours. Values for the `--dcui-calendar-*` variables on `:root` usually don't take effect at all: apps' stylesheets are joined in folder order, so most come before `xp_system`'s, whose `:root` values then win.

The `dark-mode` and `light-mode` classes that `XP.addDarkLightTheme()` puts on `body` restyle the framework shell (top bar, sidebar, sign-in screens). The `dcui-*` styles have no dark-mode variants. See [Frontend Runtime (XP)](../Frontend%20Runtime%20(XP).md).

---

# How to use the kit in admin pages

The admin panel at `/api/admin/` has its own copy of the kit, in `api/admin/apps/xp_system/components/dc_ui_kit_componenets/`. Admin pages import from that copy's registry. From `api/admin/apps/myapp/components/`, the relative path is the same as in the main app, and it resolves to the admin copy:

```jsx
import { DcTable, DcPopup } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Don't import the main app's kit into admin pages.

The admin registry exports 48 of the 68 components. It doesn't export these 20:

`DcActivityFeed`, `DcAjaxLoader`, `DcAjaxNotice`, `DcAppTiles`, `DcCalendarRangePicker`, `DcCollapsibleSidePanel`, `DcCommentFeed`, `DcDashboardWidget`, `DcDateRangePicker`, `DcEmptyState`, `DcPageHeader`, `DcPagination`, `DcPointList`, `DcQuickLinks`, `DcRadioGroup`, `DcSearchDropdown`, `DcSplitButton`, `DcStatGroup`, `DcToggleSwitch` and `DcTreeNavigation`.

The two copies are maintained separately. A component with the same name can lack props or events in the admin copy, and each component's entry on its category page notes this. The admin panel's `dc-ui-kit.css` is also older and has fewer utility classes. It has the grid, the scrolling and display classes, `dcui-full-width`, `dcui-full-height`, the `dcui-m-t-*`, `dcui-m-b-*`, `dcui-m-l-*` and `dcui-m-r-*` margins, `dcui-flex-item`, `dcui-flex-1`, the `dcui-align-*` and `dcui-justify-*` classes and the `dcui-text-*` classes. It has no padding classes, no `dcui-w-*` or `dcui-h-*`, no gap classes, no `dcui-flex-directions-*`, `dcui-flex-wrap*`, `dcui-flex-grow` or `dcui-flex-shrink`, and no `dcui-m-0`, `dcui-m-lr-*` or `dcui-m-tb-*`.

See [Admin Pages](../Building%20Apps/Admin%20Pages.md) for building admin pages.

---

# Components

The components are documented on one page per category. Every entry has an example, its props, events, slots and methods, and a note when the admin panel's copy differs.

## Component index

| Component | Page | Use it for |
| --- | --- | --- |
| [DcButton](./Buttons%20And%20Links.md#dcbutton) | Buttons And Links | The standard button, including submit buttons |
| [DcIconButton](./Buttons%20And%20Links.md#dciconbutton) | Buttons And Links | A square button with an icon or image, and a loading spinner |
| [DcSplitButton](./Buttons%20And%20Links.md#dcsplitbutton) | Buttons And Links | A main action with a caret menu of alternatives |
| [DcLink](./Buttons%20And%20Links.md#dclink) | Buttons And Links | A styled text link |
| [DcBoxIcon](./Buttons%20And%20Links.md#dcboxicon) | Buttons And Links | A Font Awesome icon in a square box |
| [DcInputField](./Form%20Fields.md#dcinputfield) | Form Fields | A single-line text input with a label and an optional icon |
| [DcTextField](./Form%20Fields.md#dctextfield) | Form Fields | A multi-line text area |
| [DcPasswordField](./Form%20Fields.md#dcpasswordfield) | Form Fields | A password input with a show/hide toggle |
| [DcPasswordGenerator](./Form%20Fields.md#dcpasswordgenerator) | Form Fields | A text input with a button that generates a random password |
| [DcSearchField](./Form%20Fields.md#dcsearchfield) | Form Fields | A search box that emits the text as the user types |
| [DcFormGroup](./Form%20Fields.md#dcformgroup) | Form Fields | Grouping a label with its fields |
| [DcCheckbox](./Form%20Fields.md#dccheckbox) | Form Fields | A single checkbox |
| [DcCheckboxGroup](./Form%20Fields.md#dccheckboxgroup) | Form Fields | Checkboxes side by side |
| [DcRadioGroup](./Form%20Fields.md#dcradiogroup) | Form Fields | One choice from a list of radio buttons |
| [DcToggleSwitch](./Form%20Fields.md#dctoggleswitch) | Form Fields | An on/off switch bound to a boolean |
| [DcTagInput](./Form%20Fields.md#dctaginput) | Form Fields | Free-text tags, added with Enter |
| [DcSelect](./Selects%20And%20Pickers.md#dcselect) | Selects And Pickers | A native select built from an array of options |
| [DcDropdown](./Selects%20And%20Pickers.md#dcdropdown) | Selects And Pickers | A custom dropdown with slots for the label and the options |
| [DcAutoComplete](./Selects%20And%20Pickers.md#dcautocomplete) | Selects And Pickers | A text input that suggests matching options |
| [DcSearchDropdown](./Selects%20And%20Pickers.md#dcsearchdropdown) | Selects And Pickers | A searchable dropdown that can load options page by page |
| [DcTagDropdown](./Selects%20And%20Pickers.md#dctagdropdown) | Selects And Pickers | Picking several options, shown as tags |
| [DcDatepicker](./Selects%20And%20Pickers.md#dcdatepicker) | Selects And Pickers | A date picked from the kit's calendar |
| [DcNativeDatePicker](./Selects%20And%20Pickers.md#dcnativedatepicker) | Selects And Pickers | The browser's own date input |
| [DcDateRangePicker](./Selects%20And%20Pickers.md#dcdaterangepicker) | Selects And Pickers | A From/To pair of date pickers bound as one value |
| [DcCalendarRangePicker](./Selects%20And%20Pickers.md#dccalendarrangepicker) | Selects And Pickers | A From/To range picked on one calendar popover |
| [DcFontAwesomeIconPicker](./Selects%20And%20Pickers.md#dcfontawesomeiconpicker) | Selects And Pickers | Searching for and picking a Font Awesome icon |
| [DcTable](./Data%20Display.md#dctable) | Data Display | Rows of records, with sorting and row selection |
| [DcPagination](./Data%20Display.md#dcpagination) | Data Display | Page numbers under a table |
| [DcLoadMore](./Data%20Display.md#dcloadmore) | Data Display | Loading more items as a list or feed is scrolled |
| [DcCard](./Data%20Display.md#dccard) | Data Display | A white content box |
| [DcCardPlain](./Data%20Display.md#dccardplain) | Data Display | A card with a top bar (left and right) and a body |
| [DcInfoPanel](./Data%20Display.md#dcinfopanel) | Data Display | A card with a top section and a two-column body |
| [DcPointList](./Data%20Display.md#dcpointlist) | Data Display | A vertical list with a dot per item |
| [DcBubbleAvatar](./Data%20Display.md#dcbubbleavatar) | Data Display | A round profile photo |
| [DcEmptyState](./Data%20Display.md#dcemptystate) | Data Display | The "nothing here" message for a table, list or picker |
| [DcActivityFeed](./Data%20Display.md#dcactivityfeed) | Data Display | A record's history, newest first, with paging |
| [DcCommentFeed](./Data%20Display.md#dccommentfeed) | Data Display | A record's comment thread, with the box to write one |
| [DcTabs](./Navigation%20And%20Layout.md#dctabs) | Navigation And Layout | Tabs that switch between panels |
| [DcCategoryTabs](./Navigation%20And%20Layout.md#dccategorytabs) | Navigation And Layout | A tab strip with optional icons and an actions area |
| [DcNavigationDrawer](./Navigation%20And%20Layout.md#dcnavigationdrawer) | Navigation And Layout | A sidebar list of links |
| [DcBreadcrumbs](./Navigation%20And%20Layout.md#dcbreadcrumbs) | Navigation And Layout | A trail of router links |
| [DcTreeNavigation](./Navigation%20And%20Layout.md#dctreenavigation) | Navigation And Layout | A tree of nodes that can expand, with optional lazy loading |
| [DcPageHeader](./Navigation%20And%20Layout.md#dcpageheader) | Navigation And Layout | The banner at the top of a section, with a title, description, icon and actions |
| [DcCollapsibleSidePanel](./Navigation%20And%20Layout.md#dccollapsiblesidepanel) | Navigation And Layout | A side panel that folds down to a thin rail |
| [DcBlueHeaderBar](./Navigation%20And%20Layout.md#dcblueheaderbar) | Navigation And Layout | A light blue bar with left and right slots |
| [DcCardBlueContainer](./Navigation%20And%20Layout.md#dccardbluecontainer) | Navigation And Layout | The same light blue bar as `DcBlueHeaderBar` |
| [DcPopup](./Feedback%20And%20Overlays.md#dcpopup) | Feedback And Overlays | A modal dialog, such as a delete confirmation |
| [DcLoaderBar](./Feedback%20And%20Overlays.md#dcloaderbar) | Feedback And Overlays | A thin animated bar while something loads |
| [DcProgressBar](./Feedback%20And%20Overlays.md#dcprogressbar) | Feedback And Overlays | Progress as steps done or a percentage |
| [DcAjaxLoader](./Feedback%20And%20Overlays.md#dcajaxloader) | Feedback And Overlays | Animated dots while a request runs |
| [DcAjaxNotice](./Feedback%20And%20Overlays.md#dcajaxnotice) | Feedback And Overlays | A short success or error message after a request |
| [DcImageUploader](./Media.md#dcimageuploader) | Media | Drag-and-drop upload of several files, with previews |
| [DcImageUploaderMini](./Media.md#dcimageuploadermini) | Media | A compact uploader with thumbnails |
| [DcMediaViewer](./Media.md#dcmediaviewer) | Media | Attachment thumbnails that open in a lightbox |
| [DcDashboardWidget](./Dashboard%20Components.md#dcdashboardwidget) | Dashboard Components | The card a dashboard widget sits in, with a loader |
| [DcAppTiles](./Dashboard%20Components.md#dcapptiles) | Dashboard Components | A grid of app tiles with icons |
| [DcQuickLinks](./Dashboard%20Components.md#dcquicklinks) | Dashboard Components | A row of links, each an icon and a label |
| [DcStatGroup](./Dashboard%20Components.md#dcstatgroup) | Dashboard Components | Large numbers with labels, side by side |
| [DcConfLogo](./Framework%20Screens.md#dcconflogo) | Framework Screens | The DoCloud Framework logo on setup screens |
| [DcConfDevLogo](./Framework%20Screens.md#dcconfdevlogo) | Framework Screens | The DoCloud Developer logo |
| [DcConfFooter](./Framework%20Screens.md#dcconffooter) | Framework Screens | The copyright footer with a privacy policy link |
| [DcConfCard](./Framework%20Screens.md#dcconfcard) | Framework Screens | The body panel of a setup screen |
| [DcConfTimeline](./Framework%20Screens.md#dcconftimeline) | Framework Screens | A step indicator for a multi-step setup |
| [DcConfCheckList](./Framework%20Screens.md#dcconfchecklist) | Framework Screens | A list of checklist items |
| [DcConfCheckListItem](./Framework%20Screens.md#dcconfchecklistitem) | Framework Screens | One checklist row, with a status indicator |
| [DcConfNeedSupport](./Framework%20Screens.md#dcconfneedsupport) | Framework Screens | The "Need Support? Contact us" line |
| [DcDoCloudLogo](./Framework%20Screens.md#dcdocloudlogo) | Framework Screens | The DoCloud logo on its own |
| [DcAuthFooter](./Framework%20Screens.md#dcauthfooter) | Framework Screens | The "Powered by DoCloud" footer line |

---

## Buttons And Links

The kit's actions: the standard `DcButton`, the square `DcIconButton`, `DcSplitButton` for a main action with a menu of alternatives, `DcLink` for a styled text link and `DcBoxIcon` for a Font Awesome icon in a square box. See [Buttons And Links](./Buttons%20And%20Links.md).

## Form Fields

The inputs a form is built from: single-line and multi-line text, password fields with show/hide and a generator, a search box, checkboxes, radio groups, a toggle switch and free-text tags. `DcFormGroup` and `DcCheckboxGroup` lay fields out. See [Form Fields](./Form%20Fields.md).

## Selects And Pickers

Fields where the user picks rather than types: a native select, a custom dropdown with slots, autocomplete, a searchable dropdown that can load pages from the server, a multi-select shown as tags, single dates, date ranges and a Font Awesome icon picker. See [Selects And Pickers](./Selects%20And%20Pickers.md).

## Data Display

Components that show records: `DcTable` with sorting and row selection, `DcPagination` and `DcLoadMore` for paging, cards and info panels, a point list, round avatars, the empty state, and a record's activity and comment feeds. See [Data Display](./Data%20Display.md).

## Navigation And Layout

Components that move the user around an app and frame its pages: tabs, category tabs, a navigation drawer, breadcrumbs, a lazy-loading tree, a page header, a collapsible side panel and light blue header bars. See [Navigation And Layout](./Navigation%20And%20Layout.md).

## Feedback And Overlays

Components that tell the user what is happening: `DcPopup` for dialogs and delete confirmations, a loading bar, a progress bar, the loading dots shown while a request runs and the notice shown after it. See [Feedback And Overlays](./Feedback%20And%20Overlays.md).

## Media

File upload and display: `DcImageUploader` for drag-and-drop upload of several files with previews, the compact `DcImageUploaderMini`, and `DcMediaViewer` for attachment thumbnails that open in a lightbox. See [Media](./Media.md).

## Dashboard Components

The pieces the framework dashboard is built from: the widget card, app tiles, quick links and a group of statistics. Use them in your own dashboard widgets (see [Dashboard Widgets](../Building%20Apps/Dashboard%20Widgets.md)). See [Dashboard Components](./Dashboard%20Components.md).

## Framework Screens

The branded pieces of the framework's own setup and sign-in screens: DoCloud logos, footers, a setup card, a step timeline, a checklist and the support line. Use them when your app adds a screen of the same kind. See [Framework Screens](./Framework%20Screens.md).
