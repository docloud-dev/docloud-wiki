---
title: Configuration Files
sidebar_label: Configuration Files
---

# Configuration Files

# Introduction

A DoFramework install reads its settings from five kinds of file:

| File | Format | What it holds |
| --- | --- | --- |
| `api/config.xml` | XML | The main backend config: which environment to use, system status, install marker, CORS domains, DoCloud token, registered apps. |
| `api/config.<environment>.xml` | XML | The per-environment overlay: system name, time zone, database, email, storage, logging, encryption and module lists. |
| `xp-config.json` | JSON | The frontend config for the main app (branding, URLs, dashboard, service worker, library resources). |
| `api/admin/xp-config.json` | JSON | The same, for the admin panel. |
| `*.dist` | XML / JSON | Tracked templates the three live files above are created from and kept in step with. |

None of the live files are committed. They hold this instance's state, so `.gitignore` excludes `api/config.xml`, the `api/config.*.xml` overlays and both `xp-config.json` files. Only the `.dist` templates are tracked.

This page explains which file each setting lives in and how the framework picks the file. To change these files from PHP, see [Config Handlers](./Config%20Handlers.md).

---

# How the environment is chosen

The backend works out one environment name per request (or per CLI process):

1. If the `APP_CONFIG_ENV` variable is set and contains only letters, digits and underscores, that name is used.
2. Otherwise the value of `<system_environment>` in `api/config.xml` is used.

The overlay file is then `api/config.<environment>.xml`, for example `api/config.development.xml`.

Setup writes three overlays, `config.development.xml`, `config.staging.xml` and `config.production.xml`, and sets `<system_environment>` to `development`. Before setup, `<system_environment>` is `initiate` and there is no overlay.

## The overlay replaces config.xml, it does not merge with it

Most settings are read with `system_config::get()` and `system_config::get_section()`. Those methods read **one** file:

- the overlay, when `api/config.<environment>.xml` exists;
- `api/config.xml`, when it does not.

The two files are not merged. If a key is only in `config.xml` and an overlay exists, `get()` returns an empty string for it.

A few settings are always read from `api/config.xml`, whatever the environment:

| Setting | Read by |
| --- | --- |
| `<system_environment>` | `system_config::environment()` |
| `<system_status>` | `system_config::get_system_status()`, checked on every API request |
| `<installed_at>` | `system_config::is_installed()` |
| `<api_version>` | `system_config::get_main_config_single()` |
| `<allowed_domains>` | `system_config::get_allowed_domains()`, used for CORS |
| `<do_cloud>` | the admin panel's DoCloud settings |
| `<apps>` | `AppManager::getRegistered_apps()` |

Everything else (system name, time zone, app directory, session lifetime, database, email, storage, logs, encryption, notification batch size and the module lists) comes from the overlay once one exists.

<aside>
⚠️ If `APP_CONFIG_ENV` names an overlay that doesn't exist, for example because of a typo, the framework doesn't report an error. It falls back to `api/config.xml`, which has no `<database>` section, so the database settings come back empty.

</aside>

---

# How to run an instance on another environment

Use `APP_CONFIG_ENV` when one checkout has to serve more than one environment, for example a development site and a test site on different databases. It overrides `<system_environment>` without editing `config.xml`.

On Apache, set it in the virtual host:

```apacheconf
<VirtualHost *:443>
    ServerName staging.example.com
    DocumentRoot /var/www/myapp
    SetEnv APP_CONFIG_ENV staging
</VirtualHost>
```

On the command line, set it in the environment of the process:

```bash
APP_CONFIG_ENV=staging php api/heartbeat.php
```

Both requests then read `api/config.staging.xml`. The name can be any overlay you have created, not only the three that setup writes.

---

# How to put the system into maintenance

`<system_status>` in `api/config.xml` controls whether the API answers requests. It takes one of three values:

| Value | Effect |
| --- | --- |
| `up` | Normal operation. |
| `maintenance` | Every API request returns HTTP 503 with "The system is currently under maintenance. Please try again later." |
| `down` | Every API request returns HTTP 503 with "The system is temporarily unavailable. Please check back later." |

Requests to the `system_admin_app` controller are always let through, so the admin panel keeps working and can switch the status back. A missing or unknown value is logged and treated as `up`.

Change it from the admin panel, by editing `api/config.xml`, or from PHP:

```php
system_config::change_system_status('maintenance');
```

