---
sidebar_position: 2
title: App Manifest
sidebar_label: App Manifest
---

# App Manifest

# Introduction

Every app has an XML manifest in its backend folder: `api/apps/<app>/<app>.xml`. While you develop in a dev workspace, the file is `dev/<app>/backend/<app>/<app>.xml` (see [Dev Workspace](./Dev%20Workspace.md)). The file name, the folder name and `<app_name>` must all be the app's name.

The manifest is the backend contract for the app. It declares the app's identity and version, which apps may call it, its permissions, roles, notifications, options and tables, how its classes load, and what runs when it is reinitialized.

Different parts of the framework read different elements, at different times. Some are read on every request. Others take effect only when the app is reinitialized, or only when it is installed from a package.

| Element | Required | Read by | A change takes effect |
| --- | --- | --- | --- |
| `<app_register>` | Yes | App boot, `CreateAppInstance`, `checkIfAppExist` | On the next request |
| `<info>` | Yes | Admin panel Apps page, packaging, dev links | Apps page: on the next load. Versions: at package upload |
| `<app_permissions>` | Only if other apps call this one | `CreateAppInstance` | On the next call |
| `<user_permissions>` | No | Roles page, reinit, scope checks | Roles page: at once. Grants and scope checks: on reinit |
| `<admin_panel_permissions>` | No | Install and reinit | On reinit, then the admin logs in again |
| `<roles>` | No | Reinit | On reinit |
| `<user_notifications>` | No | Admin notification settings, package install | Settings list: at once. Role defaults: at package install or update |
| `<app_options>` | No | Install, reinit, option reads | Declarations: at once. New options are seeded on reinit |
| `<createTables>` | No | Install, reinit, app removal | On install or reinit |
| `<autoload>` | No | Class autoloader, app boot | On the next request |
| `<dependencies>` | No | App boot | On the next request |
| `<run>` | No | Reinit, package install | On every reinit |
| `<prerequisites>` | No | Export, package upload | At package upload |
| `<uninstallConfiguration>` | No | Nothing | Never |

The root element is `<app>`. The framework doesn't check its name, but every shipped manifest uses it.

---

# How to write a manifest

