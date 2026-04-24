# JSON Manager

Owner: Nuwan Danushka

# Introduction

JSON Manager facilitates efficient JSON data handling and file management within applications. The module offers a comprehensive set of functions, including json_encode, json_decode, and file-related operations like set_file. With a focus on simplicity and clarity, JSON Manager ensures seamless interaction with JSON data, promoting reusability and scalability while maintaining a clear distinction between application logic and file manipulation. Whether encoding, decoding, or managing JSON files, this module provides a user-friendly solution for streamlined JSON data handling in diverse application scenarios.

---

# How to push an item to JSON File

This guide outlines the process of pushing an item to a JSON file using the **`JSON Manager`** module in Do Framework.

1. **Create a JSONManager Instance**
    
    ```php
    $json_manager = new JSONManager();
    
    ```
    
2. **Step 2: Set File Path**
    
    ```php
    $file_path = '/path/to/data.json';
    $json_manager->set_file($file_path);
    
    ```
    
3. **Define Existing Content**
    
    ```php
    $existingContent = [
        'items' => ['apple', 'banana', 'orange'],
        'details' => [
            'city' => 'Old City',
            'country' => 'Old Country'
        ]
    ];
    
    ```
    
4. **Define the Element to be Added**
    
    ```php
    $newItem = 'pear';
    
    ```
    
5. **Append Element to 'items' Array in JSON File**
    
    ```php
    $json_manager->push($newItem, 'items');
    
    ```
    
6. **Update JSON File**
    
    The JSON file is now updated with the new element added to the end of the 'items' array.
    

---

<aside>
💡 **Please refer to the methods for usage examples in other contexts.**

</aside>

# JSON Manager Methods

## __construct

Description:

The **`__construct`** is the class constructor for the **`JSONManager`** class. This function initializes the **`JSONManager`** instance and sets the default necessary options to the object.

Syntax:

```php
$json_manager = new JSONManager($file_path = null);
```

**Parameters**:

- **`$file_path`:** The file path of the JSON file.

This function provides a convenient way to create a new instance of the **`JSONManager`** class and set the file path for the JSON file.

---

## json_encode

Description:

The **`json_encode`** method is used to encode a PHP value into a JSON string. In the context of the **`JSONManager`** class, this method is utilized to encode a given value into its JSON representation.

Syntax:

```php
$json_manager->**json_encode**($value, $options = 0, $depth = 512);
```

**Parameters**:

- **`$value`**: The PHP value to be encoded into JSON.
- **`$options`** (optional): Bitmask consisting of JSON encoding options.
- **`$depth`** (optional): Set the maximum depth for recursion.

**Usage Example** 

```php
	$json_manager = new JSONManager();
  $result = $json_manager->**json_encode**($value);
```

This method provides a convenient way to encode PHP values into JSON strings, allowing for easy integration with various data exchange formats within your application.

---

## json_decode

Description:

The **`json_decode`** method is employed in PHP to convert a JSON string into its corresponding PHP value. Within the context of the **`JSONManager`** class, this method plays a crucial role in decoding JSON data into a PHP representation.

Syntax:

```php
$json_manager->json_decode($json, bool $asObject = false, int $depth = 512, int $flags = 0);
```

**Parameters**:

- **`$json`**: The JSON string to be decoded into a PHP value.
- **`$asObject` (optional)**: A boolean parameter indicating whether the decoded result should be returned as an associative array (default) or as an object. If set to **`true`**, the result will be an object.
- **`$depth` (optional)**: An integer representing the maximum depth for recursion during the decoding process. It prevents infinite recursion when dealing with deeply nested structures. The default depth is set to 512.
- **`$flags` (optional)**: An integer bitmask representing various flags that can modify the behavior of the decoding process. This parameter allows customization of the decoding process by specifying options like **`JSON_BIGINT_AS_STRING`**, **`JSON_OBJECT_AS_ARRAY`**, etc. The default value is 0.

**Usage Example** 

```php
	$json_manager = new JSONManager();
  $result = $json_manager->json_decode($json);
```

This method provides a convenient way to integrate external JSON data into DoFramework applications, allowing for seamless interoperability and data manipulation.

---

## set_file

Description:

The **`set_file`** method in the **`JSONManager`** class is utilized to specify the JSON file path that will be used for various JSON functions.

Syntax:

```php
$json_manager->set_file($file_path);
```

**Parameters**:

- **`$file_path`**: The file path of the JSON file to be used for various JSON operations. It should be a string representing the location of the JSON file.

This method provides a convenient way to integrate file operations with the JSONManager, allowing for easy interaction with JSON data stored in files.

---

## exists

Description:

The **`exists`** method in the **`JSONManager`** class is employed to determine whether the specified JSON file, set using the **`set_file`** method, exists in the file system.

Syntax:

```php
$json_manager->**exists**();
```

This method provides a convenient way to incorporate file existence checks into the workflow of the JSONManager class, enhancing the robustness of file-based operations.

---

## get

Description:

The **`get`** method in the **`JSONManager`** class is employed to retrieve the content of the specified JSON file. This method is particularly useful for obtaining the data stored in the JSON file for further processing within the PHP application.

Syntax:

```php
$json_manager->get(bool $asObject = false);
```

**Parameters**:

- **`$asObject`** (optional)**:** A boolean parameter indicating whether the retrieved JSON content should be returned as an associative array (default) or as an object. If set to `true`, the result will be an object.

This method provides a convenient way to integrate file content retrieval into the workflow of the JSONManager class, facilitating easy access to JSON data within the application.

---

## set

Description:

The **`set`** method in the **`JSONManager`** class is utilized to set or update the content of the specified JSON file. This method allows developers to modify the data stored in the JSON file, providing a mechanism for dynamic updates within the PHP application.

Syntax:

```php
$json_manager->set($content, string $dot = null)
```

**Parameters**:

- **`$content`**: The data to be set as the new content of the JSON file. It can be an array, object, string, number, boolean, or null.
- **`$dot` (optional)`**: A string parameter that represents the dot notation for a nested array or object elements within the JSON structure. It specifies the location where the new content should be set. If not specified, the entire content of the JSON file is replaced.

**Usage Example** 

```php
$json_manager = new JSONManager();

// Set the file path for subsequent operations
$file_path = '/path/to/data.json';
$json_manager->set_file($file_path);

// New content to be set in the JSON file
$newContent = [
    'name' => 'Updated Name',
    'age' => 35,
    'details' => [
        'city' => 'New City',
        'country' => 'New Country'
    ]
];

// Set the new content in the JSON file
$json_manager->set($newContent, 'details.city');

// The JSON file now contains the updated content
```

This method provides a convenient way to integrate content modification into the workflow of the JSONManager class, facilitating dynamic updates to JSON data within the application. The optional **`$dot`** parameter allows for targeted updates within nested structures.

---

## merge

Description:

The `merge` method is used to Merge the content with the existing JSON data.

Syntax:

```php
$json_manager->merge($content, string $dot = null);
```

**Parameters**:

- **`$content`**: The data to be merged with the existing content of the JSON file. It can be an array, object, string, number, boolean, or null.
- **`$dot` (optional)`**: A string parameter that represents the dot notation for nested array or object elements within the JSON structure. It specifies the location where the new content should be merged. If not specified, the merge operation applies to the entire content of the JSON file.

**Usage Example** 

```php
$json_manager = new JSONManager();

// Set the file path for subsequent operations
$file_path = '/path/to/data.json';
$json_manager->set_file($file_path);

// Existing content in the JSON file
$existingContent = [
    'name' => 'John Doe',
    'age' => 30,
    'details' => [
        'city' => 'Old City',
        'country' => 'Old Country'
    ]
];

// New content to be merged with the existing content
$newContent = [
    'age' => 31,
    'details' => [
        'city' => 'New City'
    ]
];

// Merge the new content with the existing content in the JSON file
$json_manager->merge($newContent, 'details');

// The JSON file now contains the merged content

```

This method provides a convenient way to integrate content merging into the workflow of the JSONManager class, facilitating dynamic updates and extensions to JSON data within the application. The optional **`$dot`** parameter allows for targeted merges within nested structures.

---

## pop

Description:

The **`pop`** method in the **`JSONManager`** class is utilized to remove and return the last element from an array or object within the specified JSON file. This method allows developers to perform a "pop" operation on the data structure stored in the JSON file, facilitating the removal of elements.

Syntax:

```php
$json_manager->pop(string $dot = null);
```

**Parameters**:

- **`$dot` (optional)`**: A string parameter that represents the dot notation for the nested array or object elements within the JSON structure. It specifies the location from which the last element should be popped. If not specified, the pop operation applies to the entire content of the JSON file.

**Usage Example** 

```php
$json_manager = new JSONManager();

// Set the file path for subsequent operations
$file_path = '/path/to/data.json';
$json_manager->set_file($file_path);

// Existing content in the JSON file
$existingContent = [
    'items' => ['apple', 'banana', 'orange'],
    'details' => [
        'city' => 'Old City',
        'country' => 'Old Country'
    ]
];

// Pop the last element from the 'items' array in the JSON file
$lastItem = $json_manager->pop('items');

// Now $lastItem contains the popped element, and the JSON file is updated

```

This method provides a convenient way to integrate "pop" operations into the workflow of the JSONManager class, facilitating the removal of elements from arrays or objects within the JSON data. The optional **`$dot`** parameter allows for targeted pops within nested structures.

---

## push

Description:

The **`push`** method in the JSONManager class is used to append an element to the end of an array within the specified JSON file. This method facilitates the addition of elements to the data structure stored in the JSON file.

Syntax:

```php
$json_manager->push($content, string $dot = null);
```

**Parameters**:

- **`$content`**: The element to be added to the end of the array.
- **`$dot` (optional)`**: A string parameter representing the dot notation for nested array elements within the JSON structure. It specifies the location where the element should be added. If not specified, the element is appended to the end of the array in the entire content of the JSON file.

