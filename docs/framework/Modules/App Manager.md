---
title: App Manager
sidebar_label: App Manager
---

# App Manager

Owner: Nuwan Danushka

# Introduction

The App Manager module is how an app talks to the framework about itself: its tables, its manifest (`<app>.xml`) and the other apps it depends on. It has three classes:

- **`AppManager`**: static methods. Table helpers, schema install and reinit, app discovery, and calls into other apps.
- **`AppManagerDatabaseFunctions`**: lower-level schema functions (create a table, add or change a column, add keys). These are instance methods. Get an instance with `AppManager::DBFunctions()`.
- **`AppConfigHandler`**: edits an app's manifest file. Get one with `AppManager::ConfigHandler($app_name)`.

Two rules apply to every `AppManager` table helper:

- **Table names are prefixed with the calling app's name.** `AppManager::insertInToTable('orders', …)` called from a file under `api/apps/myapp/` writes to `myapp_orders`. The app is worked out from the call stack: it's the nearest file under the apps directory. Code that runs outside an app folder gets no app name, and the table becomes `_orders`.
- **They use the current session's database.** In a multi-tenant setup this is the tenant database. Call `AppManager::useCoreDatabase()` to switch the helpers to the database in the config file, and `AppManager::revertToDefaultDatabaseState()` to switch back.

`AppManagerDatabaseFunctions` methods don't add a prefix. Pass them the full table name, such as `myapp_orders`.

<aside>
⚠️ Several helpers paste their WHERE values straight into the SQL string: `getRecordsFromTable`, `getRecordFromTable`, `getRecordsLimited`, `getRecordCount`, `deleteFromTable`, `deleteFromTableMultipleWhere`, `getRecordsFromMetaTable`, `deleteMetaTableRecords`, `deleteMetaTableValue`, `selectLikeFromTable`, `customSelectQuery` and `customSelectQuerySingle`. Column and table names are pasted in by every helper. Never pass user input to these helpers. For anything a user can influence, write a DAO that extends `database` and uses bound parameters (see "How to query your app's tables").

</aside>

---

# How to define your tables

Declare tables in the `<createTables>` block of your manifest, `api/apps/myapp/myapp.xml`. The framework creates them when the app is installed and converges them on every reinit.

An app can keep its schema in migration files instead, and new apps should. As soon as an app has one migration, its `<createTables>` is ignored. See [Database Migrations](../Building%20Apps/Database%20Migrations.md).

```xml
<createTables charset="utf8mb4" collation="utf8mb4_unicode_ci">
    <table name="orders">
        <column name="id" type="bigint" size="20" attributes="UNSIGNED" null="false" autoincrement="true" primarykey="true"/>
        <column name="order_no" type="varchar" size="32" null="false" unique="true"/>
        <column name="customer_id" type="bigint" size="20" attributes="UNSIGNED" null="false" index="true"/>
        <column name="status" type="enum" values="'draft','placed','cancelled'" size="'draft','placed','cancelled'" default="draft" null="false"/>
        <column name="total" type="decimal" size="12,2" default="0" null="false"/>
        <column name="note" type="text" null="true" charset="utf8mb4" collation="utf8mb4_bin"/>
        <column name="created_at" type="timestamp" default="CURRENT_TIMESTAMP" null="false"/>
        <column name="updated_at" type="timestamp" default="CURRENT_TIMESTAMP" on_update="CURRENT_TIMESTAMP" null="false"/>
        <unique name="customer_order" columns="customer_id,order_no"/>
    </table>
    <table name="order_meta" collation="utf8mb4_general_ci">
        <column name="id" type="bigint" size="20" attributes="UNSIGNED" null="false" autoincrement="true" primarykey="true"/>
        <column name="order_id" type="bigint" size="20" attributes="UNSIGNED" null="false" index="true"/>
        <column name="meta_key" type="varchar" size="255" null="false"/>
        <column name="meta_value" type="longtext" null="true"/>
        <column name="created_at" type="datetime" null="true"/>
        <column name="created_by" type="bigint" size="20" attributes="UNSIGNED" null="true"/>
        <column name="updated_at" type="datetime" null="true"/>
        <column name="updated_by" type="bigint" size="20" attributes="UNSIGNED" null="true"/>
        <unique name="order_meta_key" columns="order_id,meta_key"/>
    </table>
</createTables>
```

This creates `myapp_orders` and `myapp_order_meta`.

`<createTables>` and `<table>` attributes:

| Attribute | On | Meaning |
| --- | --- | --- |
| `charset`, `collation` | `<createTables>` | Default table charset and collation for every table. |
| `name` | `<table>` | Table name without the app prefix. Required. |
| `charset`, `collation` | `<table>` | Override the defaults for this table. |

`<column>` attributes:

| Attribute | Meaning |
| --- | --- |
| `name` | Column name. Required. |
| `type` | SQL type: `bigint`, `varchar`, `text`, `decimal`, `enum`, `timestamp` and so on. Required. |
| `size` | Goes in brackets after the type: `255`, `12,2`. |
| `values` | Enum value list, used by the install path. See the enum note below. |
| `attributes` | Raw text placed after the type, such as `UNSIGNED`. |
| `null` | `true` allows NULL. Anything else means `NOT NULL`. Always set it, see the note below. |
| `default` | Default value. Numbers, `CURRENT_TIMESTAMP`, `TRUE`, `FALSE` and `NULL` go in unquoted. Anything else is quoted. |
| `on_update` | Raw `ON UPDATE` expression, usually `CURRENT_TIMESTAMP`. |
| `autoincrement` | `true` adds `AUTO_INCREMENT`. |
| `primarykey` | `true` makes this the primary key. One column only. If several columns set it, the last one wins. |
| `unique` | `true` adds a unique key named `<column>_unique`. |
| `index` | `true` adds an index named `<column>_index`. |
| `charset`, `collation` | Column charset and collation. Leave out to inherit from the table. |

`<unique name="…" columns="a,b"/>` inside a `<table>` adds a composite unique key named `<name>_unique`. With no `name`, the key is named after the columns joined by `_`.

<aside>
💡 Always set `null` explicitly. A column with no `null` attribute is created `NOT NULL`, but the reinit check reads a missing `null` as nullable, so it re-alters the column on every reinit.

</aside>

<aside>
💡 For an `enum` column, put the same quoted list in both `values` and `size`. The install path reads `values`. Reinit, `create_table`, `add_column` and `update_column` read `size`.

</aside>

---

# How to install and reinitialise an app

