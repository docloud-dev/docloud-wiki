---
title: Dashboard Components
sidebar_label: Dashboard Components
---

# Dashboard Components

# Introduction

These components are the building blocks of dashboard widgets. The framework's own home dashboard is made from them, and your app's widgets should be too, so they match the default ones. They only display what you pass in. Each widget fetches its own data.

| Component | Use it for |
| --- | --- |
| `DcDashboardWidget` | The card a widget sits in, with a title and a loading overlay |
| `DcAppTiles` | A grid of coloured icon tiles that link to pages |
| `DcQuickLinks` | A row of text links with icons |
| `DcStatGroup` | A row of large numbers, each with a label |

This page is the component reference. To put a widget on the home dashboard, you declare it in your app's `app-config.json`. That is covered in [Dashboard Widgets](../Building%20Apps/Dashboard%20Widgets.md), together with the `--dcui-dashboard-*` variables that set these components' colours (see [Theming variables](../Building%20Apps/Dashboard%20Widgets.md#theming-variables)). The components' styles are global, so you can also use them on your own pages.

Every example imports from the kit's registry. The path below is from a component in `apps/myapp/components/`. A dashboard widget usually sits one folder deeper, in `apps/myapp/components/dashboard/`, so its import starts with `../../../`:

```jsx
import { DcDashboardWidget } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Register each imported component in the `components` option before you use its tag. See [Vue DC UI KIT](./Vue%20DC%20UI%20KIT.md) for the setup.

---

## DcDashboardWidget

The card a dashboard widget sits in: an optional heading and a body. While `loading` is true, a loader covers the body.

```jsx
import { DcDashboardWidget } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcDashboardWidget },
    data() {
        return { loading: false };
    },
    template: `
    <dc-dashboard-widget title="Orders" :loading="loading">
        <p>12 orders are waiting to ship.</p>
    </dc-dashboard-widget>
    `,
};
```

The card is a `<section>` that takes the full width of its column. The title is an `<h2>` and also becomes the section's `aria-label`. While `loading` is true the section has `aria-busy="true"`. The loader has a transparent background, so whatever is already in the body stays visible under it. The body is at least 70px tall, so the loader has room even before there is content.

`transparent` removes the card's background, border, shadow and padding. The title and the loader stay. In a dashboard widget, bind it to the widget's options, `:transparent="widget.options.transparent === true"`, so an install can drop the card without changing your code. The built-in "Available Apps" widget is declared that way.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | String | `""` | The heading. With an empty title, no heading is rendered and the section has no `aria-label`. |
| `loading` | Boolean | `false` | Shows the loader over the body. |
| `transparent` | Boolean | `false` | Drops the card's background, border, shadow and padding. |

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| default | The widget's content. |

The admin-panel registry doesn't export `DcDashboardWidget`.

---

## DcAppTiles

A wrapping grid of tiles. Each tile is a coloured rounded square with an icon in it and a label underneath, and links to a route. The dashboard's "Available Apps" widget uses it to list the apps' pages.

```jsx
import { DcAppTiles } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcAppTiles },
    data() {
        return {
            tiles: [
                { label: "Orders", to: { name: "myapp_orders" }, svg_icon: "/apps/myapp/assets/icons/orders.svg" },
                { label: "Customers", to: { name: "myapp_customers" }, icon: "fal fa-users" },
                { label: "Reports", to: { name: "myapp_reports" }, icon: "fal fa-chart-bar" },
            ],
        };
    },
    template: `<dc-app-tiles :items="tiles" />`,
};
```

How the tiles look:

- **Colours.** The tiles cycle through three colours by position: the 1st, 4th, 7th tile use `--dcui-dashboard-tile-1`, the 2nd, 5th, 8th use `-tile-2`, and the 3rd, 6th, 9th use `-tile-3`.
- **Icons.** `svg_icon` takes precedence over `icon`. The SVG is drawn in solid white whatever its own colours are, so use a one-colour icon whose shape reads on its own. A Font Awesome `icon` is white too. A tile with neither shows an empty coloured square.
- **Labels.** Each tile is 70px wide and its label stays on one line. A longer label is cut off with an ellipsis. The full label shows on hover, because it's also the link's `title`. Keep labels to one or two short words.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | Array | `[]` | One object per tile: `label` (the text under the tile), `to` (any `router-link` target), and optionally `svg_icon` (an SVG image URL) or `icon` (Font Awesome classes, such as `fal fa-users`). |

**Events**

None. Each tile is a `router-link`, so clicking it navigates.

<aside>
⚠️ Every item needs a `to` that the router can resolve. An item without `to`, or one whose `to` names a route that isn't registered (for example a page of a disabled app), makes the component throw while it renders. On the home dashboard, that removes the whole widget. Build the list only from routes you know exist, and leave out the ones the user can't open.

</aside>

The admin-panel registry doesn't export `DcAppTiles`.

---

## DcQuickLinks

A wrapping row of borderless links, each an optional icon and a semibold label. The dashboard's "Quick links" widget uses it to list the system pages, such as Settings.

```jsx
import { DcQuickLinks } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcQuickLinks },
    data() {
        return {
            links: [
                { label: "New order", to: { name: "myapp_new_order" }, icon: "fal fa-plus" },
                { label: "Settings", to: { name: "settings" }, icon: "fal fa-cog" },
            ],
        };
    },
    template: `<dc-quick-links :items="links" />`,
};
```

The links sit side by side and wrap onto more lines when they don't fit. Labels are never cut off. A link is highlighted with a light grey background on hover and on keyboard focus.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | Array | `[]` | One object per link: `label` (the link text), `to` (any `router-link` target), and optionally `icon` (Font Awesome classes). |

**Events**

None. Each link is a `router-link`, so clicking it navigates.

<aside>
⚠️ As with `DcAppTiles`, an item without `to`, or with a `to` that names a route that isn't registered, makes the component throw while it renders.

</aside>

The admin-panel registry doesn't export `DcQuickLinks`.

---

## DcStatGroup

A row of figures, each a large number over a label. Use it for a few headline counts, such as open and overdue orders.

```jsx
import { DcStatGroup } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcStatGroup },
    data() {
        return {
            stats: [
                { label: "Open", value: 12 },
                { label: "Overdue", value: 0 },
                { label: "Revenue", value: (48250).toLocaleString() },
                { label: "Returns", value: null },
            ],
        };
    },
    template: `<dc-stat-group :items="stats" />`,
};
```

A value that is `null`, `undefined` or an empty string shows as an em dash (`—`). `0` shows as `0`. So you can render the group before your data arrives, with the values still empty, and fill them in later.

Values are shown exactly as you pass them. Format them yourself, for example with `toLocaleString()` or a currency symbol.

The figures share the row in equal columns, each at least 90px wide. When the row is too narrow for all of them, they wrap onto a second row. The numbers use `--dcui-dashboard-heading-color`.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | Array | `[]` | One object per figure: `label` (the text under the number) and `value` (a number or a string). |

**Events**

None.

The admin-panel registry doesn't export `DcStatGroup`.

---

## A dashboard widget built from these components

This widget shows three order counts and two links for `myapp`. It lives at `apps/myapp/components/dashboard/OrdersWidget.js`, so the imports go three folders up. `myapp_services` stands for your app's `services.js` (see [Frontend Runtime (XP)](../Frontend%20Runtime%20%28XP%29.md)).

```jsx
import { DcDashboardWidget, DcStatGroup, DcQuickLinks, DcEmptyState } from "../../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../../services.js";

