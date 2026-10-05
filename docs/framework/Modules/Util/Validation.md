---
title: Validation
sidebar_label: Validation
---

# Validation

Owner: Nuwan Danushka

# Introduction

The `Validation` class holds checks for common input: email addresses, phone numbers, Sri Lankan NIC numbers, US ZIP codes, URLs, passwords, Base64 and JSON. Get an object through the Util accessor:

```php
$validation_object = Util::Validation();

if (!$validation_object->emailValidation($email)) {
    // reject the request
}
```

To validate several fields of a request at once with PHP filters, see `validateData` in [Common Functions](Common%20Functions.md).

---

## Validation Methods

### phoneValidation

Description:

The **`phoneValidation`** method checks a phone number against three fixed formats.

Accepted formats:

- **`(+94)771234567`**: 14 characters. `(+`, a 2-digit country code, `)`, then 9 digits.
- **`+94771234567`**: 12 characters. `+` then 11 digits.
- **`0771234567`**: 10 characters. `0` then 9 digits.

Spaces, dashes and other lengths are rejected.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->phoneValidation($phone);
```

**Parameters:**

- **`$phone`**: The phone number to validate.

**Return Value:**

- **`Boolean`**: `true` if the number matches one of the formats, `false` otherwise.

<aside>
⚠️ In the 12-character format only the first 10 characters after `+` are checked, so the last character can be anything: `+9477123456x` passes. Use `validateAllPhone2` if you need every character checked.

</aside>

---

### nicValidation

Description:

The **`nicValidation`** method checks a Sri Lankan NIC number in the old 10-character format: 9 digits followed by one non-digit character.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->nicValidation($nic);
```

**Parameters:**

- **`$nic`**: The NIC number to validate, such as `123456789V`.

**Return Value:**

- **`Boolean`**: `true` if the NIC has the old format, `false` otherwise.

The method does not accept the 12-digit NIC format, and it accepts any letter in the last position, not only `V` or `X`.

---

### emailValidation

Description:

The **`emailValidation`** method checks an email address with PHP's `FILTER_VALIDATE_EMAIL` filter.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->emailValidation($email);
```

**Parameters:**

- **`$email`**: The email address to validate.

**Return Value:**

- **`Boolean`**: `true` if the email is valid, `false` otherwise.

---

### arrayKeyExists

Description:

The **`arrayKeyExists`** method counts how many of the given keys exist in an array.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->arrayKeyExists(['name', 'email'], $data);

if ($result !== 2) {
    // a required key is missing
}
```

**Parameters:**

- **`$keys`**: A list of key names.
- **`$checkArray`**: The array to look in.

**Return Value:**

- **`Integer`**: How many of `$keys` are keys of `$checkArray`.

---

### imageStringValidation

Description:

The **`imageStringValidation`** method decodes a Base64 string and returns the decoded data if it is plain ASCII text. Despite its name, it does not check for an image, and it rejects real binary images.

It returns the decoded data only when both checks pass:

1. Decoding the string and encoding it again gives exactly the original string. A `data:image/png;base64,` prefix, line breaks or missing padding make this fail.
2. `mb_detect_encoding` reports the decoded data as `ASCII`.

PNG, JPEG, GIF and WebP files contain bytes outside the ASCII range, so they fail the second check and the method returns `false`. A Base64-encoded SVG file or any other ASCII text passes.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->imageStringValidation($imageString);
```

**Parameters:**

- **`$imageString`**: A Base64 string, without a `data:` prefix.

**Return Value:**

- **`String`**: The decoded data, when it is valid Base64 of ASCII-only content.
- **`false`**: Otherwise, including for every PNG or JPEG image.

To accept uploaded images, check the Base64 with `validateBase64String`, then check the decoded bytes with PHP's `getimagesizefromstring()` or `finfo`.

---

### validateUSAZip

Description:

The **`validateUSAZip`** method checks a US ZIP code: five digits, optionally followed by a dash and four more digits.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validateUSAZip($zip_code);
```

**Parameters:**

- **`$zip_code`**: The ZIP code to validate, such as `90210` or `90210-1234`.

**Return Value:**

- **`Boolean`**: `true` if the ZIP code is valid, `false` otherwise.

---

### valid_phone

Description:

The **`valid_phone`** method checks a phone number and returns it in a normalised form. It recognises US numbers in most common layouts. With `$international` set to `true`, it also accepts other numbers that have at least 8 digits.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->valid_phone('(212) 555-1234 ext 5');          // "212-555-1234 ext 5"
$result = $validation_object->valid_phone('+94 77 123 4567', true);         // "+94 77 123 4567"
```

**Parameters:**

- **`$str`**: The phone number to validate.
- **`$international`**: Optional. `true` to accept non-US numbers. Default: `false`.

**Return Value:**

- **`String`**: A US number as `NNN-NNN-NNNN`, followed by a space and `ext N` when there is an extension. An international number is returned trimmed.
- **`false`**: The number is not valid. Without `$international`, every non-US number returns `false`.

---

### validateAllPhone2

Description:

The **`validateAllPhone2`** method removes `(`, `)`, `-`, `.` and spaces from a phone number, then checks that what's left is 10 to 15 digits, optionally starting with `+`.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validateAllPhone2('+94 (77) 123-4567');   // "+94771234567"
```

**Parameters:**

- **`$phone`**: The phone number to validate.

**Return Value:**

- **`String`**: The cleaned number, with its leading `+` if it had one.
- **`false`**: The number is not valid.

---

### validateAllPhone

Description:

The **`validateAllPhone`** method checks a phone number against several regional patterns (international, North American, UK, French and Sri Lankan). If none matches, it accepts any number with 10 to 15 digits, optionally starting with `+`. The check is permissive.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validateAllPhone($phone);
```

**Parameters:**

- **`$phone`**: The phone number to validate. `(`, `)`, `-`, `.` and spaces are removed first.

**Return Value:**

- **`Boolean`**: `true` if the number is valid, `false` otherwise.

---

### validateLKRPhone

Description:

The **`validateLKRPhone`** method checks a Sri Lankan **mobile** number. Landline numbers are rejected.

It removes every non-digit character and any leading zeros. Then:

- With exactly 9 digits left, the number must start with a mobile prefix (see `check_for_mobile`).
- With more than 9 digits, the last 9 must start with a mobile prefix, and the digits before them must be `94`.

Syntax:

```php
$validation_object = Util::Validation();
$validation_object->validateLKRPhone('077 123 4567');   // true
$validation_object->validateLKRPhone('+94771234567');   // true
$validation_object->validateLKRPhone('0112345678');     // false: landline
```

**Parameters:**

- **`$phone`**: The phone number to validate.

**Return Value:**

- **`Boolean`**: `true` if the number is a valid Sri Lankan mobile number, `false` otherwise.

---

### check_for_mobile

Description:

The **`check_for_mobile`** method checks whether a number starts with a Sri Lankan mobile prefix: `70`, `71`, `72`, `75`, `76`, `77` or `78`. It only looks at the first two characters.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->check_for_mobile('771234567');
```

**Parameters:**

- **`$num`**: The number without the leading `0` or country code.

**Return Value:**

- **`Boolean`**: `true` if the number starts with a mobile prefix, `false` otherwise.

---

### validateBase64String

Description:

The **`validateBase64String`** method checks that a string is valid, canonical Base64. It decodes the string in strict mode, encodes it again and compares the result with the input.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validateBase64String($data);
```

**Parameters:**

- **`$data`**: The string to validate. A `data:` prefix or line breaks make it fail.

**Return Value:**

- **`Boolean`**: `true` if the string is valid Base64, `false` otherwise.

---

### checkURL

Description:

The **`checkURL`** method checks whether a string is a valid URL, using PHP's `FILTER_VALIDATE_URL` filter.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->checkURL($string);
```

**Parameters:**

- **`$string`**: The string to check. It needs a scheme, such as `https://`.

**Return Value:**

- **`Boolean`**: `true` if the string is a valid URL, `false` otherwise.

---

### validatePassword

Description:

The **`validatePassword`** method checks that a password meets these rules:

1. At least 6 characters long.
2. Contains at least one uppercase letter.
3. Contains at least one lowercase letter.
4. Contains at least one digit (0-9).

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validatePassword($password);
```

**Parameters:**

- **`$password`**: The password to check.

**Return Value:**

- **`Boolean`**: `true` if the password meets all rules, `false` otherwise.

---

### isJson

Description:

The **`isJson`** method checks whether a string is valid JSON by decoding it with `json_decode()`.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->isJson($string);
```

**Parameters:**

- **`$string`**: The string to check.

**Return Value:**

- **`Boolean`**: `true` if the string decodes without errors, `false` otherwise. Scalar JSON such as `123` or `"text"` also counts as valid. An empty string is not valid.

---