The framework also sets `maintenance` itself while it applies a system update.

---

# How to allow cross-origin requests

The API sends CORS headers from `Framework::handle_cores()`, before anything else runs. It reads the allowed hosts from `<allowed_domains>` in `api/config.xml`. List one host per `<domains>` element:

```xml
<allowed_domains>
  <domains>app.example.com</domains>
  <domains>admin.example.com</domains>
</allowed_domains>
```

For each request the framework:

1. Takes the origin from the `Origin` header. If there isn't one, it uses the scheme and host of the `Referer` header, and then the request's own scheme and host.
2. Compares only the **host** of that origin with each `<domains>` value. Scheme and port are ignored, and there is no wildcard matching on subdomains.
3. On a match, sends `Access-Control-Allow-Origin` with the request's origin and `Access-Control-Allow-Credentials: true`.
4. With no match, sends `Access-Control-Allow-Origin: *` if one of the entries is `*`. Credentials are not allowed in that case.

It always sends `Access-Control-Allow-Methods: GET, POST, OPTIONS` and `Access-Control-Allow-Headers: Content-Type, Authorization`, and answers `OPTIONS` preflight requests with 204.

<aside>
⚠️ Write a bare host such as `app.example.com`, not `https://app.example.com`. A value with a scheme never matches. Saving the DoCloud settings in the admin panel writes the DoCloud URL, with its scheme, into the first `<domains>` element. Check `<allowed_domains>` afterwards and put your own host back.

</aside>

---

# How to re-run setup

Setup writes the current time into `<installed_at>` in `api/config.xml` as its last step:

```xml
<installed_at>2026-01-15T09:30:00+00:00</installed_at>
```

While `<installed_at>` has a value, the setup endpoint answers "Already installed" and does nothing. The framework treats the system as installed in these cases:

- `<installed_at>` is present and not empty;
- `api/config.xml` is missing or can't be parsed (this check fails closed, so a broken file never reopens setup);
- `<installed_at>` is absent and the install predates it: `<system_environment>` is set to something other than `initiate` and all three overlays exist. The sync step adds the marker to such installs automatically.

To run setup again on purpose, empty the element:

```xml
<installed_at/>
```

Setup then runs every install step again. It overwrites the three overlays and sets `<system_environment>` back to `development`, so back up your `api/config.<environment>.xml` files first.

---

# How config templates keep files up to date

The three live files are created from tracked templates:

| Template | Live copy |
| --- | --- |
| `xp-config.json.dist` | `xp-config.json` |
| `api/admin/xp-config.json.dist` | `api/admin/xp-config.json` |
| `api/config.xml.dist` | `api/config.xml` |

`ConfigTemplates::sync()` (in `api/core/ConfigTemplates.php`) runs at the start of every entry point: the main app's `server.php`, the admin panel's `server.php`, `api/index.php`, `api/shell.php` and `api/heartbeat.php`. It runs once per process and never stops a request. A problem is written to the PHP error log.

For each pair it does the following:

- **Live copy missing:** copies the template.
- **Live copy can't be parsed or written:** leaves it alone and logs the reason.
- **Otherwise:** merges the template into the live copy using the rules below. It writes the file only if something changed.

**JSON files (`xp-config.json`, `api/admin/xp-config.json`):**

- `version`, `release_date`, `res_version`, `resources` and `_comments` are **release-owned**. They are always replaced with the template's value.
- `_public` is a union. The result is the template's entries followed by any entries that only the live copy has.
- Any other key keeps its live value. Keys the template has and the live copy lacks are added, recursively inside objects.
- Keys that only the live copy has are kept.

**XML file (`api/config.xml`):**

- `<system><api_version>`, `<modules>` and `<app_modules>` are **release-owned**. They are replaced wholesale from the template.
- Elements the template has and the live copy lacks are added, recursively.
- Every other element keeps its live value.

The `api/config.<environment>.xml` overlays have no template and are never synced.

<aside>
⚠️ Don't edit release-owned keys in a live file. The next request puts the template's value back. That includes adding a script to `resources` in `xp-config.json`. To load extra frontend files, list them in your app's own `app-config.json`. Removing a template entry from `_public` is also undone, because the template's entries are always kept.

</aside>

---

# Module lists and the boot health check

The backend lists the framework modules it needs in three places:

```xml
<modules>
  <module name="FileManager"/>
  <module name="Util"/>
  <!-- ... -->
</modules>
<app_modules>
  <module name="User"/>
  <!-- ... -->
</app_modules>
<sdks>
  <sdk name="PHPMailer"/>
</sdks>
```

On every request, and in the shell and heartbeat, `Framework::health_check()` reads these lists from the active file (the overlay when one exists, otherwise `api/config.xml`). It checks that each entry's file exists:

| List | File that must exist |
| --- | --- |
| `<modules>` | `api/core/Modules/<Name>/<Name>.class.php` |
| `<app_modules>` | `api/core/AppModules/<Name>/<Name>.class.php` |
| `<sdks>` | `api/sdks/<Name>/autoloader.php` |

If a file is missing, the request stops with HTTP 500 "Health Check Failed", and the response data names the module, for example "Module Not Found : Curl".

<aside>
⚠️ After setup, only the overlay's lists are checked. The lists in `api/config.xml` are release-owned and kept current by the sync step, but they are only read before setup. Also, setup writes the overlay's app modules as `<app_modules name="User"/>` instead of `<module name="User"/>`. The health check looks for `<module>` elements, so on an installed system it checks no app modules at all.

</aside>

---

# File reference

## `api/config.xml`

The main backend config, created from `api/config.xml.dist`. Placeholders are in angle brackets.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<config>
  <system>
    <!-- Release-owned: reset from the template on every request. -->
    <api_version>0.0.42</api_version>
    <!-- Which overlay to read: api/config.<this value>.xml.
         APP_CONFIG_ENV overrides it. "initiate" before setup. -->
    <system_environment>development</system_environment>
    <!-- up | maintenance | down. Read from this file only. -->
    <system_status>up</system_status>
    <!-- Written by setup. Empty means "not installed". -->
    <installed_at>2026-01-15T09:30:00+00:00</installed_at>
    <!-- The keys below are only read when no overlay exists
         (before setup). After setup, the overlay's copies are used. -->
    <session_expire_seconds>43200</session_expire_seconds>
    <system_app_structure>1</system_app_structure>
    <system_app_directory>apps</system_app_directory>
    <system_app_folder_depth>1</system_app_folder_depth>
    <db_access>false</db_access>
  </system>
  <!-- Internal start-up flags. Leave as they are. -->
  <init>
    <initializeDB>false</initializeDB>
  </init>
  <logs>
    <local_db_log_dir>db</local_db_log_dir>
    <local_db_log_file>do.db</local_db_log_file>
    <local_db_log_init_dir>include</local_db_log_init_dir>
    <local_db_log_initialize_sql>localdb_initialize.sql</local_db_log_initialize_sql>
  </logs>
  <encryption>
    <encryption_method>sha256</encryption_method>
    <encryption_key><your-encryption-key></encryption_key>
    <password_encryption_method>sha256</password_encryption_method>
    <api_key><your-api-key></api_key>
  </encryption>
  <!-- CORS: bare host names, one per <domains>. Read from this file only. -->
  <allowed_domains>
    <domains>app.example.com</domains>
  </allowed_domains>
  <!-- Release-owned module lists. Only checked before setup. -->
  <modules>
    <module name="FileManager"/>
    <module name="Loging"/>
    <module name="Email"/>
    <module name="Util"/>
    <module name="AppManager"/>
    <module name="Encryption"/>
    <module name="ExchangerApi"/>
    <module name="Curl"/>
    <module name="DoFrontend"/>
    <module name="JSONManager"/>
  </modules>
  <app_modules>
    <module name="User"/>
    <module name="Notification"/>
    <module name="SessionManager"/>
  </app_modules>
  <sdks/>
  <!-- DoCloud connection, set from the admin panel. -->
  <do_cloud>
    <system_token><your-docloud-system-token></system_token>
    <docloud_url><https-url-of-your-docloud></docloud_url>
  </do_cloud>
  <!-- Registered apps, written by AppManager::register(). -->
  <apps/>
