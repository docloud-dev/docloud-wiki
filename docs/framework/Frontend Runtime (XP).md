---
sidebar_position: 55
title: Frontend Runtime (XP)
sidebar_label: Frontend Runtime (XP)
---

# Frontend Runtime (XP)

# Introduction

`xp.js` is the framework's frontend runtime. It is part of the `lib-scripts.js` bundle that loads on every page, before any app code runs. It creates three globals:

- **`XP`**: the object described on this page. Config, URLs, the logged-in user, permissions, storage, translations, the page loader and device detection.
- **`App`**: the Vue 3 application. `XP.registerWidgets()` registers components on it.
- **`Router`**: the Vue Router instance. Your `route.js` adds routes to it.

`XP` reads its config from `XP_CONFIG_PUBLIC`, which `index.php` prints into the page. [Architecture](Architecture.md) explains the whole boot sequence.

<aside>
💡 The three globals are top-level `const` declarations in a classic script. Every script and module on the page can use them as `XP`, `App` and `Router`, but they are not properties of `window`. `window.XP` is `undefined`.

</aside>

This page documents the main SPA's copy, `xp.js` at the framework root. The admin panel loads its own copy, `api/admin/xp.js`. The differences are listed under "How the admin panel's copy differs" below.

---

# How to call your API from services.js

Keep every API call of your app in `apps/<app>/services.js`, as `helloworld` does. It is an ES module that your components import. Don't list it in `resources.scripts`.

```jsx
const api_url = XP.getApiUrl();

export const myapp_services = {

    getItems: async function (params) {
        const response = await fetch(api_url + '/myapp/get_items?' + new URLSearchParams(params), {
            method: 'GET',
            credentials: 'include',
        });
        return await response.json();
    },

    saveItem: async function (item) {
        const response = await fetch(api_url + '/myapp/save_item', {
            method: 'POST',
            body: XP.readyFormData(item),
            credentials: 'include',
        });
        return await response.json();
    },
};
```

- `XP.getApiUrl()` returns `https://<your host>/api`, or `api_url` from `xp-config.json` when it is set. It has no trailing slash.
- `credentials: 'include'` sends the session cookie, also when `api_url` points to another host.
- `XP.readyFormData()` turns an object into `FormData`, which the backend reads from `$_POST` and `$_FILES`. To send JSON instead, set the `Content-Type: application/json` header and pass `JSON.stringify(item)` as the body. The framework decodes it into the request data.

Call the service from a component and check `response.success`:

```jsx
import { myapp_services } from '../services.js';

export default {
    data() {
        return { items: [], loading: true };
    },
    async created() {
        const res = await myapp_services.getItems({ status: 'open' });
        this.loading = false;
        if (res.response.success) {
            this.items = res.data ?? [];
        }
    },
    template: `<div>...</div>`,
};
```

`fetch()` doesn't reject on `401` or `503`. The body is still the framework's JSON, so `res.response.success` is `false` and `res.response.statusMsg` says why. The backend leaves `data` out when it is empty, so always give a fallback. [Architecture](Architecture.md) lists the response format and the status codes.

---

# How to register routes in route.js

List `route.js` in `resources.scripts` of your `app-config.json`. The framework bundles it into `assets/app-scripts.js`, which runs before the app mounts. Add each page with `Router.addRoute()` and load the component lazily with `XP.import()`:

```jsx
const Myapp_List = () => XP.import('/apps/myapp/components/myapp.js');
const Myapp_Item = () => XP.import('/apps/myapp/components/item.js');

Router.addRoute({
    path: '/myapp',
    name: 'myapp',
    component: Myapp_List,
    meta: {
        title: 'My App',
        requiresAuth: true,
        permissions: {
            name: 'myapp',
            action: 'view',
        },
    },
});

Router.addRoute({
    path: '/myapp/item/:id',
    name: 'myapp_item',
    component: Myapp_Item,
    meta: {
        title: 'Item',
        requiresAuth: true,
        permissions: {
            name: 'myapp',
            action: 'view',
        },
    },
});

Router.replace(Router.currentRoute.value.fullPath);
```

End the file with the `Router.replace(...)` line, as every framework app does.

The `xp_system` app's route guard reads `meta` on every navigation:

- **`requiresAuth: true`**: a visitor who isn't logged in goes to the login page. A logged-in user goes on only when they hold the permission in `meta.permissions`, checked with `XP.checkPermission()`. Otherwise they go to the dashboard. A user who is refused the dashboard itself gets the error page with a `403` instead.
- **`requiresAuth: false`**: a public page. The guard adds the `xp-public` class to `body`.
- **`title`**: becomes the browser tab title.

