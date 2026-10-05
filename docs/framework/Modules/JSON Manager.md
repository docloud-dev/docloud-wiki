---
title: JSON Manager
sidebar_label: JSON Manager
---

# JSON Manager

Owner: Nuwan Danushka

# Introduction

JSON Manager reads and edits JSON files. It also wraps `json_encode` and `json_decode` so that errors throw instead of failing quietly.

Point an instance at a file, then read it with `get()` or change it with `set()`, `merge()`, `push()`, `pop()`, `shift()`, `unshift()` and `unset()`. Each change reads the file, edits the data and writes the whole file back, pretty-printed and with unescaped slashes.

Most methods take an optional `$dot` path to work on a nested value. `details.city` means `$data['details']['city']`, and `items.0` means the first element of `items`.

The module is loaded automatically: use `new JSONManager()` from any controller or class.

<aside>
⚠️ `get()` never throws: it logs the error and returns `false`. The methods that change the file throw an `Exception` instead, for example when the file is missing or the target isn't an array. Wrap them in `try`/`catch`.

</aside>

---

# How to push an item to a JSON file

Say `/path/to/data.json` contains:

```json
{
    "items": ["apple", "banana", "orange"],
    "details": {
        "city": "Old City",
        "country": "Old Country"
    }
}
```

Append `pear` to `items`:

```php
$json_manager = new JSONManager('/path/to/data.json');

try {
    $json_manager->push('pear', 'items');
} catch (Exception $e) {
    // The file is missing, or "items" isn't an array.
}
```

`items` is now `["apple", "banana", "orange", "pear"]`.

---

# JSON Manager Methods

### __construct

Description:

The **`__construct`** method creates a JSON Manager, optionally for a file.

Syntax:

```php
$json_manager = new JSONManager($file_path = null);
```

**Parameters:**

- **`$file_path`** (optional): Path to the JSON file. You can set it later with `set_file()`.

---

### json_encode

Description:

The **`json_encode`** method encodes a PHP value as JSON. Unlike PHP's `json_encode`, it throws on error.

Syntax:

```php
$json_string = $json_manager->json_encode($value, $options = 0, $depth = 512);
```

**Parameters:**

- **`$value`**: The value to encode.
- **`$options`** (optional): `JSON_*` flags, such as `JSON_PRETTY_PRINT`.
- **`$depth`** (optional): Maximum nesting depth.

**Return Value:**

- **`String`**: The JSON.
- Throws an `Exception` ("JSON error: …") if encoding fails.

---

### json_decode

Description:

The **`json_decode`** method decodes a JSON string. Unlike PHP's `json_decode`, it returns an array by default and throws on error.

Syntax:

```php
$data = $json_manager->json_decode($json, bool $asObject = false, int $depth = 512, int $flags = 0);
```

**Parameters:**

- **`$json`**: The JSON string.
- **`$asObject`** (optional): `false` (default) returns associative arrays. `true` returns objects.
- **`$depth`** (optional): Maximum nesting depth.
- **`$flags`** (optional): `JSON_*` decode flags, such as `JSON_BIGINT_AS_STRING`.

**Return Value:**

- The decoded value.
- Throws an `Exception` ("JSON error: …") if the string isn't valid JSON.

---

### is_valid_json

Description:

The **`is_valid_json`** method checks whether a string is valid JSON.

Syntax:

```php
$valid = $json_manager->is_valid_json('{"a": 1}'); // true
```

**Parameters:**

- **`$string`**: The string to check. An empty string is not valid JSON.

**Return Value:**

- **`Boolean`**: `true` if it decodes without error.

---

### set_file

Description:

The **`set_file`** method sets the JSON file that the other methods work on.

Syntax:

```php
$json_manager->set_file($file_path);
```

**Parameters:**

- **`$file_path`**: Path to the JSON file.

---

### exists

Description:

The **`exists`** method checks whether the file exists.

Syntax:

```php
$exists = $json_manager->exists();
```

**Return Value:**

- **`Boolean`**: `true` if the file exists.

---

### get

Description:

The **`get`** method reads the file, or one value from it.

Syntax:

```php
$data = $json_manager->get(bool $asObject = false, string $dot = null);
$city = $json_manager->get(false, 'details.city');
```

**Parameters:**

- **`$asObject`** (optional): `false` (default) returns associative arrays. `true` returns objects.
- **`$dot`** (optional): Dot path of the value to return.

**Return Value:**

- The file's data, or the value at `$dot`.
- **`false`**: The file can't be read, it isn't valid JSON, or nothing is set at `$dot`. A stored `null` also returns `false`. Read and JSON errors are logged.

<aside>
⚠️ Don't combine `$asObject = true` with a `$dot` path. The path lookup uses array access, so PHP throws an `Error` ("Cannot use object of type stdClass as array").

</aside>

---

### set

Description:

The **`set`** method replaces the whole file, or one value in it.

Syntax:

```php
$json_manager->set($content, string $dot = null);
```

**Parameters:**

- **`$content`**: The new value: an array, object, string, number, Boolean or `null`.
- **`$dot`** (optional): Dot path of the value to replace. Missing keys along the path are created. Without it, `$content` replaces the whole file.

**Return Value:**

- **`Array`**: The data written to the file.
- Throws an `Exception` if the file can't be written. With `$dot`, it also throws if the file is missing or doesn't contain an object or array.

Without `$dot`, `set()` creates the file, and its folder, if they don't exist.

**Usage Example**

```php
$json_manager = new JSONManager('/path/to/data.json');

// Replace one value
$json_manager->set('New City', 'details.city');

// Replace the whole file
$json_manager->set([
    'name' => 'Updated Name',
    'details' => ['city' => 'New City', 'country' => 'New Country']
]);
```

---

### merge

Description:

The **`merge`** method merges an array into the file's top level, or into the array at `$dot`. It's a shallow `array_merge`: string keys in `$content` replace existing keys, including nested arrays, and numeric keys are appended.

Syntax:

```php
$json_manager->merge($content, string $dot = null);
```

**Parameters:**

- **`$content`**: An array or object to merge.
- **`$dot`** (optional): Dot path of the array to merge into.

**Return Value:**

- **`Array`**: The data written to the file.
- Throws an `Exception` if the file or the target isn't an array.

**Usage Example**

```php
$json_manager = new JSONManager('/path/to/data.json');

// details was {"city": "Old City", "country": "Old Country"}
$json_manager->merge(['city' => 'New City'], 'details');
// details is now {"city": "New City", "country": "Old Country"}
```

---

### pop

Description:

The **`pop`** method removes the last element of the file's top-level array, or of the array at `$dot`, and returns it.

Syntax:

```php
$last = $json_manager->pop(string $dot = null);
```

**Parameters:**

- **`$dot`** (optional): Dot path of the array.

**Return Value:**

- The removed element, or `null` if the array was empty.
- Throws an `Exception` if the target isn't an array.

**Usage Example**

```php
// items was ["apple", "banana", "orange"]
$lastItem = $json_manager->pop('items'); // "orange"
```

---

### push

Description:

The **`push`** method appends an element to the file's top-level array, or to the array at `$dot`.

Syntax:

```php
$json_manager->push($content, string $dot = null);
```

**Parameters:**

- **`$content`**: The element to add. An object is stored as an array.
- **`$dot`** (optional): Dot path of the array.

**Return Value:**

- **`Array`**: The whole data written to the file.
- Throws an `Exception` if the file or the target isn't an array.

---

### shift

Description:

The **`shift`** method removes the first element of the file's top-level array, or of the array at `$dot`, and returns it.

Syntax:

```php
$first = $json_manager->shift(string $dot = null);
```

**Parameters:**

- **`$dot`** (optional): Dot path of the array.

**Return Value:**

- The removed element, or `null` if the array was empty.
- Throws an `Exception` if the target isn't an array.

**Usage Example**

```php
// items was ["apple", "banana", "orange"]
$firstItem = $json_manager->shift('items'); // "apple"
```

---

### unshift

Description:

The **`unshift`** method adds an element to the start of the file's top-level array, or of the array at `$dot`.

Syntax:

```php
$json_manager->unshift($content, string $dot = null);
```

**Parameters:**

- **`$content`**: The element to add. An object is stored as an array.
- **`$dot`** (optional): Dot path of the array.

**Return Value:**

- **`Array`**: The whole data written to the file.
- Throws an `Exception` if the file or the target isn't an array.

**Usage Example**

```php
// items was ["banana", "orange"]
$json_manager->unshift('apple', 'items');
// items is now ["apple", "banana", "orange"]
```

---

### unset

Description:

The **`unset`** method removes the value at a dot path.

Syntax:

```php
$json_manager->unset(string $dot, bool $reindexed = false);
```

**Parameters:**

- **`$dot`**: Dot path of the value to remove, such as `details.country` or `items.1`.
- **`$reindexed`** (optional, default `false`): `true` renumbers the file's top-level array after the removal. It never renumbers nested arrays.

**Return Value:**

- **`Array`**: The data written to the file.
- Throws an `Exception` if the file doesn't contain an array.

<aside>
⚠️ Two things to watch for:

- Use `$reindexed = true` only when the file's top level is a list, like `["a", "b", "c"]`, and you remove a top-level element. On a file whose top level has keys, it drops every top-level key: `unset('items.1', true)` on the example file above turns the whole file into a list.
- If the parent of the value doesn't exist, `unset()` creates it as `null` instead of doing nothing. For example, `unset('missing.key')` adds `"missing": null` to the file. Check the path with `get()` first.

</aside>

---