</config>
```

## `api/config.<environment>.xml`

The per-environment overlay, `api/config.<environment>.xml`. Setup generates it from the values entered on the setup screen. This is the shape it writes. Use your own values.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<config>
  <system>
    <system_name><your-system-name></system_name>
    <system_email><admin@example.com></system_email>
    <!-- PHP time zone name, used for date conversion. -->
    <system_api_timezone>UTC</system_api_timezone>
    <system_app_structure>1</system_app_structure>
    <!-- Folder that holds the apps, relative to api/ (backend)
         and to the site root (frontend). -->
    <system_app_directory>apps</system_app_directory>
    <system_app_folder_depth>1</system_app_folder_depth>
    <system_api_charset>UTF-8</system_api_charset>
    <!-- LOCAL | SMTP | AWS -->
    <email_provider>SMTP</email_provider>
    <!-- LOCAL | S3 -->
    <system_storage_type>LOCAL</system_storage_type>
    <!-- true when the system uses a database. -->
    <db_access>true</db_access>
    <system_site_path><https://app.example.com/></system_site_path>
    <session_expire_seconds>43200</session_expire_seconds>
    <local_db_backups_dir><backups-dir></local_db_backups_dir>
    <local_db_max_file_size><size></local_db_max_file_size>
    <system_access_log_session_id><true-or-false></system_access_log_session_id>
    <upload_user_dir/>
  </system>
  <init>
    <initializeDB>false</initializeDB>
  </init>
  <admin>
    <admin_name><admin-name></admin_name>
    <admin_email><admin@example.com></admin_email>
  </admin>
  <logs>
    <logs_dir>logs</logs_dir>
    <log_file>log.txt</log_file>
    <log_level><log-level></log_level>
    <log_db><0-or-1></log_db>
    <mail_logs><true-or-false></mail_logs>
    <email_log_type>
      <log_type><log-type></log_type>
    </email_log_type>
    <local_db_log_init_dir>include</local_db_log_init_dir>
    <local_db_log_initialize_sql>localdb_initialize.sql</local_db_log_initialize_sql>
    <local_db_log_dir>db</local_db_log_dir>
    <local_db_log_file>do.db</local_db_log_file>
  </logs>
  <database>
    <sql>
      <host><db-host></host>
      <dbname><db-name></dbname>
      <username><db-user></username>
      <password><db-password></password>
    </sql>
  </database>
  <notification>
    <notification_batch_size><number></notification_batch_size>
  </notification>
  <email>
    <!-- Used when email_provider is SMTP. -->
    <smtp>
      <smtp_host><smtp-host></smtp_host>
      <smtp_user_name><smtp-user></smtp_user_name>
      <smtp_password><smtp-password></smtp_password>
      <smtp_port><smtp-port></smtp_port>
    </smtp>
    <!-- Used when email_provider is AWS (Amazon SES). -->
    <aws>
      <ses_access_key/>
      <ses_access_secret/>
      <ses_region/>
      <ses_live>false</ses_live>
    </aws>
  </email>
  <encryption>
    <encryption_method>sha256</encryption_method>
    <encryption_key><your-encryption-key></encryption_key>
    <password_encryption_method>sha256</password_encryption_method>
    <api_key><your-api-key></api_key>
  </encryption>
  <storage>
    <local>
      <local_server_domain/>
    </local>
    <!-- Used when system_storage_type is S3. -->
    <aws>
      <s3_bucket/>
      <s3_access_key/>
      <s3_access_secret/>
      <s3_access_domain/>
      <s3_region/>
    </aws>
  </storage>
  <!-- Not used for CORS: CORS reads api/config.xml. -->
  <allowed_domains>
    <domains>app.example.com</domains>
  </allowed_domains>
  <!-- Checked at boot. Not synced from any template. -->
  <modules>
    <module name="FileManager"/>
    <!-- ... the same list as config.xml ... -->
  </modules>
  <app_modules>
    <app_modules name="User"/>
    <app_modules name="Notification"/>
    <app_modules name="SessionManager"/>
  </app_modules>
  <sdks>
    <sdk name="PHPMailer"/>
  </sdks>
</config>
```

`system_config::get()` searches the whole file for the key name, so key names must be unique within the file. The framework relies on this. For example, it reads `local_db_log_dir`, which sits under `<logs>`, as `get('system', 'local_db_log_dir')`.

## `xp-config.json`

The main app's frontend config, at the site root and created from `xp-config.json.dist`. `server.php` loads it on every page. In PHP the whole file is available as the `XP_CONFIG` constant. Only the keys listed in `_public` reach the browser (see below).