Installing an app from the admin panel calls `AppManager::installSchema($app_name)`. For an app with migrations, that runs every migration. Otherwise it builds every table in `<createTables>` with `generateTableFromXml()`.

Reinitialising an app (Admin panel > Apps > Reinit, or after a system update) calls `AppManager::initialize_app($app_name)`. You can also call it yourself:

```php
$result = AppManager::initialize_app('myapp');
```

`initialize_app` does this, in order:

1. Uses the app name you pass, or the calling app if you pass none.
2. Builds the schema. An app with migrations runs its pending ones (see [Database Migrations](../Building%20Apps/Database%20Migrations.md)). Any other app has the tables in `<createTables>` converged with the database. The next section has the rules.
3. Seeds the app's `<app_options>` (see [App Options](../Essentials/App%20Options.md)).
4. Registers permissions. Every permission marked `auto_update="true"` in `<user_permissions>` is added to the admin role in the app, and every one in `<admin_panel_permissions>` is added to the admin panel. This only adds: it never removes a permission an admin granted by hand.
5. Provisions the roles declared in the manifest's `<roles>` block and their default grants. This only adds. A grant an admin revoked stays revoked.
6. Downgrades role memberships whose scope no longer exists.
7. Runs the `<run>` block: each `<script class_name="…" function_name="…" file="…"/>` and `<sql>…</sql>` entry (see `runConfig`).

It returns an array with the keys `roles`, `scopes_pruned` and `scripts_runed`, plus `migrations` for an app with migrations, or `false` if an exception stops it. A failed migration doesn't stop the later steps: `migrations` holds the result, and the admin panel's Reinitialize reports `Migration <name> failed: <error>`. The array doesn't report which `<createTables>` tables or columns changed. `syncTablesFromXml` does.

---

# How schema changes converge on reinit

For each `<table>` in `<createTables>`, `initialize_app` works on `<app>_<name>`:

- **Missing table**: creates it with its columns, primary key, charset and collation, then adds its unique keys and indexes.
- **Table collation**: when the table or `<createTables>` sets a `collation` and the live table's collation differs, it runs `ALTER TABLE … DEFAULT CHARSET=… COLLATE=…`. This changes the table default only. Existing columns aren't converted.
- **Missing column**: adds it at the end of the table with `add_column`.
- **Existing column**: compares the type, `null`, default and collation with the manifest. If any of them differ, it rewrites the column with `update_column` from the full manifest definition. `AUTO_INCREMENT` on the live column is kept.
  - The type comparison is lower-case, ignores extra spaces, and strips integer display widths, so `bigint(20) unsigned` matches the `bigint unsigned` that MySQL 8.0.17+ reports. Widths on other types (`varchar(255)`, `decimal(12,2)`) are compared.
  - The default is compared only when the live column has a default. Adding a default to a column that has none isn't detected on its own.
  - The collation is compared only when the manifest sets one.
  - `on_update` and column `charset` aren't compared. They're applied when the column is added, or when one of the checks above triggers a rewrite.
- **Keys**: adds any column `unique`, table `<unique>` or column `index` key whose name doesn't exist yet.

Reinit never drops or renames anything. It doesn't drop tables, columns, indexes or unique keys. It doesn't change the primary key. A column you rename in the manifest is added as a new column, and the old one stays. To rename or remove something, move the app to [migrations](../Building%20Apps/Database%20Migrations.md), or do it yourself with a `<run>` SQL file or script.

---

# How to call another app

`AppManager::CreateAppInstance('reports')` returns a new instance of the `reports` app's main class, so your app can call its public methods.

The **target** app decides who may call it, in its own manifest:

```xml
<!-- api/apps/reports/reports.xml -->
<app_permissions>
    <permission app_name="myapp"/>
</app_permissions>
```

To let every app call it, use `allow="all"`:

```xml
<app_permissions allow="all">
</app_permissions>
```

Then, from code in `myapp`:

```php
$reports = AppManager::CreateAppInstance('reports');
if ($reports !== false) {
    $summary = $reports->monthlySummary('2026-09');
}
```

The call succeeds only when all of these hold:

- `api/apps/reports/reports.xml` exists and has `<app_register active="true"/>`.
- It has an `<app_permissions>` block that lists the calling app or has `allow="all"`. The calling app is worked out from the call stack, so make the call from a file inside your app's folder.
- The app's main class can be found (see "How apps boot").

Otherwise it logs a warning and returns `false`. An empty app name stops the request with `die()`.

<aside>
⚠️ Write `allow="all"` with an opening and a closing tag, as above. A self-closing `<app_permissions allow="all"/>` counts as an empty block, and every call is refused with "Permissions not found in xml."

</aside>

Each call builds a new object, so the app's `init()` runs again. `runCommonFuntionInApps()` uses the same permission check to call one method on every app.

---

# How to autoload app classes

Namespaced app classes live under `DoCloud\Api\Apps\`. Declare where they are with an `<autoload>` block in your manifest:

```xml
<autoload>
    <map namespace="MyApp" directory="."/>
    <map namespace="MyApp\Reports" directory="src/reports"/>
</autoload>
```

- `namespace` is added to the fixed `DoCloud\Api\Apps\` prefix. The first map above covers `DoCloud\Api\Apps\MyApp\…`.
- `directory` is relative to your app's backend folder, `api/apps/myapp/`. `.` means the folder itself.
- The longest matching prefix wins. With the maps above, `DoCloud\Api\Apps\MyApp\Reports\Monthly` loads `api/apps/myapp/src/reports/Monthly.php`.
- Sub-namespaces map to sub-folders, matched case-insensitively. The file name must match the class name exactly, plus `.php`.

Without a map, `DoCloud\Api\Apps\Foo\Bar` loads `api/apps/foo/Bar.php`. That only works when the folder name matches the namespace segment apart from case, so an app folder with underscores needs a map. Classes without a namespace still load the old way, by matching the class name against the `.php` file names in the apps directory.

---

# How apps boot

On every web, shell and heartbeat request, after the autoloaders are registered, the framework boots the active apps in two phases:

1. It reads every manifest with `<app_register active="true"/>`, along with its dependencies:

   ```xml
   <dependencies>
       <app name="reports"/>
   </dependencies>
   ```

2. It orders the apps so each app's dependencies come before it. A dependency that is missing or inactive is logged and ignored. A dependency cycle is logged and broken.
3. It creates each app's main class once. With an `<autoload>` block, the class is `<first map namespace>\<last segment>`, for example `DoCloud\Api\Apps\MyApp\MyApp`. Without one, it's the folder name in StudlyCase (`my_app` becomes `DoCloud\Api\Apps\MyApp\MyApp`). If that class doesn't exist, it falls back to a global class named after the folder, such as `class myapp`. The class must extend `App`.
4. It calls `register()` on every app, then `boot()` on every app, both in dependency order.

```php
namespace DoCloud\Api\Apps\MyApp;