The route `name` is what a menu's `path_name` in `app-config.json` points to. See [App Frontend Config](Building%20Apps/App%20Frontend%20Config.md). The `permissions` pair is one of the permissions your manifest declares. See [Roles And Permissions](Essentials/Roles%20And%20Permissions.md).

Rules that save debugging time:

- **Use absolute paths.** `route.js` runs from `/assets/app-scripts.js`, so a relative import would resolve against `/assets/`.
- **Prefix every name with your app.** All apps' `route.js` files share one module scope, and two `const` declarations with the same name break every app's routes. Vue Router also replaces a route when another one is added with the same `name`.
- **Always set `meta.permissions` on a route that requires auth.** Without it the guard can't confirm the permission and sends the user to the dashboard.
- **Always set `meta.title`.** Without it, the guard's fallback throws a `TypeError` and the tab keeps the previous page's title.

---

# How the admin panel's copy differs

The admin panel at `/api/admin/` loads `api/admin/xp.js`. Its `xp-config.json` sets `type` to `admin_panel`, and both copies switch on that. Differences:

- **`X-DC-Panel` header.** The admin copy wraps `window.fetch`. Every same-origin `fetch()` to a path under `/api/` gets the header `X-DC-Panel: admin`, which puts admin-panel `POST` requests in the admin activity log. `Content-Type` is left alone, so `FormData` uploads still work. `XMLHttpRequest` and jQuery requests are not tagged. See [Architecture](Architecture.md).
- **Router base.** With `type` set to `admin_panel`, `Router` uses `/api/admin/` as its base, so a route path `/myapp` is the URL `/api/admin/myapp`.
- **URLs.** `getAppUrl()` returns the origin plus `/api/admin`. `getApiUrl()` is the same as in the SPA, so admin pages call the same `/api/<controller>/<action>` endpoints.
- **Logged-in user.** The data is stored under `<prefix>-logged_admin_user`. Use `checkAdminPermission()` and `getAdminPermissions()`.
- **Missing members.** The admin copy has no `device_detect`, `permissionScopes`, `getTarget` or `initializeServiceWorker`, and it doesn't update the web app manifest on route changes. Its `init()` only loads the app options.
- **Import map.** Admin modules are versioned under `/api/admin/apps/`. The admin `route.js` of `helloworld` imports `./../apps/helloworld/components/helloworld-settings.js`, which resolves against `/api/admin/assets/` to a path under `/api/admin/apps/`. `getAppsDir()` still returns `/apps/...`, so don't use it to build admin paths.

See [Admin Pages](Building%20Apps/Admin%20Pages.md).

---

# XP reference

## Config and URLs

### XP.config

Description:

The **`config`** property holds the public config the server printed into the page: the keys listed in `_public` of `xp-config.json`, plus `apps`, an array with the public part of every active app's `app-config.json`.

Syntax:

```jsx
const system_name = XP.config.system_name;
```

**Return Value:**

- **`Object`**: The public config.

---

### getSystemConfig

Description:

The **`getSystemConfig`** method returns the whole public config, or one value by a colon-separated path.

Syntax:

```jsx
const config = XP.getSystemConfig();
const enabled = XP.getSystemConfig(':service_worker:enable_service_worker:');
```

**Parameters:**

- **`location`** (optional): A path such as `':service_worker:path:'`. Empty parts are ignored, so the leading and trailing colons are optional.

**Return Value:**

- **`Object | any | null`**: The config object, the value at the path, or `null` when the last key is missing. A missing key in the middle of a longer path throws a `TypeError`.

---

### getApiUrl

Description:

The **`getApiUrl`** method returns the base URL of the API: `api_url` from `xp-config.json` when it is set, otherwise the current origin plus `/api`.

Syntax:

```jsx
const api_url = XP.getApiUrl(); // "https://example.com/api"
```

**Return Value:**

- **`String`**: The API base URL, without a trailing slash.

---

### getAppUrl

Description:

The **`getAppUrl`** method returns the base URL of the frontend: `app_url` from `xp-config.json` when it is set, otherwise the current origin.

Syntax:

```jsx
const app_url = XP.getAppUrl(); // "https://example.com"
```

**Return Value:**

- **`String`**: The frontend base URL, without a trailing slash unless `app_url` has one.

---

### getDoCloudUrl

Description:

The **`getDoCloudUrl`** method returns `do_cloud_url` from `xp-config.json`.

Syntax:

```jsx
const docloud_url = XP.getDoCloudUrl();
```

