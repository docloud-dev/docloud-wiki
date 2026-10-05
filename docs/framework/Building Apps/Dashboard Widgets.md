---
sidebar_position: 4
title: Dashboard Widgets
sidebar_label: Dashboard Widgets
---

# Dashboard Widgets

# Introduction

The SPA's home route is the framework dashboard. It shows a greeting and the widgets that the active apps declare. An app adds a widget by listing it in the `dashboard` block of its `app-config.json` and shipping a Vue component for it. The app doesn't need to change the dashboard page itself.

The dashboard route is set up in `apps/xp_system/route.js`:

- Its path is `/<dashboard_page_name>` (`/dashboard` by default), aliased to `/`. The route name is always `dashboard`.
- It needs a login and the `dashboard` / `view` permission, unless `xp-config.json` sets `"public_dashboard": "true"`.
- The page is `apps/xp_system/components/dashboard/dashboard.js`.

The greeting depends on the browser's local hour: "Good Morning" from 5:00, "Good Afternoon" from 12:00, "Good Evening" from 17:00, and "Hello" from 22:00 until 5:00. The user's first name is added when it is known, for example "Good Morning, Ada!".

This page covers the framework dashboard as of DoFramework 0.0.42. For the rest of `app-config.json`, see [App Frontend Config](./App%20Frontend%20Config.md). For the `XP` methods used here, see [Frontend Runtime (XP)](../Frontend%20Runtime%20%28XP%29.md).

---

# How to replace the dashboard

To use your own page instead of the framework dashboard, set these keys in the site's `xp-config.json`:

```json
"external_dashboard": "true",
"dashboard_url": "/apps/myapp/components/dashboard/MyDashboard.js"
```

`external_dashboard` is a string, and only the exact value `"true"` switches it on. `dashboard_url` is the URL of a component module. The route loads it with `XP.import()`. Both keys are already in the default `_public` list.

The replacement takes over the whole page. It gets no greeting and no widgets, and the `dashboard` blocks of all apps are ignored. The route path, the route name and the permission check stay the same.

---

# How the dashboard is laid out

Widgets go into three regions:

| Region | Where it renders |
| --- | --- |
| `aside` | The left column. |
| `main` | The right column. |
| `full` | Full width, under both columns. |

When `aside` and `main` both have widgets, they share one row on screens 1200px wide or more: `aside` takes 5/12 of the width and `main` takes 7/12. On narrower screens they stack, with `aside` first. When only one of them has widgets, that column spans the whole row. A region with no widgets renders nothing.

Widgets inside a region stack vertically with a 25px gap. The page content is at most 1100px wide.

<aside>
⚠️ The page's CSS removes the gap between the two stacked columns from 992px, but the columns only sit side by side from 1200px. On screens between 992px and 1199px wide, the first `main` widget sits directly under the last `aside` widget with no space between them.

</aside>

## Default widgets

The `xp_system` app declares three widgets:

| Key | Region | Priority | Shows |
| --- | --- | --- | --- |
| `xp_system.profile` | `aside` | 10 | The user's avatar and full name, without a card. |
| `xp_system.apps` | `aside` | 20 | "Available Apps": a tile for each sidebar menu of a `custom` app. Declared with `"options": {"transparent": true}`. |
| `xp_system.quick_links` | `main` | 10 | "Quick links": the sidebar menus of `system` apps, apart from the dashboard itself. |

The two menu widgets follow the sidebar's rules. They list menus with `position.sidebar` set and a `permission` the user holds, and skip menus without a permission. They sort by `position.sidebar_priority` (100 when it's missing). A widget with no menus to show renders nothing.

`app_type` decides which of the two widgets lists an app's menus. The server always sends an app's `app_type` to the browser, even if the app's `_public` list leaves it out. An app without an `app_type` counts as `custom`.

You can hide or move any default widget. See "How to hide and show widgets" below.

---

# How to add a widget

A widget has two parts: an entry in your app's `app-config.json` and a component module.

**1. Declare the widget** in a `dashboard` block in `apps/myapp/app-config.json`:

```json
"dashboard": {
    "widgets": [
        {
            "id": "order_stats",
            "component": "/apps/myapp/components/dashboard/OrderStatsWidget.js",
            "region": "main",
            "priority": 20,
            "permission": { "name": "myapp", "action": "get_dashboard_stats" },
            "options": { "days": 7 }
        }
    ]
}
```

The widget's key is `<app_name>.<id>`, here `myapp.order_stats`. The key is how other apps and the install hide or show it. The fields are listed in [Widget fields](#widget-fields).

**2. Make the block public.** Add `"dashboard"` to the app's `_public` list, next to `"app_name"`:

```json
"_public": [
    "version", "release_date", "app_name", "status", "description", "menus", "dashboard"
]
```

