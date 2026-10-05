---
title: QR Code
sidebar_label: QR Code
---

# QR Code

Owner: Nuwan Danushka

# Introduction

The `QrCode` class builds the text for common QR code types (URL, text, email, phone, SMS, contact) and turns it into a PNG image. You can save the image to a file or send it straight to the browser.

The image is not generated locally. `QRCODE()` sends the data to Google's Image Charts endpoint, `https://chart.apis.google.com/chart`.

<aside>
⚠️ Google has deprecated the Image Charts API. When this page was checked in October 2026, the endpoint answered HTTP 404, so `QRCODE()` returned `false`. The method also needs outbound internet access from the server. Test it in your environment before you depend on it.

</aside>

---

## How to Create a QR Code

### Step 1: Get a QrCode object

```php
$qrcode = Util::QrCode();
```

### Step 2: Set the data for the QR code

Call one of the data methods. Each call replaces the data set by the previous one.

```php
$qrcode->URL('https://example.com');                                  // URL
// OR
$qrcode->TEXT('Hello, World!');                                       // plain text
// OR
$qrcode->EMAIL('recipient@example.com', 'Subject', 'Message body');   // email
```

### Step 3: Generate the QR code

Call `QRCODE()`. Pass a file name **and** a directory to save the image. Leave them out to send the image to the browser.

```php
// Save to a file (400 x 400 pixels)
$saved = $qrcode->QRCODE(400, 'qrcode.png', '/path/to/save/directory');

if ($saved === false) {
    // the request or the file write failed
}

// OR send the PNG to the browser
$qrcode->QRCODE();
```

### Step 4: Check the result

When saving, `QRCODE()` returns the full path of the written file. Check that the file exists and opens as an image.

---

## QR Code Methods

### URL

Description:

The **`URL`** method sets a URL as the QR code data.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->URL('example.com/page');   // stored as "http://example.com/page"
```

**Parameters:**

- **`$url`**: The URL to encode. If it does not start with `http://` or `https://`, `http://` is added in front.

---

### TEXT

Description:

The **`TEXT`** method sets plain text as the QR code data.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->TEXT($text);
```

**Parameters:**

- **`$text`**: The text to encode, stored unchanged.

---

### EMAIL

Description:

The **`EMAIL`** method sets an email message as the QR code data, in the `MATMSG` format that phone scanners open as a new email.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->EMAIL('recipient@example.com', 'Subject', 'Message body');
// MATMSG:TO:recipient@example.com;SUB:Subject;BODY:Message body;;
```

**Parameters:**

- **`$email`**: The recipient address. (Optional)
- **`$subject`**: The subject. (Optional)
- **`$message`**: The message body. (Optional)

The values are inserted as they are. A `;` or `:` inside a value can break the format.

---

### PHONE

Description:

The **`PHONE`** method sets a phone number as the QR code data, as `TEL:` followed by the number.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->PHONE('+94771234567');
```

**Parameters:**

- **`$phone`**: The phone number.

---

### SMS

Description:

The **`SMS`** method sets a text message as the QR code data, in the `SMSTO:` format.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->SMS('+94771234567', 'Hello');
// SMSTO:+94771234567:Hello
```

**Parameters:**

- **`$phone`**: The phone number. (Optional)
- **`$msg`**: The message body. (Optional)

---

### CONTACT

Description:

The **`CONTACT`** method sets a contact card as the QR code data, in the `MECARD` format.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->CONTACT('Jane Perera', '1 Main Street, Colombo', '+94771234567', 'jane@example.com');
// MECARD:N:Jane Perera;ADR:1 Main Street, Colombo;TEL:+94771234567;EMAIL:jane@example.com;;
```

**Parameters:**

- **`$name`**: The contact's name. (Optional)
- **`$address`**: The contact's address. (Optional)
- **`$phone`**: The contact's phone number. (Optional)
- **`$email`**: The contact's email address. (Optional)

---

### CONTENT

Description:

The **`CONTENT`** method sets the QR code data to a string in the form `CNTS:TYPE:<type>;LNG:<size>;BODY:<content>;;`. This is not a widely supported QR format, so most scanners show it as plain text.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->CONTENT($type, $size, $content);
```

**Parameters:**

- **`$type`**: The value for the `TYPE` field. (Optional)
- **`$size`**: The value for the `LNG` field. (Optional)
- **`$content`**: The value for the `BODY` field. (Optional)

---

### QRCODE

Description:

The **`QRCODE`** method posts the data to the Image Charts endpoint and either saves the returned PNG or sends it to the browser. The request times out after 30 seconds.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->QRCODE($size = 400, $file_name = null, $file_path = null);
```

**Parameters:**

- **`$size`**: The width and height of the image, in pixels. Default: `400`.
- **`$file_name`**: The file name to save the image as. (Optional)
- **`$file_path`**: The directory to save the image in. A trailing `/` is optional. (Optional)

**Return Value:**

- **`String`**: With both `$file_name` and `$file_path`, the full path of the saved file.
- **`String`**: Without them, the raw PNG bytes. The method has already sent a `Content-type: image/png` header and echoed the bytes.
- **`false`**: The endpoint did not answer with HTTP 200, or the file could not be written.

If you pass only one of `$file_name` and `$file_path`, nothing is saved and the image is sent to the browser. Because direct output sends a header and writes to the response, use it only in a handler that writes nothing else.

---
