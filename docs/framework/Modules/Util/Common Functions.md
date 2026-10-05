---
title: Common Functions
sidebar_label: Common Functions
---

# Common Functions

Owner: Nuwan Danushka

# Introduction

`CommonFunction` is a grab bag of small helpers: reading the request host and scheme, parsing HTTP headers, resolving relative URLs, converting file sizes, string and encoding helpers, a country list, and input sanitizing and validation.

The methods are instance methods. Get an object through the Util accessor:

```php
$common_function_obj = Util::CommonFunction();
```

---

# How to sanitize and validate request data

Use `sanitize` to clean values before you store or echo them, and `validateData` to check that they have the right type.

```php
$common_function_obj = Util::CommonFunction();

// Sanitize two fields with named filter types
$clean = $common_function_obj->sanitize($data, [
    'name'  => 'string',
    'email' => 'email',
]);

// Check types on the raw data: returns false when everything is valid
$error = $common_function_obj->validateData($data, [
    'email' => FILTER_VALIDATE_EMAIL,
    'age'   => [
        'filter'  => FILTER_VALIDATE_INT,
        'options' => ['options' => ['min_range' => 1, 'max_range' => 120]],
    ],
]);

if ($error !== false) {
    // $error is a message such as "email, age are invalid."
}
```

---

## Common Functions Methods

### createDomain

Description:

The **`createDomain`** method returns the host name of the current request, read from `$_SERVER['HTTP_HOST']`.

Syntax:

```php
$common_function_obj->createDomain();
```

**Return Value:**

- **`String`**: The host, for example `example.com` or `localhost:8080`.
- **`false`**: There is no `HTTP_HOST`, for example in a shell or heartbeat run.

---

### requestScheme

Description:

The **`requestScheme`** method returns the scheme of the current request, read from `$_SERVER['REQUEST_SCHEME']`.

Syntax:

```php
$common_function_obj->requestScheme();
```

**Return Value:**

- **`String`**: `http` or `https`.
- **`false`**: `REQUEST_SCHEME` is not set. Some servers and proxies don't set it.

---

### parseHeaders

Description:

The **`parseHeaders`** method turns a list of raw HTTP header lines into an associative array. Each `Name: value` line becomes a key and value. A line without a colon (the status line, such as `HTTP/1.1 200 OK`) is added with a numeric key, and its status code is stored under `response_code`.

Syntax:

```php
$response = file_get_contents('https://example.com');
$headers = $common_function_obj->parseHeaders($http_response_header);
// ['HTTP/1.1 200 OK', 'response_code' => 200, 'Content-Type' => 'text/html', ...]
```

**Parameters:**

- **`$headers`**: An array of header lines, such as PHP's `$http_response_header`.

**Return Value:**

- **`Array`**: The parsed headers. An empty input gives an empty array.

---

### rel2abs

Description:

The **`rel2abs`** method converts a relative URL to an absolute URL, using a base URL.

Syntax:

```php
$common_function_obj->rel2abs('../img/logo.png', 'https://example.com/docs/page.html');
// "https://example.com/img/logo.png"
```

**Parameters:**

- **`$rel`**: The relative URL. If it already has a scheme, it is returned unchanged.
- **`$base`**: The base URL.

**Return Value:**

- **`String`**: The absolute URL.

---

### FindUrlAndParameters

Description:

The **`FindUrlAndParameters`** method finds the first URL in a string and checks whether its query string contains `Response=1`.

Syntax:

```php
$common_function_obj->FindUrlAndParameters($string);
```

**Parameters:**

- **`$string`**: The string to search for a URL.

**Return Value:**

- **`true`**: The first URL has the query parameter `Response` set to `1`.
- **`false`**: Otherwise, including when the string has no URL.

---

### decodeEmoticons

Description:

The **`decodeEmoticons`** method replaces Unicode escape sequences (`\uXXXX`) in a string with the UTF-8 characters they stand for.

