---
sidebar_position: 5
title: Admin Pages
sidebar_label: Admin Pages
---

# Admin Pages

# Introduction

The admin panel is a second Vue 3 single-page app, served from `/api/admin/`. Administrators use it to manage apps, users, roles, backups, updates and system settings. Your app can add its own pages to it, for example a settings screen.

The admin panel works like the main SPA: no build step, plain ES-module components, routes added with `Router.addRoute()`, and resources bundled per request. It has its own copy of the frontend runtime, though, and these differences matter when you write pages for it:

| | Main SPA (`/`) | Admin panel (`/api/admin/`) |
| --- | --- | --- |
| App folder | `apps/<app>/` | `api/admin/apps/<app>/` |
| Site config | `xp-config.json` | `api/admin/xp-config.json` (`"type": "admin_panel"`) |
| Who logs in | Users, with roles | Admins, with one shared admin permission set |
| Permissions declared in | `<user_permissions>` | `<admin_panel_permissions>` |
| Frontend check | `XP.checkPermission()` | `XP.checkAdminPermission()` |
| UI kit | `apps/xp_system/.../dc_ui_kit_registry.js` | its own copy, with fewer exports |
| Bundles | `assets/` | `api/admin/assets/` |

There is no separate admin API. Admin pages call your app's normal controllers.

The built-in `helloworld` app has a complete admin page in `api/admin/apps/helloworld/`. Copy it to start.

---

# How to add an admin page

In a dev workspace, the admin part of an app lives in `dev/<app>/adminpanel/<app>/`, and the framework links it to `api/admin/apps/<app>/` (see [Dev Workspace](./Dev%20Workspace.md)). Without a dev workspace, create `api/admin/apps/<app>/` directly.

## Create the folder

```
api/admin/apps/myapp/
    index.php           empty guard file
    app-config.json     menu entry, resources, status
    route.js            Router.addRoute(...) for each page
    service.js          fetch wrappers for your controllers
    components/         page components
    assets/             scripts.js, styles.css
```

Only the files listed under `resources` in `app-config.json` are loaded on every page. Components and `service.js` load when a route or component imports them.

## Write `app-config.json`

```json
{
    "version": "1.0.0",
    "release_date": "2026-10-05",
    "app_name": "myapp",
    "app_type": "custom",
    "status": "active",
    "description": "",

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
            "icon": "fas fa-cog",
            "path_name": "myapp",
            "description": "Settings of My App.",
            "position": { "sidebar": true, "sidebar_priority": 100, "megabar": true, "megabar_priority": 100 },
            "permission": { "name": "myapp", "action": "view_admin_settings" }
        }
    ],

    "_public": [
        "version", "release_date", "app_name", "status", "description", "menus"
    ]
}
```

- `status` must be `active`, or the admin panel doesn't load the app.
- `path_name` is the route **name** from `route.js`, not a URL.
- `menus` must be in `_public`, or the browser never sees them.
- Keep `version` and `release_date` equal to the manifest's `<app_version>` and `<release_date>` (see [Packaging And Updates](./Packaging%20And%20Updates.md)).

The keys are the same as in the main SPA's file. [App Frontend Config](./App%20Frontend%20Config.md) is the full reference.

## Register the routes in `route.js`

```jsx
const Myapp_Admin_Settings = () =>
    import("./../apps/myapp/components/myapp-settings.js");

Router.addRoute({
    path: "/myapp",
    name: "myapp",
    component: Myapp_Admin_Settings,
    meta: {
        title: "My App",
        requiresAuth: true,
        permissions: {
            name: "myapp",
            action: "view_admin_settings",
        },
    },
});
```

On every navigation to a route with `requiresAuth: true`, the admin panel posts `meta.permissions` to `system_admin_app/validate_session_admin`. The server checks the admin's session. If the admin isn't logged in, the router goes to the login page. If they are logged in but don't hold the permission, it goes to the dashboard.

<aside>
⚠️ A `requiresAuth` route without `meta.permissions` can never be opened: the server reports no permission and the router always sends the admin to the dashboard.

</aside>

<aside>
⚠️ Every app's `route.js` and `assets/scripts.js` are joined into one module, `api/admin/assets/app-scripts.js`. Two apps that declare the same top-level name, such as `const Settings`, break the whole bundle with a duplicate declaration error, and the admin panel stops loading. Prefix your top-level names with the app name.

</aside>

## Write the page component

```jsx
import dc_sidebar from "../../system_admin_app/components/navigation/dc_sidebar.js";
import {DcButton} from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import {myapp_admin_services} from "../service.js";

export default {
    components: {
        dc_sidebar,
        DcButton,
    },
    data() {
        return {
            settings: null,
        };
    },
    template: `
<dc_sidebar />
<div class="dc-app-container">
    <div id="app-container">
        <div class="ac-content">
            <h1 class="m-t-0 m-b-35">My App Settings</h1>
            <DcButton @click="save">Save</DcButton>
        </div>
    </div>
