---
title: App Options
sidebar_label: App Options
---

# App Options

Owner: Nuwan Danushka

# Introduction

App options are named settings that an app stores in its own database table, such as a display name or a feature flag. Each app declares its options in its XML manifest. The framework seeds their default values, and the `app_options` class reads and writes them on the backend. The frontend reads them through `XP.app_options`.

Only options listed under `<allowed_options>` can be read. Reads on the backend and on the frontend both go through that list.

<aside>
⚠️ Allowed options are public. The frontend loads them from `GET /api/system_admin_app/get_public_options`, which needs no login. It returns the allowed options of every app. Never put secrets, keys or personal data in an app option.

</aside>

All values are stored as strings. When you write `true` or `false`, the framework stores the strings `"true"` and `"false"`.

---

# How to declare options

Add an `<app_options>` block to your app's XML manifest (for example `api/apps/myapp/myapp.xml`). Also declare the options table in `<createTables>`. The framework does not create the table for you.

```xml
<app_options active="true">
    <db_table name="options"
              name_column="name"
              value_column="value"
              timestamp_column="updated_at"
              user_id_column="updated_by" />
    <allowed_options>
        <option name="display_name" default_value="My App"/>
        <option name="show_banner" default_value="false"/>
    </allowed_options>
</app_options>

<createTables>
    <table name="options">
        <column name="id" type="bigint" size="20" default="" attributes="UNSIGNED" null="false" autoincrement="true" primarykey="true" index="true"/>
        <column name="name" type="varchar" size="255" default="" attributes="" null="false" index="true"/>
        <column name="value" type="longtext" size="" default="" attributes="" null="true"/>
        <column name="updated_at" type="datetime" size="" default="" attributes="" null="true"/>
        <column name="updated_by" type="bigint" size="20" default="" attributes="UNSIGNED" null="true" index="true"/>
    </table>
</createTables>
```

- `active="true"` turns the block on. With any other value, the app's options are not read.
- `<db_table>` names the table and its columns. All five attributes are required. Write the table name without the app prefix: `options` becomes the table `myapp_options`.
- Each `<option>` in `<allowed_options>` has a `name` and an optional `default_value`.

The framework seeds the options every time the app is initialized: when it is installed, and when it is reinitialized from the admin panel. Each allowed option that is not in the table yet is inserted with its `default_value`, or an empty string. Options that already exist keep their values. You don't need a run script for this.

---

# How to read and write options on the backend

Write an option with `insert_option`. It updates the row if the option exists and inserts it if not.

```php
app_options::insert_option('myapp', 'display_name', 'Sales Portal');
app_options::insert_option('myapp', 'show_banner', true); // stored as "true"
```

Read one option with `get_option`. Pass both the app name and the option name.

```php
$display_name = app_options::get_option('myapp', 'display_name'); // "Sales Portal"
```

Read every allowed option of every app with `get_app_options`.

```php
$all = app_options::get_app_options();
$myapp_options = $all['myapp'] ?? [];
```

```php
Array
(
    [myapp] => Array
        (
            [display_name] => Sales Portal
            [show_banner] => true
        )
)
```

<aside>
💡 `insert_option` accepts any option name, but `get_option` and `get_app_options` only return names listed in `<allowed_options>`. Add a name to the list before you rely on reading it.

</aside>

---

# How to read options on the frontend

When the app starts, `XP.init()` fetches the public options and caches them in browser storage. `XP.app_options.get_option` reads from that cache.

```jsx
// One option: returns its value, or "" if it doesn't exist
const display_name = XP.app_options.get_option('myapp', 'display_name');

// All options of one app: returns an object, or "" if the app has none
const myapp_options = XP.app_options.get_option('myapp');

// Options of every app
const all_options = XP.app_options.get_option(null, null, true);
```

Compare boolean options as strings:

```jsx
const show_banner = XP.app_options.get_option('myapp', 'show_banner') === 'true';
```

<aside>
💡 The fetch is not awaited. On the first load in a browser, `get_option` can return `""` until the request finishes. After that, it returns the values cached on the previous load. A value you change on the backend reaches the frontend on the next page load. Always give a fallback, for example `XP.app_options.get_option('myapp', 'display_name') || 'My App'`.

</aside>

---

# Methods

### get_option

Description:

The **`get_option`** method returns the value of one allowed option.

Syntax:

```php
$value = app_options::get_option($app_name, $option_name);
```

**Parameters:**

- **`$app_name`**: The app name, for example `myapp`.
- **`$option_name`**: The option name.

**Return Value:**

- **`String`**: The option's value.
- **`Array`**: An empty array `[]` if the app or option is not found, or if the option is not in `<allowed_options>`. If you pass only the app name, you also get `[]`, not the app's options.

<aside>
💡 An option whose value is an empty string or `"0"` also returns `[]`. The method treats empty values as missing.

</aside>

---

### get_app_options

Description:

The **`get_app_options`** method returns the allowed options of every app whose `<app_options>` block is active.

Syntax:

```php
$options = app_options::get_app_options();
```

**Return Value:**

- **`Array`**: The options keyed by app name, then by option name. Apps with no stored options are left out.

---

### insert_option

Description:

The **`insert_option`** method sets an option's value. It updates the existing row, or inserts one, and records the time and the logged-in user in the timestamp and user ID columns.

Syntax:

```php
$result = app_options::insert_option($app_name, $option_name, $option_value);
```

**Parameters:**

- **`$app_name`**: The app name. The app must have a `<db_table>` in its `<app_options>` block.
- **`$option_name`**: The option name.
- **`$option_value`**: The value. `true` and `false` are stored as `"true"` and `"false"`.

**Return Value:**

- **`Boolean`**: `true` on success, `false` if the app has no `<db_table>` or the write fails.

---

### init_app_options

Description:

The **`init_app_options`** method inserts each allowed option that is missing from the table, using its `default_value`. The framework calls it on every app install and reinitialize, so you rarely call it yourself.

Syntax:

```php
$result = app_options::init_app_options($app_name);
```

**Parameters:**

- **`$app_name`**: The app name.

**Return Value:**

- **`Boolean`**: `true` if every option was inserted or already existed. `false` if database access is off, the table doesn't exist, a `<db_table>` attribute is missing, or `<allowed_options>` is missing.

---

### XP.app_options.get_option

Description:

The **`XP.app_options.get_option`** method reads options on the frontend from the cached public options.

Syntax:

```jsx
const value = XP.app_options.get_option(app_name, option_name, return_all);
```

**Parameters:**

- **`app_name`**: The app name.
- **`option_name`** (optional): The option name. Leave it out to get all options of the app.
- **`return_all`** (optional, default `false`): If `true` and the app name is empty or not found, returns the options of every app.

**Return Value:**

- **`String`**: The option's value, or `""` if the app, the option or the cache is missing.
- **`Object`**: The app's options when you pass only `app_name`, or every app's options when `return_all` applies.

---
