---
title: Config Handlers
sidebar_label: Config Handlers
---

# Config Handlers

Owner: Nuwan Danushka

# Introduction

DoFramework gives you four ways to read and change configuration from PHP:

| Handler | File it works on |
| --- | --- |
| `system_config` (static class) | `api/config.xml` and the active overlay `api/config.<environment>.xml` |
| `DoFrontend::DoFrontendConfigHandler()` | `xp-config.json` or `api/admin/xp-config.json` |
| `DoFrontend::DoFrontendAppConfigHandler()` | an app's `apps/<app>/app-config.json` |
| `AppManager::ConfigHandler()` | an app's backend manifest `api/apps/<app>/<app>.xml` |

The two frontend handlers work on a copy in memory. Nothing is saved until you call `commit_modification_to_config()`. `system_config` and `AppManager::ConfigHandler()` write the file on every call.

For which settings live in which file, and which keys the framework resets on every request, see [Configuration Files](./Configuration%20Files.md).

<aside>
⚠️ The frontend handlers and `AppManager::ConfigHandler()` build their paths from `$_SERVER['DOCUMENT_ROOT']`. On the command line (shell, heartbeat) that is empty, so they look in the wrong place. Use them in API requests only.

</aside>

---

# How to read backend settings

Use `system_config::get()` for a single value and `system_config::get_section()` for a whole section. Both read the active overlay, or `api/config.xml` when there is no overlay.

```php
$timezone = system_config::get('system', 'system_api_timezone');
$db_name  = system_config::get('database', 'dbname');

if (system_config::get('system', 'db_access')) {
    // "true" and "false" come back as booleans
}

$smtp = system_config::get_section('email')['smtp'] ?? [];
$smtp_host = $smtp['smtp_host'] ?? '';
```

`get()` returns an empty string when the key isn't found.

---

# How to change backend settings

All of the `set` methods write to the active overlay, `api/config.<environment>.xml`. They return `false` when that file doesn't exist.

Change one value. Note the argument order: the value comes second.

```php
system_config::set('system', 'Asia/Colombo', 'system_api_timezone');

// Nested: <database><sql><dbname>
system_config::set('database', 'myapp_db', 'sql', 'dbname');
```

Change several values at once. The array mirrors the XML. Only elements that already exist are changed, and any others are skipped without an error:

```php
system_config::set_multiple([
    'system' => [
        'system_name' => 'My App',
        'session_expire_seconds' => '28800',
    ],
    'notification' => [
        'notification_batch_size' => '50',
    ],
]);
```

Add a value that may not exist yet. `set_in_environment()` creates the section and the key if they're missing:

```php
system_config::set_in_environment('myapp', 'report_email', 'reports@example.com');
```

The settings that live in `api/config.xml` have their own methods, for example `change_system_status()`. See the reference below.

---

# How to change the frontend config

`DoFrontend::DoFrontendConfigHandler()` edits `xp-config.json` (`'app_config'`) or `api/admin/xp-config.json` (`'admin_config'`).

1. **Create the handler.** Pass the config type. The factory has no default.

    ```php
    $config_handler = DoFrontend::DoFrontendConfigHandler('app_config');
    ```

2. **Make your changes.** Each call changes the copy in memory.

    ```php
    // Add or update a top-level key
    $config_handler->manage_root_config_key('add', 'doc_title', 'My App');
    $config_handler->manage_root_config_key('add', 'support_email', 'help@example.com');

    // Send the new key to the browser
    $config_handler->modify_config_section_array_items('add', '_public', ['support_email']);

    // Remove a key you added earlier
    $config_handler->manage_root_config_key('remove', 'old_banner_text');
    ```

3. **Save.** Without this call, nothing is written.

    ```php
    $config_handler->commit_modification_to_config();
    ```

The next page load reads the new file. In the browser, `XP.getSystemConfig(":support_email:")` then returns `help@example.com`.