This manifest declares every element. Copy it, rename `myapp` and delete the blocks you don't need. Only `<app_register>` and `<info>` are required.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<app>
    <!-- "true" lets the app boot and be called by other apps. -->
    <app_register active="true"/>

    <!-- Identity and version. Shown on the admin panel Apps page and used by packaging. -->
    <info>
        <app_name>myapp</app_name>
        <app_author>Example Ltd</app_author>
        <display_name>My App</display_name>
        <app_version>1.0.0</app_version>
        <api_version>0.0.42</api_version>
        <app_icon>fas fa-globe-americas</app_icon>
        <app_image src="/assets/images/app_icons/app-icon.png"/>
        <app_type>custom</app_type>
        <status>active</status>
        <release_date>2026-10-05</release_date>
        <description>Orders and order notes.</description>
        <changelog>First release.</changelog>
    </info>

    <!-- Apps that may call THIS app with AppManager::CreateAppInstance('myapp'). -->
    <app_permissions>
        <permission app_name="xp_system"/>
        <permission app_name="myapp"/>
    </app_permissions>

    <!-- Actions users can be granted. "name" is the controller name. -->
    <user_permissions name="myapp">
        <category name="basic_permissions" display_name="My App">
            <permission display_name="View my app" name="view" auto_update="true"/>
            <permission display_name="Get orders" name="get_orders" auto_update="true"/>
        </category>
    </user_permissions>

    <!-- Actions for the app's admin panel pages. -->
    <admin_panel_permissions>
        <category name="basic_permissions">
            <permission display_name="View settings page" name="view" auto_update="true"/>
        </category>
    </admin_panel_permissions>

    <!-- Roles created on reinit, with their default grants. -->
    <roles>
        <role name="myapp_operator" display_name="Operator">
            <grant app="myapp" actions="*"/>
            <grant app="auth" actions="logout"/>
        </role>
    </roles>

    <!-- Notification types the app can send. -->
    <user_notifications>
        <category name="orders" display_name="Orders">
            <notification name="order_placed" display_name="Order placed" description="Sent when an order is placed" default_enabled="true">
                <email active="false"/>
                <push active="true"/>
                <sms active="false"/>
            </notification>
        </category>
    </user_notifications>

    <!-- Key-value settings stored in the myapp_options table. -->
    <app_options active="true">
        <db_table name="options"
                  name_column="name"
                  value_column="value"
                  timestamp_column="updated_at"
                  user_id_column="updated_by"/>
        <allowed_options>
            <option name="greeting" default_value="Hello"/>
        </allowed_options>
    </app_options>

    <!-- Tables, created as myapp_<name>. -->
    <createTables>
        <table name="orders">
            <column name="id" type="bigint" size="20" attributes="UNSIGNED" null="false" autoincrement="true" primarykey="true"/>
            <column name="message" type="text" null="true"/>
            <column name="status" type="int" size="5" null="true"/>
            <column name="created_date" type="datetime" null="false"/>
            <column name="created_by" type="bigint" size="20" attributes="UNSIGNED" null="true"/>
        </table>
        <table name="options">
            <column name="id" type="bigint" size="20" attributes="UNSIGNED" null="false" autoincrement="true" primarykey="true"/>
            <column name="name" type="varchar" size="255" null="false" index="true"/>
            <column name="value" type="longtext" null="true"/>
            <column name="updated_at" type="datetime" null="true"/>
            <column name="updated_by" type="bigint" size="20" attributes="UNSIGNED" null="true"/>
        </table>
    </createTables>

    <!-- Namespaced classes under DoCloud\Api\Apps\MyApp load from this folder. -->
    <autoload>
        <map namespace="MyApp" directory="."/>
    </autoload>

    <!-- Apps whose register() and boot() must run before this app's. -->
    <dependencies>
        <app name="xp_users"/>
    </dependencies>

    <!-- Runs at the end of every reinit. -->
    <run>
        <script class_name="myappRun" function_name="init" file="run.class.php"/>
    </run>

    <!-- Apps an install package expects. Shown when the package is uploaded. -->
    <prerequisites>
        <apps>
            <xp_users>
                <app_name>xp_users</app_name>
                <app_version>1.0.0</app_version>
            </xp_users>
        </apps>
    </prerequisites>

    <!-- Not read by the framework. -->
    <uninstallConfiguration>
    </uninstallConfiguration>
</app>
```

The built-in `helloworld` app has a working manifest at `api/apps/helloworld/helloworld.xml`.

---

# How to apply manifest changes

What you need to do after editing the manifest depends on the element.

**Nothing.** These are read on every request, or every time they're used, so the next request sees the change:

- `<app_register>`, `<autoload>` and `<dependencies>`
- `<app_permissions>`
- the `<info>` fields the Apps page shows
- the permission list on the Roles page, and the notification list in the admin panel's notification settings
- the `<app_options>` declarations that option reads use

**Reinitialize the app.** In the admin panel, open **Apps**, open the app and click **Reinitialize**. From code, call `AppManager::initialize_app('myapp')`. The reinit applies:

- `<createTables>`: missing tables, columns and keys are added, and changed columns are altered
- `<app_options>`: options that don't exist yet are seeded with their defaults
- `auto_update` permissions in `<user_permissions>` and `<admin_panel_permissions>`
- `<roles>`, and the checks on `<scopes>`
- `<run>`

See [initialize_app](../Modules/App%20Manager.md#initialize_app) for the exact order, and [Roles And Permissions](../Essentials/Roles%20And%20Permissions.md) for when users and admins see new grants.

**Install or update the app from a package.** These are read only when a package is installed: `<info>` version checks, `<prerequisites>`, and the default role preferences in `<user_notifications>`. See [Packaging And Updates](./Packaging%20And%20Updates.md).

<aside>
⚠️ Installing a package doesn't provision `<roles>`. Reinitialize the app after you install it.

</aside>

---

# How to let other apps call your app

`AppManager::CreateAppInstance('myapp')` returns an instance of `myapp`'s main class. The **target** app's manifest decides who may make that call. List each calling app:

```xml
<!-- api/apps/myapp/myapp.xml: these apps may call myapp -->
<app_permissions>
    <permission app_name="reports"/>
    <permission app_name="myapp"/>