Syntax:

```php
$common_function_obj->decodeEmoticons($src);
```

**Parameters:**

- **`$src`**: The string containing escape sequences.

**Return Value:**

- **`String`**: The string with the escapes decoded.

---

### sizeConverter

Description:

The **`sizeConverter`** method converts a size in `B`, `KB`, `MB`, `GB` or `TB` to **bytes**, using 1024 as the step. It converts only to bytes, never between other units.

Syntax:

```php
$bytes = $common_function_obj->sizeConverter(2, 'MB');   // 2097152
```

**Parameters:**

- **`$value`**: The size, as a number or numeric string.
- **`$unit`**: The unit of `$value`: `B`, `KB`, `MB`, `GB` or `TB`. Case matters: `mb` is not recognised.

**Return Value:**

- **`Integer`** or **`Float`**: The size in bytes.
- **`false`**: The unit is not recognised.

---

### stringWithSquareBracket

Description:

The **`stringWithSquareBracket`** method extracts every piece of text enclosed in square brackets from a string.

Syntax:

```php
$common_function_obj->stringWithSquareBracket('Hello [name], your code is [code]');
// ['[name]', '[code]']
```

**Parameters:**

- **`$text`**: The input string.

**Return Value:**

- **`Array`**: Each bracketed piece, including the brackets.

---

### stringWithoutSquareBracket

Description:

The **`stringWithoutSquareBracket`** method removes every bracketed piece, brackets included, from a string.

Syntax:

```php
$common_function_obj->stringWithoutSquareBracket('Total [draft] 100');
// "Total  100"
```

**Parameters:**

- **`$text`**: The input string.

**Return Value:**

- **`String`**: The input string without the bracketed text.

---

### convert_from_latin1_to_utf8_recursively

Description:

The **`convert_from_latin1_to_utf8_recursively`** method converts strings from ISO-8859-1 (Latin-1) to UTF-8. It walks through arrays and object properties recursively.

Syntax:

```php
$common_function_obj->convert_from_latin1_to_utf8_recursively($data);
```

**Parameters:**

- **`$data`**: A string, array or object.

**Return Value:**

- **`Mixed`**: The same structure with every string converted. Values that are not strings, arrays or objects are returned unchanged. Objects are changed in place.

---

### detectEncoding

Description:

The **`detectEncoding`** method detects the encoding of a string with `mb_detect_encoding`, trying every encoding that mbstring supports.

Syntax:

```php
$common_function_obj->detectEncoding($string);
```

**Parameters:**

- **`$string`**: The input string.

**Return Value:**

- **`String`**: The detected encoding.
- **`false`**: The encoding could not be determined.

---

### varSanitize

Description:

The **`varSanitize`** method extracts every `http` or `https` URL from a string. Despite its name, it does not clean the input. Use `sanitize` for that.

Syntax:

```php
$common_function_obj->varSanitize($var);
```

**Parameters:**

- **`$var`**: The string to search.

**Return Value:**

- **`Array`**: Every URL found. An empty array if there are none.

---

### countryList

Description:

The **`countryList`** method returns a list of countries keyed by ISO 3166-1 alpha-2 code.

Syntax:

```php
$countries = $common_function_obj->countryList();
// ['AF' => 'Afghanistan', ..., 'LK' => 'Sri Lanka', ...]
```

**Return Value:**

- **`Array`**: Country codes as keys and country names as values.

---

### smsDivider

Description:

The **`smsDivider`** method splits a billing period into monthly start and end dates, based on a recurring type.

Syntax:

```php
$common_function_obj->smsDivider($recurringType, $startDate, $timezone);
```

**Parameters:**

- **`$recurringType`**: `1` monthly, `2` quarterly, `3` half-yearly, `4` yearly, `5` one-time.
- **`$startDate`**: The start date, in `Y-m-d` format.
- **`$timezone`**: The time zone for the date calculations.