<aside>
⚠️ Don't use this handler to change `version`, `release_date`, `res_version`, `resources` or `_comments`. The framework resets those keys from `xp-config.json.dist` on the next request, so your change disappears. For the same reason, removing one of the template's own entries from `_public` doesn't last. Your own keys and `_public` entries are kept.

</aside>

---

# How to change an app's frontend config

`DoFrontend::DoFrontendAppConfigHandler()` edits an app's `app-config.json`: its menus, settings pages, resources and `_public` list. The file is `apps/<app>/app-config.json`, where `apps` is `<system_app_directory>`. This file isn't synced from a template, so every key can be changed.

```php
try {
    $app_config = DoFrontend::DoFrontendAppConfigHandler('myapp');

    $app_config->addMenuItem([
        'label' => 'Reports',
        'icon' => 'fas fa-chart-bar',
        'path_name' => 'myapp_reports',
        'description' => 'Monthly reports.',
        'position' => ['sidebar' => true, 'sidebar_priority' => 50, 'megabar' => true, 'megabar_priority' => 50],
        'permission' => ['name' => 'myapp', 'action' => 'view'],
    ]);

    $app_config->addSettingsItem([
        'name' => 'myapp_preferences',
        'src' => '/apps/myapp/components/settings/preferences.js',
        'icon' => 'fas fa-sliders-h',
        'label' => 'My App',
        'permission' => 'myapp_settings',
    ]);

    $app_config->addToPublic('settings');

    $app_config->commit_modification_to_config();
} catch (Exception $e) {
    // The app has no app-config.json, or the file could not be written
}
```

The `add` methods return `false` and change nothing when an item with the same `path_name` (menus) or `name` (settings) is already there. Settings items from every active app are listed by `XP.getSettings()` in the browser, as long as `settings` is in the app's `_public` list.

---

# How to change an app's backend manifest

`AppManager::ConfigHandler()` returns an `AppConfigHandler`. It edits the app's backend manifest, `api/apps/<app>/<app>.xml`: its tables, user permissions and app permissions. This is a different file from `app-config.json`.

Each method writes the file straight away. There is no commit step.

```php
$manifest = AppManager::ConfigHandler('myapp');

$manifest->addColumnToTable('myapp', [
    'name' => 'archived',
    'type' => 'int',
    'size' => '1',
    'default' => '0',
    'null' => 'false',
]);

$manifest->addUserPermission('myapp', 'basic_permissions', [
    'display_name' => 'Export reports',
    'name' => 'export',
]);
```

These methods change the XML only. They don't create tables or columns in the database. For that, see [App Manager](../Modules/App%20Manager.md).

---

# Methods reference

## system_config

### get

Description:

The **`get`** method returns one setting. By default it reads the backend config: the active overlay, or `api/config.xml` when there is no overlay. With `$from = 'frontend'` it reads a top-level key of `xp-config.json`.

Syntax:

```php
$value = system_config::get('system', 'system_api_timezone');
$title = system_config::get('app', 'doc_title', 'frontend');
```

**Parameters:**

- **`$section`**: The top-level XML section, for example `system` or `database`. For `frontend`, either `app` or `admin`.
- **`$key`**: The element name to find.
- **`$from`**: `backend` (default) or `frontend`.

**Return Value:**

- **`Boolean`**: `true` or `false` when the stored text is `true` or `false`.
- **`String`**: The value, or an empty string when it isn't found or an error was logged.
- **`Mixed`**: For `frontend`, the JSON value. An empty value (such as `""`, `0` or `[]`) comes back as an empty string.

<aside>
⚠️ The key is searched across the **whole** file, not only inside `$section`. The first element with that name wins, and the section only has to exist. Keep key names unique. Also, `get('admin', $key, 'frontend')` reads `xp-config.json`, not `api/admin/xp-config.json`. Use `DoFrontend::DoFrontendConfigHandler('admin_config')` to read the admin panel config.

</aside>

---

### get_section

Description:

The **`get_section`** method returns a whole top-level section of the active overlay (or `api/config.xml`) as an array.

Syntax:

```php
$database = system_config::get_section('database');
$host = $database['sql']['host'] ?? '';
```

**Parameters:**