class MyApp extends \App
{
    public function register(): bool
    {
        // Phase 1: set up what other apps may need from you.
        return true;
    }

    public function boot(): void
    {
        // Phase 2: every active app has run register(), so their bindings are ready.
    }

    public function init() {}

    public function search(string $search_text) {}
}
```

`register()`, `init()` and `search()` are abstract and must be implemented. `boot()` is optional. `init()` runs from the constructor, so it runs on every request and on every `CreateAppInstance` call: keep it cheap. An exception in one app's `register()` or `boot()` is logged and doesn't stop the other apps.

---

# How to query your app's tables

The helpers suit simple reads and writes with values your code controls:

```php
$id = AppManager::insertInToTable('orders', [
    'order_no'    => 'A-1001',
    'customer_id' => 42,
]);

$order = AppManager::getRecordFromTable('orders', 'id', (string) $id);
AppManager::updateTable('orders', ['status' => 'placed'], 'id', (string) $id);
```

`insertInToTable` and `updateTable` bind their values. Most read and delete helpers don't (see the warning in the Introduction).

For anything a user can influence, write a DAO that extends `database` and binds every value. Use the full, prefixed table name:

```php
class myappDAO extends database
{
    public function getOrdersForCustomer(int $customer_id): array
    {
        $this->query("SELECT * FROM myapp_orders WHERE customer_id = :customer_id ORDER BY id DESC");
        $this->bind(':customer_id', $customer_id);
        return $this->resultset();
    }
}
```

<aside>
💡 The helpers skip a WHERE value that PHP treats as empty. Passing `'0'` as the value returns or counts every row instead of the rows where the column is 0.

</aside>

---

# AppManager methods

## Table data

### insertInToTable

Description:

The **`insertInToTable`** method inserts one row. Values are bound.

Syntax:

```php
$id = AppManager::insertInToTable('orders', ['order_no' => 'A-1001', 'customer_id' => 42]);
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$data`**: Column => value array.

**Return Value:**

- **`Integer`**: The `lastInsertId`. It's `0` for a table with no auto-increment column.
- **`false`** on failure.

---

### insertMultiple

Description:

The **`insertMultiple`** method is meant to insert several rows in one call.

<aside>
⚠️ In v0.0.42 it builds one statement with a value group per row, then runs that statement once per row. Each row is inserted once for every row in the batch: three rows give nine. Call `insertInToTable` in a loop, or use a DAO, until this is fixed.

</aside>

Syntax:

```php
$id = AppManager::insertMultiple('orders', [
    'column' => ['order_no', 'customer_id'],
    'data'   => [
        ['order_no' => 'A-1001', 'customer_id' => 42],
        ['order_no' => 'A-1002', 'customer_id' => 43],
    ],
]);
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$dataArray`**: `column` is the column list. `data` is a list of column => value rows.

**Return Value:**

- **`Integer`**: The `lastInsertId`.
- **`false`** on failure.

---

### updateTable

Description:

The **`updateTable`** method updates the rows where one column equals a value. Values are bound.

Syntax:

```php
$ok = AppManager::updateTable('orders', ['status' => 'placed'], 'id', '15');
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$data`**: Column => new value array.
- **`$where_column_name`**: Column for the WHERE clause.
- **`$where_value`**: Value to match.

**Return Value:**

- **`Boolean`**: `true` if the statement ran, even when no row matched.

---

### getRecordsFromTable

Description:

The **`getRecordsFromTable`** method returns rows, optionally filtered by one column and sorted.

<aside>
⚠️ Don't combine a WHERE pair with `$orderby`. The method puts the `ORDER BY` after the `;` that ends the SELECT, so the sort isn't applied.

</aside>

Syntax:

```php
$rows = AppManager::getRecordsFromTable('orders', 'customer_id', '42', ['id', 'order_no'], false, null, true);
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$where_column_name`**, **`$where_value`** (optional): Filter. Both must be non-empty. The value isn't bound.
- **`$columns`** (optional): Columns to return. Default all.
- **`$distinct`** (optional): `true` for `SELECT DISTINCT`.
- **`$orderby`** (optional): Column to sort by.
- **`$latestrecord`** (optional): `true` (default) sorts `DESC`, `false` sorts `ASC`.

**Return Value:**

- **`Array`**: List of rows.
- **`false`** when there are no rows or on error.

---

### getRecordFromTable

Description:

The **`getRecordFromTable`** method returns the first matching row.

Syntax:

```php
$row = AppManager::getRecordFromTable('orders', 'id', '15');
```

**Parameters:**

- Same as the first five parameters of `getRecordsFromTable`. The value isn't bound.

**Return Value:**

- **`Array`**: One row.
- **`false`** when there's no row or on error.

---

### getRecordsLimited

Description:

The **`getRecordsLimited`** method returns one page of rows. Note the order of the WHERE parameters: value first, then column.

<aside>
⚠️ In v0.0.42 the WHERE clause is missing its closing quote, so any call with a WHERE pair fails and returns `false`. Calls without a filter work.

</aside>

Syntax:

```php
$rows = AppManager::getRecordsLimited('orders', 2, 25, null, null, null, 'id', true);
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$page`**: Page number, starting at 1.
- **`$records_per_page`**: Rows per page.
- **`$where_value`**, **`$where_column_name`** (optional): Filter. Broken, see above.
- **`$columns`** (optional): Columns to return.
- **`$orderby`** (optional): Column to sort by.
- **`$latestrecord`** (optional): `true` (default) for `DESC`.

**Return Value:**

- **`Array`**: List of rows.
- **`false`** when there are no rows or on error.

---

### getRecordCount

Description:

The **`getRecordCount`** method counts rows, optionally where one column equals a value.

Syntax:

```php
$count = AppManager::getRecordCount('orders', 'status', 'placed')['count'];
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$where_column`**, **`$where_value`** (optional): Filter. The value isn't bound.

**Return Value:**

- **`Array`**: `['count' => n]`.
- **`false`** on error.

---

### selectLikeFromTable

Description:

The **`selectLikeFromTable`** method returns rows where a column matches a `LIKE` pattern. Include the `%` wildcards yourself. The pattern isn't bound.

Syntax:

```php
$rows = AppManager::selectLikeFromTable('orders', 'order_no', 'A-10%');
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$where`**: Column to search.
- **`$like`**: Pattern.
- **`$columns`** (optional): Columns to return.
- **`$distinct`** (optional): `true` for `SELECT DISTINCT`.

**Return Value:**

- **`Array`**: List of rows.
- **`false`** when there are no rows or on error.

---

### customSelectQuery

Description:

The **`customSelectQuery`** method runs `SELECT <select> FROM <app>_<table> <join> WHERE <where>` with the fragments you pass. Only the main table is prefixed. Name joined tables in full.

<aside>
⚠️ The fragments are HTML-escaped before use, so `<`, `>` and `&` become `&lt;`, `&gt;` and `&amp;` and the query fails. Use `BETWEEN`, or a DAO, for range conditions.

</aside>

Syntax:

```php
$rows = AppManager::customSelectQuery('orders', 'id, order_no', "status = 'placed'", null, false);
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$select`**: Column list.
- **`$where`** (optional): WHERE condition, without the keyword.
- **`$join`** (optional): JOIN clause.
- **`$getSingle`** (optional): `true` returns only the first row.

**Return Value:**

- **`Array`**: Rows, or one row with `$getSingle`.
- **`false`** when there are no rows or on error.

---

### customSelectQuerySingle

Description:

The **`customSelectQuerySingle`** method is `customSelectQuery` with `$getSingle` set to `true`.

Syntax:

```php
$row = AppManager::customSelectQuerySingle('orders', 'MAX(total) AS top');
```

**Parameters:**

- **`$tableName`**, **`$select`**, **`$where`**, **`$join`**: As for `customSelectQuery`.

**Return Value:**

- **`Array`**: One row.
- **`false`** when there's no row or on error.

---

### deleteFromTable

Description:

The **`deleteFromTable`** method deletes the rows where one column equals a value. The value isn't bound.

Syntax:

```php
$ok = AppManager::deleteFromTable('orders', 'id', '15');
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$where_column_name`**: Column to match.
- **`$where_value`**: Value to match.

**Return Value:**

- **`Boolean`**: `true` if the statement ran.

---

### deleteFromTableMultipleWhere

Description:

The **`deleteFromTableMultipleWhere`** method deletes rows that match every column => value pair (joined with `AND`). Values aren't bound. An empty array makes the query fail.

Syntax:

```php
$ok = AppManager::deleteFromTableMultipleWhere('order_meta', ['order_id' => '15', 'meta_key' => 'gift_note']);
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$where_columns_n_values`**: Column => value array.

**Return Value:**

- **`Boolean`**: `true` if the statement ran.

---

### checkRecordExistById

Description:

The **`checkRecordExistById`** method checks for a row by its `id` column.

Syntax:

```php
$exists = AppManager::checkRecordExistById('orders', 15) === 1;
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$id`**: The id.

**Return Value:**

- **`Integer`**: `1` if the row exists, `0` if not.
- **`false`** on error.

---

### checkRecordExistByIdnKey

Description:

The **`checkRecordExistByIdnKey`** method checks for a row by `id` plus one other column. Both values are bound.

Syntax:

```php
$exists = AppManager::checkRecordExistByIdnKey('orders', 15, 'customer_id', '42');
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$id`**: The id.
- **`$keyColumn`**, **`$keyValue`**: Second column and its value.

**Return Value:**

- **`Integer`**: `1` or `0`.
- **`false`** on error.

---

### checkRecordExistByColumnnValue

Description:

The **`checkRecordExistByColumnnValue`** method checks whether a row exists where `$name_column` equals `$option_name` (bound). With `$check_value`, it also requires `$value_column` to be not NULL. An empty string still counts as a value.

Syntax:

```php
$has = AppManager::checkRecordExistByColumnnValue('settings', 'option_name', 'currency', true, 'option_value');
```

**Parameters:**

- **`$table_name`**: Table name without the prefix.
- **`$name_column`**: Column to match.
- **`$option_name`**: Value to match.
- **`$check_value`** (optional): `true` to also check `$value_column`.
- **`$value_column`** (optional): Column that must hold a value.

**Return Value:**

- **`Boolean`**: `true` if a row matches.

---

### getNextAutoIncrementID

Description:

The **`getNextAutoIncrementID`** method is meant to return a table's next `AUTO_INCREMENT` value. It doesn't add the app prefix and it reads the database named in the config file.

<aside>
⚠️ In v0.0.42 it throws a `TypeError` whenever the table exists, because it returns the result row where its signature promises an integer. Don't use it.

</aside>

Syntax:

```php
$next = AppManager::getNextAutoIncrementID('myapp_orders');
```

**Parameters:**

- **`$table_name`**: Full table name.

**Return Value:**

- **`false`** if the table isn't found. Otherwise it throws, see above.

---

## Meta tables

Meta tables store key/value rows against a parent record: a parent id column, `meta_key` and `meta_value`. `order_meta` in the XML example is one.

### insertIntoMetaTable

Description:

The **`insertIntoMetaTable`** method inserts one row per key in `$dataToInsert`. Values are bound. It doesn't check for existing keys: use `updateMetaTable` to upsert.

Syntax:

```php
$ok = AppManager::insertIntoMetaTable('order_meta', 'order_id', '15', ['gift_note' => 'Happy birthday', 'channel' => 'web']);
```

**Parameters:**

- **`$tableName`**: Meta table name without the prefix.
- **`$uniqueColumn`**: Parent id column.
- **`$uniqueValue`**: Parent id.
- **`$dataToInsert`**: meta_key => meta_value array.

**Return Value:**

- **`Boolean`**: `true` on success.

---

### getRecordsFromMetaTable

Description:

The **`getRecordsFromMetaTable`** method returns every key for one parent. The parent id isn't bound.

Syntax:

```php
$meta = AppManager::getRecordsFromMetaTable('order_meta', 'order_id', '15');
// ['gift_note' => 'Happy birthday', 'channel' => 'web']
```

**Parameters:**

- **`$tableName`**, **`$uniqueColumn`**, **`$uniqueValue`**: As for `insertIntoMetaTable`.

**Return Value:**

- **`Array`**: meta_key => meta_value.
- **`false`** when there are no rows or on error.

---

### updateMetaTable

Description:

The **`updateMetaTable`** method sets one key for one parent: it updates the row if the key exists and inserts it if not. Values are bound.

The table must have `updated_by` and `created_by` columns. The method always writes `$modifier` to `updated_by` on update and to `created_by` on insert. When you pass `$current_datetime`, it also writes `updated_at` on update and `created_at` on insert.

Syntax:

```php
$ok = AppManager::updateMetaTable('order_meta', 'order_id', '15', 'gift_note', 'Congrats', $now, $user_id);
```

**Parameters:**

- **`$tableName`**, **`$uniqueColumn`**, **`$uniqueValue`**: As for `insertIntoMetaTable`.
- **`$meta_key_column`**: The meta key.
- **`$updating_value`**: The new value.
- **`$current_datetime`** (optional): Timestamp for `updated_at`/`created_at`.
- **`$modifier`** (optional, `int`, default `0`): User id for `updated_by`/`created_by`.

**Return Value:**

- **`Boolean`**: `true` on success.

---

### deleteMetaTableRecords

Description:

The **`deleteMetaTableRecords`** method deletes every key for one parent. The parent id isn't bound.

Syntax:

```php
$ok = AppManager::deleteMetaTableRecords('order_meta', 'order_id', '15');
```

**Parameters:**

- **`$tableName`**, **`$uniqueColumn`**, **`$uniqueValue`**: As for `insertIntoMetaTable`.

**Return Value:**

- **`Boolean`**: `true` if the statement ran.

---

### deleteMetaTableValue

Description:

The **`deleteMetaTableValue`** method deletes one key for one parent. Neither value is bound.

Syntax:

```php
$ok = AppManager::deleteMetaTableValue('order_meta', 'order_id', '15', 'gift_note');
```

**Parameters:**

- **`$tableName`**, **`$uniqueColumn`**, **`$uniqueValue`**: As for `insertIntoMetaTable`.
- **`$meta_key_column`**: The meta key to delete.

**Return Value:**

- **`Boolean`**: `true` if the statement ran.

---

## Table structure

### createTable

Description:

The **`createTable`** method runs `CREATE TABLE IF NOT EXISTS <app>_<name>` from a column => definition array. Prefer `<createTables>`, which reinit keeps in step.

Syntax:

```php
$ok = AppManager::createTable('audit', [
    'id'      => 'bigint UNSIGNED NOT NULL AUTO_INCREMENT',
    'message' => 'text NULL',
], 'id');
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.
- **`$ColumnAndDataType`**: Column => SQL definition.
- **`$primaryKey`** (optional): Primary key column.

