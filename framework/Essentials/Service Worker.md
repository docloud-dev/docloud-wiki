# Service Worker

Owner: Nuwan Danushka

# How to add service worker functionality to the framework

To add service worker functionality to the framework, follow these steps:

### 1. **Configure Service Worker Settings**

Navigate to the `xp-config` directory located in the root of the framework. The `xp-config` file is the frontend configuration file for the framework.

Locate the **`service_worker`** section within the configuration file. Update its properties as follows:

- **Enable Service Worker:** Set the `enable_service_worker` property to `"true"`.
- **Specify Path:** Define the path to your service worker file in the `path` property.
- **Set Version:** Provide a version number for the service worker using the `version` property.
- **Enable Debugging:** Optionally, set `debug` to `"true"` to allow console logs for debugging purposes.

Example configuration:

```json
"service_worker": {
    "enable_service_worker": "true",
    "path": "/sw.js",
    "version": "1.0.0",
    "debug": "true"
}
```

### 2. **Add Your Custom Service Worker File**

Place your custom service worker file (`sw.js`) in the root directory of the framework. This file will be included automatically when the service worker functionality is enabled.

### 3. **Update or Remove the Service Worker**

- **To Update the Service Worker:** Increment the version number in the `version` property. For example, change `"version": "1.0.0"` to `"version": "1.1.0"`.
- **To Disable the Service Worker:** Set the `enable_service_worker` property to `"false"`.

By following these steps, you can seamlessly integrate and manage service worker functionality within the framework.