---
sidebar_position: 25
title: Architecture
sidebar_label: Architecture
---

# Architecture

# Introduction

This page explains how DoFramework handles a request from start to finish. Read it before you build your first app. It covers the parts of an app, the three ways the framework runs, what happens inside each API request, how the browser starts the single-page app, and the response format every endpoint returns.

An app has up to three parts:

| Part | Folder | Runs |
| --- | --- | --- |
| Backend | `api/apps/<app>/` | PHP: the controller, business classes and the manifest `<app>.xml` |
| Frontend | `apps/<app>/` | Vue 3 components in the main single-page app (SPA), plus `app-config.json`, `route.js` and `services.js` |
| Admin pages (optional) | `api/admin/apps/<app>/` | Vue 3 components in the admin panel, a second SPA under `/api/admin/` |

The frontend never touches the database. It calls the backend over HTTP at `/api/<controller>/<action>` and gets JSON back. [Building Apps](Building%20Apps/Building%20Apps.md) walks through each file, and the [Todo App](Todo%20App.md) tutorial builds one end to end.

The overall flow:

```text
 Browser                         Apache (.htaccess)              PHP
 -------                         ------------------              ---
 GET /myapp/orders  ───────────► not a file: /index.php ───────► server.php + index.php
                                                                  render the SPA shell,
 ◄──────────── HTML: import map, bundles, XP_CONFIG_PUBLIC ─────  rebuild assets/*-scripts.js

 (Vue Router shows the page, components call the API)

 GET /api/myapp/get_items ─────► api/.htaccess: api/index.php ──► core/init.php
                                                                  ConfigTemplates::sync()
                                                                  Framework::run()
                                                                    init, autoloaders,
                                                                    dev links, health check,
                                                                    SDKs, boot_apps()
                                                                    dispatch()
                                                                      myappController
                                                                        authenticate()
                                                                        Render()
 ◄──────────── JSON: { "response": {...}, "data": ... } ────────

 cron / terminal
 php api/shell.php myapp rebuild_index ─────────────────────────► Framework::run_shell()
 php api/heartbeat.php ─────────────────────────────────────────► Framework::run_heartbeat()
```

---

# How the framework runs

The backend has three entry points. All three first call `ConfigTemplates::sync()`, which creates or updates the live config files (`api/config.xml`, `xp-config.json` and `api/admin/xp-config.json`) from their `.dist` templates. See [Configuration Files](Essentials/Configuration%20Files.md).

| Mode | Entry point | Boots with | Used for |
| --- | --- | --- | --- |
| HTTP | `api/index.php` → `api/core/init.php` | `Framework::run()` | Every API call from the browser |
| Shell | `api/shell.php` → `api/core/shell_init.php` | `Framework::run_shell()` | Running a controller action from a terminal or cron job |
| Heartbeat | `api/heartbeat.php` → `api/core/heartbeat_init.php` | `Framework::run_heartbeat()` | The scheduler, called by cron once a minute |

The shell and heartbeat entry points run only when `is_shell()` is true, which means the command line (or a CGI SAPI). Called through a normal web server module they stop with "Not Authorized to call via ...".

## HTTP

The root `.htaccess` redirects plain HTTP to HTTPS and sends every path that is not a real file or folder to `/index.php`, the SPA shell. Requests under `/api/` are handled by `api/.htaccess` instead, which sends them to `api/index.php`. Requests under `/api/admin/` go to `api/admin/index.php`, the admin panel's shell.

`api/index.php` sets the PHP error log to `api/logs/debug.log` and loads `api/core/init.php`. That file syncs the config templates, loads the config, constants and helper functions, and calls `Framework::run()` inside a `try` block. An uncaught `Exception` becomes a `500` response whose message is `Exception: <message>` and whose `data` holds the file and line.

## Shell

Run a controller action from a terminal, from inside the `api/` folder:

```bash
cd api
php shell.php <controller> <action> [key=value,key=value]
```