**Return Value:**

- **`String | undefined`**: The configured URL.

---

### getAppPrefix

Description:

The **`getAppPrefix`** method returns the prefix used in local storage keys: `prefix` from `xp-config.json` when it is set, otherwise the initials of the system name (the `system_name` option of `xp_system`). For "Developer Framework" it is `DF`.

Syntax:

```jsx
const prefix = XP.getAppPrefix();
```

**Return Value:**

- **`String`**: The prefix, or `""` when neither is set.

<aside>
💡 Without `prefix`, renaming the system changes the prefix. Users then look logged out on the frontend until they log in again, because their stored user data is under the old key.

</aside>

---

### getAppsDir

Description:

The **`getAppsDir`** method returns the URL path of the frontend apps folder, or of one app.

Syntax:

```jsx
const dir = XP.getAppsDir('myapp'); // "/apps/myapp/"
```

**Parameters:**

- **`app_name`** (optional): The app folder name.

**Return Value:**

- **`String`**: `/apps/` or `/apps/<app_name>/`.

---

### getApps

Description:

The **`getApps`** method returns the public config of every active app, from `XP.config.apps`.

Syntax:

```jsx
const apps = XP.getApps();
```

**Return Value:**

- **`Array | null`**: One object per app, or `null` when there are none.

---

### checkIfAppsAvailable

Description:

The **`checkIfAppsAvailable`** method tells you whether other apps are installed and active, matched by `app_name`. Use it before you call or link to another app.

Syntax:

```jsx
const available = XP.checkIfAppsAvailable(['xp_notification', 'otherapp']);
if (available.otherapp) {
    // show the link
}
```

**Parameters:**

- **`app_names`**: One app name or an array of names.

**Return Value:**

- **`Object`**: Each name mapped to `true` or `false`. When no apps are listed at all, it returns an empty array.

---

### getSettings

Description:

The **`getSettings`** method returns the settings pages that apps declare under `settings` in `app-config.json`.

Syntax:

```jsx
const all_settings = XP.getSettings();
const profile = XP.getSettings('profile');
```

**Parameters:**

- **`name`** (optional): The `name` of one settings entry.

**Return Value:**

- **`Array | Object | undefined | null`**: All entries, the one entry with that name (`undefined` when there is none), or `null` when no apps are listed.

---

### getWidgetList

Description:

The **`getWidgetList`** method returns the dashboard widgets that apps declare under `widgets` in `app-config.json`. See [Dashboard Widgets](Building%20Apps/Dashboard%20Widgets.md).

Syntax:

```jsx
const widgets = XP.getWidgetList();
```

**Return Value:**

- **`Array`**: The widget entries, or an empty array.

---

### registerWidgets

Description:

The **`registerWidgets`** method imports each widget's `url` and registers its default export on `App` under its `component_name`. The dashboard calls it. A widget that fails to load is logged and skipped.

Syntax:

```jsx
await XP.registerWidgets(XP.getWidgetList());
```

**Parameters:**

- **`widgets`**: An array of widget entries with `url` and `component_name`.

**Return Value:**

- **`Promise`**: Resolves when every import has settled. Rejects when `widgets` is not an array.

---

### getAppVersion

Description:

The **`getAppVersion`** method returns `version` from `xp-config.json`. This is the framework version, not your app's version.

Syntax:

```jsx
const version = XP.getAppVersion(); // "0.0.44"
```

**Return Value:**

- **`String | undefined`**: The version, or `undefined` when it is empty.

---

### getResVersion

Description:

The **`getResVersion`** method returns `res_version` from `xp-config.json`.

Syntax:

```jsx
const res_version = XP.getResVersion();
```

**Return Value:**

- **`String | undefined`**: The resource version, or `undefined` when it is empty.

---

### get_last_impact_time

Description:

The **`get_last_impact_time`** method returns `last_impact_time` from `xp-config.json`. Since 0.0.38 cache busting uses the import map, not this value.

Syntax:

```jsx
const lpt = XP.get_last_impact_time();
```

**Return Value:**

- **`String | Number`**: The value, or `"0000"` when it is not set.

---

## Users and session

The frontend keeps a copy of the logged-in user in local storage. The login page saves it with `saveLocalLoggedUserData()`. The server session is still what the backend checks. See [Authentication](Essentials/Authentication.md).

### getLocalLoggedUserData

Description:

The **`getLocalLoggedUserData`** method returns the stored data of the logged-in user.

Syntax:

```jsx
const raw = XP.getLocalLoggedUserData();
const user = raw ? JSON.parse(raw) : null;
```