Only the keys in `_public` reach the browser. Without `"dashboard"` the browser never sees the widget, and nothing is logged. The dashboard also reads `app_name` from the public config to build the key. Without it, the key becomes `undefined.order_stats`. See [The `_public` list](../Essentials/Configuration%20Files.md#the-_public-list).

**3. Write the component** at the `component` URL. See the next section.

Apps are read in their folder-name order, and only **active** apps are sent to the browser. A disabled app's widgets don't render, and its `hide` list doesn't apply.

<aside>
⚠️ Don't put an apostrophe (`'`), a double quote inside a value, or a backslash anywhere in the `dashboard` block. The server writes the whole public config into the page inside `JSON.parse('…')` without escaping it. One apostrophe is a JavaScript syntax error, and one double quote inside a value makes `JSON.parse` throw. Either way every page of the site stops loading. A backslash either breaks the page the same way or silently changes the value. The same applies to every public key of every app and of `xp-config.json`. Keep user-facing text, such as titles, in the component.

</aside>

The older top-level `widgets` key that some apps, such as `helloworld`, still carry belongs to an earlier widget system. The dashboard doesn't read it.

---

# How to write a widget component

A widget is a Vue component in a JS module with a default export. The dashboard loads it with `XP.import(component)` and renders it with one prop, `widget`:

```jsx
{
    key: "myapp.order_stats",
    app_name: "myapp",
    id: "order_stats",
    component: "/apps/myapp/components/dashboard/OrderStatsWidget.js",
    region: "main",
    priority: 20,
    options: { days: 7 }
}
```

`options` is always an object, so `widget.options.someKey` is safe to read. `permission` isn't passed in.

Follow these rules:

- **Fetch your own data.** The dashboard passes nothing but `widget`. Call your app's API in `created()`.
- **Render inside `DcDashboardWidget`.** It gives the widget its card, title and loading overlay.
- **Pass the `transparent` convention through.** Bind `:transparent="widget.options.transparent === true"`, so an install or another app can drop the card with `"options": {"transparent": true}` without changing your code. The built-in widgets all do this.
- **Handle your own errors.** Catch request failures and show an empty state, so the widget stays on the page.
- **Import kit components from the registry,** `dc_ui_kit_registry.js`. Don't import a component's own file, and keep import paths bare, with no `?v=`.

## A complete widget

This widget shows three order counts for `myapp`. It lives at `apps/myapp/components/dashboard/OrderStatsWidget.js`, so the registry import goes three folders up, to `apps/`, and then into `xp_system/`:

```jsx
import { DcDashboardWidget, DcStatGroup } from "../../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcDashboardWidget, DcStatGroup },
    props: {
        widget: { type: Object, required: true },
    },
    data() {
        return {
            loading: true,
            failed: false,
            stats: {},
        };
    },
    computed: {
        items() {
            return [
                { label: "Open", value: this.stats.open },
                { label: "Overdue", value: this.stats.overdue },
                { label: `Closed in ${this.days} days`, value: this.stats.closed },
            ];
        },
        days() {
            return Number(this.widget.options.days) || 7;
        },
    },
    async created() {
        try {
            const query = new URLSearchParams({ days: this.days });
            const res = await fetch(XP.getApiUrl() + "/myapp/get_dashboard_stats?" + query, {
                method: "GET",
                credentials: "include",
            });
            const json = await res.json();

            if (json.response.success) {
                this.stats = json.data;
            } else {
                this.failed = true;
            }
        } catch (error) {
            console.error("[myapp] order stats failed to load", error);
            this.failed = true;
        } finally {
            this.loading = false;
        }
    },
    template: `
<dc-dashboard-widget title="Orders" :loading="loading" :transparent="widget.options.transparent === true">
    <p v-if="failed">The order counts could not be loaded.</p>
    <dc-stat-group v-else :items="items" />
</dc-dashboard-widget>`,
};
```

While the request runs, `DcStatGroup` shows an em dash for each missing value, under the loading overlay.

The endpoint is an ordinary GET action in `api/apps/myapp/myappController.class.php`. Route `get_dashboard_stats` to it in the controller's `GetHandler()`:

```php
private function get_dashboard_stats()
{
    $res = new Response();

    try {
        $params = $this->getRequest()->getData() ?? [];
        $days = max(1, (int) ($params['days'] ?? 7));

        // Replace these numbers with your DAO calls.
        $res->setData([
            'open' => 12,
            'overdue' => 3,
            'closed' => 40, // closed in the last $days days
        ]);
        echo $res->create(200, 'Dashboard stats.', true);
    } catch (Exception $ex) {
        System::errorlog(Loging::log($ex->getMessage(), 'myappController:get_dashboard_stats', LOG_WARN));
        echo $res->create(200, 'Something went wrong.', false);
    }
}
```

Declare `get_dashboard_stats` as a permission in the app's manifest and grant it to the roles that should see the widget. The widget's `permission` field names the same action, so users who can't call the endpoint don't get the widget at all. See [Roles And Permissions](../Essentials/Roles%20And%20Permissions.md).

## When a widget fails

Each widget is wrapped in a boundary component (`XpDashboardWidgetBoundary.js`) that keeps its failures away from the rest of the page:

- **The module fails to load**, or it has no usable default export (an object with `template`, `render` or `setup`, or a function). The widget is dropped and the console shows `[dashboard] widget <key> failed to load`.
- **The component throws** while it renders or in a lifecycle hook. The widget is dropped and the console shows `[dashboard] widget <key> failed to render`.

The other widgets render normally in both cases.

<aside>
⚠️ The boundary catches every error from the widget, not only render errors. A rejected promise in an `async created()`, or an exception in a click handler long after the page loaded, also removes the widget from the page. Catch errors inside the widget, as in the example above.

</aside>

---

# How to hide and show widgets

Hiding works by widget key, `<app_name>.<id>`.

**From an app.** An app's `dashboard.hide` lists keys that must not render while the app is active. The keys can be its own or another app's. For example, an app that brings its own profile card can hide the default one:

```json
"dashboard": {
    "hide": ["xp_system.profile"],
    "widgets": [
        { "id": "profile", "component": "/apps/myapp/components/dashboard/ProfileWidget.js", "region": "aside", "priority": 10 }
    ]
}
```

**From the install.** The site's `xp-config.json` can override every app in both directions with its own `dashboard` block:

```json
"dashboard": {
    "hide": ["xp_system.apps"],
    "show": ["xp_system.quick_links"]
}
```

Add `"dashboard"` to `xp-config.json`'s `_public` list too, or the browser won't see it. The default `xp-config.json.dist` has neither the key nor the `_public` entry.

The dashboard works out the hidden set like this:

```text
hidden = (every active app's dashboard.hide ∪ install dashboard.hide) − install dashboard.show
```

So the install's `show` beats any `hide`, including its own. `show` only brings back a widget that some app declares. It can't add a widget, and it never skips the widget's `permission` check.

`hide` and `show` must be arrays. Entries that aren't strings are ignored.

To move a widget to another region, or change its priority, hide it and declare your own copy with the same `component` URL in your app.

---

# How to theme the dashboard

Set the `--dcui-dashboard-*` variables on `:root` in your app's stylesheet. The stylesheet must be listed in the app's `resources.styles`.

```css
:root {
    --dcui-dashboard-greeting-color: #102a43;
    --dcui-dashboard-heading-color: #243b53;
    --dcui-dashboard-avatar-border: #0f766e;
    --dcui-dashboard-tile-1: #0f766e;
    --dcui-dashboard-tile-2: #1d4ed8;
    --dcui-dashboard-tile-3: #b45309;
    --dcui-dashboard-backdrop: linear-gradient(135deg, #ccfbf1, #dbeafe);
}
```

The variables are listed in [Theming variables](#theming-variables).

The framework doesn't set its defaults on `:root`. Each rule in `base_components.css` uses a fallback instead, such as `var(--dcui-dashboard-tile-1, #544fac)`. All apps' stylesheets are merged into one bundle in app-folder order, so an app's stylesheet usually comes before `xp_system`'s. A `:root` default in `xp_system` would then override the app's value. With fallbacks, your `:root` value always wins, wherever your stylesheet lands in the bundle.

---

# Reference

## Widget fields

The fields of each entry in `dashboard.widgets`:

| Field | Required | Default | Meaning and validation |
| --- | --- | --- | --- |
| `id` | yes | none | Unique within the app. The widget's key is `<app_name>.<id>`. Must be a non-empty string. |
| `component` | yes | none | URL of the component module, loaded with `XP.import()`. Must be a non-empty string. Use an absolute `/apps/...` path, so the module gets the framework's cache-busting URL. |
| `region` | no | `main` | `aside`, `main` or `full`. Any other value becomes `main`, without a warning. |
| `priority` | no | `50` | Lower numbers render first within the region. A number or a numeric string such as `"20"`. `true`, `false`, `null`, `""` and non-numeric values become `50`. Ties keep app order, then declaration order. |
| `permission` | no | none | A `{name, action}` object checked with `XP.checkPermission()`. Without it, anyone who can open the dashboard sees the widget. |
| `options` | no | `{}` | Passed to the component unchanged as `widget.options`. Anything that isn't a plain object, including an array, becomes `{}`. |

An entry that isn't an object, or that lacks a valid `id` or `component`, is skipped with a console warning: `[dashboard] <app>: widget skipped, it needs an id and a component`. A second entry with the same key is skipped with `[dashboard] duplicate widget <key> ignored`.

`permission` must be an object. A string such as `"myapp_view"` never matches, so the widget is hidden from everyone. With `public_dashboard` on and no one logged in, every widget that has a `permission` is hidden.

The `dashboard` block itself also takes `hide`, an array of widget keys. See "How to hide and show widgets" above.

## Kit components

The dashboard's kit components are exported from `apps/xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js`. For the rest of the kit, see [Vue DC UI KIT](../Vue%20DC%20UI%20KIT.md).

### DcDashboardWidget

Description:

The **`DcDashboardWidget`** component is the card a widget sits in. It renders an optional heading and a body. While `loading` is true it shows a transparent loader over the body. It is purely presentational: the widget inside fetches its own data.

Syntax:

```jsx
import { DcDashboardWidget } from "../../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

// in the template
// <dc-dashboard-widget title="Orders" :loading="loading" :transparent="widget.options.transparent === true">
//     ...widget content...
// </dc-dashboard-widget>
```

**Props:**

- **`title`** (`String`, default `""`): The heading. No heading is rendered when it's empty.
- **`loading`** (`Boolean`, default `false`): Shows the loader overlay and sets `aria-busy`.
- **`transparent`** (`Boolean`, default `false`): Drops the card's background, border, shadow and padding, so the content sits directly on the page.

**Slots:**

- **default**: The widget's content.

---

### DcAppTiles

Description:

The **`DcAppTiles`** component renders a wrapping grid of app tiles. Each tile is a coloured rounded square holding an SVG icon (shown in white) or a Font Awesome icon, with the label underneath. The tile colours cycle through `--dcui-dashboard-tile-1`, `-2` and `-3`. `xp_system.apps` uses it.

Syntax:

```jsx
import { DcAppTiles } from "../../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

const items = [
    { label: "Orders", to: { name: "myapp_orders" }, svg_icon: "/apps/myapp/assets/orders.svg" },
    { label: "Reports", to: { name: "myapp_reports" }, icon: "fal fa-chart-bar" },
];

// in the template
// <dc-app-tiles :items="items" />
```

**Props:**

- **`items`** (`Array`, default `[]`): One object per tile:
    - **`label`**: The text under the tile, also used as its `title`.
    - **`to`**: Any `router-link` target.
    - **`svg_icon`** (optional): An SVG image URL. It takes precedence over `icon`.
    - **`icon`** (optional): Font Awesome class names.

---

### DcQuickLinks

Description:

The **`DcQuickLinks`** component renders a wrapping row of borderless links, each an optional icon and a semibold label. `xp_system.quick_links` uses it.

Syntax:

```jsx
import { DcQuickLinks } from "../../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

const items = [
    { label: "New order", to: { name: "myapp_new_order" }, icon: "fal fa-plus" },
    { label: "Settings", to: { name: "settings" } },
];

// in the template
// <dc-quick-links :items="items" />
```

**Props:**

- **`items`** (`Array`, default `[]`): One object per link:
    - **`label`**: The link text.
    - **`to`**: Any `router-link` target.
    - **`icon`** (optional): Font Awesome class names.

---

### DcStatGroup

Description:

The **`DcStatGroup`** component renders equal-width columns, each a large number over a label. A value that is `null`, `undefined` or `""` shows as an em dash (`—`). `0` shows as `0`.

Syntax:

```jsx
import { DcStatGroup } from "../../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

const items = [
    { label: "Open", value: 12 },
    { label: "Overdue", value: null },
];

// in the template
// <dc-stat-group :items="items" />
```

**Props:**

- **`items`** (`Array`, default `[]`): One object per column:
    - **`label`**: The text under the number.
    - **`value`**: The number or text to show.

---

## Theming variables

| Variable | Default | Styles |
| --- | --- | --- |
| `--dcui-dashboard-greeting-color` | `#1e1e1e` | The greeting. |
| `--dcui-dashboard-heading-color` | `#3f3f3f` | Widget titles and `DcStatGroup` numbers. |
| `--dcui-dashboard-avatar-border` | `#657ff5` | The border around the avatar in `xp_system.profile`. |
| `--dcui-dashboard-tile-1` | `#544fac` | The 1st, 4th, 7th … `DcAppTiles` tile. |
| `--dcui-dashboard-tile-2` | `#4686ac` | The 2nd, 5th, 8th … tile. |
| `--dcui-dashboard-tile-3` | `#4dae84` | The 3rd, 6th, 9th … tile. |
| `--dcui-dashboard-backdrop` | `none` | The background of a large rotated decorative shape behind the page, such as a gradient. With `none`, no shape shows. |
