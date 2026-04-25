# XML Manager

Owner: Nuwan Danushka

A robust PHP class for managing XML files, inspired by JSONManager

## Overview

`XMLManager` is a PHP class designed to handle XML file operations with a similar interface to `JSONManager`. It provides methods for reading, writing, and manipulating XML data, including support for attributes, elements, and hierarchical structures using XPath. This class is ideal for applications needing to manage configuration files or data stored in XML format.

## Features

- **File Management**: Load and save XML files with pretty printing.
- **Data Retrieval**: Fetch XML content as `SimpleXMLElement` or array, with optional XPath filtering.
- **Element Manipulation**: Add, update, and remove elements and attributes.
- **Attribute Support**: Fully handles XML attributes in both `SimpleXMLElement` and array formats.
- **Error Handling**: Throws exceptions for invalid operations, with optional logging.

## **Usage**

**Basic Example**

```php
<?php
require_once 'XMLManager.php';

try {
    $xml_manager = new XMLManager('config.xml');

    // Add an element
    $xml_manager->addElement('/root', 'setting', ['name' => 'theme'], 'dark');

    // Get as array
    $config_array = $xml_manager->get(true);
    print_r($config_array);

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
```

## Methods

### Constructor

- **Syntax**:  `public function __construct(?string $file_path = null)`
- **Description**: Initializes the `XMLManager` with an optional file path.
- **Parameters**:
    - `$file_path`: Path to the XML file (optional).

### Set File Path

- **Syntax**: `public function set_file(string $file_path): void`
- **Description**: Sets the XML file path after instantiation.
- **Parameters**:
    - `$file_path`: Path to the XML file.

### Check Existence

- **Syntax**: `public function exists(): bool`
- **Description**: Checks if the XML file exists.
- **Returns**: `true` if the file exists, `false` otherwise.

### Get Content

- **Syntax**: `public function get(bool $asArray = false, ?string $xpath = null)`
- **Description**: Retrieves XML content as `SimpleXMLElement` or array, optionally filtered by XPath.
- **Parameters**:
    - `$asArray`: If `true`, returns an array; otherwise, returns `SimpleXMLElement`.
    - `$xpath`: Optional XPath query to filter results.
- **Returns**: `SimpleXMLElement`, array, or `false` on error.
- **Example**:
    
    ```php
    $xml = $xml_manager->get(); *// SimpleXMLElement*
    $array = $xml_manager->get(true, '/app/info'); *// Array of info node*
    ```
    

### Set Content

- **Syntax**: `public function set($content, ?string $xpath = null)`
- **Description**: Replaces the entire XML or a specific node with new content.
- **Parameters**:
    - `$content`: `SimpleXMLElement` or array to set.
    - `$xpath`: Optional XPath to target a specific node.
- **Returns**: Updated `SimpleXMLElement`.

### Merge Content

- **Syntax**: `public function merge($content, ?string $xpath = null)`
- **Description**: Merges new content into an existing node.
- **Parameters**:
    - `$content`: SimpleXMLElement or array to merge.
    - `$xpath`: Optional XPath to target the merge location.
- **Returns**: Updated `SimpleXMLElement`.

### Unset Node

- **Syntax**: `public function unset(string $xpath)`
- **Description**: Removes nodes matching an XPath query.
- **Parameters**:
    - `$xpath`: XPath to the nodes to remove.
- **Returns**: `Updated SimpleXMLElement`.

### Push Content

- **Syntax**: `public function push($content, ?string $xpath = null)`
- **Description**: Adds new content as a child element.
- **Parameters**:
    - `$content`: SimpleXMLElement or array to add.
    - `$xpath`: Optional XPath to the parent node.
- **Returns**: Updated `SimpleXMLElement`.

### Add Element

- **Syntax**: `public function addElement(string $xpath, string $element_name, array $attributes = [], ?string $content = null)`
- **Description**: Adds a new element with attributes and optional text content.
- **Parameters**:
    - `$xpath:` Parent XPath where the element will be added.
    - `$element_name`: Name of the new element.
    - `$attributes:` Key-value pairs of attributes.
    - `$content`: Optional text content.
- **Returns**: The new `SimpleXMLElement.`
- **Example**:
    
    ```php
    $xml_manager->addElement('/app', 'version', ['major' => '1'], '1.0.0');
    ```
    

### Update Element

- **Syntax**: `public function updateElement(string $xpath, array $attributes = [], ?string $content = null)`
- **Description**: Updates an element’s attributes and/or content.
- **Parameters**:
    - `$xpath`: XPath to the element.
    - `$attributes`: New or updated attributes.
    - `$content`: Optional new text content.
- **Returns**: `true` if updated, `false` if not found.

### Remove Attribute

- **Syntax**: `public function removeAttribute(string $xpath, string $attribute_name)`
- **Description**: Removes an attribute from an element.
- **Parameters**:
    - `$xpath`: XPath to the element.
    - `$attribute_name`: Name of the attribute to remove.
- **Returns**: `true` if removed, `false` if not found.

### Get Attribute

- **Syntax**: `public function getAttribute(string $xpath, string $attribute_name)`
- **Description**: Retrieves an attribute’s value.
- **Parameters**:
    - `$xpath`: XPath to the element.
    - `$attribute_name`: Name of the attribute.
- **Returns**: Attribute value as string or `null` if not found.

## Array Structure

When `get(true)` is called, the XML is converted to an array with the following conventions:

- **Attributes**: Stored under `@attributes` key as an associative array.
- **Text Content**: Stored under `@content` key if present.
- **Multiple Children**: Same-named child elements are grouped as an indexed array.

### Example

For XML:

```php
<app>
    <info name="system">
        <version major="1">1.0.0</version>
    </info>
</app>
```

Array output:

```php
[
    'app' => [
        'info' => [
            '@attributes' => ['name' => 'system'],
            'version' => [
                '@attributes' => ['major' => '1'],
                '@content' => '1.0.0'
            ]
        ]
    ]
]
```

---

## Error Handling

- **Exceptions**: Thrown for file errors, invalid XPath, or unsupported content types.
- **Logging**: Errors are logged via a `System::errorlog` call.

## Notes

- **XPath**: Use XPath queries (e.g., `/app/info`, `//permission[@name='list']`) for precise targeting.
- **SimpleXML**: Returned objects are `SimpleXMLElement` instances, which can be further manipulated directly.
- **DOM**: Used internally for advanced operations like attribute removal and pretty printing.