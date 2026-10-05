---
title: XML Manager
sidebar_label: XML Manager
---

# XML Manager

Owner: Nuwan Danushka

# Introduction

`XMLManager` reads and edits XML files. Its interface follows [JSON Manager](JSON%20Manager.md): point an instance at a file, read it with `get()`, and change it with `set()`, `merge()`, `push()`, `unset()` and the element and attribute methods. You pick nodes with XPath, such as `/app/info` or `//permission[@name='list']`.

The module is loaded automatically. Don't `require` it: create it with `new XMLManager()` from any controller or class.

Each change reads the file, edits it and writes the whole file back, pretty-printed with an `<?xml version="1.0" encoding="UTF-8"?>` declaration. The folder is created if it doesn't exist.

When the file doesn't exist:

- `get()` logs the error and returns `false`, and `getAttribute()` returns `null`.
- `set()`, `merge()`, `push()` and `addElement()` start from an empty `<root>` document.
- `unset()`, `updateElement()` and `removeAttribute()` throw an `Exception` ("No XML content to modify.").

---

# How to read and edit an XML file

This example expects `settings.xml` to exist with a `<settings>` document element. If the file is missing, the empty document's element is `<root>`, so the XPath `/settings` matches nothing and `addElement()` throws.

```php
$xml_manager = new XMLManager(__DIR__ . '/settings.xml');

try {
    // Add <setting name="theme">dark</setting> under the document element
    $xml_manager->addElement('/settings', 'setting', ['name' => 'theme'], 'dark');

    // Change it
    $xml_manager->updateElement("/settings/setting[@name='theme']", [], 'light');

    // Read the file as an array
    $settings = $xml_manager->get(true);
} catch (Exception $e) {
    // The XPath matched nothing, or the file couldn't be written.
}
```

---

# How get(true) converts XML to an array

`get(true)` converts the XML with these rules:

- The document element's own name is left out: the array holds its attributes and children.
- Attributes go under an `@attributes` key.
- Text goes under an `@content` key, only for elements with no child elements.
- Two or more children with the same name become a list.

For this file:

```xml
<app>
    <info name="system">
        <version major="1">1.0.0</version>
    </info>
</app>
```

`get(true)` returns:

```php
[
    'info' => [
        '@attributes' => ['name' => 'system'],
        'version' => [
            '@attributes' => ['major' => '1'],
            '@content' => '1.0.0'
        ]
    ]
]
```

With an XPath, `get()` returns a list of matches, even when only one node matches. `get(true, '/app/info')` returns `[ ['@attributes' => [...], 'version' => [...]] ]`, and `get(false, '/app/info')` returns an array of `SimpleXMLElement` objects.

---

# How to pass content to set, merge and push

`set()`, `merge()` and `push()` take a `SimpleXMLElement` or an array. An array is converted with the same `@attributes` and `@content` keys as above, and wrapped in a `<root>` element:

| Call | Result |
| --- | --- |
| `set($array)` | The whole file becomes a `<root>` document. |
| `set($array, $xpath)` | The matched node is replaced by a `<root>` element. |
| `push($array, $xpath)` | A `<root>` element is added under the matched node. |
| `merge($array, $xpath)` | The array's elements are added under the matched node, with no wrapper. |

To control the element names, pass a `SimpleXMLElement` to `set()` and `push()`:

```php
$xml_manager->push(new SimpleXMLElement('<setting name="lang">en</setting>'), '/settings');
```

<aside>
⚠️ Content arrays can't contain lists. A numeric key, as in `['items' => ['a', 'b']]`, is not a valid element name: the write produces a file that holds only the XML declaration, so `set()` with such an array erases the file. Build repeated elements with `addElement()` or a `SimpleXMLElement` instead.

</aside>

---

# XML Manager Methods

### __construct

Description:

The **`__construct`** method creates an XML Manager, optionally for a file.

Syntax:

```php
$xml_manager = new XMLManager($file_path = null);
```

**Parameters:**

- **`$file_path`** (optional): Path to the XML file. You can set it later with `set_file()`.

---

### set_file

Description:

The **`set_file`** method sets the XML file that the other methods work on.

Syntax:

```php
$xml_manager->set_file($file_path);
```

---

### exists

Description:

The **`exists`** method checks whether the file exists.

Syntax:

```php
$exists = $xml_manager->exists();
```

**Return Value:**

- **`Boolean`**: `true` if the file exists.

---

### get

Description:

The **`get`** method reads the file, optionally only the nodes that match an XPath.

Syntax:

```php
$xml = $xml_manager->get();                  // SimpleXMLElement
$array = $xml_manager->get(true);            // array
$infos = $xml_manager->get(true, '/app/info'); // list of arrays
```

**Parameters:**

- **`$asArray`** (optional, default `false`): `true` returns arrays, converted as described above.
- **`$xpath`** (optional): XPath query.

**Return Value:**

- **`SimpleXMLElement`** or **`Array`**: The document, when there is no `$xpath`.
- **`Array`**: A list of matches, when there is an `$xpath`.
- **`false`**: The file is missing or isn't valid XML, or the XPath matched nothing. File and parse errors are logged.

---

### set

Description:

The **`set`** method replaces the whole document, or the first node that matches `$xpath`.

Syntax:

```php
$xml_manager->set($content, ?string $xpath = null);
```

**Parameters:**

- **`$content`**: A `SimpleXMLElement` or an array. See "How to pass content to set, merge and push".
- **`$xpath`** (optional): XPath of the node to replace.

**Return Value:**

- **`SimpleXMLElement`**: The saved document.
- Throws an `Exception` if the XPath matches nothing or the file can't be written.

---

### merge

Description:

The **`merge`** method adds the child elements of `$content` under the document element, or under the first node that matches `$xpath`. It doesn't replace existing elements with the same name.

Syntax:

```php
$xml_manager->merge(['theme' => 'dark', 'lang' => 'en'], '/settings');
```

**Parameters:**

- **`$content`**: A `SimpleXMLElement` or an array.
- **`$xpath`** (optional): XPath of the parent node.

**Return Value:**

- **`SimpleXMLElement`**: The saved document.
- Throws an `Exception` if the XPath matches nothing or the file can't be written.

---

### push

Description:

The **`push`** method adds `$content` as a child of the first node that matches `$xpath`, or of the document element.

Syntax:

```php
$xml_manager->push($content, ?string $xpath = null);
```

**Parameters:**

- **`$content`**: A `SimpleXMLElement` or an array.
- **`$xpath`** (optional): XPath of the parent node. If it matches nothing, the content is added under the document element without an error.

**Return Value:**

- **`SimpleXMLElement`**: The saved document.

---

### unset

Description:

The **`unset`** method removes every node that matches `$xpath`.

Syntax:

```php
$xml_manager->unset("//setting[@name='theme']");
```

**Parameters:**

- **`$xpath`**: XPath of the nodes to remove.

**Return Value:**

- **`SimpleXMLElement`**: The document. If nothing matched, the file isn't written.
- Throws an `Exception` if the file is missing.

---

### addElement

Description:

The **`addElement`** method adds an element, with attributes and optional text, under the first node that matches `$xpath`. Special characters in `$content` are escaped for you.

Syntax:

```php
$xml_manager->addElement('/app', 'version', ['major' => '1'], '1.0.0');
```

**Parameters:**

- **`$xpath`**: XPath of the parent node.
- **`$element_name`**: Name of the new element.
- **`$attributes`** (optional): Attribute name => value array.
- **`$content`** (optional): Text content.

**Return Value:**

- **`SimpleXMLElement`**: The new element.
- Throws an `Exception` if the XPath matches nothing.

---

### updateElement

Description:

The **`updateElement`** method sets attributes and, optionally, the text of the first node that matches `$xpath`. Setting the text replaces everything inside the element, including child elements.

Syntax:

```php
$xml_manager->updateElement('/app/version', ['major' => '2'], '2.0.0');
```

**Parameters:**

- **`$xpath`**: XPath of the element.
- **`$attributes`** (optional): Attributes to add or change.
- **`$content`** (optional): New text content. `null` leaves the content as it is.

**Return Value:**

- **`Boolean`**: `true` if updated, `false` if the XPath matched nothing.
- Throws an `Exception` if the file is missing.

---

### removeAttribute

Description:

The **`removeAttribute`** method removes an attribute from the first node that matches `$xpath`.

Syntax:

```php
$xml_manager->removeAttribute('/app/version', 'major');
```

**Return Value:**

- **`Boolean`**: `true` if removed, `false` if the element or attribute wasn't found.
- Throws an `Exception` if the file is missing.

---

### getAttribute

Description:

The **`getAttribute`** method returns an attribute of the first node that matches `$xpath`.

Syntax:

```php
$major = $xml_manager->getAttribute('/app/version', 'major');
```

**Return Value:**

- **`String`**: The attribute value.
- **`null`**: The file, element or attribute wasn't found. An attribute whose value is empty or `"0"` also returns `null`.

---
