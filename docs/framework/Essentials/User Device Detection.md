# User Device Detection

Owner: Nuwan Danushka

<aside>
💡

**Note:** Device detection relies on the device’s user agent.

</aside>

# Introduction

Starting from **framework version 0.0.17**, device detection features are introduced. The framework automatically adds a class to the `<body>` tag based on the detected device type.

## Device Detection and Body Classes

- **Mobile devices**: The class **`device-type--mobile`** is added.
- **Tablets**: The class **`device-type--tablet`** is added.
- **Other devices (e.g., desktops, laptops)**: The class **`device-type--pc`** is added.

## Accessing Device Information

### Backend

In the backend, developers can retrieve device details using the **`DeviceDetect`** class.

Example:

```php
$obj = new DeviceDetect();
$deviceInfo = $obj->getDeviceInfo(); // Retrieves detailed device information
$deviceType = $obj->get_device_type(); // Retrieves the device type (mobile, tablet, PC)
```

### Frontend

On the frontend, the framework integrates **UAParser** to analyze the user-agent string and extract detailed device, browser, and OS information.

For further reference on how UAParser works and its API, visit the official documentation:

[UAParser Documentation](https://docs.uaparser.dev/api/main/overview.html)

## Information Available

- **User Agent String**: Provides the raw UA string.
- **Browser Information**: Name and version of the browser.
- **CPU Architecture**: Details about the CPU architecture of the device.
- **Device Type**: Type of device (e.g., mobile, tablet, PC).
- **Engine Information**: Name and version of the rendering engine.
- **Operating System**: Name and version of the OS.

This functionality enables robust, device-specific customizations within both the frontend and backend of the framework.