</app_permissions>
```

The calling app is worked out from the call stack, so an app that calls itself through `CreateAppInstance` must list its own name too.

To let every app call yours, add `allow="all"`:

```xml
<app_permissions allow="all">
    <permission app_name="myapp"/>
</app_permissions>
```

<aside>
⚠️ An `<app_permissions>` element with no child counts as missing, even when it has `allow="all"`. Both `<app_permissions allow="all"/>` and an empty `<app_permissions allow="all"></app_permissions>` make every call fail with "Permissions not found in xml." Put at least one `<permission>` inside, as above.

</aside>

[CreateAppInstance](../Modules/App%20Manager.md#createappinstance) in App Manager covers the rest of the call.

---

# How to run code when the app is reinitialized

Use `<run>` for work that `<createTables>` can't do, such as dropping an old key or backfilling a column. Each `<script>` names a PHP file in the app's backend folder, a class in it and a static method:

```xml
<run>
    <script class_name="myappRun" function_name="init" file="run.class.php"/>
</run>
```

```php
<?php
// api/apps/myapp/run.class.php

class myappRun
{
    public static function init()
    {
        // Runs at the end of every reinit, after the tables have been converged.
        // Make it safe to run many times.
        return true;
    }
}
```

The method is called with no arguments. Return a truthy value for success. `initialize_app` reports it under `scripts_runed`.

The script runs on **every** reinit, and after every framework update that changes a system app's manifest. Write it so a second run changes nothing.

<aside>
⚠️ Name the class after your app, as in `myappRun`. Run scripts are loaded with `include_once` into the same process, and `system_admin_app` already declares a class called `run`. A second class with the same name stops the reinit with a fatal error.

</aside>

`<run>` can also hold `<sql>` entries. See the `<run>` reference below for where the file is looked up.

---

# Element reference

## app_register

```xml
<app_register active="true"/>
```

**Required.** `active="true"` registers the app. Any other value, or a missing attribute, leaves it unregistered:

- The app isn't booted: its main class gets no `register()` or `boot()` call. See [How apps boot](../Modules/App%20Manager.md).
- `AppManager::CreateAppInstance()` refuses to create it.
- `AppManager::checkIfAppExist()` returns `false`.

Read on every request.

<aside>
⚠️ `active="false"` doesn't turn off the app's API. Its controllers still load and answer `api/<app>/<action>` requests. To hide the app's pages, set `"status": "disabled"` in its [app-config.json](./App%20Frontend%20Config.md). To block the API, remove the app.

</aside>

---

## info

The app's identity. `AppManager::getAppsInfo()` returns every child of `<info>` as a string, so the admin panel's Apps page shows them as soon as you save the file. A framework or app update reads them from the package.

| Child | Required | What it does |
| --- | --- | --- |
| `<app_name>` | Yes | The app's name. Must equal the folder name. The dev workspace links, package installs and notification defaults all go by this name. |
| `<display_name>` | No | The title on the Apps page. |
| `<app_author>` | No | Shown when a package is uploaded. Defaults to "DoCloud". |
| `<app_version>` | For packages | The app's version, as numbers separated by dots. When a package is uploaded over an installed app, its version must be the same or higher, or the admin panel won't install it. |
| `<api_version>` | For packages | The lowest framework version the app supports. The admin panel won't install the package unless the framework's `api_version` in `api/config.xml` is the same or higher. |
| `<app_type>` | No | `system_app` for apps that ship with the framework. A framework update merges and reinitializes only manifests marked `system_app`. Use any other value for your own apps; `custom` is the convention. The Apps page shows it as the app's type. |
| `<status>` | No | Shown on the Apps page and kept across updates. Nothing else reads it: it doesn't disable the app. |
| `<release_date>` | No | Shown on the Apps page. |
| `<app_icon>` | No | Font Awesome class shown on the Apps page when there is no `<app_image>`. |
| `<app_image src>` | No | App icon image. `src` is relative to the frontend app folder and starts with `/`: `/assets/images/app_icons/app-icon.png` becomes `/apps/myapp/assets/images/app_icons/app-icon.png`. |
| `<description>` | No | Shown on the Apps page and when a package is uploaded. |
| `<changelog>` | No | Carried in exported packages. The admin panel doesn't show it. |

Any other child you add is returned by `getAppsInfo()` too.

The frontend config has its own `app_type` with different values (`system` or `custom`). The two are independent.

---

## app_permissions

```xml
<app_permissions allow="all">
    <permission app_name="reports"/>
