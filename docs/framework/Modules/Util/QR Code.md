# QR Code

Owner: Nuwan Danushka

# Introduction

Introducing QR Code Class: Simplifying QR Code Management in the Do Framework. This module facilitates the generation and storage of QR codes as images, providing seamless integration within your applications

---

## How to Create a QR Code

step-by-step guide:

### Step 1: Instantiate the QrCode object

Create an instance of the `QrCode` class:

```php
$qrcode = Util::QrCode();

```

### Step 2: Set the data for the QR code

Call one of the methods provided by the `QrCode` class to set the data for the QR code. Choose the appropriate method based on the type of QR code you want to generate. For example:

```php
$qrcode->URL('<https://example.com>'); // For URL type
// OR
$qrcode->TEXT('Hello, World!'); // For Text type
// OR
$qrcode->EMAIL('recipient@example.com', 'Subject', 'Message Body'); // For Email type
// And so on...

```

### Step 3: Generate the QR code

Call the `QRCODE()` method to generate the QR code. You can specify the size of the QR code (optional) and whether to save it to a file or output it directly. If you provide a filename and file path, the QR code will be saved as an image file. Otherwise, it will be output directly.

```php
// Output directly (default size: 400x400)
$qrcode->QRCODE();

// OR save to file (size: 400x400)
$filename = 'qrcode.png';
$file_path = '/path/to/save/directory/';
$qrcode->QRCODE(400, $filename, $file_path);

```

### Step 4: Verify the output

Check the output to ensure that the QR code is generated correctly. If you saved it to a file, navigate to the specified directory to view the image. If you output it directly, the QR code image should be displayed in the browser.

### Example Code:

```php
// Instantiate the QrCode object
$qrcode = new QrCode();

// Set the data for the QR code (e.g., URL, text, email, etc.)
$qrcode->URL('<https://example.com>');

// Generate the QR code with default size (400x400) and output directly
$qrcode->QRCODE();

// If you want to save the QR code to a file, specify the filename and file path
$filename = 'qrcode.png';
$file_path = '/path/to/save/directory/';
$qrcode->QRCODE(400, $filename, $file_path);

```

Ensure that you adjust the data and file path according to your requirements.

---

## QR Code Methods

### URL

Description:

The **`URL`** method is utilized to set the data for generating a URL-type QR code.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->URL($url = null);
```

**Parameters:**

- **`$url`**: The URL to encode into the QR code.

This method prepares the data for generating a URL-type QR code. It accepts a URL as input and ensures that the URL starts with either "http://" or "https://". If the provided URL does not have a scheme, it adds "http://" as the default scheme. The formatted URL is then stored in the $data property of the QR code object.

---

### TEXT

Description:

The **`TEXT`** method is utilized to set the data for generating a Text-type QR code.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->TEXT($text);
```

**Parameters:**

- **`$text`**: The text to encode into the QR code.

This method prepares the data for generating a Text-type QR code. It accepts a text string as input and stores it in the **`$data`** property of the QR code object.

---

### EMAIL

Description:

The **`EMAIL`** method is utilized to set the data for generating an Email-type QR code.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->EMAIL($email = null, $subject = null, $message = null) ;
```

**Parameters:**

- **`$email`**: The email address to include in the QR code. (Optional)
- **`$subject`**: The subject of the email. (Optional)
- **`$message`**: The body of the email. (Optional)

This method prepares the data for generating an Email-type QR code. It accepts the email address, subject, and message body as optional parameters. The provided data is formatted into a mailto URL scheme and stored in the $data property of the QR code object.

---

### PHONE

Description:

The **`EMAIL`** method is utilized to set the data for generating a Phone number type QR code.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->PHONE($phone);
```

**Parameters:**

- **`$phone`**: The phone number to include in the QR code.

This method prepares the data for generating a Phone number type QR code. It accepts a phone number as input and stores it in the **`$data`** property of the QR code object.

---

### SMS

Description:

The **`SMS`** method is utilized to set the data for generating an SMS-type QR code.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->SMS($phone = null, $msg = null);
```

**Parameters:**

- **`$phone`**: The phone number to include in the QR code. (Optional)
- **`$msg`**: The message body of the SMS. (Optional)

This method prepares the data for generating an SMS-type QR code. It accepts the phone number and message body as optional parameters. The provided data is formatted into a SMS URL scheme and stored in the **`$data`** property of the QR code object.

---

### CONTACT

Description:

The **`CONTACT`** method is utilized to set the data for generating a VCARD-type QR code.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->CONTACT($name = null, $address = null, $phone = null, $email = null);
```

**Parameters:**

- **`$name`**: The name of the contact. (Optional)
- **`$address`**: The address of the contact. (Optional)
- **`$phone`**: The phone number of the contact. (Optional)
- **`$email`**: The email address of the contact. (Optional)

This method prepares the data for generating a VCARD-type QR code. It accepts the contact's name, address, phone number, and email address as optional parameters. The provided data is formatted into a VCARD string and stored in the **`$data`** property of the QR code object.

---

### CONTENT

Description:

The **`CONTENT`** method is utilized to set the data for generating a Content-type QR code.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->CONTENT($type = null, $size = null, $content = null);
```

**Parameters:**

- **`$type`**: The type of content. (Optional)
- **`$size`**: The size of the content. (Optional)
- **`$content`**: The actual content data. (Optional)

This method prepares the data for generating a Content-type QR code. It accepts the type, size, and content data as optional parameters. The provided data is stored in the $data property of the QR code object.

---

### QRCODE

Description:

The **`QRCODE`** method is utilized to generate a QR code image and either save it to a file or output it directly.

Syntax:

```php
$qr_code_object = Util::QrCode();
$qr_code_object->QRCODE($size = 400, $file_name = null, $file_path = null);
```

**Parameters:**

- **`$size`**: The size of the QR code image (both width and height).
- **`$file_name`**: The filename to save the QR code image. If not provided, the image will be outputted directly. (Optional)
- **`$file_path`**: The directory path where the image should be saved. Required if **`$file_name`** is provided. (Optional)

This method sends a request to the QR code API to generate a QR code image with the specified size and data. It then processes the response and either saves the image to a file or outputs it directly, depending on the provided filename and file path.

---