**Return Value:**

- **`Array`**: One entry per month, each with `s_date` and `e_date` keys.
- An empty array if the type is not supported or a date is invalid. The error is logged.

<aside>
⚠️ The periods are not calendar months. The method uses `getNextPayDate`, which moves each month result to the last day of the month (see [Date And Time Manager](Date%20And%20Time%20Manager.md)), and it adds a growing number of months to a start date that has already moved. For example, a quarterly split from `2024-01-15` returns `2024-01-15` to `2024-02-28`, then `2024-02-29` to `2024-04-29`, then `2024-04-30` to `2024-07-30`. Check the output before you rely on it.

</aside>

---

### maxValueInArray

Description:

The **`maxValueInArray`** method finds the largest value stored under a given key across the rows of a two-dimensional array.

Syntax:

```php
$rows = [['qty' => 3], ['qty' => 8], ['price' => 10]];
$common_function_obj->maxValueInArray($rows, 'qty');   // 8
```

**Parameters:**

- **`$array`**: The array of rows to search.
- **`$keyToSearch`**: The key to look for in each row.

**Return Value:**

- The largest value found under that key, or **`null`** if no row has the key.

---

### sanitize

Description:

The **`sanitize`** method cleans an array of input with PHP's `filter_var_array`. With no field list, it applies one filter to every value. With a field list, it applies a named filter type to each listed field.

Syntax:

```php
// Escape every value (and every value inside nested arrays)
$clean = $common_function_obj->sanitize($inputs);

// Sanitize selected fields only
$clean = $common_function_obj->sanitize($inputs, ['name' => 'string', 'email' => 'email']);
```

**Parameters:**

- **`$inputs`**: The array to sanitize, for example the request data.
- **`$fields`**: Optional. Maps each field name to a filter type name. The built-in types are:
  - **`string`**: `FILTER_SANITIZE_FULL_SPECIAL_CHARS` (HTML special characters escaped).
  - **`string[]`**: The same filter, for a field that holds an array of strings.
  - **`email`**: `FILTER_SANITIZE_EMAIL`.
  - **`int`**: `FILTER_SANITIZE_NUMBER_INT` (keeps digits, `+` and `-`).
- **`$default_filter`**: The filter used when `$fields` is empty. Default: `FILTER_SANITIZE_FULL_SPECIAL_CHARS`.
- **`$filters`**: Optional. Your own map of type names to filters, used instead of the built-in types. The format matches the definitions accepted by `filter_var_array`.

**Return Value:**

- **`Array`**: The sanitized data. With a field list, the result holds **only** the listed fields. A listed field missing from the input is returned as `null`.

---

### validateData

Description:

The **`validateData`** method checks values in an array against `filter_var` validation filters and reports the fields that fail.

Syntax:

```php
$error = $common_function_obj->validateData($data, [
    'email' => FILTER_VALIDATE_EMAIL,
    'age'   => ['filter' => FILTER_VALIDATE_INT, 'options' => ['options' => ['min_range' => 1]]],
]);
```

**Parameters:**

- **`$data`**: The array to check.
- **`$validation_rules`**: Maps each field name to a rule. A rule is either a filter constant or an array with a `filter` key and an optional `options` key. `options` is passed to `filter_var` as its third argument, so it uses the same `options` and `flags` keys.

**Return Value:**

- **`false`**: Every field that has a rule and is present in `$data` passed.
- **`String`**: A message listing the failed fields, such as `age is invalid.` or `email, age are invalid.`

Fields that have a rule but are missing from `$data` are skipped, not reported. Check required fields separately. `FILTER_VALIDATE_BOOLEAN` reports a valid `false` value as a failure.

<aside>
💡 On PHP 8.2 and later, each passing field raises a "Creation of dynamic property" deprecation notice, which shows up in the log when deprecations are reported. The validation result is not affected.

</aside>

---
