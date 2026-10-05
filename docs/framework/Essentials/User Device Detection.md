---
title: User Device Detection
sidebar_label: Device Detection
---

# User Device Detection

Owner: Nuwan Danushka

# Introduction

The framework detects the visitor's device from the browser's user agent string, on the server and in the browser:

- The server adds a device class to the main app's `body` tag.
- The `DeviceDetect` module gives the same information to backend code.
- `XP.device_detect` gives a parsed user agent to frontend code, using the bundled UAParser library.

<aside>
💡 Detection relies on the user agent string. Browsers can hide or fake it, and "request desktop site" modes change it, so use it for layout and analytics, not for security decisions.

</aside>

---

# How to style by device type

The main app's `index.php` adds one of these classes to `body`:

| Device | Class |
| --- | --- |
| Phone | `device-type--mobile` |
| Tablet | `device-type--tablet` |
| Anything else (desktop, laptop) | `device-type--pc` |

```css
body.device-type--mobile .sidebar {
    display: none;
}
```

The class is set once, when the page is served. The admin panel doesn't add it.

---

# How to detect the device in the backend

Create a `DeviceDetect` object. It reads the user agent of the current request.

```php
$detect = new DeviceDetect();

$type = $detect->getDeviceType();               // "mobile", "tablet" or "pc"
$info = json_decode($detect->getDeviceInfo(), true);

if ($info['device']['is_mobile']) {
    // ...
}
```

`getDeviceInfo()` returns a JSON string. Decode it to read the fields.

---

# How to detect the device in the frontend

`XP.device_detect` holds the parsed user agent. It's filled when the app mounts.

```jsx
const { browser, os, device } = XP.device_detect;

if (device.type === 'mobile' || device.type === 'tablet') {
    // touch layout
}

console.log(browser.name, browser.major, os.name);
```

UAParser leaves `device.type` `undefined` for desktop browsers. For anything the properties don't cover, `XP.device_detect.UAParser()` returns a new UAParser instance. See the [UAParser documentation](https://docs.uaparser.dev/api/main/overview.html) for its API, and [Frontend Runtime (XP)](../Frontend%20Runtime%20%28XP%29.md) for the rest of `XP.device_detect`, including `isRunningAsPWA()`.

`XP.device_detect` exists only in the main app. The admin panel's `XP` has no device detection.

---

# Methods

## DeviceDetect

### getDeviceType

Description:

The **`getDeviceType`** method returns the device type of the current request.

Syntax:

```php
$detect = new DeviceDetect();
$type = $detect->getDeviceType();
```

**Return Value:**

- **`String`**: `tablet`, `mobile` or `pc`. Tablets are checked first.

---

### getDeviceInfo

Description:

The **`getDeviceInfo`** method returns details of the device and browser.

Syntax:

```php
$detect = new DeviceDetect();
$info = json_decode($detect->getDeviceInfo(), true);
```

**Return Value:**

- **`String`**: JSON with this shape:

```json
{
    "device": {
        "is_mobile": false,
        "is_tablet": false,
        "is_desktop": true,
        "brand": "Unknown",
        "os": "Windows",
        "os_version": false
    },
    "browser": {
        "name": "Chrome",
        "version": "129.0.0.0"
    },
    "user_agent": "Mozilla/5.0 ..."
}
```

`brand` is `Samsung`, `Apple`, `Huawei` or `Unknown`. `os` is `Android`, `iOS`, `Windows`, `Mac`, `Linux` or `Unknown`. `os_version` is filled for Android and iOS only, `false` for other known systems and `null` when the OS is unknown. `browser.name` is `Chrome`, `Firefox`, `Safari`, `Internet Explorer` or `Unknown`. Other browsers built on Chromium, such as Edge, report as `Chrome`.

---

## XP.device_detect

### Properties

Description:

The properties hold the result of UAParser for the current browser.

Syntax:

```jsx
const os_name = XP.device_detect.os.name;
```

**Return Value:**

- **`ua`**: The user agent string.
- **`browser`**: `name`, `version` and `major`.
- **`cpu`**: `architecture`.
- **`device`**: `type`, `vendor` and `model`, where UAParser can tell them.
- **`engine`**: `name` and `version`.
- **`os`**: `name` and `version`.

---

### UAParser

Description:

The **`UAParser`** method returns a new UAParser instance for the current user agent.

Syntax:

```jsx
const parser = XP.device_detect.UAParser();
const result = parser.getResult();
```

**Return Value:**

- **`UAParser`**: A new parser.

---
