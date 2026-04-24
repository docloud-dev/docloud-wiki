# Common Functions

Owner: Nuwan Danushka

# Introduction

Your Essential Toolkit for Simplified Development with Do Framework. From generating domain names with createDomain to parsing HTTP headers with parse headers, Common Functions streamlines a myriad of development tasks. Whether it's decoding emoticons, converting file sizes, or sanitizing input variables, this versatile component offers a comprehensive set of tools to optimize workflows and enhance application functionality. With Common Functions, developers can tackle common challenges effortlessly, ensuring efficient and reliable development processes within the Do Framework ecosystem.

---

## Common Functions Methods

### createDomain

Description:

The **`createDomain`** method is utilized to create a domain based on the HTTP host. This function retrieves the HTTP host from the server environment variables ($_SERVER).

Syntax:

```php
$common_function_obj->createDomain();
```

**Return Value:**

- If the HTTP host is set, it returns the value.
- Otherwise, it returns false.

This method fetches the HTTP host from the server environment variables ($_SERVER) and returns it, or returns false if it's not set.

---

### requestScheme

Description:

The **`requestScheme`** method is utilized to retrieve the request scheme. This function retrieves the request scheme from the server environment variables ($_SERVER).

Syntax:

```php
$common_function_obj->requestScheme();
```

**Return Value:**

- If the request scheme is set, it returns the value.
- Otherwise, it returns false.

This method fetches the request scheme from the server environment variables ($_SERVER) and returns it, or returns false if it's not set.

---

### parseHeaders

Description:

The **`parseHeaders`** method is utilized to parse HTTP headers into an associative array. This function iterates through each header line, splitting it by the first colon encountered. If the header contains a colon, it interprets the text before the colon as the key and the text after the colon as the value. If there's no colon, it assumes it's an HTTP status line and extracts the response code.

Syntax:

```php
$common_function_obj->parseHeaders($headers);
```

**Parameters:**

- **`$headers`**: The HTTP headers to be parsed.

**Return Value:**

- **`array`**: The parsed headers as an associative array.
- In case of failure, an empty array is returned.

This method parses HTTP headers into an associative array, interpreting each header line to extract the key-value pairs.

---

### rel2abs

Description:

The **`rel2abs`** method is utilized to convert a relative URL to an absolute URL based on a base URL. This function takes a relative URL and a base URL and converts the relative URL to an absolute URL.

Syntax:

```php
$common_function_obj->rel2abs($rel, $base);
```

**Parameters:**

- **`$rel`**: The relative URL.
- **`$base`**: The base URL.

**Return Value:**

- **`string`**: The absolute URL.
- In case of failure, an empty string is returned.

This method converts a relative URL to an absolute URL using the provided base URL. If the operation fails, it returns an empty string.

---

### FindUrlAndParameters

Description:

The **`FindUrlAndParameters`** method is utilized to search for a URL and its parameters in a given string. It extracts the first URL found and parses it to extract its query parameters. Then, it checks if the parameter "Response" is set to "1”

Syntax:

```php
$common_function_obj->FindUrlAndParameters($string);
```

**Parameters:**

- **`$string`**: The string to search for URLs and parameters.

**Return Value:**

- **`true`** if the "Response" parameter is set to "1".
- **`false`** otherwise.

This method searches for a URL and its parameters in the given string. It then checks if the "Response" parameter is set to "1" and returns the corresponding boolean value.

---

### decodeEmoticons

Description:

The **`decodeEmoticons`** method is utilized to decode emoticons represented in Unicode escape sequences into UTF-8 characters.

Syntax:

```php
$common_function_obj->decodeEmoticons($src);
```

**Parameters:**

- **`$src`**:  The string containing emoticons represented in Unicode escape sequences.

**Return Value:**

- The string with emoticons is decoded into UTF-8 characters.

This method is used to decode emoticons represented in Unicode escape sequences back into their original UTF-8 characters.

---

### sizeConverter

Description:

The **`sizeConverter`** method is utilized to convert a size value from one unit to another.

Syntax:

```php
$common_function_obj->sizeConverter($value, $unit);
```

**Parameters:**

- **`$value`**: The size value to convert.
- **`$src`**:  The unit of the size value (e.g., MB, GB).

**Return Value:**

- The converted size value.

This method is used to convert a size value from one unit to another. For example, converting from megabytes to gigabytes.