</div>
`,
    methods: {
        save() {
            const form = new FormData();
            form.append("mode", "strict");
            myapp_admin_services.save_settings(form);
        },
    },
    mounted() {
        myapp_admin_services.get_settings({}).then((res) => {
            if (res.response.success) {
                this.settings = res.data;
            }
        });
    },
};
```

`dc_sidebar` is the admin panel's navigation. Include it on each page, as the built-in pages do.

## Declare the admin permissions

Declare the actions in the app's backend manifest, under `<admin_panel_permissions>`:

```xml
<admin_panel_permissions>
    <category name="basic_permissions">
        <permission display_name="View settings page" name="view_admin_settings" auto_update="true"/>
        <permission display_name="Get settings" name="get_settings" auto_update="true"/>
        <permission display_name="Save settings" name="save_settings" auto_update="true"/>
    </category>
</admin_panel_permissions>
```

Then reinitialise the app (**Apps**, open the app, **Reinitialize**) and log out of the admin panel and back in. [Roles And Permissions](../Essentials/Roles%20And%20Permissions.md#admin-panel-permissions) explains how admin permissions are stored and granted.

Open `/api/admin/` and your menu entry appears.

---

# How menu entries are shown

The admin sidebar and megabar list the `menus` of every active admin app. An entry is shown only when:

- it has a `permission` object (entries without one are never shown), and
- `XP.checkAdminPermission(permission)` returns `true`, and
- `position.sidebar` (for the sidebar) or `position.megabar` (for the megabar) is `true`.

Entries are sorted by `sidebar_priority` or `megabar_priority`, lowest first. A missing priority counts as 100.

`XP.checkAdminPermission()` reads the admin permissions stored in the browser at login. They aren't refreshed while the admin stays logged in. After any change to admin permissions, including a reinitialise that adds new ones, admins must log out and log in again to see new menu entries. See [Frontend Runtime (XP)](../Frontend%20Runtime%20%28XP%29.md) for the method.

---

# How to call your controllers

Admin pages call the same `api/<controller>/<action>` endpoints as the main SPA. Send the session cookie with `credentials: "include"`:

```jsx
const api_url = XP.getApiUrl();

export const myapp_admin_services = {
    get_settings: async function (data) {
        const response = await fetch(api_url + "/myapp/get_settings?" + new URLSearchParams(data), {
            method: "GET",
            credentials: "include",
        });
        return await response.json();
    },

    save_settings: async function (form_data) {
        const response = await fetch(api_url + "/myapp/save_settings", {
            method: "POST",
            credentials: "include",
            body: form_data,
        });
        return await response.json();
    },
};
```

Your controller doesn't need a separate check for admins. `auth::appUserPermission()` passes when either the user session or the admin session holds the action. The admin permission set is keyed by the app's folder name and the action name, so declare one `<admin_panel_permissions>` entry for each action your admin pages call, with the action's exact name:

```php
public function authenticate()
{
    return auth::appUserPermission(
        $this->getRequest()->getAction(),
        $this->getRequest()->getController(),
        array()
    );
}
```

Use `POST` for every request that changes something. Only `POST` requests are recorded in the admin activity log.

---

# How import paths resolve

- **In `route.js`.** The file runs inside the bundle `api/admin/assets/app-scripts.js`, so a dynamic `import()` resolves from `api/admin/assets/`. Write `./../apps/myapp/components/page.js`, as `helloworld` does. Don't write `/apps/myapp/...`: that is the main SPA's folder.
- **In components.** Imports resolve from the component's own URL. From `api/admin/apps/myapp/components/page.js`, `../service.js` is your service file and `../../xp_system/...` is the admin panel's `xp_system` app.

The URLs are the same in a dev workspace, because the browser only sees `/api/admin/apps/myapp/`. Keep imports bare, with no `?v=` or `?ver=`. Cache busting is done by the import map.

---

# How to use the UI kit in admin pages

The admin panel has its own copy of the DC UI kit. Import components from the admin registry:

```jsx
import {DcTable, DcPopup, DcInputField} from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Don't import from a component's own file, and don't import the main SPA's kit into admin pages.

The admin registry exports these 48 components:

| Group | Components |
| --- | --- |
| Forms | `DcInputField`, `DcTextField`, `DcPasswordField`, `DcPasswordGenerator`, `DcSelect`, `DcDropdown`, `DcCheckbox`, `DcCheckboxGroup`, `DcFormGroup`, `DcSearchField`, `DcAutoComplete`, `DcTagInput`, `DcTagDropdown`, `DcDatepicker`, `DcNativeDatePicker`, `DcFontAwesomeIconPicker`, `DcImageUploader`, `DcImageUploaderMini` |
| Actions and display | `DcButton`, `DcIconButton`, `DcLink`, `DcBoxIcon`, `DcBubbleAvatar`, `DcMediaViewer`, `DcTable`, `DcPopup` |
| Navigation | `DcTabs`, `DcCategoryTabs`, `DcNavigationDrawer`, `DcBreadcrumbs` |
| Feedback and progress | `DcLoaderBar`, `DcProgressBar`, `DcLoadMore` |
| Cards and containers | `DcCard`, `DcCardPlain`, `DcInfoPanel`, `DcBlueHeaderBar`, `DcCardBlueContainer` |
| Setup and branding | `DcConfLogo`, `DcConfDevLogo`, `DcConfFooter`, `DcConfCard`, `DcConfTimeline`, `DcConfCheckList`, `DcConfCheckListItem`, `DcConfNeedSupport`, `DcDoCloudLogo`, `DcAuthFooter` |

These main-SPA components are **not** in the admin registry: `DcActivityFeed`, `DcAjaxLoader`, `DcAjaxNotice`, `DcAppTiles`, `DcCalendarRangePicker`, `DcCollapsibleSidePanel`, `DcCommentFeed`, `DcDashboardWidget`, `DcDateRangePicker`, `DcEmptyState`, `DcPageHeader`, `DcPagination`, `DcPointList`, `DcQuickLinks`, `DcRadioGroup`, `DcSearchDropdown`, `DcSplitButton`, `DcStatGroup`, `DcToggleSwitch` and `DcTreeNavigation`.

The two copies are maintained separately, so a component with the same name can lag behind its main-SPA version. See [Vue DC UI KIT](../Vue%20DC%20UI%20KIT/Vue%20DC%20UI%20KIT.md) for the components themselves.

---

# How admin activity is logged

The admin panel keeps a log of what each admin changed. Admins read it in the Log Viewer's **Admin activity** tab. Your admin pages are covered without any extra code, as long as they use `fetch()` and `POST`.

## What is recorded

The admin panel's `xp.js` wraps `window.fetch`. Every `fetch()` to a same-origin URL under `/api/` gets the header `X-DC-Panel: admin`. The framework's `dispatch()` then records a request when it is a `POST` and either:

- the controller is `system_admin_app` (apart from a few read-only actions such as `validate_session_admin`), or
- the request has the `X-DC-Panel: admin` header and an admin session is active.

These are **not** recorded:

- `GET` requests, even ones that change data.
- Requests made with `XMLHttpRequest` or jQuery, which don't get the header.
- Calls to your app's endpoints from anywhere other than the admin panel, such as the main SPA or a script. The server can't tell them from normal app use.

## What an entry holds

| Field | Content |
| --- | --- |
| Time, admin | The time, and the admin's id, name and email. For a login the admin is read after the action, for a logout before it. |
| App, action | The controller and action, plus a label made from the action name (`save_settings` becomes "Save settings"). |
| Description | The line set with `AdminActivity::describe()`, if any. |
| Outcome | `success` or `failed` from the response's `success` flag. `denied` when `authenticate()` refused the request. `failed` when an exception was thrown. `unknown` when the response wasn't the framework's JSON. |
| Status message | The response's `statusMsg`, up to 255 characters. |
| IP, browser | The client IP and user agent. |
| Request fields | The request data as JSON, with uploaded files listed by name under `_files`. Over 4096 bytes, only the field names are kept. |

Fields whose key looks secret are stored as `***`, at any depth, including inside JSON strings. A key is secret when one of its parts (split on `_`, `-` and camelCase) is `pass`, `password`, `passwd`, `pwd`, `secret` or `token`, or when it has more than one part and the last is `key` (`api_key`, `apiKey`). Name your fields so that secrets match these rules.

Entries are kept for `logs/admin_activity_retention_days` days, 365 by default, set on **Settings > Logs**. Older entries are deleted each time a new one is written.

## Add context to an entry

Call `AdminActivity::describe()` in the action to say what was changed:

```php
private function save_settings()
{
    $data = $this->getRequest()->getData();
    AdminActivity::describe('Mode: ' . ($data['mode'] ?? ''));

    // ... save, then send the response
}
```

Call it once you have read the input. The line is stored whatever the outcome.

---

# Methods

### AdminActivity::describe

Description:

The **`describe`** method adds a one-line description to the admin activity entry of the current request. If the request isn't recorded (for example a `GET`, or a request without the admin header), the call does nothing. A second call replaces the first.

Syntax:

```php
AdminActivity::describe("Role: $role_name");
```

**Parameters:**

- **`$line`**: The description. Leading and trailing spaces are trimmed, and text over 255 characters is cut to 254 plus `…`.

**Return Value:**

- **`void`**: Nothing.

---

For `XP.checkAdminPermission()`, see [Roles And Permissions](../Essentials/Roles%20And%20Permissions.md).
