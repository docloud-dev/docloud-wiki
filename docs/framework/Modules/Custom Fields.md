---
title: Custom Fields
sidebar_label: Custom Fields
---

# Custom Fields

# Introduction

The Custom Fields module stores definitions of extra fields that an app lets its users add to records, such as a "Customer tier" field on a contact. A field can also have conditions and actions: when your app reports a new value for the field, the module checks each condition and runs the matching actions through a handler class in your app.

The module stores field definitions only. Your app stores the values, usually in a meta table, one row per record and field.

It uses three tables, shared by every app:

| Table | Holds |
| --- | --- |
| `xp_system_custom_fields` | Field definitions. |
| `xp_system_custom_fields_conditions` | Conditions on a field. |
| `xp_system_custom_fields_actions` | Actions to run when a field's condition is met. |

`CustomFields` is loaded automatically. `CustomFieldsActionManager` and the `CustomFieldsAction` base class load with it, so reference `CustomFields` first (for example with `class_exists('CustomFields')`) before you use them directly.

<aside>
⚠️ In v0.0.42 no framework app, admin page or `xp.js` function uses this module, and there is no UI for it. Parts of it don't work as written: the setup creates the actions table under the wrong name, and the app detection fails in the dev workspace. The warnings below say what to do about each.

</aside>

---

# How fields are grouped

Every method that reads or writes fields for one app combines two names into an entity name, `<app_name>_<calling app>`:

- **`$app_name`** is the first argument you pass. Use your app's name. If you pass nothing, it's `Direct`.
- **The calling app** is detected from the path of the PHP file that called the method: the folder name under `api/apps/`. If the call doesn't come from a file there, it's `default`.

So a call with `'myapp'` from code in `api/apps/myapp/` uses the entity `myapp_myapp`. Each field also gets a key, `<entity>_<field_name>-CustomField`, for example `myapp_myapp_tier-CustomField`. Use this key to store the field's values and to run its actions.

<aside>
⚠️ In the [dev workspace](../Building%20Apps/Dev%20Workspace.md), PHP reports your files under `dev/<folder>/backend/<app_name>/`, not `api/apps/<app_name>/`, so the calling app is `default`. Fields created while you develop get the entity `myapp_default`, and a production install looking for `myapp_myapp` won't find them. App Manager handles this path, but this module doesn't.

</aside>

---

# How to create the tables

Call `CustomFields::initialize_app()` once. A `<run>` script in your manifest is a good place, since it runs on install and reinit (see [App Manifest](../Building%20Apps/App%20Manifest.md)):

```php
class myappRun
{
    public static function init()
    {
        CustomFields::initialize_app();
    }
}
```

It runs plain `CREATE TABLE` statements, so on later runs they fail because the tables exist. The errors are logged and do no harm.

<aside>
⚠️ `initialize_app()` creates the actions table as `xp_system_field_actions`, but the module reads and writes `xp_system_custom_fields_actions`. Until that's fixed, creating a field with actions fails and `execute_actions()` throws. If you need actions, create the table yourself with the SQL below.

</aside>

Make `condition_id` nullable, because actions without a condition don't set it:

```sql
CREATE TABLE IF NOT EXISTS `xp_system_custom_fields_actions` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT,
    `entity_name` varchar(255) NOT NULL,
    `field_key` varchar(255) NOT NULL,
    `condition_id` bigint(20) DEFAULT NULL,
    `action_type` varchar(255) NOT NULL,
    `action_data` text DEFAULT NULL,
    `action_order` int NOT NULL DEFAULT 0,
    `created_at` datetime NOT NULL DEFAULT current_timestamp(),
    `updated_at` datetime DEFAULT NULL,
    PRIMARY KEY (`id`)
);
```

---

# How to define a field

```php
$field_id = CustomFields::create_new_custom_field('myapp', [
    'field_name'      => 'tier',
    'field_type'      => 'select',
    'field_value'     => 'bronze,silver,gold',
    'description'     => 'Customer tier',
    'additional_data' => '',
    'created_by'      => $user_id,
    'created_at'      => date('Y-m-d H:i:s'),
]);
```

