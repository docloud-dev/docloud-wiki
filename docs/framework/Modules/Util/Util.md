---
title: Util
sidebar_label: Util
---

# Util

Owner: Nuwan Danushka

# Introduction

The Util module in the DoFramework delivers a versatile toolkit comprising essential utility classes tailored to streamline common programming challenges. From handling date and time functionalities to managing IP addresses and performing data validations, this module offers a comprehensive array of tools to simplify development tasks. With classes such as `CommonFunction`, `DateAndTimeManager`, `IpManager`, `Timezone`, `Validation`, `QrCode` and `ImageManager` (each reached through an accessor such as `Util::Validation()`), developers gain access to reusable components that enhance code efficiency and maintainability. By incorporating the Util Classes module into their projects, developers can accelerate development workflows, promote code reusability, and ensure robustness across various application scenarios.

---

# How to Access The Util Module’s Classes

To access the classes within the Util module, you can utilize either Type 1 or Type 2.

Type 1 includes static methods, while Type 2 does not.

---

## Type 1: Access Static Methods in Util Class

```php
// Access Util class for static methods
$timestamp = Util::DateAndTimeManager()::get_timestamp();
```

In this step:

- **`DateAndTimeManager()`** is a static method inside the **`Util`** class, returning a class that manages date and time.
- Then, we call the **`get_timestamp()`** method on the returned class to retrieve the timestamp.

---

## **Type2: Access Non-Static Methods in Util Class**

```php
// Access Util class for non-static methods
$common_functions_obj = Util::CommonFunction(); // Returns an instance of the CommonFunction class
$country_list = $common_functions_obj->countryList(); // Call the countryList() function
```

In this step:

- **`CommonFunction()`** is a method inside the **`Util`** class, returning an instance of the **`CommonFunction`** class.
- We store this instance in **`$common_functions_obj`**.
- Then, we call the **`countryList()`** method on the **`$common_functions_obj`** instance to retrieve the list of countries.

---

## Common Functions

`Util::CommonFunction()` holds general helpers: domain and URL parsing, header parsing, converting sizes to bytes, text encoding, sanitizing variables, validating sets of data, and a country list.

---

## Date And Time Manager

`Util::DateAndTimeManager()` creates, converts and compares dates and times: date ranges and intervals, time zone conversion, differences between dates, and the system's current date and time.

---

## IP Manager

`Util::IpManager()` returns the client's and the server's IP address.

---

## QR Code

`Util::QrCode()` builds QR codes for a URL, text, email, phone number, SMS or contact card through Google's deprecated Image Charts service, which no longer responds (see the page).

---

## Time Zone

`Util::Timezone()` lists the available time zones and looks up the client's time zone.

---

## Validation

`Util::Validation()` checks input: email addresses, URLs, phone numbers, NIC numbers, US ZIP codes, passwords, JSON and image data.

---

## Image Manager

`Util::ImageManager()` works with images that reach your controller as base64 text, such as a canvas drawing or a camera capture. It reads the image type and width and scales the image to a given width. For images uploaded from a form, use File Manager instead.

---