**Usage Example** 

```php
$json_manager = new JSONManager();

// Set the file path for subsequent operations
$file_path = '/path/to/data.json';
$json_manager->set_file($file_path);

// Existing content in the JSON file
$existingContent = [
    'items' => ['apple', 'banana', 'orange'],
    'details' => [
        'city' => 'Old City',
        'country' => 'Old Country'
    ]
];

// Element to be added
$newItem = 'pear';

// Append the element to the end of the 'items' array in the JSON file
$json_manager->push($newItem, 'items');

// The JSON file is updated with the new element added to the end of the 'items' array

```

This method provides a convenient way to integrate "push" operations into the workflow of the JSONManager class, facilitating the addition of elements to arrays within the JSON data. The optional **`$dot`** parameter allows for targeted appending within nested structures.

---

## shift

Description:

The **`shift`** method in the **`JSONManager`** class is employed to remove and return the first element from an array or object within the specified JSON file. This method allows developers to perform a "shift" operation on the data structure stored in the JSON file, facilitating the removal of elements from the beginning of the array or object.

Syntax:

```php
$json_manager->shif(string $dot = null);
```

**Parameters**:

- **`$dot` (optional)`**: A string parameter that represents the dot notation for nested array or object elements within the JSON structure. It specifies the location from which the first element should be shifted. If not specified, the shift operation applies to the entire content of the JSON file.

**Usage Example** 

```php
$json_manager = new JSONManager();

// Set the file path for subsequent operations
$file_path = '/path/to/data.json';
$json_manager->set_file($file_path);

// Existing content in the JSON file
$existingContent = [
    'items' => ['apple', 'banana', 'orange'],
    'details' => [
        'city' => 'Old City',
        'country' => 'Old Country'
    ]
];

// Shift the first element from the 'items' array in the JSON file
$firstItem = $json_manager->shift('items');

// Now $firstItem contains the shifted element, and the JSON file is updated

```

This method provides a convenient way to integrate "shift" operations into the workflow of the JSONManager class, facilitating the removal of elements from arrays or objects within the JSON data. The optional **`$dot`** parameter allows for targeted shifts within nested structures.

---

## unset

Description:

The **`unset`** method in the **`JSONManager`** class is utilized to remove an element by dot notation from the specified JSON file. This method allows developers to unset or delete a specific element within the JSON data structure, providing a mechanism for removing targeted elements.

Syntax:

```php
$json_manager->unset(string $dot, bool $reindexed = false);
```

**Parameters**:

- **`$dot`**: A string parameter that represents the dot notation for a nested array or object elements within the JSON structure. It specifies the location from which the element should be unset.
- **`$reindexed`** (optional): A boolean parameter that determines whether the array should be reindexed after unsetting an element. If set to true, the array indices will be reindexed. The default value is **`false`**.

**Usage Example** 

```php
$json_manager = new JSONManager();

// Set the file path for subsequent operations
$file_path = '/path/to/data.json';
$json_manager->set_file($file_path);

// Existing content in the JSON file
$existingContent = [
    'items' => ['apple', 'banana', 'orange'],
    'details' => [
        'city' => 'Old City',
        'country' => 'Old Country'
    ]
];

// Unset the 'items' array from the JSON file
$json_manager->unset('items');

// The 'items' array is now removed from the JSON file

```

This method provides a convenient way to integrate "unset" operations into the workflow of the JSONManager class, facilitating the removal of specific elements from arrays or objects within the JSON data. The optional **`$reindexed`** parameter allows for additional control over array reindexing after unsetting an element.

---

## unshift

Description:

The **`unshift`** method in the **`JSONManager`** class is utilized to add an element to the beginning of an array within the specified JSON file. This method allows developers to prepend new elements to the beginning of an array, providing a mechanism for dynamic updates to the JSON data.

Syntax:

```php
$json_manager->unshift($content, string $dot = null)
```

**Parameters**:

- **`$content`**: The data to be added to the beginning of the array in the JSON file. It can be an array, object, string, number, boolean, or null.
- **`$dot` (optional)`**: A string parameter that represents the dot notation for nested array or object elements within the JSON structure. It specifies the location where the new element should be added. If not specified, the unshift operation applies to the entire content of the JSON file.

**Usage Example** 

```php
$json_manager = new JSONManager();

// Set the file path for subsequent operations
$file_path = '/path/to/data.json';
$json_manager->set_file($file_path);

// Existing content in the JSON file
$existingContent = [
    'items' => ['banana', 'orange'],
    'details' => [
        'city' => 'Old City',
        'country' => 'Old Country'
    ]
];

// New content to be added to the beginning of the 'items' array
$newItem = 'apple';
$json_manager->unshift($newItem, 'items');

// The 'items' array now contains 'apple' at the beginning in the JSON file

```

This method provides a convenient way to integrate "unshift" operations into the workflow of the JSONManager class, facilitating the addition of elements to the beginning of arrays within the JSON data. The optional **`$dot`** parameter allows for targeted unshifts within nested structures.

---