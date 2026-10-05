---
title: Service Worker
sidebar_label: Service Worker
---

# Service Worker

Owner: Nuwan Danushka

# Introduction

The main app can register a service worker and be installed as a progressive web app (PWA). The framework provides the pieces around the service worker, but not the worker itself:

- `sw_reg.js` at the framework root registers and unregisters the worker. `index.php` loads it when the file exists.
- `XP.initializeServiceWorker()`, called on every page load, registers the worker when it's enabled in `xp-config.json` and unregisters it when it isn't.
- `index.php` links a web app manifest, and the admin panel can set the manifest's name, colours and icons.

The admin panel has no service worker.

---

# How to add a service worker

1. Write your service worker and save it as `sw.js` in the framework root, beside `index.php`. No `sw.js` ships with the framework.
2. Open `xp-config.json` in the framework root. It's a single JSON file. See [Configuration Files](./Configuration%20Files.md).
3. In its `service_worker` block, set `enable_service_worker` to the string `"true"`:

    ```json
    "service_worker": {
        "enable_service_worker": "true",
        "path": "/sw.js",
        "version": "1.0.0",
        "debug": "true"
    }
    ```

4. Reload the page. The browser console shows `[SW] Service Worker registered successfully`.

The worker is registered with scope `/`, so it controls the whole site.

<aside>
⚠️ The `path`, `version` and `debug` values have no effect. `XP.initializeServiceWorker()` passes them on, but `sw_reg.js` ignores them and always registers `/sw.js` with debug logging on. Keep your worker at `/sw.js`. If that file is missing, the server answers with the app's HTML page instead, and registration fails with an "unsupported MIME type ('text/html')" error in the console.

</aside>

---

# How to update or remove the service worker

- **Update**: change `sw.js`. The browser checks the file on navigation and installs the new version when its content differs. Changing `version` in `xp-config.json` does nothing. To check for an update at once, call `window.updateServiceWorker()` from the console or your code.
- **Remove**: set `enable_service_worker` to `"false"`. On the next page load, every service worker registered for the site is unregistered, not only yours.

<aside>
⚠️ `sw_reg.js` loads with `async`, so on a slow connection it can arrive after the page has already called `XP.initializeServiceWorker()`. The call then fails with `serviceWorkerManager is not defined` in the console, and nothing is registered or unregistered until the next load.

</aside>

---

# How the app is installed as a PWA

## The manifest

`index.php` links the manifest from the API:

```xml
<link rel="manifest" href="/api/system/manifest?uri=/current/route">
```

The frontend updates the link on every route change. The endpoint is public and picks the manifest like this:

1. If the route belongs to an app that has `apps/<app>/manifest.json`, it returns that file. A route belongs to an app when it matches a `path` passed to `Router.addRoute()` in the app's `route.js`.
2. Otherwise it returns the system manifest set on the admin panel's **Settings > Mobile App Branding** page.
3. If `<db_access>` is off, it returns a default manifest named "DoFramework".

## Icons

On **Settings > Mobile App Branding**, upload a PNG app icon. The framework resizes it to ten sizes, from 36×36 to 512×512, saves them in `assets/pwa_icons/` (for example `assets/pwa_icons/icon-192x192.png`) and adds them to the system manifest. The same page sets the name, short name, language, theme and background colours, display mode, orientation and description.

## Styling the installed app

When the app runs as an installed PWA (display mode `standalone`, `fullscreen` or `minimal-ui`), the frontend adds the class `dc-pwa-mode` to `body`. Use it to adjust the layout:

```css
body.dc-pwa-mode .my-header {
    padding-top: env(safe-area-inset-top);
}
```

To check it in code, call `XP.device_detect.isRunningAsPWA()`. See [Frontend Runtime (XP)](../Frontend%20Runtime%20%28XP%29.md).
