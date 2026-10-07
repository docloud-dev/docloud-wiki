---
sidebar_position: 3
title: App Frontend Config
sidebar_label: App Frontend Config
---

# App Frontend Config

# Introduction

Every app with a frontend has a config file in its frontend folder: `apps/<app>/app-config.json`. While you develop in a dev workspace, the file is `dev/<app>/frontend/<app>/app-config.json` (see [Dev Workspace](./Dev%20Workspace.md)).

The file tells the SPA about the app: whether it's loaded at all, which scripts and styles to bundle, which menu entries to show, its settings pages and dashboard widgets, and which of these fields reach the browser.

`server.php` reads every app's `app-config.json` on every page load. Save the file and reload the page to see a change. There's no cache to clear and no reinit to run.

The admin panel has its own copy of this file for the app's admin pages, `api/admin/apps/<app>/app-config.json`. See [Admin panel config](#admin-panel-config) below.

The backend has a separate manifest, `api/apps/<app>/<app>.xml`. See [App Manifest](./App%20Manifest.md).

---

# How to write app-config.json

This config is based on the built-in `helloworld` app (`apps/helloworld/app-config.json`), renamed to `myapp`:

```json
{
	"version": "1.0.0",
	"release_date": "2026-10-05",
	"app_name": "myapp",
	"app_type": "custom",
	"status": "active",
	"description": "Orders and order notes.",

	"resources": {
		"scripts": [
			{ "url": "assets/scripts.js" },
			{ "url": "route.js" }
		],
		"styles": [
			{ "url": "assets/styles.css" }
		]
	},

	"menus": [
		{
			"label": "My App",
			"svg_icon": "/apps/myapp/assets/icons/myapp.svg",
			"icon": "fas fa-globe-americas",
			"path_name": "myapp",
			"sub_paths": ["myapp-orders"],
			"description": "Orders and order notes.",
			"position": { "sidebar": true, "sidebar_priority": 100, "megabar": true, "megabar_priority": 100 },
			"permission": { "name": "myapp", "action": "view" }
		}
	],

	"dashboard": {
		"widgets": [
			{
				"id": "open_orders",
				"component": "/apps/myapp/components/dashboard/OpenOrdersWidget.js",
				"region": "main",
				"priority": 20,
				"permission": { "name": "myapp", "action": "view" }
			}
		]
	},

	"_comments": {
		"app_type": "system or custom",
		"status": "active or disabled"
	},

	"_public": [
		"version", "release_date", "app_name", "status", "description", "menus", "dashboard"
	]
}
```

The `route.js` listed under `resources` registers the route the menu entry opens. Its `name` matches the menu's `path_name`:

```jsx
// apps/myapp/route.js
const MyApp_Home = () => XP.import('/apps/myapp/components/home.js');
const MyApp_Orders = () => XP.import('/apps/myapp/components/orders.js');

Router.addRoute({
    path: '/myapp',
    name: 'myapp',
    component: MyApp_Home,
    meta: {
        title: 'My App',
        requiresAuth: true,
        permissions: { name: 'myapp', action: 'view' },
    },
});

Router.addRoute({
    path: '/myapp-orders',
    name: 'myapp-orders',
    component: MyApp_Orders,
    meta: {
        title: 'Orders',
        requiresAuth: true,
        permissions: { name: 'myapp', action: 'view' },
    },
});

// Re-resolve the current URL, in case the page was opened on one of these routes.
Router.replace(Router.currentRoute.value.fullPath);
```

See [Frontend Runtime (XP)](../Frontend%20Runtime%20(XP).md) for `XP.import` and the router.

---

# How the server loads the config

On every page load, `server.php` does this with each folder in `apps/`, in alphabetical order:

1. Reads `app-config.json` and parses it.
2. Skips the app unless `status` is `active`. A skipped app sends nothing to the browser: no scripts, styles, menus or widgets.
3. Adds the app's `resources` to the page bundles. All apps' scripts are joined into one file, `assets/app-scripts.js`, and all their styles into `assets/app-styles.css`. Files are added app by app, in folder order, then in the order the app lists them.
4. Builds the app's public entry: `app_type`, plus every key named in the app's `_public` list.

The public entries of all loaded apps become the `apps` array of `XP_CONFIG_PUBLIC`, written into the page. In the browser, `XP.getApps()` returns that array. A key that isn't listed in `_public` never reaches the browser.

<aside>
⚠️ Every `app-config.json` needs a `_public` array, even an empty one. Without it, the server throws a PHP error and the whole page fails to load, for every app. And if the file isn't valid JSON, the app is skipped without any message, as if it were disabled. Check the JSON when an app's menu disappears.

</aside>