---

### stringWithSquareBracket

Description:

The **`stringWithSquareBracket`** method is utilized to extract text enclosed within square brackets from an input string.

Syntax:

```php
$common_function_obj->stringWithSquareBracket($text);
```

**Parameters:**

- **`$text`**: The input string.

**Return Value:**

- An array containing text enclosed within square brackets, including the square brackets themselves.

This method is used to extract text enclosed within square brackets from an input string. For example, it can be used to extract metadata or specific identifiers enclosed within square brackets.

---

### stringWithoutSquareBracket

Description:

The **`stringWithoutSquareBracket`** method is utilized to remove text enclosed within square brackets from a given string.

Syntax:

```php
$common_function_obj->stringWithoutSquareBracket($text);
```

**Parameters:**

- **`$text`**: The input string.

**Return Value:**

- **`string`**: The input string with text enclosed within square brackets removed.

This method is used to remove text enclosed within square brackets from an input string. For example, it can be used to extract metadata or specific identifiers enclosed within square brackets.

---

### convert_from_latin1_to_utf8_recursively

Description:

The **`convert_from_latin1_to_utf8_recursively`** method is utilized to recursively convert data from 

ISO-8859-1 (Latin-1) encoding to UTF-8 encoding.

Syntax:

```php
$common_function_obj->convert_from_latin1_to_utf8_recursively($data);
```

**Parameters:**

- **`$data`**: The input data (string, array, or object) to be converted.

**Return Value:**

- **`string`**: The converted data with strings converted to UTF-8.

This function recursively traverses through the input data and converts any strings found from ISO-8859-1 encoding to UTF-8 encoding.

---

### detectEncoding

Description:

The **`detectEncoding`** method is utilized to detect the encoding of a string.

Syntax:

```php
$common_function_obj->detectEncoding($string);
```

**Parameters:**

- `$string`:  The input string to detect encoding.

**Return Value:**

- **`string`**: The detected encoding of the string
- **`false`:** if the encoding could not be determined.

This function detects the encoding of the input string using the mb_detect_encoding function with a list of supported encodings.

---

### varSanitize

Description:

The **`varSanitize`** method is utilized to sanitize a variable by extracting URLs from it.

Syntax:

```php
$common_function_obj->varSanitize($var);
```

**Parameters:**

- `$string`:  The variable to be sanitized.

**Return Value:**

- `Array`: An array containing all URLs extracted from the variable.
- If no URLs are found, it returns an empty array.

This method extracts URLs from the provided variable and returns them in an array. If no URLs are found, it returns an empty array.

---

### countryList

Description:

The **`countryList`** method is utilized to get a list of countries with their corresponding country codes.

Syntax:

```php
$common_function_obj->countryList();
```

**Return Value:**

- `Array`: An associative array of countries with country codes as keys and country names as values.

This method returns an associative array containing a list of countries along with their corresponding country codes. The country codes serve as keys, while the country names serve as values.

---

### smsDivider

Description:

The **`smsDivider`** method is utilized to generate an array of start and end dates for SMS messages based on recurring type, start date, and timezone

Syntax:

```php
$common_function_obj->smsDivider($recurringType, $startDate, $timezone);
```

**Parameters:**

- **`$recurringType`**:  The type of recurrence (1: Monthly, 2: Quarterly, 3: Half-yearly, 4: Yearly, 5: One-time).
- **`$startDate`**: The start date for SMS messages.
- **`$timezone`**: The timezone for date calculations.

**Return Value:**

- `Array`:  An array of start and end dates for SMS messages.
- If no SMS messages are generated, it returns an empty array.

This method generates an array of start and end dates for SMS messages based on the provided recurring type, start date, and timezone.

---

### maxValueInArray

Description:

The **`maxValueInArray`** method is utilized to find the maximum value associated with a specific key in a multidimensional array.

Syntax:

```php
$common_function_obj->maxValueInArray($array, $keyToSearch);
```

**Parameters:**

- **`$keyToSearch`**:  The key to search for in the nested arrays.
- **`$array`:** The multidimensional array to search.

**Return Value:**

- The maximum value associated with the specified key, or NULL if the key is not found in any array.

This method searches through a multidimensional array to find the maximum value associated with the specified key. If the key is not found in any array, it returns **`NULL`**.

---