**Parameters:**

- **`app_type`** (optional): `'admin_panel'` for the admin user, anything else for the SPA user. Defaults to `XP.config.type`.

**Return Value:**

- **`String | null`**: The JSON string, or `null` when nobody is logged in.

---

### getLocalLoggedUserDataKeyString

Description:

The **`getLocalLoggedUserDataKeyString`** method returns the local storage key of the logged-in user data.

Syntax:

```jsx
const key = XP.getLocalLoggedUserDataKeyString(); // "DF-logged_user"
```

**Parameters:**

- **`app_type`** (optional): As for `getLocalLoggedUserData`.

**Return Value:**

- **`String`**: `<prefix>-logged_user`, or `<prefix>-logged_admin_user` for the admin panel.

---

### saveLocalLoggedUserData

Description:

The **`saveLocalLoggedUserData`** method stores the user data, replacing what was there. It serialises the object for you.

Syntax:

```jsx
XP.saveLocalLoggedUserData(res.data);
```

**Parameters:**

- **`data`**: The user object, usually `data` of the login response.

**Return Value:**

- **`undefined`**

---

### updateLocalLoggedUserData

Description:

The **`updateLocalLoggedUserData`** method sets the given keys on the stored user data and keeps the others.

Syntax:

```jsx
XP.updateLocalLoggedUserData({ first_name: 'Ann' });
```

**Parameters:**

- **`data`**: An object of keys to set.

**Return Value:**

- **`undefined`**. Throws a `TypeError` when no user data is stored.

---

### removeLocalLoggedUserData

Description:

The **`removeLocalLoggedUserData`** method removes keys from the stored user data.

Syntax:

```jsx
XP.removeLocalLoggedUserData({ target: true });
```

**Parameters:**

- **`data`**: An object whose **keys** are removed. The values are ignored. Don't pass an array: its keys are `0`, `1` and so on.

**Return Value:**

- **`undefined`**. Throws a `TypeError` when no user data is stored.

---

### deleteLocalLoggedUserData

Description:

The **`deleteLocalLoggedUserData`** method removes the stored user data entirely. The logout flow calls it.

Syntax:

```jsx
XP.deleteLocalLoggedUserData();
```

**Return Value:**

- **`undefined`**

---

### isLoggedUserDataInLocalStorage

Description:

The **`isLoggedUserDataInLocalStorage`** method checks whether user data is stored.

Syntax:

```jsx
const has_user = XP.isLoggedUserDataInLocalStorage('logged_user');
```

**Parameters:**

- **`user_type`**: `'logged_user'` or `'logged_admin_user'`.

**Return Value:**

- **`Boolean`**: `true` when the entry exists.

---

### getTarget

Description:

The **`getTarget`** method returns `target` from the stored user data: the route name the user lands on instead of the dashboard. The route guard uses it when the user opens `/`.

Syntax:

```jsx
const target = XP.getTarget();
```

**Return Value:**

- **`String | null`**: The route name, or `null`.

---

## Permissions

These methods read the permissions stored with the logged-in user. They decide what the interface shows. The backend checks every request again. See [Roles And Permissions](Essentials/Roles%20And%20Permissions.md).

### checkPermission

Description:

The **`checkPermission`** method checks whether the logged-in user holds one action of one app.

Syntax:

```jsx
if (XP.checkPermission({ name: 'myapp', action: 'edit_item' })) {
    // show the edit button
}
```

**Parameters:**

- **`permission`**: An object with **`name`** (the app) and **`action`**.

**Return Value:**

- **`Boolean`**: `true` when the user holds the action.

---

### checkAdminPermission

Description:

The **`checkAdminPermission`** method is `checkPermission` for the admin panel user. It reads `admin_permissions` instead of `permissions`.

Syntax:

```jsx
const can_edit = XP.checkAdminPermission({ name: 'myapp', action: 'edit_settings' });
```

**Parameters:**

- **`permission`**: An object with **`name`** and **`action`**.

**Return Value:**

- **`Boolean`**: `true` when the admin holds the action.

---

### getPermissions

Description:

The **`getPermissions`** method returns every permission of the logged-in user, grouped by app.

Syntax:

```jsx
const permissions = XP.getPermissions();
// { myapp: ["view", "edit_item"], dashboard: ["view"] }
```

**Return Value:**

- **`Object | false`**: The permissions, or `false` when nobody is logged in or the data can't be read.

---

### getAdminPermissions

Description:

The **`getAdminPermissions`** method returns the admin permissions of the logged-in admin user, grouped by app.

Syntax:

```jsx
const admin_permissions = XP.getAdminPermissions();
```

**Return Value:**

- **`Object | false`**: The permissions, or `false` when the user has none. Throws a `TypeError` when nobody is logged in, so call it only on authenticated pages.

---

### permissionScopes

Description:

The **`permissionScopes`** method tells you where the user holds an action. Use it to offer only the records a user may act on, for example in a picker. See the scopes section of [Roles And Permissions](Essentials/Roles%20And%20Permissions.md).

Syntax:

```jsx
const scopes = XP.permissionScopes({ name: 'myapp', action: 'edit_item' });
if (scopes === '*') {
    // everywhere
} else if (scopes.length) {
    // only these scopes, e.g. ["myapp.store:3"]
}
```

**Parameters:**

- **`permission`**: An object with **`name`** and **`action`**.

**Return Value:**

- **`String | Array`**: `"*"` when the grant applies everywhere, a list of scope strings when it is limited, or `[]` when the user doesn't hold the action.

---

### getPermissionType

Description:

The **`getPermissionType`** method returns the key that holds permissions in the stored user data.

Syntax:

```jsx
const key = XP.getPermissionType(); // "permissions"
```

**Parameters:**

- **`app_type`** (optional): Defaults to `XP.config.type`.

**Return Value:**

- **`String`**: `'admin_permissions'` for the admin panel, `'permissions'` otherwise.

---

### injectPermissionsToLocalStorage

Description:

The **`injectPermissionsToLocalStorage`** method adds permissions to the stored user data. It changes only what the interface shows. The backend doesn't see it.

Syntax:

```jsx
XP.injectPermissionsToLocalStorage({ myapp: ['view'] });
XP.injectPermissionsToLocalStorage({ myapp: ['view'] }, null, true);
```

**Parameters:**

- **`new_permission_array`**: An object of app names mapped to action arrays.
- **`app_type`** (optional): Defaults to `XP.config.type`.
- **`replace`** (optional): `true` replaces each listed app's actions. The default `false` merges them with the existing ones.

**Return Value:**

- **`Boolean`**: `true` on success, `false` when nobody is logged in or the stored data has no permissions.

---

## Routing and mounting

### mountApp

Description:

The **`mountApp`** method installs `Router` on `App`, mounts Vue on `#app` and calls `XP.init()`. In the SPA it also keeps the web app manifest link in step with the current route. `index.php` calls it once, after every app's `route.js` has run. Apps never call it.

Syntax:

```jsx
XP.mountApp();
```

**Return Value:**

- **`undefined`**

---

### init

Description:

The **`init`** method starts the runtime services: it fetches the public app options (`XP.app_options.init()`) and fills `XP.device_detect`. `mountApp()` calls it.

Syntax:

```jsx
XP.init();
```

**Return Value:**

- **`undefined`**

---

## Imports

### import

Description:

The **`import`** method loads an ES module and returns its default export. Use it for lazy route components and anything you load on demand. Since 0.0.38 it passes the path through unchanged: the import map versions it. Don't add query strings.

Syntax:

```jsx
const Myapp_List = () => XP.import('/apps/myapp/components/myapp.js');

const helpers = await XP.import('/apps/myapp/helpers.js');
```

**Parameters:**

- **`path`**: An absolute path such as `/apps/myapp/components/myapp.js`. A relative path resolves against `/assets/`, where `xp.js` is bundled.

**Return Value:**

- **`Promise`**: Resolves with the module's default export, or the whole module when it has none. Resolves with `null` when the import fails (the error is logged) and with `""` when `path` is empty or not a string.

---

### dynamicImportComponents

Description:

The **`dynamicImportComponents`** method loads a component and assigns it to a data property of a component, for use with `component :is`.

Syntax:

```jsx
data() {
    return { panel: null };
},
created() {
    XP.dynamicImportComponents(this, 'panel', '/apps/myapp/components/panel.js');
},
```

**Parameters:**

- **`vueInstance`**: The component, usually `this`.
- **`dataPropertyName`**: The data property that receives the component.
- **`path`**: The module path.

**Return Value:**

- **`undefined`**. A failed import is not caught: it shows as an unhandled promise rejection in the console.

---

## Storage and cookies

### saveToStorage

Description:

The **`saveToStorage`** method stores a value in local storage.

Syntax:

```jsx
XP.saveToStorage('myapp-filters', JSON.stringify(filters));
```

**Parameters:**

- **`key`**: The storage key. Prefix it with your app name.
- **`value`**: The value. Local storage keeps strings, so serialise objects yourself.

**Return Value:**

- **`undefined`**