Every key except `conditions` and `actions` is written to a column of `xp_system_custom_fields`, so only use these keys:

| Key | Required | Notes |
| --- | --- | --- |
| `field_name` | Yes | Part of the field key. |
| `field_type` | Yes | Free text. The module doesn't interpret it, so use whatever your UI needs, such as `text` or `select`. |
| `field_value` | No | Free text, such as a default value or a list of options. |
| `description` | No | Up to 255 characters. |
| `additional_data` | Yes | Up to 255 characters. Pass `''` if you have nothing. |
| `status` | No | `active` (default) or `inactive`. `CustomFields::$STATUS_ACTIVE` and `CustomFields::$STATUS_INACTIVE` hold these values. |
| `created_at` | Yes | The column has no default. |
| `created_by`, `updated_by`, `updated_at` | No | |

`entity_name` and `field_key` are set for you. The method returns the new field's id, or `false` if anything fails (the error is logged and nothing is saved). An unknown key fails the insert.

<aside>
⚠️ Array keys are written into the SQL as column names. Never build the array from request data without checking the keys.

</aside>

---

# How to read fields

```php
// Every field of the entity
$fields = CustomFields::get_custom_field('myapp');

// One field
$rows = CustomFields::get_custom_field('myapp', $field_id);
$field = $rows ? $rows[0] : null;
```

Both return a list of rows, or `false` if there are none. Inactive fields are included: check the `status` column. Call it from your own app's code, so the calling app matches the one used when the fields were created.

To look fields up by key across all apps, use `getCustomFieldsByFieldKey()`:

```php
$fields = CustomFields::getCustomFieldsByFieldKey(['myapp_myapp_tier-CustomField']);
```

---

# How to store field values

The module doesn't store values. Keep them in a meta table in your app, with the field key as `meta_key`. App Manager's meta table helpers do this; see [App Manager](App%20Manager.md):

```php
AppManager::updateMetaTable('contact_meta', 'contact_id', $contact_id, 'myapp_myapp_tier-CustomField', 'gold', date('Y-m-d H:i:s'), $user_id);
```

This module has its own copies of these helpers (`insertIntoMetaTable`, `updateMetaTable` and `deleteMetaTableRecords`). Prefer App Manager's: these copies have the dev workspace problem described above, and `CustomFields::updateMetaTable()` ignores its `$modifier` argument and always writes `0`.

---

# How to run actions when a value changes

Actions need a handler class in your app, the actions table described above, and fields created with `conditions` and `actions`.

## Add conditions and actions to a field

```php
$field_id = CustomFields::create_new_custom_field('myapp', [
    'field_name'      => 'tier',
    'field_type'      => 'select',
    'additional_data' => '',
    'created_at'      => date('Y-m-d H:i:s'),
    'conditions'      => [
        ['type' => 'equals', 'value' => 'gold', 'order' => 1],
    ],
    'actions'         => [
        ['type' => 'notifyManager', 'data' => ['role' => 'sales'], 'order' => 1],
    ],
]);
```

- A condition has a `type`, a `value` and an optional `order`. The built-in types are `equals` (a strict `===` comparison), `greater_than` and `less_than` (both only for numeric values).
- An action has a `type`, which must match a method of your handler, optional `data` (stored as JSON) and an optional `order`.
- Every action is attached to every condition. With two conditions, an action runs once for each condition that's met.
- Without `conditions`, the actions always run.

## Write the handler

The handler is a class without a namespace, named after the `$app_name` with the first letter in upper case and the rest in lower case, plus `CustomFieldsAction`. For `myapp`, that's `MyappCustomFieldsAction`. Put it in `api/apps/myapp/myappCustomFieldsAction.class.php`, where the framework's class-name lookup finds it.