</app_permissions>
```

**Required only if another app calls this one** with `AppManager::CreateAppInstance()`. It lists the apps allowed to call **this** app. It doesn't control which apps this app may call.

- **`<permission app_name>`**: an app allowed to call this one.
- **`allow="all"`**: any app may call this one.

Read on every `CreateAppInstance()` call. "How to let other apps call your app", above, has an example and the empty-block gotcha.

---

## user_permissions

```xml
<user_permissions name="myapp">
    <category name="basic_permissions" display_name="My App">
        <permission display_name="View my app" name="view" auto_update="true"/>
    </category>
</user_permissions>
```

**Optional.** The actions users can be granted on the Roles page. `name` is the controller name the actions are checked under. Each `<permission>` can set `display_name`, `info`, `auto_update` and `scopable`. A manifest can hold more than one block, one per controller.

The Roles page reads the block directly, so new actions show up at once. `auto_update="true"` grants the action to the `system_admin` role on install and on every reinit.

[Roles And Permissions](../Essentials/Roles%20And%20Permissions.md) has the full rules.

<aside>
⚠️ Keep each `name` unique across installed apps. When two manifests declare a block with the same `name`, only one of them is used: the one from the app whose folder sorts last. The other's actions disappear from the Roles page, and `<roles>` grants for them are skipped as unknown.

</aside>

---

## scopes

```xml
<user_permissions name="myapp">
    <scopes resolver="myappScopeResolver">
        <scope type="branch" display_name="Branch"/>
    </scopes>
    ...
</user_permissions>
```

**Optional**, inside a `<user_permissions>` block. Declares the scope types the block's `scopable` actions can be limited to, and the resolver class. `<scopes from="otherapp"/>` borrows another app's scopes instead. The reinit checks the declaration. See [How to scope grants](../Essentials/Roles%20And%20Permissions.md#declare-scopes).

---

## admin_panel_permissions

```xml
<admin_panel_permissions>
    <category name="basic_permissions">
        <permission display_name="View settings page" name="view" auto_update="true"/>
    </category>
</admin_panel_permissions>
```

**Optional.** Actions for the app's admin panel pages. No `name` attribute: the actions are stored under the app's folder name. `auto_update="true"` adds the action to the admin panel's permission set on install and on every reinit. Admins see the change after they log in again. See [Admin panel permissions](../Essentials/Roles%20And%20Permissions.md#admin-panel-permissions) and [Admin Pages](./Admin%20Pages.md).

---

## roles

```xml
<roles>
    <role name="myapp_operator" display_name="Operator">
        <grant app="myapp" actions="*"/>
        <grant app="auth" actions="logout"/>
    </role>
</roles>
```

**Optional.** Roles the app creates, with default grants. A `<grant app>` can be any installed app's `<user_permissions name>`. `actions` is a comma-separated list or `*`. `reach` is `global` or `scoped`.

Provisioned on every reinit, and only adds: a grant an admin revoked stays revoked. See [How to create roles from the manifest](../Essentials/Roles%20And%20Permissions.md).

---

## user_notifications

```xml
<user_notifications>
    <category name="orders" display_name="Orders">
        <notification name="order_placed" display_name="Order placed" description="Sent when an order is placed" default_enabled="true">
            <email active="false"/>
            <push active="true"/>
            <sms active="false"/>
        </notification>
    </category>
</user_notifications>
```

**Optional.** The notification types the app can send. The admin panel's notification settings read the manifests directly. The `default_enabled` role defaults are applied only when the app is installed or updated from a package, not on reinit. See [Notification](../Essentials/Notification.md).

---

## app_options

```xml
<app_options active="true">
    <db_table name="options" name_column="name" value_column="value" timestamp_column="updated_at" user_id_column="updated_by"/>
    <allowed_options>
        <option name="greeting" default_value="Hello"/>
    </allowed_options>