---

### getFromStorage

Description:

The **`getFromStorage`** method reads a value from local storage.

Syntax:

```jsx
const filters = JSON.parse(XP.getFromStorage('myapp-filters') || '{}');
```

**Parameters:**

- **`key`**: The storage key.

**Return Value:**

- **`String | null`**: The stored string, or `null`.

---

### deleteFromStorage

Description:

The **`deleteFromStorage`** method removes a key from local storage.

Syntax:

```jsx
XP.deleteFromStorage('myapp-filters');
```

**Parameters:**

- **`key`**: The storage key.

**Return Value:**

- **`undefined`**

---

### isLocalStorageItemExist

Description:

The **`isLocalStorageItemExist`** method checks whether a key exists in local storage.

Syntax:

```jsx
if (XP.isLocalStorageItemExist('myapp-filters')) {
    // restore the filters
}
```

**Parameters:**

- **`item_name`**: The storage key.

**Return Value:**

- **`Boolean`**: `true` when the key exists.

---

### updateStorageKeyValue

Description:

The **`updateStorageKeyValue`** method sets keys on a JSON object stored in local storage and keeps its other keys.

Syntax:

```jsx
XP.updateStorageKeyValue('myapp-filters', { status: 'open' });
```

**Parameters:**

- **`item`**: The storage key. It must already hold a JSON object.
- **`data`**: An object of keys to set.

**Return Value:**

- **`undefined`**. Throws a `TypeError` when the key doesn't exist.

---

### removeStorageKey

Description:

The **`removeStorageKey`** method removes keys from a JSON object stored in local storage.

Syntax:

```jsx
XP.removeStorageKey('myapp-filters', { status: true });
```

**Parameters:**

- **`item`**: The storage key. It must already hold a JSON object.
- **`data`**: An object whose **keys** are removed.

**Return Value:**

- **`undefined`**. Throws a `TypeError` when the key doesn't exist.

---

### getCookie

Description:

The **`getCookie`** method reads a cookie.

Syntax:

```jsx
const language = XP.getCookie('language');
```

**Parameters:**

- **`name`**: The cookie name.

**Return Value:**

- **`String | null`**: The value, or `null`.

---

### setCookie

Description:

The **`setCookie`** method sets a cookie on a parent domain, with path `/`.

Syntax:

```jsx
XP.setCookie('myapp_seen_intro', '1', 30, 'example.com');
```

**Parameters:**

- **`cookieName`**: The cookie name.
- **`cookieValue`**: The value.
- **`expiryDate`**: Days until it expires.
- **`parentDomain`**: The domain, without a leading dot. The cookie is set for `.<parentDomain>`, so it is shared with subdomains.

**Return Value:**

- **`undefined`**

---

### delete_cookie

Description:

The **`delete_cookie`** method expires a cookie on path `/`.

Syntax:

```jsx
XP.delete_cookie('myapp_seen_intro');
```

**Parameters:**

- **`name`**: The cookie name.

**Return Value:**

- **`undefined`**. It sets no domain, so it can't remove a cookie that `setCookie` created with one.

---

## Internationalization

The page load stores the strings of every app's `languages/lang.json`, for the current language, in local storage under `XP_LANGUAGE`. The current language is the `language` cookie, default `EN`. See [Localization](Essentials/Localization.md).

### getLanguageJSON

Description:

The **`getLanguageJSON`** method returns one app's strings for the current language. It works in every browser, so prefer it to `getLocale()` when you only need the current language.

Syntax:

```jsx
const t = XP.getLanguageJSON('myapp') ?? {};
const label = t.add_item ?? 'Add item';
```

**Parameters:**

- **`app_name`**: The app's folder name under `apps/`.

**Return Value:**

- **`Object | undefined`**: The strings, or `undefined` when the app has none for this language.

---

### getLocale

Description:

The **`getLocale`** method returns the calling app's strings. It works out the app from the URL of the file that calls it (`/apps/<app>/...`). Given a language other than the one in the `language` cookie, it first loads that language from the server.

Syntax:

```jsx
const t = await XP.getLocale();
const t_si = await XP.getLocale('SI');
```

**Parameters:**

- **`lang`** (optional): A language key from `lang.json`, such as `EN`.

**Return Value:**

- **`Promise`**: Resolves with the strings, or `""` when there are none. Returns `undefined` instead of a promise when the caller isn't a file under `apps/`.