```php
class MyappCustomFieldsAction extends CustomFieldsAction
{
    // One public method per action type. Its existence enables the action.
    public function notifyManager(array $context, $optional_data = null)
    {
        $value = current($context['field_values']);
        $role = $context['action_data']['role'] ?? null;
        // ...
    }

    // Called for every action whose condition is met.
    public function execute(string $actionType, array $context, $optional_data = null)
    {
        return $this->$actionType($context, $optional_data);
    }

    // Describe each action's inputs, for your own UI.
    public static function getActionParameters($action_type)
    {
        return [];
    }
}
```

The framework calls `execute()`, not the action method. The action method must still exist: an action whose type isn't a public method of the handler is skipped.

`$context` holds `field_values` (an array with one entry, the field key and its new value) and `action_data` (the action's `data`, decoded).

## Run the actions

After you save a value, pass the field keys and their new values:

```php
CustomFieldsActionManager::execute_actions('myapp', [
    'myapp_myapp_tier-CustomField' => 'gold',
], $optional_data);
```

Pass values as strings when you use `equals`: the condition value comes from the database as a string, and the comparison is strict. `execute_actions()` throws an `Exception` if the handler class doesn't exist.

---

# Custom Fields Methods

## CustomFields class

### initialize_app

Description:

The **`initialize_app`** static method creates the module's tables. See "How to create the tables".

Syntax:

```php
CustomFields::initialize_app();
```

---

### create_new_custom_field

Description:

The **`create_new_custom_field`** static method creates a field, with its conditions and actions, in one transaction.

Syntax:

```php
$field_id = CustomFields::create_new_custom_field($app_name, $data);
```

**Parameters:**

- **`$app_name`**: Your app's name. See "How fields are grouped".
- **`$data`**: The field's columns, plus optional `conditions` and `actions`. See "How to define a field".

**Return Value:**

- **`String`**: The new field's id.
- **`false`**: An error. Nothing is saved.

---

### get_custom_field

Description:

The **`get_custom_field`** static method returns the fields of the entity, or one of them.

Syntax:

```php
$rows = CustomFields::get_custom_field($app_name = null, $id = null);
```

**Parameters:**

- **`$app_name`** (optional): Your app's name. Defaults to `Direct`.
- **`$id`** (optional): A field id.

**Return Value:**

- **`Array`**: A list of rows from `xp_system_custom_fields`.
- **`false`**: No rows, or an error.

---

### getCustomFieldsByFieldKey

Description:

The **`getCustomFieldsByFieldKey`** static method returns fields by key, from every app.

Syntax:

```php
$rows = CustomFields::getCustomFieldsByFieldKey($fieldKeyArray);
```

**Parameters:**

- **`$fieldKeyArray`**: A field key, or an array of keys. An empty array returns every field of every app.

**Return Value:**

- **`Array`**: A list of rows.
- **`false`**: No rows, or an error.

---

### update_custom_field

Description:

The **`update_custom_field`** static method updates the rows of `xp_system_custom_fields` where `$where_column_name` equals `$where_value`. It isn't limited to your entity, so match on `id` or `field_key`.

Syntax:

```php
$ok = CustomFields::update_custom_field(['status' => CustomFields::$STATUS_INACTIVE], 'id', $field_id);
```

**Parameters:**

- **`$data`**: Column => value array. The keys are written into the SQL, as for `create_new_custom_field`.
- **`$where_column_name`**: The column to match. Also written into the SQL.
- **`$where_value`**: The value to match.

**Return Value:**

- **`Boolean`**: `true` if the statement ran.

---

### remove_custom_field

Description:

The **`remove_custom_field`** static method deletes a field definition. It doesn't delete the field's conditions, actions or stored values: delete those yourself by `field_key`.

Syntax:

```php
$ok = CustomFields::remove_custom_field(['id' => $field_id]);
```

**Parameters:**

- **`$data`**: An array with the field's `id`.

**Return Value:**

- **`Boolean`**: `true` on success.

---

### callingApp

Description:

The **`callingApp`** static method returns the calling app that the module detects. See "How fields are grouped".

Syntax:

```php
$app = CustomFields::callingApp();
```

**Return Value:**

- **`String`**: The folder name under `api/apps/`.
- **`null`**: Not called from a file there.

---

### insertIntoMetaTable, updateMetaTable, deleteMetaTableRecords

Description:

Copies of the App Manager meta table helpers. The table name is prefixed with the calling app. Use [App Manager](App%20Manager.md)'s versions instead: see "How to store field values".

Syntax:

```php
CustomFields::insertIntoMetaTable($tableName, $uniqueColumn, $uniqueValue, $dataToInsert, $optionalParams);
CustomFields::updateMetaTable($tableName, $uniqueColumn, $uniqueValue, $meta_key_column, $updating_value, $current_datetime);
CustomFields::deleteMetaTableRecords($tableName, $metaKeyValue, $metaValueValue, $uniqueColumn, $uniqueValue);
```

- `insertIntoMetaTable` also writes each `$optionalParams` entry (column => value) on every row. The argument is required: pass `[]` if you have none.
- `deleteMetaTableRecords` deletes only the rows that match the parent id, the meta key and the meta value.

---

## CustomFieldsActionManager class

### execute_actions

Description:

The **`execute_actions`** static method runs the actions of the given fields whose conditions are met. See "How to run actions when a value changes".

Syntax:

```php
CustomFieldsActionManager::execute_actions($app_name, $field_values, $optional_data = null);
```

**Parameters:**

- **`$app_name`**: Your app's name. It also picks the handler class.
- **`$field_values`**: Field key => new value array.
- **`$optional_data`** (optional): Passed to the handler's `execute()` unchanged.

Throws an `Exception` if the handler class doesn't exist, or if the folder `api/apps` isn't found under the web server's document root.

---

### registerConditionHandler

Description:

The **`registerConditionHandler`** static method adds a condition type, or replaces one.

Syntax:

```php
CustomFieldsActionManager::getAvailableConditions(); // load the built-in types first
CustomFieldsActionManager::registerConditionHandler('contains', function ($actual, $expected) {
    return is_string($actual) && str_contains($actual, $expected);
});
```

**Parameters:**

- **`$conditionType`**: The name used in a condition's `type`.
- **`$handler`**: A function that takes the new value and the condition's value and returns a Boolean.

<aside>
⚠️ The built-in types are only added while the list is empty. If you register a type before anything has loaded them, `equals`, `greater_than` and `less_than` stop working. Call `getAvailableConditions()` first, as above.

</aside>

---

### getAvailableConditions

Description:

The **`getAvailableConditions`** static method returns the names of the condition types, for your UI.

Syntax:

```php
$types = CustomFieldsActionManager::getAvailableConditions(); // ['equals', 'greater_than', 'less_than']
```

---

### getAvailableActions

Description:

The **`getAvailableActions`** static method returns the action types your handler supports: its public, non-static methods other than `execute`.

Syntax:

```php
$actions = CustomFieldsActionManager::getAvailableActions('myapp');
```

**Return Value:**

- **`Array`**: Method names, or an empty array if there's no handler.

---

### getActionParameters

Description:

The **`getActionParameters`** static method returns what your handler's `getActionParameters($action_type)` returns.

Syntax:

```php
$params = CustomFieldsActionManager::getActionParameters('notifyManager', 'myapp');
```

**Return Value:**

- **`Array`**: The handler's parameter definitions, or an empty array if there's no handler.

---

### getCustomHandlers

Description:

The **`getCustomHandlers`** static method returns the handler classes of every app that has one: a file named `<app_name>CustomFieldsAction.php` or `<app_name>CustomFieldsAction.class.php` in its folder under `api/apps/`.

Syntax:

```php
$handlers = CustomFieldsActionManager::getCustomHandlers();
```

**Return Value:**

- **`Array`**: Class names.

---