export default {
    components: { DcDashboardWidget, DcStatGroup, DcQuickLinks, DcEmptyState },
    props: {
        widget: { type: Object, required: true },
    },
    data() {
        return { loading: true, failed: false, stats: {} };
    },
    computed: {
        figures() {
            return [
                { label: "Open", value: this.stats.open },
                { label: "Overdue", value: this.stats.overdue },
                { label: "Shipped today", value: this.stats.shipped_today },
            ];
        },
        links() {
            return [
                { label: "New order", to: { name: "myapp_new_order" }, icon: "fal fa-plus",
                  permission: { name: "myapp", action: "create_order" } },
                { label: "All orders", to: { name: "myapp_orders" }, icon: "fal fa-list",
                  permission: { name: "myapp", action: "list_orders" } },
            ].filter((link) => XP.checkPermission(link.permission));
        },
    },
    async created() {
        try {
            const res = await myapp_services.get_dashboard_stats();
            if (res.response.success) {
                this.stats = res.data;
            } else {
                this.failed = true;
            }
        } catch (error) {
            this.failed = true;
        } finally {
            this.loading = false;
        }
    },
    template: `
    <dc-dashboard-widget title="Orders" :loading="loading" :transparent="widget.options.transparent === true">
        <dc-empty-state v-if="failed">The order counts could not be loaded.</dc-empty-state>
        <dc-stat-group v-else :items="figures" />
        <dc-quick-links v-if="links.length" class="dcui-m-t-15" :items="links" />
    </dc-dashboard-widget>
    `,
};
```

- The dashboard passes the widget one prop, `widget`. Its `options` come from the widget's entry in `app-config.json`.
- While the request runs, the figures show em dashes under the loader.
- The `catch` keeps a failed request inside the widget. Without it, the dashboard removes the widget from the page.
- The links are filtered with `XP.checkPermission()`, so users only see links to pages they have the permission for. `DcQuickLinks` itself shows every item you pass.

To make it appear on the dashboard, declare it in your app's `app-config.json` and add `"dashboard"` to the app's `_public` list. The steps, the regions and the widget fields are in [Dashboard Widgets](../Building%20Apps/Dashboard%20Widgets.md#widget-fields).