**Return Value:**

- **`Boolean`**: `true` on success.

---

### addPrimaryKeyToTable

Description:

The **`addPrimaryKeyToTable`** method adds a primary key to a table.

Syntax:

```php
$ok = AppManager::addPrimaryKeyToTable('audit', 'id');
```

**Parameters:**

- **`$table`**: Table name without the prefix.
- **`$primary_key_column`**: Column, or comma-separated columns.

**Return Value:**

- **`Boolean`**: `true` on success.

---

### emptyTable

Description:

The **`emptyTable`** method truncates a table, which also resets its auto-increment counter.

Syntax:

```php
$ok = AppManager::emptyTable('audit');
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.

**Return Value:**

- **`Boolean`**: `true` if the statement ran.

---

### dropTable

Description:

The **`dropTable`** method drops a table. If it's still in `<createTables>`, the next reinit creates it again.

Syntax:

```php
$ok = AppManager::dropTable('audit');
```

**Parameters:**

- **`$tableName`**: Table name without the prefix.

**Return Value:**

- **`Boolean`**: `true` on success.

---

## Schema and install

### initialize_app

Description:

The **`initialize_app`** method reinitialises an app. See "How to install and reinitialise an app" for the steps.

Syntax:

```php
$result = AppManager::initialize_app('myapp');
```

**Parameters:**

- **`$app_name`** (optional): App name. Default is the calling app.

**Return Value:**

- **`Array`**: Keys `roles`, `scopes_pruned` and `scripts_runed`, and `migrations` (the run's result: `ran`, `failed`, `error`, `skipped`, `warnings`) for an app with migrations.
- **`false`** if an exception stops it.

---

### installSchema

Description:

The **`installSchema`** method builds an app's tables at install time. An app with migrations runs them all. Any other app gets its `<createTables>` tables, through `generateTableFromXml`.

Syntax:

```php
$ok = AppManager::installSchema('myapp');
```

**Parameters:**

- **`$app_name`**: App name.

**Return Value:**

- **`Boolean`**: For an app with migrations, `false` when a migration failed. For any other app, `false` when it has no tables to build, and `true` otherwise, even if some tables failed: check the log, or call `generateTableFromXml` for per-table results.

---

### syncTablesFromXml

Description:

The **`syncTablesFromXml`** method runs only the table step of `initialize_app` for an app on `<createTables>`: it creates missing tables and converges columns, keys and collation, as described in "How schema changes converge on reinit". It doesn't seed options, register permissions, provision roles or run `<run>`. It compares `SHOW CREATE TABLE` before and after to report what changed. The admin panel's **Sync tables** action calls it.

Syntax:

```php
$report = AppManager::syncTablesFromXml('myapp');
// ['created' => [], 'changed' => ['myapp_orders'], 'unchanged' => ['myapp_order_meta'], 'missing' => []]
```

**Parameters:**

- **`$app_name`**: App name.

**Return Value:**

- **`Array`**: Full table names under `created`, `changed`, `unchanged` and `missing` (declared, but still not there afterwards). A change to only the `AUTO_INCREMENT` counter doesn't count.

---

### generateTableFromXml

Description:

The **`generateTableFromXml`** method runs `CREATE TABLE IF NOT EXISTS` for each `<table>` in `api/apps/<app>/<app>.xml`, with keys, charset and collation, then creates each column `index`.

Use it for a first install. For existing tables use `initialize_app`: the `CREATE INDEX` step fails on a table that already has the index, and that table is reported as `false`.

Syntax:

```php
$results = AppManager::generateTableFromXml('myapp');
// ['orders' => true, 'order_meta' => true]
```

**Parameters:**

- **`$app_name`**: App name. Required.

**Return Value:**

- **`Array`**: Table name => `true` or `false`.
- **`false`** if the manifest is missing or has no tables.

---

### createTablesfromxml

Description:

The **`createTablesfromxml`** method calls `generateTableFromXml` for the calling app and discards the result.

Syntax:

```php
AppManager::createTablesfromxml();
```

**Return Value:**

- None.

---

### get_tables_from_xml

Description:

The **`get_tables_from_xml`** method returns the `<createTables>` element of an app's manifest.

Syntax:

```php
$tables = AppManager::get_tables_from_xml('myapp');
foreach ($tables->table as $table) {
    echo (string) $table['name'];
}
```

**Parameters:**

- **`$app_name`** (optional): App name. Default is the calling app.

**Return Value:**

- **`SimpleXMLElement`**: The `<createTables>` element.
- **`false`** if the manifest doesn't exist.

---

### getTableNames

Description:

The **`getTableNames`** method lists the table names in an app's `<createTables>`, without the prefix.

Syntax:

```php
$names = AppManager::getTableNames('myapp'); // ['orders', 'order_meta']
```

**Parameters:**

- **`$app_name`** (optional): App name. Default is the calling app.

**Return Value:**

- **`Array`**: Table names. Empty if none.

---

### DBFunctions

Description:

The **`DBFunctions`** method returns a new `AppManagerDatabaseFunctions` object.

Syntax:

```php
$db = AppManager::DBFunctions();
```

**Return Value:**

- **`AppManagerDatabaseFunctions`**

---

### ConfigHandler

Description:

The **`ConfigHandler`** method returns an `AppConfigHandler` for an app's manifest.

Syntax:

```php
$config = AppManager::ConfigHandler('myapp');
```

**Parameters:**

- **`$app_name`**: App name.

**Return Value:**

- **`AppConfigHandler`**. Throws an `Exception` if the manifest doesn't exist.

---

### useCoreDatabase

Description:

The **`useCoreDatabase`** method switches the `AppManager` table helpers from the session database to the database in the config file for the rest of the request, or until you call `revertToDefaultDatabaseState`. `AppManagerDatabaseFunctions` and your DAOs aren't affected.

Syntax:

```php
AppManager::useCoreDatabase();
try {
    $rows = AppManager::getRecordsFromTable('settings');
} finally {
    AppManager::revertToDefaultDatabaseState();
}
```

**Return Value:**

- None.

---

### revertToDefaultDatabaseState

Description:

The **`revertToDefaultDatabaseState`** method switches the helpers back to the session database.

Syntax:

```php
AppManager::revertToDefaultDatabaseState();
```

**Return Value:**

- None.

---

### isUsingMainDatabase

Description:

The **`isUsingMainDatabase`** method tells you whether `useCoreDatabase` is in effect.

Syntax:

```php
$core = AppManager::isUsingMainDatabase();
```

**Return Value:**

- **`Boolean`**

---

## Apps and manifests

### CreateAppInstance

Description:

The **`CreateAppInstance`** method returns a new instance of another app's main class, if that app allows the calling app. See "How to call another app".

Syntax:

```php
$reports = AppManager::CreateAppInstance('reports');
```

**Parameters:**

- **`$AppName`**: Target app's folder name.

**Return Value:**

- **`Object`**: The app instance.
- **`false`** if the app is missing, inactive, has no `<app_permissions>`, doesn't allow the caller, or has no main class.

---

### runCommonFuntionInApps

Description:

The **`runCommonFuntionInApps`** method calls one method on every app that lets the calling app in (through `CreateAppInstance`) and that has the method. Apps that refuse the caller log a warning and are skipped.

Syntax:

```php
$results = AppManager::runCommonFuntionInApps('dashboardWidgets', ['user_id' => 7]);
```

**Parameters:**

- **`$function_name`**: Method name.
- **`$params`**: Passed to the method as its one argument.

**Return Value:**

- **`Array`**: App name => return value, for each app whose method returned something other than `null`.

---

### getAppPermission

Description:

The **`getAppPermission`** method lists the apps named in an app's `<app_permissions>`, that is, the apps allowed to call it. It doesn't report `allow="all"`.

Syntax:

```php
$callers = AppManager::getAppPermission('reports'); // ['myapp']
```

**Parameters:**

- **`$app_name`**: App name.

**Return Value:**

- **`Array`**: App names.
- **`false`** if the manifest doesn't exist.

---

### checkIfAppExist

Description:

The **`checkIfAppExist`** method checks that an app's folder, `<app>.xml` and `<app>.class.php` exist and that the app is active. An app whose main class is only a namespaced file, such as `MyApp.php`, returns `false`.

Syntax:

```php
if (AppManager::checkIfAppExist('reports')) { /* … */ }
```

**Parameters:**

- **`$app_name`**: App name.

**Return Value:**

- **`Boolean`**

---

### get_current_app_name

Description:

The **`get_current_app_name`** method returns the calling app's name, the same name the table helpers use as a prefix.

Syntax:

```php
$app = AppManager::get_current_app_name(); // 'myapp'
```

**Return Value:**

- **`String`**: App folder name.
- **`null`** if the call doesn't come from an app folder.

---

### getAppsInfo

Description:

The **`getAppsInfo`** method reads the `<info>` block of every app's manifest. Each child element becomes a string. `app_image` is turned into a path under `/apps/<app>`.

Syntax:

```php
$info = AppManager::getAppsInfo();
// ['myapp' => ['app_name' => 'myapp', 'display_name' => 'My App', 'app_version' => '1.0.0', …]]
```

**Return Value:**

- **`Array`**: App name => info array. Empty if none.

---

### get_system_apps_info

Description:

The **`get_system_apps_info`** method is `getAppsInfo` filtered to apps whose `app_type` is `system_app`.

Syntax:

```php
$system_apps = AppManager::get_system_apps_info();
```

**Return Value:**

- **`Array`**: App name => info array.

---

### extract_xml_section_from_all_app_configs

Description:

The **`extract_xml_section_from_all_app_configs`** method returns one named top-level section from every app's manifest.

Syntax:

```php
$options = AppManager::extract_xml_section_from_all_app_configs('app_options');
```

**Parameters:**

- **`$section`**: Element name, such as `app_options`.

**Return Value:**

- **`Array`**: App name => `SimpleXMLElement`, for apps that have the section.

---

### getAppsUserPermissions

Description:

The **`getAppsUserPermissions`** method reads every `<user_permissions>` block in every manifest, whatever their `auto_update` setting. A manifest that doesn't parse is logged and skipped.

Syntax:

```php
$all = AppManager::getAppsUserPermissions();
// ['myapp' => ['app_info' => […], 'permission_list' => ['basic_permissions' => [[ 'name' => 'view', … ]]]]]
```

**Return Value:**

- **`Array`**: Keyed by each block's `name`. Each entry has `app_info` and `permission_list` (category => permissions), plus `scopes` when the block declares them.

---

### getAppUserPermission

Description:

The **`getAppUserPermission`** method returns only the permissions marked `auto_update="true"` in one app's `<user_permissions>` or `<admin_panel_permissions>`, as one flat list.

Syntax:

```php
$perms = AppManager::getAppUserPermission('myapp', 0);
// ['permission_list' => [['display_name' => 'View', 'name' => 'view', 'info' => '', 'auto_update' => 'true']]]
```

**Parameters:**

- **`$app_name`**: App name.
- **`$permission_type`** (optional): `0` (default) for `<user_permissions>`, `1` for `<admin_panel_permissions>`.

**Return Value:**

- **`Array`**: `['permission_list' => […]]`, or an empty array if there are none.

---

### getRegistered_apps

Description:

The **`getRegistered_apps`** method returns the `apps` section of the main system config.

Syntax:

```php
$apps = AppManager::getRegistered_apps();
```

**Return Value:**

- **`Array`**: The registered apps. Empty if there are none.

---

### register

Description:

The **`register`** method writes an app's active flag to the `apps` section of the main system config. It's unrelated to the `register()` method of the `App` class.

Syntax:

```php
AppManager::register('myapp', true);
```

**Parameters:**

- **`$app_name`**: App name.
- **`$active`**: Value to store.

**Return Value:**

- None.

---

### getAppRun

Description:

The **`getAppRun`** method returns the `<run>` element of an app's manifest.

Syntax:

```php
$run = AppManager::getAppRun('myapp');
```

**Parameters:**

- **`$app_name`** (optional): App name. Default is the calling app.

**Return Value:**

- **`SimpleXMLElement`**: The `<run>` element. It's empty if the manifest has none.
- **`false`** if the manifest doesn't exist.

---

### runConfig

Description:

The **`runConfig`** method runs the entries in an app's `<run>` block:

- `<script class_name="myappRun" function_name="init" file="run.class.php"/>` includes `api/apps/myapp/run.class.php` and calls `myappRun::init()` statically, with no arguments. A truthy return counts as success.
- `<sql>myapp/setup</sql>` runs `api/apps/myapp/setup.sql`. The path is relative to the apps directory and has no `.sql` extension.

```xml
<run>
    <script class_name="myappRun" function_name="init" file="run.class.php"/>
    <sql>myapp/setup</sql>