The first two arguments are required. The optional third argument is **one** argument holding comma-separated `key=value` pairs. It becomes the request data, which your action reads with `$this->getRequest()->getData()`:

```bash
REQUEST_METHOD=GET php shell.php myapp rebuild_index from=2026-01-01,limit=500
```

A shell run builds a `Request` from the arguments, calls the controller's `authenticate()` and then `Render()`, exactly as HTTP does. The differences are listed under CLI gotchas at the end of this page. [Dev Workspace](Building%20Apps/Dev%20Workspace.md) shows how to use this while you develop.

## Heartbeat

```bash
* * * * * php /path/to/api/heartbeat.php
```

With no arguments, the heartbeat runs every scheduled task that is due. With an argument it manages tasks instead: `add`, `edit`, `remove`, `view`, `functions`, `config` or `healthcheck`. See [Scheduler (Heartbeat)](Essentials/Scheduler%20(Heartbeat).md).

---

# What happens in an API request

`Framework::run()` runs these steps in this order, for every request to `/api/...`:

1. **`init()`**: sends the CORS headers and answers an `OPTIONS` preflight with `204` and no body. Then it sets the session lifetime from `<session_expire_seconds>` (secure, HTTP-only cookie) and starts the PHP session.
2. **`core_autoload()`**: registers the autoloader for `api/core/classes/` (`Controller`, `Request`, `Response`, `App` and so on).
3. **`load_logging_module()`**: loads the logging module, which every later step may use.
4. **`setup_dev_links()`**: when `<system_environment>` in `api/config.xml` is `development` and a `dev/` folder exists, links each `dev/<app>/` into `apps/`, `api/apps/` and `api/admin/apps/`. Otherwise it does nothing. See [Dev Workspace](Building%20Apps/Dev%20Workspace.md).
5. **`health_check()`**: see [The health check](#the-health-check).
6. **`controller_autoload()`**: registers the autoloader for `api/controllers/` and `api/classes/`.
7. **`app_autoload()`**: registers the app class autoloader (`<autoload>` maps, the default `DoCloud\Api\Apps\` namespace, then a filename scan of `api/apps/`), when `<system_app_structure>` is `1`. See [App Manager](Modules/App%20Manager.md).
8. **`module_autoload()`**: registers the autoloader for `api/core/Modules/`.
9. **`app_module_autoload()`**: registers the autoloader for `api/core/AppModules/`.
10. **`check_Controller_Action()`**: stops with `400` when the URL has no controller or no action.
11. **`Load_SDKs()`**: includes `autoloader.php` of every SDK listed in `<sdks>`.
12. **`heartbeat_autoload()`**: registers the autoloader for `api/core/heartbeat/`.
13. **`boot_apps()`**: calls `register()` and then `boot()` on every active app's `App` class, dependencies first. See [App Manager](Modules/App%20Manager.md).
14. **`dispatch()`**: checks maintenance mode, builds the `Request`, and hands it to your controller.

`run_shell()` skips `init()`, `load_logging_module()`, `check_Controller_Action()` and `heartbeat_autoload()`, and ends with `shell_dispatch()`. `run_heartbeat()` skips `init()`, `load_logging_module()`, `controller_autoload()` and `check_Controller_Action()`, and ends by running the scheduler.

## URL routing

The controller and action come from the second and third path segments:

```text
/api/myapp/get_items?status=open
     │     │
     │     └─ ACTION     = "get_items"
     └─────── CONTROLLER = "myapp"   →  class myappController
```

Segments after the action are ignored. Pass data as a query string or in the request body.

`dispatch()` then:

1. Lower-cases the controller name and appends `Controller`, so `/api/MyApp/...` also loads `myappController`.
2. Reads the request data. For `GET` it uses `$_GET`. For `POST` it uses `$_POST`, or the decoded JSON body when `Content-Type` is `application/json`, and passes `$_FILES` along. Other HTTP methods get no usable data.
3. Builds a `Request` with the controller, action, data and files. The `Request` constructor stops with `497` when the request did not arrive over HTTPS.
4. Returns `501` when no `myappController` class exists.
5. Calls `authenticate()`. When it returns `false`, the response is `401 Not Authorized`. When it returns `true`, it calls `Render()`.

`Render()` is yours: it reads `$this->getRequest()->getType()` (`GET` or `POST`) and `getAction()`, and calls the method for that action. The `helloworld` controller is the reference pattern. See [Core Classes](Core%20Classes.md) for the `Controller`, `Request` and `Response` classes and [Authentication](Essentials/Authentication.md) for `authenticate()`.

<aside>
⚠️ `Request::getFiles()` throws an `Error` on a `GET` request and on a shell run, because the files property is only set for `POST`. Call it only in your `POST` handlers.

</aside>

## The health check

The health check runs on every HTTP, shell and heartbeat run, before any app class is loaded. It stops the request with `500 Health Check Failed` when:

- `<db_access>` is `true` and the database connection fails. `data` holds the connection errors.
- An SDK listed in `<sdks>` has no `api/sdks/<sdk>/autoloader.php`. `data` is `SDK Not Found : <sdk>`.
- A module listed in `<modules>` has no `api/core/Modules/<module>/<module>.class.php`. `data` is `Module Not Found : <module>`.
- An app module listed in `<app_modules>` has no class file. `data` is `APP Module Not Found : <module>`.

It also creates the local SQLite log database (by default `api/db/do.db`) when its tables are missing. That step never fails the request.

## Maintenance and down mode

`<system_status>` in `api/config.xml` is `up`, `maintenance` or `down`. An admin changes it in the admin panel under **Settings > System > System Status**.

In `maintenance` or `down`, `dispatch()` answers every controller except `system_admin_app` with `503` and does not call the controller:

| Status | `statusMsg` |
| --- | --- |
| `maintenance` | The system is currently under maintenance. Please try again later. |
| `down` | The system is temporarily unavailable. Please check back later. |

`system_admin_app` stays reachable so an admin can still log in and switch the system back to `up`. The SPA shell itself still loads. Only its API calls fail. A missing or unknown value is logged and treated as `up`. Shell and heartbeat runs ignore the status.

## Admin activity recording

`dispatch()` records state-changing admin-panel requests in the admin activity log, which admins read in the admin panel's Log Viewer. A request is recorded when it is a `POST` and either:

- its controller is `system_admin_app`, apart from a few read-only actions, or
- it carries the header `X-DC-Panel: admin` and a valid system admin session.

The admin panel's copy of `xp.js` adds that header to every same-origin `fetch()` to `/api/`. So the `POST` requests your admin pages make with `fetch()` are recorded automatically. Requests made with `XMLHttpRequest` or jQuery don't get the header and aren't recorded.

Each entry holds the admin, controller, action, outcome (`success`, `failed`, `denied` or `unknown`, read from the response's `success` flag) and the request fields. Values whose key looks secret are stored as `***`: keys with a part named `pass`, `password`, `passwd`, `pwd`, `secret` or `token`, and keys such as `api_key` or `apiKey` that end in a `key` part. Uploaded files are stored by name only. To add a line of context, call this in your action:

```php
AdminActivity::describe('Archived order ' . $order_id);
```

See [Admin Pages](Building%20Apps/Admin%20Pages.md).

---

# How the frontend starts

The SPA has no build step. Every page load is rendered by `index.php`, which includes `server.php`:

1. **`server.php`** syncs the config templates. When the URL is a versioned module URL (`/_v/...`), it serves that file and stops. Otherwise it fetches the public app options from its own API (`/api/system_admin_app/get_public_options`, a server-to-server request), reads `xp-config.json` and reads every `apps/*/app-config.json` whose `status` is `active`.
2. **`index.php`** prints the page head: the web app manifest link, the favicon and title (from the `xp_system` app options), the import map, and the style bundles.
3. The body holds `#app` with the loader and a `router-view`. An inline script defines two constants:
   - `XP_CONFIG_PUBLIC`: the keys listed in `_public` of `xp-config.json`, plus an `apps` array with, for each active app, its `app_type` and the keys listed in its own `_public` (menus, widgets, settings and so on).
   - `XP_LANGUAGE`: the strings of every app's `languages/lang.json` for the current language (the `language` cookie, default `EN`), keyed by app folder name.
4. The script bundles load. `lib-scripts.js` is a classic script holding Vue, Vue Router, jQuery, the other libraries, `xp.js` and the UI kit. `xp.js` creates the Vue app (`App`), the router (`Router`) and the global `XP` object. `app-scripts.js` is a module holding every active app's `resources.scripts`, which is where each app's `route.js` calls `Router.addRoute()`.
5. A final inline module calls `XP.mountApp()`, saves `XP_LANGUAGE` to local storage, applies the theme classes and starts or removes the service worker.

`XP.mountApp()` installs the router, mounts Vue on `#app`, fetches the public app options into local storage and starts device detection. See [Frontend Runtime (XP)](Frontend%20Runtime%20(XP).md).

The admin panel at `/api/admin/` works the same way, with its own `index.php`, `server.php`, `xp-config.json` and `xp.js`, and `api/admin/apps/` in place of `apps/`.

<aside>
⚠️ Both constants are printed inside single-quoted JavaScript strings without escaping. An apostrophe, double quote, backslash or line break in a public config value (an app's `description`, a menu `label` or `description`, `system_name`) or in a translation stops the inline script. `XP_CONFIG_PUBLIC` is then undefined and the page stays blank. Keep these characters out of public `app-config.json` values and `lang.json` strings until this is fixed.

</aside>

## How resources are bundled

There is no build or compile step. On every page render, `server.php` concatenates the resource files and writes four bundles to `assets/`:

| Bundle | Built from | Loaded as |
| --- | --- | --- |
| `assets/lib-styles.css` | `resources.styles` in `xp-config.json` | stylesheet |
| `assets/lib-scripts.js` | `resources.scripts` in `xp-config.json` | classic script |
| `assets/app-styles.css` | `resources.styles` of every active app's `app-config.json` | stylesheet |
| `assets/app-scripts.js` | `resources.scripts` of every active app's `app-config.json` | `type="module"` |

Apps are bundled in folder-name order. Each bundle URL carries `?v=<content hash>`, so the browser fetches a bundle again exactly when its content changes. Edit a file, reload, and the change is live.

Because every app's scripts end up in one module file:

- A syntax error in any app's bundled script stops the routes of every app. Check the browser console first when routes disappear.
- Top-level names share one scope. Two apps that both declare `const Orders` in `route.js` break the bundle. Prefix top-level names with your app name.
- Relative imports in a bundled file resolve against `/assets/`. Use absolute paths such as `/apps/myapp/components/orders.js`.
- The web server user must be able to write to `assets/`.

Only list `route.js` and plain setup scripts in `resources.scripts`. Components and `services.js` are ES modules that load on demand through `import`. See [App Frontend Config](Building%20Apps/App%20Frontend%20Config.md).

## Cache busting with the import map

Since 0.0.38, module URLs are versioned by an import map instead of query strings. `index.php` prints this before any module runs:

```json
{ "imports": { "/apps/": "/_v/3f9c2a7b1e/apps/" } }
```

The token is a hash of the newest modification time and the file count under `apps/`. Adding, removing or editing any file there changes it. The browser then loads `/apps/myapp/components/orders.js` from `/_v/3f9c2a7b1e/apps/myapp/components/orders.js`. Relative imports resolve against that versioned URL, so the whole module graph moves to new URLs together.

The root `.htaccess` maps `/_v/<token>/<path>` back to `/<path>` and marks `.js` and `.css` responses as immutable. Where that rule doesn't apply (`AllowOverride None`, or nginx), `server.php` serves the file itself, for static file types only. The admin panel maps `/api/admin/apps/` the same way.

So your imports stay bare. Never add `?v=` or `?ver=` to an import: the same module loaded under two URLs becomes two instances with separate state.

---

# The API response

Every framework and app endpoint answers with the `Response` class:

```php
$res = new Response();
$res->setData($items);
echo $res->create(200, 'Items loaded.', true);
```

The body is pretty-printed JSON:

```json
{
    "response": {
        "statusCode": 200,
        "statusMsg": "Items loaded.",
        "success": true
    },
    "data": [
        { "id": 1, "name": "First item" }
    ]
}
```

- `create()` also sets the HTTP status line from the code. A code the framework doesn't know is sent as `999 API Error`.
- `data` is left out when the data is empty or falsy: `[]`, `""`, `0`, `false` or `null`. Check for the key, not just its value.
- `errors` is added when the request logged messages and `<log_db>` is `true`. It lists those log entries.
- The frontend checks `response.success`. Many actions return `200` with `success: false` for a handled failure, as `helloworld` does.

## Status codes the framework sends

| Code | `statusMsg` | When |
| --- | --- | --- |
| `204` | (no body) | CORS preflight (`OPTIONS`) |
| `400` | `Arigato!` | The URL has no controller or no action |
| `400` | `Bad request` | `Response::badRequest()`, the usual answer for an unsupported HTTP method |
| `401` | `Not Authorized` | `authenticate()` returned `false` |
| `497` | `Please Use HTTPS!` | The request did not arrive over HTTPS |
| `500` | `Health Check Failed` | The health check failed |
| `500` | `Exception: <message>` | An uncaught exception |
| `501` | `Not Supported yet` | No controller class for the URL |
| `503` | see above | Maintenance or down mode |

Your actions choose their own codes, usually `200` and `501` for an unknown action.

---

# CLI gotchas

- **Run from the `api/` folder.** The framework loads controllers by absolute path, but some lookups (for example `AppManager::getAppsInfo()` and `getAppUserPermission()`) read the apps folder as a path relative to the working directory. Run from the project root, those find no apps and no permissions.
- **Set `REQUEST_METHOD`.** On the command line, `getRequest()->getType()` returns `cli`, not `GET` or `POST`. A controller that switches on the HTTP method, as `helloworld` does, answers `400 Bad request`. Prefix the command with `REQUEST_METHOD=GET` or `REQUEST_METHOD=POST`.
- **Pick the environment with `APP_CONFIG_ENV`.** Database and site settings come from `api/config.<environment>.xml`. On the command line, `APP_CONFIG_ENV=staging php shell.php ...` selects `config.staging.xml` instead of the one named by `<system_environment>`. On Apache, the same variable can be set per virtual host with `SetEnv`.
- **There is no session.** `run_shell()` never starts one, so a session-based `authenticate()` returns `false` and the shell prints `Not Authorized` (with code `500`, not `401`). Let shell runs through explicitly, and keep HTTP checks for everything else:

  ```php
  public function authenticate()
  {
      if (php_sapi_name() === 'cli') {
          return true;
      }
      return auth::appUserPermission(
          $this->getRequest()->getAction(),
          $this->getRequest()->getController(),
          []
      );
  }
  ```

  Test `php_sapi_name() === 'cli'` here, not the framework's `is_shell()`. `is_shell()` also returns `true` for the `cgi` and `cgi-fcgi` SAPIs, so on a host that runs PHP as CGI it would let every web request through.

- **One data argument, simple values.** The data argument is split on `,` and then on `=`. A value can't contain a comma, anything after a second `=` is dropped, and a pair without `=` raises a PHP warning. Read the data with `getData()`: `$_GET` and `$_POST` are empty.
- **No maintenance check, HTTPS check or activity log.** Shell runs skip all three. A missing controller answers `500 Not Supported yet`.
- **Dev links are not created from the CLI.** `setup_dev_links()` needs the web server's document root, which is empty on the command line. Load any page once after creating a new `dev/<app>/` folder, so the links exist before you run the shell.