- **`$section`**: The top-level section name.

**Return Value:**

- **`Array`**: The section as a nested array. Attributes appear under `@attributes`, and empty elements come back as empty arrays.
- **`String`**: An empty string when the section doesn't exist.

---

### set

Description:

The **`set`** method writes one value to the active overlay, `api/config.<environment>.xml`. It creates the element if it's missing.

Syntax:

```php
system_config::set('system', 'My App', 'system_name');
system_config::set('database', 'myapp_db', 'sql', 'dbname');
```

**Parameters:**

- **`$section`**: The top-level section.
- **`$value`**: The new value.
- **`$key`**: The element inside the section.
- **`$key2`** (optional): A child element of `$key`, for one more level of nesting.

**Return Value:**

- **`Boolean`**: `true` when written. `false` when the overlay file doesn't exist.

---

### set_multiple

Description:

The **`set_multiple`** method updates several values in the active overlay in one write. The array mirrors the XML structure. Elements that don't already exist are skipped without an error.

Syntax:

```php
system_config::set_multiple([
    'database' => ['sql' => ['host' => 'db.example.com', 'dbname' => 'myapp_db']],
    'system' => ['system_name' => 'My App'],
]);
```

**Parameters:**

- **`$changes`**: A nested array of section, element and value.

**Return Value:**

- **`Boolean`**: `true` when the overlay was written, even if no key matched. `false` when the overlay file doesn't exist.

---

### set_in_environment

Description:

The **`set_in_environment`** method sets a `<section><key>` value in the active overlay. It creates the section and the key when they're missing, which `set_multiple` doesn't do.

Syntax:

```php
$ok = system_config::set_in_environment('myapp', 'report_email', 'reports@example.com');
```

**Parameters:**

- **`$section`**: The top-level section. Created if missing.
- **`$key`**: The element inside the section. Created if missing.
- **`$value`**: The new value, as a string.

**Return Value:**

- **`Boolean`**: `true` when written. `false` when there is no environment, the overlay doesn't exist, or the write failed.

---

### change_system_status

Description:

The **`change_system_status`** method writes `<system_status>` in `api/config.xml`. `maintenance` and `down` make every API request return 503, except requests to the `system_admin_app` controller. See [Configuration Files](./Configuration%20Files.md).

Syntax:

```php
if (system_config::change_system_status('maintenance') === true) {
    // ...
}
```

**Parameters:**

- **`$status`**: `up`, `maintenance` or `down`.

**Return Value:**

- **`Boolean`**: `true` when written. `false` when `api/config.xml` doesn't exist.
- **`Null`**: When the status is not one of the three values. The error is logged, not thrown, so compare the result with `=== true`.

---

### Other system_config methods

| Method | What it does | File |
| --- | --- | --- |
| `environment()` | Returns the active environment name: `APP_CONFIG_ENV`, or `<system_environment>`. | reads `config.xml` |
| `get_system_status()` | Returns `up`, `maintenance` or `down`, or `null` if the value is missing or invalid. | reads `config.xml` |
| `get_main_config_single($section, $key)` | Like `get()`, but always reads `api/config.xml`. | reads `config.xml` |
| `set_main_config($section, $key, $value)` | Writes `<section><key>` in `api/config.xml`. Don't use it for `api_version`, `modules` or `app_modules`, which are reset from the template. | writes `config.xml` |
| `change_environment($environment)` | Writes `<system_environment>`. It doesn't check that the overlay exists. | writes `config.xml` |
| `is_installed()` | Whether `<installed_at>` marks the system as installed. | reads `config.xml` |

---

## DoFrontendConfigHandler

Create it with `DoFrontend::DoFrontendConfigHandler($config_type)`, where `$config_type` is `app_config` (`xp-config.json`) or `admin_config` (`api/admin/xp-config.json`). The constructor loads the file into memory.

### manage_root_config_key

Description:

The **`manage_root_config_key`** method adds, updates or removes a top-level key.

Syntax:

```php
$config_handler->manage_root_config_key('add', 'doc_title', 'My App');
$config_handler->manage_root_config_key('remove', 'old_banner_text');
```

**Parameters:**

- **`$action`**: `add` (add or overwrite) or `remove`.
- **`$key`**: The top-level key.
- **`$value`** (optional): The value for `add`. Any JSON-encodable value.

**Return Value:**

- **`Void`**: Throws `InvalidArgumentException` for an empty key or an unknown action.

---

### modify_config_section_array_items

Description:

The **`modify_config_section_array_items`** method adds items to, or removes items from, a top-level list of strings such as `_public`. Adding skips duplicates. A missing section is created.

Syntax:

```php
$config_handler->modify_config_section_array_items('add', '_public', ['support_email']);
$config_handler->modify_config_section_array_items('remove', '_public', ['support_email']);
```

**Parameters:**

- **`$action`**: `add` or `remove`.
- **`$section`**: The top-level key that holds the list.
- **`$items`**: An array of strings.

**Return Value:**

- **`Void`**: Throws `InvalidArgumentException` for an empty section name or an unknown action.

---

### manage_resource_in_config

Description:

The **`manage_resource_in_config`** method adds a URL to, or removes one from, `resources.scripts` or `resources.styles`.

Syntax:

```php
$config_handler->manage_resource_in_config('add', 'scripts', './assets/libs/example/example.js');
```

**Parameters:**

- **`$action`**: `add` or `remove`.
- **`$type`**: `scripts` or `styles`.
- **`$url`**: The resource URL.

**Return Value:**

- **`Void`**: Throws `InvalidArgumentException` for an unknown type or action.

<aside>
⚠️ `resources` is release-owned in both `xp-config.json` files, so this change is overwritten on the next request. Add your app's scripts and styles to its `app-config.json` instead, with `DoFrontendAppConfigHandler::addResource()`.

</aside>

---

### commit_modification_to_config

Description:

The **`commit_modification_to_config`** method writes the in-memory config back to the JSON file. Call it after your changes, or they are lost. It does nothing when the config is empty, for example because the file couldn't be read.

Syntax:

```php
$config_handler->commit_modification_to_config();
```

**Return Value:**

- **`Void`**: Throws `Exception` when the file can't be written.

---

### getConfigDataArray / setConfigDataArray

Description:

**`getConfigDataArray`** returns the in-memory config as an array, or `false` if the file couldn't be read. **`setConfigDataArray`** replaces it. Neither one writes the file.

Syntax:

```php
$config = $config_handler->getConfigDataArray();
$doc_title = $config['doc_title'] ?? '';
```

---

## DoFrontendAppConfigHandler

Create it with `DoFrontend::DoFrontendAppConfigHandler($app_name)`. The constructor throws `Exception` when `apps/<app_name>/app-config.json` doesn't exist. As with `DoFrontendConfigHandler`, call `commit_modification_to_config()` to save. `getConfigDataArray()` and `setConfigDataArray()` work the same way too.

### addMenuItem / updateMenuItem / removeMenuItem

Description:

These methods manage the `menus` list. Items are matched by `path_name`.

Syntax:

```php
$app_config->addMenuItem(['label' => 'Reports', 'path_name' => 'myapp_reports', 'icon' => 'fas fa-chart-bar']);
$app_config->updateMenuItem('myapp_reports', ['path_name' => 'myapp_reports', 'label' => 'Monthly Reports']);
$app_config->removeMenuItem('myapp_reports');
```

**Parameters:**

- **`$menu_item`** / **`$updated_item`**: The menu item. It must include `path_name`. `updateMenuItem` merges the new keys into the existing item.
- **`$path_name`**: The `path_name` of the item to update or remove.

**Return Value:**

- **`Boolean`**: `true` when the list changed. `false` when the item already exists (add) or wasn't found (update, remove). Throws `InvalidArgumentException` when `path_name` is missing.

---

### addSettingsItem / updateSettingsItem / removeSettingsItem

Description:

These methods manage the `settings` list, the pages the app adds to the Settings screen. Items are matched by `name`.

Syntax:

