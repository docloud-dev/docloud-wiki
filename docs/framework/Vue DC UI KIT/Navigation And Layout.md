---
title: Navigation And Layout
sidebar_label: Navigation And Layout
---

# Navigation And Layout

# Introduction

These components move the user around an app and frame its pages:

- `DcTabs`: tabs that switch between panels.
- `DcCategoryTabs`: a tab strip with optional icons and an actions area.
- `DcNavigationDrawer`: a sidebar list of links.
- `DcBreadcrumbs`: a trail of router links.
- `DcTreeNavigation`: a tree of nodes that can expand, with optional lazy loading.
- `DcPageHeader`: the banner at the top of a section, with a title, description, icon and actions.
- `DcCollapsibleSidePanel`: a side panel that folds down to a thin rail.
- `DcBlueHeaderBar` and `DcCardBlueContainer`: a light blue bar with left and right slots.

Import them from the kit registry. The examples assume a component in `apps/myapp/components/`.

---

## DcTabs

`DcTabs` shows a row of tabs and one panel per tab. Each panel is a named slot whose name is the tab's `key`.

```jsx
import { DcTabs } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcTabs },
    data() {
        return {
            tab: "details",
            tabs: [
                { name: "Details", key: "details" },
                { name: "History", key: "history" },
            ],
        };
    },
    template: `
<dc-tabs :tabs="tabs" v-model="tab" @tab_changed="onTabChanged">
    <template #details>Order details</template>
    <template #history>Order history</template>
</dc-tabs>`,
    methods: {
        onTabChanged(tab) {
            // tab is the clicked object, e.g. { name: "History", key: "history" }
        },
    },
};
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `tabs` | Array | `[]` | One object per tab: `name` (the label) and `key` (the slot name). |
| `modelValue` | Number, String | `undefined` | The active tab, matched against each tab's `model_key` field. Use `v-model`. |
| `model_key` | String | `"name"` | The tab field that `v-model` reads and writes. |

**Events**

| Event | Payload | When |
| --- | --- | --- |
| `update:modelValue` | The clicked tab's `model_key` value, lowercased when it is a string | A tab is clicked. |
| `tab_changed` | The clicked tab object | A tab is clicked. |

**Slots**

| Slot | Content |
| --- | --- |
| one per tab, named by its `key` | That tab's panel. |

<aside>
⚠️ `v-model` uses the tab's `name` unless you set `model_key`. With the default, clicking "History" sets the model to `"history"`, not to the tab's `key`. Set `model_key="key"` to work with keys. Matching is case-insensitive and only works for string values: a number in `v-model` never selects a tab.

</aside>

All panels are rendered at once and the inactive ones are hidden with CSS, so every panel's components mount when the tabs do.

---

## DcCategoryTabs

`DcCategoryTabs` is a tab strip for switching between categories. Each tab can show an image icon, and an `actions` slot sits at the right end of the strip. The panel content goes in the `holder` slot, which receives the active tab's index.

```jsx
import { DcCategoryTabs } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcCategoryTabs },
    data() {
        return {
            category: "overview",
            tabs: [{ label: "Overview" }, { label: "Properties" }],
        };
    },
    template: `
<dc-category-tabs :tabs="tabs" v-model="category">
    <template #holder="{ active_tab }">
        <div v-if="active_tab === 0">Overview panel</div>
        <div v-else>Properties panel</div>
    </template>
</dc-category-tabs>`,
};
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `tabs` | Array | `null` | One object per tab: `label`, and optionally `icon`, an image URL shown 20px wide. |
| `modelValue` | Number, String | none | The active tab, matched case-insensitively against each tab's `model_key` field. Use `v-model`. |
| `model_key` | String | `"label"` | The tab field that `v-model` reads and writes. Use a lowercase field name. |

**Events**

| Event | Payload | When |
| --- | --- | --- |
| `update:modelValue` | The clicked tab's `model_key` value, lowercased | A tab is clicked. |
| `tab_changed` | The clicked tab object | A tab is clicked. |

**Slots**

| Slot | Scope | Content |
| --- | --- | --- |
| `holder` | `active_tab`: the active tab's index | The panel content. |
| `actions` | none | Controls at the right end of the tab strip. |

<aside>
⚠️ Leave `v-model` undefined rather than `null` until you have a value: a `null` model throws when the component mounts. The component renders two root elements, so a `class` set on `dc-category-tabs` is not applied.

</aside>

---

## DcNavigationDrawer

`DcNavigationDrawer` is a card with a title and a scrollable list of links, for an app's sidebar. Bind `v-model` to the selected item's key so the selection follows the route.

```jsx
import { DcNavigationDrawer } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcNavigationDrawer },
    data() {
        return {
            items: [
                { key: "orders", title: "Orders", icon: "fa-receipt" },
                { key: "customers", title: "Customers", icon: "fa-users" },
                { heading: true, title: "Settings" },
                { key: "general", title: "General", icon: "fa-gear" },
            ],
        };
    },
    computed: {
        selected() {
            return this.$route.name;
        },
    },
    template: `
