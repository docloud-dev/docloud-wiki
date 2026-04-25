# Validation

Owner: Nuwan Danushka

# Introduction

Introducing the Validation Class : Elevating Data Integrity in the Do Framework. This module offers a variety of validation methods, empowering developers to ensure robust data integrity within their applications.

---

## Validation Methods

### phoneValidation

Description:

The **`phoneValidation`** method is utilized to validate a phone number if it adheres to one of the accepted formats.

Accepted formats:

- **`(+CountryCode)NNNNNNNNNN`** (14 characters)
- **`+CountryCodeNNNNNNNNNN`** (12 characters)
- **`0NNNNNNNNNN`** (10 characters)

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->phoneValidation($phone);
```

**Parameters:**

- **`$phone`**: The string representation of the phone number to be validated.

**Return Value:**

- **`Boolean`**:  Returns a true if the phone number is valid, false otherwise.

This method validates the provided phone number against the accepted formats. It returns **`true`** if the phone number adheres to one of the specified formats, otherwise it returns **`false`**.

---

### nicValidation

Description:

The **`nicValidation`** method is utilized to validate a Sri Lankan NIC (National Identity Card) number.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->nicValidation($nic);
```

**Parameters:**

- **`$nic`**: The string representation of the NIC to be validated.

**Return Value:**

- **`Boolean`**:  Returns a true if the NIC is valid, false otherwise.

This method validates the provided NIC adheres to the standard format of Sri Lankan NICs. It returns true if the NIC is valid according to the validation, otherwise it returns false.

---

### emailValidation

Description:

The **`emailValidation`** method is utilized to check if the given email address is valid using PHP's built-in email validation filter.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->emailValidation($email);
```

**Parameters:**

- **`$email`**: The string representation of the email to be validated.

**Return Value:**

- **`Boolean`**:  Returns a true if the email is valid, false otherwise.

This method validates the provided email address using PHP's built-in email validation filter. It returns **`true`** if the email is valid according to the filter, otherwise it returns **`false`**.

---

### arrayKeyExists

Description:

The **`arrayKeyExists`** method is utilized to count the number of keys present in an array.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->arrayKeyExists(array $keys, array $checkArray);
```

**Parameters:**

- **`$keys`**: An array of keys to check for existence.
- **`$checkArray`**: The array to check for key existence.

**Return Value:**

- **`Int`**: The count of keys present in the **`$checkArray`**.

This method counts the number of keys present in the **`$checkArray`** that match any of the keys in the **`$keys`** array.

---

### imageStringValidation

Description:

The **`imageStringValidation`** method is utilized to validate if a string is an image encoded in base64 format.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->imageStringValidation($imageString);
```

**Parameters:**

- **`$imageString`**:  The image string to validate.

**Return Value:**

- **`String`**: Returns the decoded image string if valid, **`false`** otherwise.

This method validates whether the provided string is an image encoded in base64 format. If the string is a valid base64-encoded image, it returns the decoded image string. Otherwise, it returns **`false`**.

---

### validateUSAZip

Description:

The **`imageStringValidation`** method is utilized to validate a US ZIP code.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validateUSAZip($zip_code);
```

**Parameters:**

- **`$zip_code`**:  The zip code to validate.

**Return Value:**

- **`Boolean`**: Returns true if the ZIP code is valid, false otherwise.

This method validates whether the provided string is a valid US ZIP code.

---

### valid_phone

Description:

The **`valid_phone`** method is utilized to validate a phone number.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->valid_phone($str, $international = false);
```

**Parameters:**

- **`$str`**: The phone number string to validate.
- **`$international`**: (Optional) A boolean indicating whether the phone number is in international format. Default is **`false`**.

**Return Value:**

- **`Boolean`**: Returns **`true`** if the phone number is valid, **`false`** otherwise.

This method validates whether the provided phone number is valid. If the phone number is in international format, set **`$international`** to **`true`**. It returns **`true`** if the phone number is valid, otherwise it returns **`false`**.

---

### validateAllPhone2

Description:

The **`validateAllPhone2`** method is utilized to validate a phone number using various patterns and formats.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validateAllPhone2($phone);
```

**Parameters:**

- **`$phone`**: The phone number string to validate.

**Return Value:**

- **`Boolean`**: Returns **`true`** if the phone number is valid, **`false`** otherwise.