<aside>
⚠️ Two known problems. `getLocale()` finds the calling file from a Chromium-style stack trace. In Firefox and Safari that lookup fails and the call throws a `TypeError`. Switching language also fails: `getLanguageFromServer()` builds the gateway URL as `getAppUrl() + "gateway.php"` with no slash between them, so the request goes to the wrong host, and the promise never resolves. Use `getLanguageJSON()` for the current language.

</aside>

---

### getLanguageFromServer

Description:

The **`getLanguageFromServer`** method asks `gateway.php` for another language. The gateway sets the `language` cookie for 30 days and returns the strings. The method saves them to `XP_LANGUAGE` and calls the callback. See the warning under `getLocale`: with the default empty `app_url`, the request URL is wrong.

Syntax:

```jsx
XP.getLanguageFromServer('SI', () => {
    // XP_LANGUAGE now holds the SI strings
});
```

**Parameters:**

- **`language`**: The language key.
- **`callback`**: Called after the strings are saved.

**Return Value:**

- **`undefined`**

---

### getCallerFileName

Description:

The **`getCallerFileName`** method returns the URL of the file that called the function that calls it. `getLocale()` uses it. It relies on the Chromium stack trace format.

Syntax:

```jsx
const file = XP.getCallerFileName();
```

**Return Value:**

- **`String | null`**: The file URL, or `null` when the stack can't be read.

---

## App options

`XP.app_options` caches the public app options in local storage under `app_options`. See [App Options](Essentials/App%20Options.md) for declaring and reading options.

### XP.app_options.get_option

Description:

The **`get_option`** method reads cached public options.

Syntax:

```jsx
const display_name = XP.app_options.get_option('myapp', 'display_name') || 'My App';
const myapp_options = XP.app_options.get_option('myapp');
const all_options = XP.app_options.get_option(null, null, true);
```

**Parameters:**

- **`app_name`** (optional): The app name.
- **`option_name`** (optional): The option name. Without it, all options of the app are returned.
- **`return_all`** (optional): `true` returns the options of every app when `app_name` is empty or not found.

**Return Value:**

- **`String | Object`**: The value, an object of options, or `""` when nothing matches or the cache is empty.

---

### XP.app_options.init

Description:

The **`init`** method starts `get_public_options_from_backend()` without waiting for it. `XP.init()` calls it on every page load.

Syntax:

```jsx
XP.app_options.init();
```

**Return Value:**

- **`undefined`**

---

### XP.app_options.get_public_options_from_backend

Description:

The **`get_public_options_from_backend`** method fetches `/api/system_admin_app/get_public_options` and stores the result as `{ "apps": ... }` under `app_options`. Await it when you need fresh values right away.

Syntax:

```jsx
await XP.app_options.get_public_options_from_backend();
```

**Return Value:**

- **`Promise`**: Resolves when the options are stored.

---

## Loader

`XP.xp_loader` drives the thin progress bar at the top of the page, the `.xp-loader` element in `index.php`. The route guard starts it on every navigation and stops it when the page is ready. Call it yourself around long actions.

### XP.xp_loader.start

Description:

The **`start`** method shows the bar and moves it up by 10% every half second, up to 90%.

Syntax:

```jsx
XP.xp_loader.start();
```

**Return Value:**

- **`undefined`**

---

### XP.xp_loader.stop

Description:

The **`stop`** method fills the bar to 100% and hides it about a second later.

Syntax:

```jsx
XP.xp_loader.start();
try {
    await myapp_services.saveItem(this.item);
} finally {
    XP.xp_loader.stop();
}
```

**Return Value:**

- **`undefined`**

---

### XP.xp_loader.update

Description:

The **`update`** method sets the bar's width from `xp_loader_loadingProgress` (0 to 100). `start()` and `stop()` call it.

Syntax:

```jsx
XP.xp_loader.xp_loader_loadingProgress = 50;
XP.xp_loader.update();
```

**Return Value:**

- **`undefined`**

---

## Device detection

`XP.device_detect` describes the visitor's browser and device, from the bundled UAParser library. `XP.init()` fills it. The server also adds a `device-type--mobile`, `device-type--tablet` or `device-type--pc` class to `body`. See [User Device Detection](Essentials/User%20Device%20Detection.md).

### XP.device_detect properties

Description:

The properties hold the parsed user agent.

Syntax:

```jsx
const { browser, os, device } = XP.device_detect;
if (device.type === 'mobile') {
    // compact layout
}
```

**Return Value:**

- **`ua`**: The user agent string.
- **`browser`**: `name`, `version` and `major`.
- **`cpu`**: `architecture`.
- **`device`**: `type`, `vendor` and `model`, where UAParser can tell them.
- **`engine`**: `name` and `version`.
- **`os`**: `name` and `version`.