</app_options>
```

**Optional.** Key-value settings for the app, stored in a table you declare in `<createTables>`. Option reads use the declaration as it is in the file. Install and every reinit insert any allowed option that isn't in the table yet. See [App Options](../Essentials/App%20Options.md).

---

## createTables

```xml
<createTables charset="utf8mb4" collation="utf8mb4_unicode_ci">
    <table name="orders">
        <column name="id" type="bigint" size="20" attributes="UNSIGNED" null="false" autoincrement="true" primarykey="true"/>
        <column name="order_no" type="varchar" size="32" null="false" unique="true"/>
    </table>
</createTables>
```

**Optional.** This is how an app declares its tables. Each `<table name>` becomes `<app>_<name>`. Install creates the tables. Every reinit converges them: it adds missing tables, columns and keys, and alters changed columns. It never drops or renames anything. When an admin removes the app and ticks the option to remove its tables, the tables listed here are dropped.

[How to define your tables](../Modules/App%20Manager.md) lists every `<table>` and `<column>` attribute, and [initialize_app](../Modules/App%20Manager.md#initialize_app) covers how changes converge.

---

## autoload

```xml
<autoload>
    <map namespace="MyApp" directory="."/>
    <map namespace="MyApp\Reports" directory="src/reports"/>
</autoload>
```

**Optional.** Maps namespaces under `DoCloud\Api\Apps\` to folders in the app's backend folder. `.` is the folder itself. The first map's namespace also names the app's main class (`DoCloud\Api\Apps\MyApp\MyApp`). Without a map, the framework tries the folder name in StudlyCase, then a global class named after the folder.

Read on every request. Maps are read from every app's manifest, whatever its `<app_register>` says. See [How to autoload app classes](../Modules/App%20Manager.md).

---

## dependencies

```xml
<dependencies>
    <app name="xp_users"/>
</dependencies>
```

**Optional.** Apps whose `register()` and `boot()` must run before this app's. A missing or inactive dependency is logged and ignored. A cycle is logged and broken. Read on every request. See [How apps boot](../Modules/App%20Manager.md).

---

## run

```xml
<run>
    <script class_name="myappRun" function_name="init" file="run.class.php"/>
    <sql>myapp/cleanup</sql>
</run>
```

**Optional.** Work to do at the end of every reinit, after tables, options, permissions and roles. "How to run code when the app is reinitialized", above, has an example.

- **`<script>`**: `file` is relative to the app's backend folder. The framework includes it, checks that `class_name` has a static method `function_name`, and calls it with no arguments. If the file or class is missing, the script is skipped without an error.
- **`<sql>`**: the name of a `.sql` file, without the extension. On reinit, the name is resolved against the backend apps folder, `api/apps/`. So `myapp/cleanup` runs `api/apps/myapp/cleanup.sql`.

When a package is installed, `<run>` is read from the package instead, and the paths differ. A `<sql>` name is looked up in the package's `database/` folder. Only one `<script>` is run: with two or more, none runs at install.

<aside>
⚠️ Because install and reinit look for `<sql>` files in different places, one `<sql>` entry can't work for both unless you ship the file in both. Prefer a `<script>`, which uses the same path in both cases.

</aside>

---

## prerequisites

```xml
<prerequisites>
    <apps>
        <xp_users>
            <app_name>xp_users</app_name>
            <app_version>1.0.0</app_version>
        </xp_users>
    </apps>
</prerequisites>
```

**Optional.** The apps, and their lowest versions, that the app expects. Exporting the app copies this block into the package. When the package is uploaded, the admin panel lists each prerequisite as compatible or not: the app must be installed, at that version or higher.

The list is advice only. An unmet prerequisite doesn't block the install.

Give each prerequisite its own element name, such as the app's name. Two entries with the same element name aren't read correctly. Nothing reads this block in an installed manifest. See [Packaging And Updates](./Packaging%20And%20Updates.md).

---

## uninstallConfiguration

```xml
<uninstallConfiguration>
</uninstallConfiguration>
```

**Optional.** No code reads it in 0.0.42. Removing an app is controlled by the options the admin picks in the admin panel. You can leave the element empty or leave it out.