</run>
```

Syntax:

```php
$result = AppManager::runConfig('myapp');
```

**Parameters:**

- **`$app_name`** (optional): App name. Default is the calling app.

**Return Value:**

- **`Array`**: `script_run` => `['script_executed' => bool]` and `sql_run` => `['sql_executed' => bool]`. With several entries of one kind, only the last one's result is kept.
- **`false`** if nothing ran.

---

# AppManagerDatabaseFunctions methods

Get an instance with `AppManager::DBFunctions()`. These methods take **full** table names (`myapp_orders`) and always use the session database.

```php
$db = AppManager::DBFunctions();
if ($db->check_table_exist('myapp_orders')) {
    $db->add_index('myapp_orders', 'status');
}
```

---

### check_table_exist

Description:

The **`check_table_exist`** method checks whether a base table exists.

Syntax:

```php
$exists = $db->check_table_exist('myapp_orders');
```

**Parameters:**

- **`$table_name`**: Full table name.

**Return Value:**

- **`Boolean`**

---

### show_create_table

Description:

The **`show_create_table`** method returns a table's `SHOW CREATE TABLE` statement.

Syntax:

```php
$ddl = $db->show_create_table('myapp_orders');
```

**Parameters:**

- **`$table_name`**: Full table name.

**Return Value:**

- **`String`**: The `CREATE TABLE` statement.
- **`null`** if the table doesn't exist.

---

### create_table

Description:

The **`create_table`** method creates a table from a `<table>` element: its columns, primary key, charset and collation. It doesn't add `unique`, `index` or `<unique>` keys: call `add_unique_key` and `add_index` afterwards. It's a static method, so `AppManagerDatabaseFunctions::create_table(…)` also works.

Syntax:

```php
$tables = AppManager::get_tables_from_xml('myapp');
$db->create_table($tables->table[0], 'myapp', 'utf8mb4', 'utf8mb4_unicode_ci');
```

**Parameters:**

- **`$table`**: A `<table>` `SimpleXMLElement`.
- **`$prefix`**: App name. The table is created as `<prefix>_<name>`.
- **`$defaultCharset`** (optional): Used if the table sets no `charset`.
- **`$defaultCollation`** (optional): Used if the table sets no `collation`.

**Return Value:**

- None. Errors are logged.

---

### get_columns

Description:

The **`get_columns`** method returns `SHOW FULL COLUMNS` for a table.

Syntax:

```php
$columns = $db->get_columns('myapp_orders');
```

**Parameters:**

- **`$table_name`**: Full table name.

**Return Value:**

- **`Array`**: One row per column with `Field`, `Type`, `Collation`, `Null`, `Key`, `Default`, `Extra`, `Privileges` and `Comment`.
- **`false`** on error.

---

### get_column_info

Description:

The **`get_column_info`** method returns the `SHOW FULL COLUMNS` row for one column.

Syntax:

```php
$info = $db->get_column_info('myapp_orders', 'status');
```

**Parameters:**

- **`$table_name`**: Full table name.
- **`$column_name`**: Column name.

**Return Value:**

- **`Array`**: The column row.
- **`false`** if the column doesn't exist or on error.

---

### add_column

Description:

The **`add_column`** method adds a column at the end of a table.

Syntax:

```php
$ok = $db->add_column('myapp_orders', 'paid_at', 'datetime', null, null, null, true);
```

**Parameters:**

- **`$table_name`**: Full table name.
- **`$column_name`**: New column.
- **`$type`**: SQL type.
- **`$size`** (optional): Size, without brackets.
- **`$default`** (optional): Default value. Quoted the same way as the XML `default`.
- **`$attributes`** (optional): Raw text after the type, such as `UNSIGNED`.
- **`$nullable`** (optional): `true` for NULL. Default `false`.
- **`$on_update`** (optional): `ON UPDATE` expression.
- **`$charset`**, **`$collation`** (optional): Column charset and collation. Only letters, digits and `_` are accepted. Anything else is dropped and logged.

**Return Value:**

- **`Boolean`**: `true` on success.

---

### update_column

Description:

The **`update_column`** method rewrites a column's whole definition with `ALTER TABLE … CHANGE`, and can rename it. If the live column is `AUTO_INCREMENT`, that's kept.

Syntax:

```php
$ok = $db->update_column('myapp_orders', 'note', 'varchar', '500', null, null, true, 'customer_note');
```

**Parameters:**

- **`$table_name`**, **`$column_name`**: Table and current column name.
- **`$type`**, **`$size`**, **`$default`**, **`$attributes`**, **`$nullable`**: As for `add_column`.
- **`$new_column_name`** (optional): New name.
- **`$on_update`**, **`$charset`**, **`$collation`** (optional): As for `add_column`.

**Return Value:**

- **`Boolean`**: `true` on success.

---

### add_unique_key

Description:

The **`add_unique_key`** method adds a unique key if no unique key with that name exists in the current database. With one column the key is named `<column>_unique`. With several columns it's `<name>_unique`, or the columns joined by `_` plus `_unique`.

Syntax:

```php
$ok = $db->add_unique_key('myapp_orders', ['customer_id', 'order_no'], 'customer_order');
```

**Parameters:**

- **`$table_name`**: Full table name.
- **`$columns`**: A column name or an array of column names.
- **`$name`** (optional): Name for a multi-column key.

**Return Value:**

- **`Boolean`**: `true` if the key was added or already exists.

---

### add_index

Description:

The **`add_index`** method adds a single-column index named `<column>_index` if it doesn't exist yet.

Syntax:

```php
$ok = $db->add_index('myapp_orders', 'status');
```

**Parameters:**

- **`$table_name`**: Full table name.
- **`$column_name`**: Column.

**Return Value:**

- **`Boolean`**: `true` if the index was added or already exists.

---

### get_table_collation

Description:

The **`get_table_collation`** method returns a table's collation.

Syntax:

```php
$collation = $db->get_table_collation('myapp_orders');
```

**Parameters:**

- **`$table_name`**: Full table name.

**Return Value:**

- **`String`**: The collation.
- **`null`** if the table doesn't exist or on error.

---

### update_table_options

Description:

The **`update_table_options`** method changes a table's default charset and collation. Existing columns aren't converted.

Syntax:

```php
$ok = $db->update_table_options('myapp_orders', 'utf8mb4', 'utf8mb4_unicode_ci');
```

**Parameters:**

- **`$table_name`**: Full table name.
- **`$charset`**, **`$collation`**: New values. Only letters, digits and `_` are accepted.

**Return Value:**

- **`Boolean`**: `false` if both values are empty or invalid, or on error.

---

### compareAndUpdateColumn

Description:

The **`compareAndUpdateColumn`** method is an unfinished stub. It runs an empty query and does nothing useful. Reinit does the column comparison itself (see "How schema changes converge on reinit").

---

# AppConfigHandler methods

`AppConfigHandler` edits `api/apps/<app>/<app>.xml`. Each method writes the file straight away and reformats it. None of them touch the database: run `AppManager::initialize_app()` afterwards to apply new tables, columns or permissions.

```php
$config = AppManager::ConfigHandler('myapp');
$config->addColumnToTable('orders', ['name' => 'paid_at', 'type' => 'datetime', 'null' => 'true']);
AppManager::initialize_app('myapp');
```

---

### addTable

Description:

The **`addTable`** method adds a `<table>` to `<createTables>`. The manifest must already have a `<createTables>` element.

Syntax:

```php
$added = $config->addTable([
    'name'    => 'invoices',
    'columns' => [
        ['name' => 'id', 'type' => 'bigint', 'size' => '20', 'attributes' => 'UNSIGNED', 'null' => 'false', 'autoincrement' => 'true', 'primarykey' => 'true'],
        ['name' => 'total', 'type' => 'decimal', 'size' => '12,2', 'null' => 'false'],
    ],
]);
```

**Parameters:**

- **`$table_data`**: `name` plus `columns`, a list of column attribute arrays. Any column attribute from the table above can be used.

**Return Value:**

- **`Boolean`**: `false` if a table with that name exists. Throws `InvalidArgumentException` if `name` or `columns` is missing.

---

### addColumnToTable

Description:

The **`addColumnToTable`** method adds a `<column>` to an existing `<table>`. It writes only `name`, `type`, `size`, `default`, `attributes` and `null` (default `true`). Other attributes are ignored.

Syntax:

```php
$added = $config->addColumnToTable('orders', ['name' => 'paid_at', 'type' => 'datetime', 'null' => 'true']);
```

**Parameters:**

- **`$table_name`**: Table name without the prefix.
- **`$column_data`**: Column attributes. `name` and `type` are required.

**Return Value:**

- **`Boolean`**: `false` if the table is missing or the column exists. Throws `InvalidArgumentException` without `name` or `type`.

---

### addUserPermission

Description:

The **`addUserPermission`** method adds a permission to a `<user_permissions>` block and category, creating them if needed. It doesn't set `auto_update`, so reinit doesn't grant the new permission to the admin role.

Syntax:

```php
$added = $config->addUserPermission('myapp', 'basic_permissions', ['display_name' => 'Export orders', 'name' => 'export_orders']);
```

**Parameters:**

- **`$permission_name`**: The `<user_permissions>` block's `name`.
- **`$category_name`**: Category name.
- **`$permission_data`**: `display_name` and `name`. Both are required.

**Return Value:**

- **`Boolean`**: `false` if the permission exists.

---

### addAppPermission

Description:

The **`addAppPermission`** method adds `<permission app_name="…"/>` to `<app_permissions>`, which lets that app call this one. The manifest must already have an `<app_permissions>` element.

Syntax:

```php
$added = AppManager::ConfigHandler('reports')->addAppPermission('myapp');
```

**Parameters:**

- **`$app_name`**: App to allow.

**Return Value:**

- **`Boolean`**: `false` if it's already listed.

---

### updateAppPermissionName

Description:

The **`updateAppPermissionName`** method renames an app in `<app_permissions>`.

Syntax:

```php
$ok = $config->updateAppPermissionName('oldapp', 'newapp');
```

**Parameters:**

- **`$current_app_name`**: Name to find.
- **`$new_app_name`**: Replacement.

**Return Value:**

- **`Boolean`**: `false` if the name isn't listed.

---

### setAppPermissionsAllowAll

Description:

The **`setAppPermissionsAllowAll`** method removes every `<permission>` from `<app_permissions>` and sets `allow="all"`. It creates the block if it's missing.

<aside>
⚠️ If the block ends up written as a self-closing `<app_permissions allow="all"/>`, `CreateAppInstance` treats it as empty and refuses every call. Check the file afterwards. It needs an opening and a closing tag.

</aside>

Syntax:

```php
$config->setAppPermissionsAllowAll();
```

**Return Value:**

- **`Boolean`**: `true`.

---

### getConfigData

Description:

The **`getConfigData`** method returns the whole manifest.

Syntax:

```php
$xml = $config->getConfigData();
echo (string) $xml->info->app_version;
```

**Return Value:**

- **`SimpleXMLElement`**

---