<dc-navigation-drawer :items="items" :model-value="selected" label="Orders navigation" compact
    @change_navigation="(item) => $router.push({ name: item.key })">
    <template #navigator_title>Orders</template>
</dc-navigation-drawer>`,
};
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | Array | `null` | One object per row: `title`, `icon` (a Font Awesome icon name such as `fa-inbox`; the `fa-solid` style is added for you) and the key field named by `itemKey`. A row with `heading: true` is a group label, not a link. |
| `modelValue` | String, Number | `undefined` | The selected item's key. Use `v-model`. While it is undefined, the drawer highlights the row last clicked instead. |
| `itemKey` | String | `"key"` | The item field that `v-model` reads and writes. |
| `compact` | Boolean | `false` | A denser layout with tighter rows and a tinted selected row. |
| `label` | String | `"Navigation"` | The `aria-label` of the list. |
| `scrollContainerId` | String | `dc-navigation-<n>` | The id of the scrolling element. Each drawer gets its own, so two drawers can share a page. |
| `loading` | Boolean | `false` | Shows a loader over the list. |
| `navigation_item_class` | String, Function | `null` | Extra classes for each row. A function is called with `(item, index)` and returns the classes. |
| `selected_navigation_item` | String | `null` | The index of the row to highlight when `v-model` isn't used. See the note below. |
| `hide_icons` | Boolean | `false` | Hides the row icons. |
| `show_bullets` | Boolean | `false` | Adds the `show-bullets` class to the list. |
| `show_line` | Boolean | `false` | Adds the `show-line` class to the list. |
| `nav_container_class` | String | `""` | Extra classes for the scrolling element. |

**Events**

| Event | Payload | When |
| --- | --- | --- |
| `update:modelValue` | The item's `itemKey` value | A row is clicked, or chosen with Enter or Space. |
| `change_navigation` | `(item, index)` | Same as above. |
| `scrolled_to` | `"Bottom"` | The list is scrolled to the bottom. |

**Slots**

| Slot | Scope | Content |
| --- | --- | --- |
| `navigator_title` | none | The drawer's title. |
| `navigator_button` | none | A control to the right of the title. |
| `navigation-title` | `item`, `index` | Replaces a row's title text. |
| `custom-navigation-items` | `item`, `index` | Extra content under a row's title. |
| `custom-nav-container-slot` | none | Content under the list, inside the scrolling area, such as a `DcTreeNavigation`. |

<aside>
⚠️ `selected_navigation_item` is declared as a String, but a row is highlighted only when the value is a number. A string never highlights anything, and a number logs a prop type warning. Use `v-model` instead.

</aside>

The admin panel has an older copy of this component. It has no `v-model`, `itemKey`, `compact`, `label`, `scrollContainerId`, `show_bullets`, `show_line` or heading rows, and doesn't emit `scrolled_to`.

---

## DcBreadcrumbs

`DcBreadcrumbs` renders a trail of `router-link`s with a chevron between them.

```jsx
import { DcBreadcrumbs } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcBreadcrumbs },
    data() {
        return {
            crumbs: [
                { text: "Orders", link: { name: "myapp_orders" } },
                { text: "ORD-1042", link: { name: "myapp_order", params: { id: 1042 } } },
            ],
        };
    },
    template: `<dc-breadcrumbs :items="crumbs" />`,
};
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | Array | required | One object per crumb: `text` and `link`, any `router-link` target. An item without `text` renders as an empty entry. |

It has no events or slots.

---

## DcTreeNavigation

`DcTreeNavigation` shows nested nodes that expand and collapse. It can load a node's children on demand. Arrow keys move between rows, Right and Left expand and collapse, Home and End jump to the ends, and Enter or Space selects.

```jsx
import { DcTreeNavigation } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcTreeNavigation },
    data() {
        return {
            selected: null,
            expanded: ["projects"],
            nodes: [
                { id: "projects", label: "Projects", icon: "fa-regular fa-folder-open", children: [
                    { id: "design", label: "Design", icon: "fa-regular fa-folder" },
                    { id: "archive", label: "Archive", icon: "fa-regular fa-folder", hasChildren: true },
                ] },
            ],
        };
    },
    methods: {
        async loadChildren(node) {
            // Call your app's service and return an array of nodes. Throw to show the error and Retry.
            return [];
        },
    },
    template: `
<dc-tree-navigation v-model="selected" v-model:expanded-keys="expanded"
    :nodes="nodes" :load-children="loadChildren" label="Project folders" />`,
};
```

A node is `{ id, label, icon?, disabled?, children?, hasChildren? }`. IDs must be unique across the tree. A node with `hasChildren: true` and no `children` calls `loadChildren(node)` the first time it is expanded. The result is cached. To discard the cached children, for example when you switch to another dataset, give the component a new `key`.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `nodes` | Array | `[]` | The root nodes. |
| `modelValue` | String, Number | `null` | The selected node's `id`. Use `v-model`. |
| `expandedKeys` | Array | `null` | The `id`s of the expanded nodes. Use `v-model:expanded-keys`. When it is `null`, the tree keeps its own state. |
| `loadChildren` | Function | `null` | Called with a node. Returns an array of child nodes, or a Promise of one. |
| `label` | String | `"Navigation tree"` | The tree's `aria-label`. |
| `loading` | Boolean | `false` | Shows `loadingText` under the root nodes. |
| `emptyText` | String | `"No items."` | Shown when there are no root nodes, or a node has no children. |
| `loadingText` | String | `"Loading..."` | Shown while nodes load. |
| `errorText` | String | `"Could not load items."` | Shown when `loadChildren` fails. |
| `retryText` | String | `"Retry"` | The label of the retry button. |