---

### XP.device_detect.isRunningAsPWA

Description:

The **`isRunningAsPWA`** method checks whether the app runs as an installed web app (display mode `standalone`, `fullscreen` or `minimal-ui`). `helloworld` uses it to hide the sidebar.

Syntax:

```jsx
const is_pwa = XP.device_detect.isRunningAsPWA();
```

**Return Value:**

- **`Boolean`**: `true` when running as an installed app.

---

### XP.device_detect.attachPWAClass

Description:

The **`attachPWAClass`** method adds the `dc-pwa-mode` class to `body` when the app runs as an installed web app, and removes it otherwise. `init()` calls it.

Syntax:

```jsx
XP.device_detect.attachPWAClass();
```

**Return Value:**

- **`undefined`**

---

### XP.device_detect.init

Description:

The **`init`** method parses the user agent and fills the properties. `XP.init()` calls it.

Syntax:

```jsx
XP.device_detect.init();
```

**Return Value:**

- **`undefined`**

---

### XP.device_detect.UAParser

Description:

The **`UAParser`** method returns a new UAParser instance, for details the properties don't cover.

Syntax:

```jsx
const parser = XP.device_detect.UAParser();
```

**Return Value:**

- **`UAParser`**: A new parser for the current user agent.

---

## Forms

### readyFormData

Description:

The **`readyFormData`** method turns an object into `FormData` for a `POST` request. `File` and `Blob` values are sent as uploads. Every other value is converted to a string, so an object becomes `"[object Object]"` and `null` becomes `"null"`. `JSON.stringify` nested values yourself.

Syntax:

```jsx
const body = XP.readyFormData({
    name: this.item.name,
    tags: JSON.stringify(this.item.tags),
    photo: this.$refs.photo.files[0],
});
```

**Parameters:**

- **`data`**: An object of field names and values.

**Return Value:**

- **`FormData`**: The form data. Empty when `data` is `undefined`.

---

### resetFromData

Description:

The **`resetFromData`** method sets every field of an object to `""`. Use it to clear a form after a save.

Syntax:

```jsx
XP.resetFromData(this.form);
```

**Parameters:**

- **`inputs`**: The object to clear. It is changed in place.

**Return Value:**

- **`Object`**: The same object.

---

## Theme and service worker

`index.php` applies the theme on every page load. The setters only store the choice: it takes effect on the next page load, or when you change the `body` classes yourself.

### addCustomTheme

Description:

The **`addCustomTheme`** method adds the stored theme class to `body`. With nothing stored, it stores and adds `default-theme`.

Syntax:

```jsx
XP.addCustomTheme();
```

**Return Value:**

- **`undefined`**

---

### addDarkLightTheme

Description:

The **`addDarkLightTheme`** method adds `dark-mode` or `light-mode`, plus `dc-bg-light-ash`, to `body`. With nothing stored, it stores and applies dark mode.

Syntax:

```jsx
XP.addDarkLightTheme();
```

**Return Value:**

- **`undefined`**

---

### getSystemTheme

Description:

The **`getSystemTheme`** method returns the stored theme name.

Syntax:

```jsx
const theme = XP.getSystemTheme();
```

**Return Value:**

- **`String`**: The theme, or `'default-theme'`.

---

### setSystemTheme

Description:

The **`setSystemTheme`** method stores a theme name.

Syntax:

```jsx
XP.setSystemTheme('default-theme');
```

**Parameters:**

- **`theme`**: The theme class name.

**Return Value:**

- **`undefined`**

---

### checkDarkTheme

Description:

The **`checkDarkTheme`** method checks whether dark mode is stored.

Syntax:

```jsx
const is_dark = XP.checkDarkTheme();
```

**Return Value:**

- **`Boolean | undefined`**: `true` for dark, `false` for light, `undefined` when nothing is stored.

---

### setDarkLightTheme

Description:

The **`setDarkLightTheme`** method stores dark or light mode.

Syntax:

```jsx
XP.setDarkLightTheme(true); // dark
```

**Parameters:**

- **`value`**: `true` for dark, `false` for light.

**Return Value:**

- **`undefined`**

---

### initializeServiceWorker

Description:

The **`initializeServiceWorker`** method registers the service worker when `service_worker.enable_service_worker` in `xp-config.json` is `"true"`, and unregisters it otherwise. `index.php` calls it. It is not in the admin panel's copy. See [Service Worker](Essentials/Service%20Worker.md).

Syntax:

```jsx
XP.initializeServiceWorker();
```

**Return Value:**

- **`undefined`**