This method checks if the provided phone number and alidates a phone number and returns it on success, false on failure.

---

### validateAllPhone

Description:

The **`validateAllPhone`** method is utilized to validate a phone number using various patterns and formats.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validateAllPhone($phone);
```

**Parameters:**

- **`$phone`**: The phone number string to validate.

**Return Value:**

- **`Boolean`**: Returns **`true`** if the phone number is valid, **`false`** otherwise.

This method checks if the provided phone number matches any known patterns for international and specific country formats. If it does, it returns true. If not, it proceeds with manual validation to check if the phone number has the correct length and format. If everything passes, it returns true. Otherwise, it returns false.

---

### validateLKRPhone

Description:

The **`validateLKRPhone`** method is utilized to validate a Sri Lankan phone number.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validateLKRPhone($phone);
```

**Parameters:**

- **`$phone`**: The phone number string to validate.

**Return Value:**

- **`Boolean`**: Returns **`true`** if the phone number is valid, **`false`** otherwise.

This function removes all non-numeric characters from the provided phone number, and then checks the length of the cleaned number. If the length is less than 9, it returns false. If the length is 9, it calls the **`Validation::check_for_mobile()`** method to validate the number. If the length is greater than 9, it extracts the last 9 digits and checks if they are a valid mobile number prefix. It also checks if the remaining digits before the prefix are '94', indicating an international Sri Lankan phone number.

---

### check_for_mobile

Description:

The **`check_for_mobile`** method is utilized to validate if a given number is a mobile phone number based on Sri Lankan mobile phone codes.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->check_for_mobile($num);
```

**Parameters:**

- **`$phone`**: The phone number string to check.

**Return Value:**

- **`Boolean`**: Returns **`true`** if the number is a mobile phone number, **`false`** otherwise.

This function takes a numeric string as input and checks if the first two digits of the string match any of the Sri Lankan mobile phone codes ('70', '71', '72', '75', '76', '77', '78'). If a match is found, it returns **`true`**, indicating that the number is a mobile phone number; otherwise, it returns **`false`**.

---

### validateBase64String

Description:

The **`validateBase64String`** method is utilized to validate that a given string is a valid Base64 encoded string.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validateBase64String($data);
```

**Parameters:**

- **`$date`**: The string to validate.

**Return Value:**

- **`Boolean`**: Returns true if the string is a valid Base64 encoded string, false otherwise.

This function checks if the given string is a valid Base64 encoded string by attempting to decode it and then re-encode it. If the re-encoded string matches the original string, it is considered a valid Base64 encoded string.

---

### checkURL

Description:

The **`check_for_mobile`** method is utilized to validate if a given string is a valid URL.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->checkURL($string);
```

**Parameters:**

- **`$string`**: The string to check if it is a valid URL.

**Return Value:**

- **`Boolean`**: Returns **`true`** if the string is a valid URL, **`false`** otherwise.

This function uses the PHP built-in function **`filter_var()`** with **`FILTER_VALIDATE_URL`** to determine if the provided string is a valid URL. If the string passes the URL validation, the function returns **`true`**, indicating that it is a valid URL. Otherwise, it returns **`false`**.

---

### validatePassword

Description:

The **`validatePassword`** method is utilized to validate a password to ensure it meets certain criteria.

- Criteria:
1. Length is at least 6 characters.
2. Contains at least one uppercase letter.
3. Contains at least one lowercase letter.
4. Contains at least one digit (0-9).

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->validatePassword($password);
```

**Parameters:**

- **`$password`**:  The password string to check.

**Return Value:**

- **`Boolean`**: Returns **`true`** if the password meets all criteria, **`false`** otherwise.

This function checks if the provided password meets the criteria, and the function returns true, indicating that it is a valid password. Otherwise, it returns false.

---

### isJson

Description:

The **`isJson`** method is utilized to validate if a string is a valid JSON.

Syntax:

```php
$validation_object = Util::Validation();
$result = $validation_object->isJson($string);
```

**Parameters:**

- **`$string`**:  The string to validate if it is a valid JSON.

**Return Value:**

- **`Boolean`**: Returns true if the string is a valid JSON, false otherwise.

This method checks if the provided string is a valid JSON by attempting to decode it using json_decode(). If the decoding process succeeds without errors, it indicates that the string is valid JSON, and the method returns true. Otherwise, it returns false.

---