**Events**

| Event | Payload | When |
| --- | --- | --- |
| `update:modelValue` | The node's `id` | A node is selected. |
| `update:expandedKeys` | The new array of expanded `id`s | A node expands or collapses. |
| `select` | The node | A node is selected. |
| `toggle` | `{ node, expanded }` | A node expands or collapses. |
| `load-error` | `{ node, error }` | `loadChildren` throws, rejects or doesn't return an array. |

**Slots**

| Slot | Scope | Content |
| --- | --- | --- |
| `label` | `node`, `selected` | Replaces a node's label. |
| `actions` | `node` | Controls at the end of each row. Clicks on them don't select the row. |

---

## DcPageHeader

`DcPageHeader` is the banner at the top of a section: a title, a short description, an icon, and the page's actions at the top right.

```jsx
import { DcPageHeader, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcPageHeader, DcButton },
    template: `
<dc-page-header title="Orders" description="Orders placed in the last 30 days." icon="fa-regular fa-receipt">
    <template #actions>
        <dc-button @click="createOrder">Create Order</dc-button>
    </template>
</dc-page-header>`,
    methods: {
        createOrder() {
            // Open your create form.
        },
    },
};
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | String | required | The heading. |
| `description` | String | `""` | The line under the heading. |
| `icon` | String | `""` | Font Awesome classes for the icon, such as `fa-regular fa-receipt`. |

It has no events.

**Slots**

| Slot | Content |
| --- | --- |
| `actions` | Buttons at the top right. |
| `icon` | Replaces the icon. |
| `description` | Replaces the description text. |

---

## DcCollapsibleSidePanel

`DcCollapsibleSidePanel` wraps content beside the main column, such as an activity feed. A toggle folds it to a thin rail that shows the title.

```jsx
import { DcCollapsibleSidePanel } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcCollapsibleSidePanel },
    data() {
        return { collapsed: false };
    },
    template: `
<div class="dcui-flex-item">
    <div class="dcui-flex-1">Main content</div>
    <dc-collapsible-side-panel v-model:collapsed="collapsed" title="Activity" :expand-below="900">
        Panel content
    </dc-collapsible-side-panel>
</div>`,
};
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `collapsed` | Boolean | `false` | Whether the panel is folded. Use `v-model:collapsed`. |
| `side` | String | `"right"` | `right` or `left`. Sets which way the toggle's chevron points. |
| `title` | String | `""` | Shown on the folded rail, and used in the toggle's `aria-label`. |
| `expandBelow` | Number | `0` | At or below this viewport width in pixels, the panel is always open and the toggle is hidden. `0` turns this off. |

**Events**

| Event | Payload | When |
| --- | --- | --- |
| `update:collapsed` | The new folded state | The toggle or the rail is clicked. |

**Slots**

| Slot | Content |
| --- | --- |
| default | The panel content. |
| `collapsed-rail` | Replaces the title on the folded rail. |

<aside>
⚠️ The panel never changes `collapsed` itself. It only emits `update:collapsed`, so without `v-model:collapsed` the toggle does nothing. Pass `expand-below` bound (`:expand-below="900"`) so it arrives as a number.

</aside>

On a narrow screen, `expand-below` only changes what is shown. Your `collapsed` value is left alone, so the user's choice comes back when the screen widens.

The admin panel registry doesn't export `DcCollapsibleSidePanel`.

---

## DcBlueHeaderBar

`DcBlueHeaderBar` is a card with a light blue background and two slots, one on each side. Use it for a toolbar strip above a list.

```jsx
import { DcBlueHeaderBar, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcBlueHeaderBar, DcButton },
    template: `
<dc-blue-header-bar>
    <template #left><strong>12 orders</strong></template>
    <template #right><dc-button>Export</dc-button></template>
</dc-blue-header-bar>`,
};
```

It has no props or events.

**Slots**

| Slot | Content |
| --- | --- |
| `left` | Content on the left. |
| `right` | Content on the right. |

---

## DcCardBlueContainer

`DcCardBlueContainer` is identical to `DcBlueHeaderBar`: the same light blue card with `left` and `right` slots. Use either; there is no difference between them.

```jsx
import { DcCardBlueContainer } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcCardBlueContainer },
    template: `
<dc-card-blue-container>
    <template #left>Left content</template>
    <template #right>Right content</template>
</dc-card-blue-container>`,
};
```

It has no props or events.

**Slots**

| Slot | Content |
| --- | --- |
| `left` | Content on the left. |
| `right` | Content on the right. |