```php
$app_config->addSettingsItem([
    'name' => 'myapp_preferences',
    'src' => '/apps/myapp/components/settings/preferences.js',
    'icon' => 'fas fa-sliders-h',
    'label' => 'My App',
    'permission' => 'myapp_settings',
]);
$app_config->updateSettingsItem('myapp_preferences', ['name' => 'myapp_preferences', 'label' => 'Preferences']);
$app_config->removeSettingsItem('myapp_preferences');
```

**Parameters:**

- **`$settings_item`** / **`$updated_item`**: The settings item. It must include `name`. `updateSettingsItem` merges the new keys into the existing item.
- **`$name`**: The `name` of the item to update or remove.

**Return Value:**

- **`Boolean`**: `true` when the list changed, otherwise `false`. Throws `InvalidArgumentException` when `name` is missing.

---

### addResource

Description:

The **`addResource`** method adds a URL to, or removes one from, the app's `resources.scripts` or `resources.styles`. Despite its name, it also removes.

Syntax:

```php
$app_config->addResource('add', 'scripts', 'assets/reports.js');
$app_config->addResource('remove', 'styles', 'assets/old.css');
```

**Parameters:**

- **`$action`**: `add` or `remove`.
- **`$type`**: `scripts` or `styles`.
- **`$url`**: The resource URL.

**Return Value:**

- **`Void`**: Throws `InvalidArgumentException` for an unknown type or action.

---

### addToPublic / updatePublicItem / removeFromPublic

Description:

These methods manage the app's `_public` list, the keys of `app-config.json` that are sent to the browser.

Syntax:

```php
$app_config->addToPublic('settings');
$app_config->updatePublicItem('widgets', 'dashboard_widgets');
$app_config->removeFromPublic('description');
```

**Parameters:**

- **`$public_item`**: The key to add or remove.
- **`$old_item`**, **`$new_item`**: For `updatePublicItem`, the entry to replace and its replacement.

**Return Value:**

- **`Boolean`**: `true` when the list changed, otherwise `false`.

---

## AppConfigHandler

Create it with `AppManager::ConfigHandler($app_name)`. The constructor throws `Exception` when `api/apps/<app_name>/<app_name>.xml` doesn't exist. Every method below writes the file immediately.

| Method | What it does | Returns |
| --- | --- | --- |
| `addTable(array $table_data)` | Adds a `<table>` under `<createTables>`. `$table_data` needs `name` and `columns`, a list of column attribute arrays. | `false` if the table exists. Throws if `<createTables>` is missing. |
| `addColumnToTable(string $table_name, array $column_data)` | Adds a `<column>` to an existing table. `$column_data` needs `name` and `type`. `size`, `default`, `attributes` and `null` are optional. | `false` if the table is missing or the column exists. |
| `addUserPermission(string $permission_name, string $category_name, array $permission_data)` | Adds a `<permission>` with `display_name` and `name` under `<user_permissions name="...">` and its `<category>`, creating both if needed. | `false` if the permission exists. |
| `addAppPermission(string $app_name)` | Adds `<permission app_name="..."/>` under `<app_permissions>`. | `false` if it exists. Throws if `<app_permissions>` is missing. |
| `updateAppPermissionName(string $current_app_name, string $new_app_name)` | Renames an app permission. | `false` if not found. |
| `setAppPermissionsAllowAll()` | Removes every app permission and sets `allow="all"` on `<app_permissions>`. | `true` |
| `getConfigData()` | Returns the manifest as a `SimpleXMLElement`. | `SimpleXMLElement` |

```php
$manifest = AppManager::ConfigHandler('myapp');

$manifest->addTable([
    'name' => 'myapp_notes',
    'columns' => [
        ['name' => 'id', 'type' => 'bigint', 'size' => '20', 'attributes' => 'UNSIGNED', 'null' => 'false', 'autoincrement' => 'true', 'primarykey' => 'true'],
        ['name' => 'note', 'type' => 'text', 'null' => 'true'],
    ],
]);

$manifest->addAppPermission('xp_users');
```