<aside>
⚠️ Don't put an apostrophe (`'`), a double quote inside a value, a backslash or a line break in any public field. The server writes the public config into the page inside `JSON.parse('…')` without escaping it. Any of these characters can stop every page of the site from loading. Keep text such as descriptions plain, and put longer user-facing text in your components.

</aside>

The script bundle loads as a single `<script type="module">`. Every app's scripts share its top-level scope:

<aside>
⚠️ Prefix every top-level name in your resource scripts with your app's name, as `route.js` does above with `MyApp_Home`. If two apps declare the same top-level `const`, `let`, `class` or `function` name, the whole bundle fails with a syntax error, and no app's routes are registered.

</aside>

Because the bundle is served from `/assets/`, a relative `import` in a resource script resolves against `/assets/`, not against your app folder. Use absolute paths such as `/apps/myapp/components/home.js`.

---

# How to add a menu entry

Each entry in `menus` can appear in two places:

- **The sidebar**, the column of icons on the left of every page, when `position.sidebar` is `true`.
- **The megabar**, a full-screen menu of every app, when `position.megabar` is `true`. It shows each entry's icon, label and `description`.

<aside>
⚠️ In 0.0.44 the **Menu** button of the current sidebar (`dc_sidebar.js`, used by the dashboard, Settings and most app pages) doesn't open the megabar. Only the older `sidebar.js` and `topbar.js` components, still used by a few framework pages, open it. Set `position.megabar` anyway, so your entry appears wherever the megabar is shown.

</aside>

An entry is shown only when it has a `permission` and the logged-in user holds it. **An entry without `permission` is never shown.** The permission is checked with `XP.checkPermission`, the same way as a route's `meta.permissions` (see [Roles And Permissions](../Essentials/Roles%20And%20Permissions.md)).

Entries are sorted by `sidebar_priority` in the sidebar and by `megabar_priority` in the megabar. Lower numbers come first. A missing priority counts as `100`. Entries with the same priority keep the folder order of their apps, then the order in the file. The built-in Dashboard entry uses priority `1`.

Clicking an entry opens the route whose **name** is `path_name`. It isn't a URL. The entry is highlighted while the first segment of the current URL, or the current route's name, equals `path_name`. To keep it highlighted on the app's other pages, list their first URL segments or route names in `sub_paths`.

The framework dashboard also lists `sidebar` entries: a `custom` app's entries appear under "Available Apps", a `system` app's under "Quick links". See [Dashboard Widgets](./Dashboard%20Widgets.md#default-widgets).

---

# How to add a settings page

The framework's **Settings** page has a navigation list built from the `settings` arrays of all apps. Add an item, and list `settings` in `_public`:

```json
"settings": [
	{
		"name": "myapp",
		"src": "/apps/myapp/components/settings/myapp_settings.js",
		"icon": "fas fa-cog",
		"label": "My App",
		"permission": "myapp_settings"
	}
],
"_public": ["app_name", "status", "menus", "settings"]
```

The page opens at `/settings/<name>`. The item is listed only when the user's `settings` permissions include its `permission`. When the page opens, the server checks the permission again with `api/auth/validate_settings`, then the component at `src` is imported. If the check fails, the user is sent to `/settings/profile`.

<aside>
⚠️ `permission` is an action under the `settings` permission key, which the `xp_system` app declares in its own `<user_permissions name="settings">` block. Don't declare a second `settings` block in your manifest: when two apps declare the same permission key, only one block is used, and the other's actions disappear from the Roles page. A settings page that needs its own permission is better built as a route in your app, with a menu entry.

</aside>

---

# How updates treat the file

When an app is updated from a package, the packaged `app-config.json` replaces the installed one, except for `status`: the installed value is kept, so an app disabled on this system stays disabled. See [Packaging And Updates](./Packaging%20And%20Updates.md).

To change the file from PHP, for example from a `<run>` script, use `DoFrontend::DoFrontendAppConfigHandler('myapp')`. It can add, update and remove menu items, settings items, resources and `_public` entries. See [DoFrontendAppConfigHandler](../Essentials/Config%20Handlers.md#dofrontendappconfighandler).

---

# Field reference

### version

The app's frontend version, such as `"1.0.0"`. Informational: the framework doesn't compare it. Keep it equal to `<app_version>` in the manifest.

---

### release_date

The release date, such as `"2026-10-05"`. Informational.

---

### app_name

The app's name. Must equal the folder name. Put it in `_public`: dashboard widget keys are built from it (`myapp.open_orders`), and `XP.checkIfAppsAvailable()` looks apps up by it.

---

### app_type

**Values:** `system` for apps that ship with the framework, `custom` for yours. Defaults to `custom` when missing.

Always sent to the browser, whether or not `_public` lists it. The dashboard uses it to choose where the app's menus appear: `system` apps under "Quick links", every other value under "Available Apps".

The manifest's `<app_type>` uses different values (`system_app`) and is read by different code. See [App Manifest](./App%20Manifest.md#info).

---

### status

**Values:** `active` or `disabled`. Required.

Only `active` apps are loaded. Any other value, or a missing `status`, removes the app from the frontend: its scripts, styles, routes, menus and widgets are all left out. It doesn't affect the backend. The app's API still answers.

An update from a package keeps the installed value.

---

### description

A short text about the app. Public if listed. Not shown by the framework's own components.

---

### resources

```json
"resources": {
	"scripts": [{ "url": "assets/scripts.js" }, { "url": "route.js" }],
	"styles": [{ "url": "assets/styles.css" }]
}
```

Files to load on every page. Each `url` is relative to the app's folder. Remote URLs aren't supported here: the server prefixes every `url` with the app's folder.

The server joins all apps' scripts into `assets/app-scripts.js` and all their styles into `assets/app-styles.css`, rebuilt on every page load. Each bundle's URL carries a hash of its content, so browsers fetch it again only when it changes. The script bundle is loaded as a module, after the framework's library bundle. "How the server loads the config", above, covers the shared scope.

Never sent to the browser, so it doesn't need to be in `_public`.

Load your Vue components on demand with `XP.import` from `route.js`, rather than listing them here.

---

### menus

An array of menu entries. Must be in `_public`. "How to add a menu entry", above, explains how they're shown.

| Field | Required | Meaning |
| --- | --- | --- |
| `label` | Yes | The entry's text. |
| `path_name` | Yes | The name of the route to open. Not a URL. |
| `permission` | Yes | `name` and `action` of the permission the user must hold. Without it the entry is never shown. |
| `position.sidebar` | No | `true` shows the entry in the sidebar. |
| `position.sidebar_priority` | No | Sort order in the sidebar. Lower first. Default `100`. |
| `position.megabar` | No | `true` shows the entry in the megabar. |
| `position.megabar_priority` | No | Sort order in the megabar. Lower first. Default `100`. |
| `icon` | No | Font Awesome classes, such as `fas fa-globe-americas`. Used by the megabar, and by the sidebar when there's no `svg_icon`. |
| `svg_icon` | No | Absolute URL of an image for the sidebar. When set, the sidebar shows it instead of `icon`. The megabar always uses `icon`, so set both. |
| `sub_paths` | No | First URL segments or route names that also highlight the entry. |
| `description` | No | Shown under the label in the megabar. |

---

### settings

An array of items for the Settings page. Must be in `_public`. See "How to add a settings page", above.

| Field | Meaning |
| --- | --- |
| `name` | The slug. The page opens at `/settings/<name>`. |
| `src` | Absolute URL of the component module. |
| `label` | The text in the settings navigation. |
| `icon` | Font Awesome classes for the navigation. |
| `permission` | The action, under the `settings` permission key, that the user must hold. |

---

### dashboard

Widgets the app adds to the framework dashboard, and widgets it hides. Must be in `_public`.

```json
"dashboard": {
	"widgets": [
		{ "id": "open_orders", "component": "/apps/myapp/components/dashboard/OpenOrdersWidget.js", "region": "main", "priority": 20 }
	],
	"hide": ["xp_system.quick_links"]
}
```

[Dashboard Widgets](./Dashboard%20Widgets.md) has every field, the regions and how to write a widget component.

---

### widgets

```json
"widgets": [
	{
		"display_name": "My widget",
		"component_name": "myapp_widget",
		"sizes": ["small", "medium", "large"],
		"url": "/apps/myapp/components/widgets/myapp_widget.js"
	}
]
```

The older way to share components. The dashboard doesn't read it. Nothing in the framework reads it on its own either: `XP.getWidgetList()` collects every public app's `widgets`, and `XP.registerWidgets(list)` imports each `url` and registers its default export as a global Vue component named `component_name`. Your code must call both. `display_name` and `sizes` aren't used by the framework.

For new dashboard widgets, use `dashboard`.

---

### _public

```json
"_public": ["version", "release_date", "app_name", "status", "description", "menus", "dashboard"]
```

**Required**, even if empty. The keys of this file that are sent to the browser. `app_type` is always sent. Every other key, including `resources` and `_comments`, stays on the server unless it's listed.

List at least `app_name` and `menus`. Add `settings`, `dashboard` or `widgets` when the app uses them. Keep secrets out of this file's public keys: anyone who can load the page can read them.

---

### _comments

Free-form notes. The server ignores it. Don't add it to `_public`.

---

## Admin panel config

An app with admin panel pages has a second config, `api/admin/apps/<app>/app-config.json` (`dev/<app>/adminpanel/<app>/app-config.json` in a dev workspace). The admin panel's `api/admin/server.php` reads it the same way, with these differences:

- Its scripts and styles are bundled into `api/admin/assets/`, and loaded only in the admin panel.
- Its menu entries go in the admin panel's own navigation, and their permissions are `<admin_panel_permissions>` actions.
- `app_type` is sent to the browser only if `_public` lists it.

The same `_public`, `status`, quoting and top-level name rules apply. See [Admin Pages](./Admin%20Pages.md).