```json
{
    "version": "0.0.42",
    "release_date": "2026-10-02",
    "res_version": "0.0.42",
    "last_impact_time": 1714129151,
    "mode": "dev",
    "doc_title": "My App",
    "fav_icon_url": "/assets/images/docloud-fav.png",
    "do_cloud_url": "",
    "side_icon_bar_url": "/assets/images/docloud-fav.png",
    "login_logo_url": "/assets/images/logo-dc-landscape-colored.png",
    "login_redirection": "dashboard",
    "external_dashboard": "false",
    "dashboard_page_name": "dashboard",
    "dashboard_url": "",
    "public_dashboard": "false",
    "api_url": "",
    "app_url": "",
    "prefix": "",
    "system_name": "My App",
    "type": "app",
    "service_worker": {
        "enable_service_worker": "false",
        "path": "/sw.js",
        "version": "1.0.0",
        "debug": "true"
    },
    "resources": {
        "scripts": [
            { "url": "./assets/libs/vue/3.2.45/vue.global.prod.min.js" },
            { "url": "./xp.js" }
        ],
        "styles": [
            { "url": "./assets/libs/dc-ui-kit/0.0.2/dc-ui-kit.css" }
        ]
    },
    "_comments": {
        "mode": "The running environment of the system. Accepted values: dev | staging | live"
    },
    "_public": [
        "version", "res_version", "release_date", "mode", "system_name",
        "doc_title", "api_url", "app_url", "do_cloud_url", "type", "prefix",
        "last_impact_time", "side_icon_bar_url", "login_logo_url",
        "external_dashboard", "dashboard_url", "public_dashboard",
        "service_worker", "dashboard_page_name", "login_redirection"
    ]
}
```

| Key | Owner | Meaning |
| --- | --- | --- |
| `version`, `res_version`, `release_date` | release | Framework version and release date. `res_version` is the version of the bundled resources. |
| `resources` | release | The framework's library scripts and styles, loaded in order. |
| `_comments` | release | Notes for people editing the file. Not read by code. |
| `_public` | union | Keys sent to the browser. |
| `mode` | instance | `dev`, `staging` or `live`. |
| `type` | instance | `app` for the main app, `admin_panel` for the admin panel. Changes routing in `xp.js`. |
| `doc_title`, `system_name` | instance | Page title and system name. |
| `fav_icon_url`, `side_icon_bar_url`, `login_logo_url` | instance | Branding images. |
| `api_url` | instance | API base URL. Empty means `<page origin>/api`. |
| `app_url` | instance | App base URL. Empty means it is worked out from the page location. |
| `do_cloud_url` | instance | DoCloud URL returned by `XP.getDoCloudUrl()`. |
| `prefix` | instance | Prefix for the app's browser storage keys. Empty means the initials of the system name. |
| `dashboard_page_name` | instance | Route path of the dashboard page. |
| `external_dashboard`, `dashboard_url` | instance | When `external_dashboard` is `"true"`, the dashboard component is loaded from `dashboard_url`. |
| `public_dashboard` | instance | `"true"` lets the dashboard open without login. |
| `login_redirection` | instance | Route name to open after login. Defaults to `dashboard`. |
| `service_worker` | instance | Service worker settings. See [Service Worker](./Service%20Worker.md). |
| `last_impact_time` | instance | A timestamp returned by `XP.get_last_impact_time()`. Nothing in the framework uses it for caching any more. |

The flags are strings (`"true"`/`"false"`), not JSON booleans, and the frontend compares them as strings.

## `api/admin/xp-config.json`

The admin panel's frontend config, created from `api/admin/xp-config.json.dist`. It has the same shape as `xp-config.json`, with these differences in the template:

- `type` is `admin_panel`.
- It adds `project_name`.
- It has no `service_worker`, `login_redirection`, `dashboard_page_name` or `public_dashboard`.
- `do_cloud_url` is set to the DoCloud URL.

The same release-owned keys and `_public` rules apply.

## The `_public` list

`_public` decides which keys leave the server. `XP_SERVER::create_config_public_json()` builds the `XP_CONFIG_PUBLIC` object written into the page from:

- every top-level key of `xp-config.json` that is named in its `_public` list;
- an `apps` array with one entry per **active** app. Each entry has the app's `app_type`, plus the keys named in that app's own `app-config.json` `_public` list.

In the browser, `XP.getSystemConfig()` returns that object, and `XP.getSystemConfig(":doc_title:")` returns one key. A key that isn't listed in `_public` isn't sent to the browser, so keep secrets out of `_public`.

You can add your own keys to `xp-config.json` and to `_public`. Both survive the sync step. Every app's `app-config.json` needs a `_public` array, even an empty one.
