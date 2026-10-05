---
title: Encryption
sidebar_label: Encryption
---

# Encryption

Owner: Nuwan Danushka

# Introduction

The Encryption module encrypts and decrypts strings, and packs an array of data into a URL-safe token that you can decode later. It has three classes:

- `Encryption`: the module class. Encrypts and decrypts a stored string, and builds and decodes tokens.
- `EncryptFunctions`: static helpers to encrypt, decrypt and hash a string with a key you choose.
- `Token`: the token functions behind `Encryption::buildToken()` and `Encryption::decodeToken()`, plus `getAuthorizeToken()`.

`Encryption` is loaded automatically. `EncryptFunctions` and `Token` are loaded with it, so reference `Encryption` first (for example with `class_exists('Encryption')`) if you call them before anything else has used the module.

The module encrypts with AES-128-CTR. The key is the `encryption_key` in the `<encryption>` section of `api/config.<environment>.xml`, which you can also change in the admin panel's security settings (see [Configuration Files](../Essentials/Configuration%20Files.md)). The "Encryption Method" setting on that page doesn't affect this module. If you change the key, data and tokens made with the old key can no longer be decrypted.

<aside>
⚠️ Don't use this module's tokens for authentication, and don't use the module to protect passwords, payment details or other sensitive data. For that, use PHP's `sodium_*` functions, or `openssl_encrypt()` with a random IV for each message.

</aside>

---

# How to encrypt

```php
$encryption = new Encryption();
$encryption->setString("Hello World");
$encrypted_string = $encryption->getEncryptedData();
```

`getEncryptedData()` encrypts the stored string with the configured key and returns a base64 string, or `false` if encryption fails.

You can also pass the string to the constructor under the `do_token` key:

```php
$encryption = new Encryption(['do_token' => "Hello World"]);
$encrypted_string = $encryption->getEncryptedData();
```

---

# How to decrypt

Store the encrypted string with `setString()`, then call `getDecryptedData()`:

```php
$decryption = new Encryption();
$decryption->setString($encrypted_string);
$decrypted_data = $decryption->getDecryptedData(); // "Hello World"
```

`getDecryptedData()` returns `false` if decryption fails.

---

# How to build a token

A token holds an array of data as a single URL-safe string, so you can put it in a link:

```php
$token_data = array(
    "user_id" => $user_id,
    "email" => $email,
    "expire" => strtotime('+1 day')
);

$token = Encryption::buildToken($token_data);
```

`buildToken()` returns the token string, or `null` if it fails. The token grows with the data you put in it.

---

# How to decode a token

```php
$decoded_data = Encryption::decodeToken($token);

if ($decoded_data === null) {
    // Not a valid token.
}

$user_id = $decoded_data['user_id'] ?? null;
$expire = $decoded_data['expire'] ?? null;

if ($expire === null || $expire < time()) {
    // Expired.
}
```

`decodeToken()` returns the array you passed to `buildToken()`, or `null` if the token can't be decoded. A token doesn't expire on its own: if you need an expiry, store it in the data and check it yourself, as above.

---

# Encryption Methods

## Encryption class

### __construct

Description:

The **`__construct`** method reads the encryption key from the config. If `$data` has a `do_token` key, its value becomes the stored string.

Syntax:

```php
$encryption = new Encryption($data = null);
```

**Parameters:**

- **`$data`** (optional): An array. Only the `do_token` key is used.

---

### setString

Description:

The **`setString`** method stores the string that `getEncryptedData()` or `getDecryptedData()` works on.

Syntax:

```php
$encryption->setString($string);
```

**Parameters:**

- **`$string`**: Plain text to encrypt, or encrypted text to decrypt.

---

### getString

Description:

The **`getString`** method returns the stored string.

Syntax:

```php
$string = $encryption->getString();
```

---

### getEncryptedData

Description:

The **`getEncryptedData`** method encrypts the stored string with the configured key.

Syntax:

```php
$encrypted = $encryption->getEncryptedData();
```

**Return Value:**

- **`String`**: The encrypted text, base64-encoded.
- **`false`**: Encryption failed.

---

### getDecryptedData

Description:

The **`getDecryptedData`** method decrypts the stored string with the configured key.

Syntax:

```php
$plain = $encryption->getDecryptedData();
```

**Return Value:**

- **`String`**: The decrypted text.
- **`false`**: Decryption failed.

---

### buildToken

Description:

The **`buildToken`** static method serializes and encrypts an array into a URL-safe token.

Syntax:

```php
$token = Encryption::buildToken(array $data);
```

**Parameters:**

- **`$data`**: The data to put in the token.

**Return Value:**

- **`String`**: The token.
- **`null`**: Building the token failed.

---

### decodeToken

Description:

The **`decodeToken`** static method decrypts a token made by `buildToken()`.

Syntax:

```php
$data = Encryption::decodeToken(string $token);
```

**Parameters:**

- **`$token`**: The token string.

**Return Value:**

- **`Array`**: The data passed to `buildToken()`.
- **`null`**: The token couldn't be decoded.

---

## EncryptFunctions class

### encrypt

Description:

The **`encrypt`** static method encrypts a string with AES-128-CTR and the key you pass.

Syntax:

```php
$encrypted = EncryptFunctions::encrypt($string, $encryptionKey);
```

**Parameters:**

- **`$string`**: The text to encrypt.
- **`$encryptionKey`**: The key.

**Return Value:**

- **`String`**: The encrypted text, base64-encoded.
- **`false`**: Encryption failed.

---

### decrypt

Description:

The **`decrypt`** static method decrypts a string made by `encrypt()` with the same key.

Syntax:

```php
$plain = EncryptFunctions::decrypt($encrypted, $decryptionKey);
```

**Parameters:**

- **`$encrypted`**: The encrypted text.
- **`$decryptionKey`**: The key used to encrypt it.

**Return Value:**

- **`String`**: The decrypted text.
- **`false`**: Decryption failed.

---

### generate_hash

Description:

The **`generate_hash`** static method hashes a string. It calls PHP's `hash()`.

Syntax:

```php
$hash = EncryptFunctions::generate_hash('sha256', $data_string, false);
```

**Parameters:**

- **`$algo`**: The algorithm, such as `sha256`. See `hash_algos()` for the full list.
- **`$data_string`**: The string to hash.
- **`$binary`**: `true` returns raw binary. `false` returns lowercase hex.

**Return Value:**

- **`String`**: The hash.

<aside>
💡 Don't use it for passwords. Use `password_hash()` and `password_verify()`.

</aside>

---

## Token class

### getAuthorizeToken

Description:

The **`getAuthorizeToken`** static method encrypts the `api_key` from the `<encryption>` section of the config with the configured key.

Syntax:

```php
$token = Token::getAuthorizeToken();
```

**Return Value:**

- **`String`**: The encrypted API key.
- **`false`**: Encryption failed.

---
