---
sidebar_position: 10
title: Get Started
sidebar_label: Get Started
---

# Get Started

Owner: Thilina Deepal

# Introduction

This page takes you from an empty server to a working DoFramework install. You check the requirements, copy the framework files to the server, run the installer in the admin panel, and then finish a few settings the installer doesn't cover.

---

# Requirements

## Server

- **Web server:** Apache 2.4, OpenLiteSpeed 1.7.x or later, or LiteSpeed Web Server (LSWS) 6.0 or later. Other web servers are not officially tested.
- **`.htaccess` support** with `mod_rewrite`. The framework's `.htaccess` sends every request that isn't a real file to `index.php`.
- **HTTPS.** The `.htaccess` redirects HTTP to HTTPS, and the API refuses plain HTTP requests with `497 Please Use HTTPS!`.
- **A domain or subdomain of its own.** Install the framework at the web root. The installer builds every URL from the site's origin (`https://your-domain`), and the rewrite rules assume `/`.

<aside>
⚠️ The installer's self-check accepts only a web server that reports itself as `Apache` or `LiteSpeed`. On any other server, such as nginx, the check fails and the installer won't continue.

</aside>

## PHP

- **PHP 8.1 or above.**
- **Memory limit (`memory_limit`) of 128 MB or above.**

<aside>
💡 The installer's self-check screen still accepts PHP 7.2, but the framework itself needs PHP 8.1 or above. Check your PHP version yourself before installing.

</aside>

<aside>
⚠️ The self-check reads only the number in `memory_limit` and treats it as megabytes. Write the limit in megabytes, such as `256M`. A value of `1G` or `-1` (no limit) fails the check even though it's large enough.

</aside>

## PHP extensions

The installer doesn't check extensions, so confirm them yourself with `php -m`.

**Required.** The framework's own code uses these:

| Extension | What needs it |
| --- | --- |
| `PDO`, `pdo_mysql` | The MySQL or MariaDB database. |
| `sqlite3` | The local SQLite database that every log entry is written to. |
| `simplexml`, `dom`, `libxml` | Reading and writing the XML config files and app manifests. |
| `json`, `session`, `filter`, `hash`, `date`, `ctype` | Core request handling. Most PHP builds include these. |
| `mbstring` | Text encoding helpers in `Util` and the admin activity log. |
| `openssl` | Sign-in tokens, the `Encryption` module and HTTPS calls to DoCloud. |
| `curl` | The `Curl` module, every call to DoCloud and QR code generation. |
| `zip` | Uploading, installing, exporting, backing up, restoring and updating apps and the framework. |

**Needed for some features.** The framework runs without these, but the feature named fails:

| Extension | What needs it |
| --- | --- |
| `gd` | Image thumbnails in `FileManager`, the `ImageManager` utility, and the PWA icons made under **Settings > Mobile App Branding**. |
| `exif` | Image type checks when `FileManager` uploads images. |
| `fileinfo` | MIME type detection for S3 uploads and the mobile branding icon upload. |
| `intl` | Optional. The bundled PHPMailer uses it, when present, to send to email addresses with international domain names. |

Library installs from DoCloud also need `allow_url_fopen` turned on, because they download the zip with `file_get_contents()`.

<aside>
💡 Earlier versions of this page also listed `bcmath`, `gettext`, `iconv`, `mysqli`, `Phar` and `redis`. The framework doesn't use them. Install them only if one of your own apps needs them.

</aside>

## Database

- MySQL or MariaDB. The framework connects through `pdo_mysql` with the `utf8mb4` character set.
- Create an empty database and a user that can create tables in it before you run the installer. The installer tests the connection, but it doesn't create the database.

## File permissions

The web server's PHP user must be able to write inside the install folder. Setup writes the config files in `api/`, and the framework writes logs, the local SQLite database, temporary files, exports and backups.

---

# How to get the framework files

1. Download the latest framework zip from your DoCloud developer account. See [Docloud](./Docloud.md) for creating the account and finding the download.
2. Upload the zip to the web root of your domain (often `public_html`) and extract it there. `index.php`, `.htaccess`, `api/` and `apps/` should end up directly in the web root.
3. Install the framework from the admin panel, as described in the next section.

---

# How to install the framework

The installer is part of the admin panel. Until setup has run, every admin panel page sends you to it.

1. Open `https://your-domain/api/admin/`.
2. On **Welcome to DoCloud SDK**, click **Get Started**.
3. On **Self System Check**, click **Start Systems Self Check**. It checks the web server, PHP version and memory limit. If all three pass, the button changes to **Begin Installation**. Click it. If a check fails, fix it and click **Retry System Self Check**.
4. On **Ready for Action!**, choose how to set up:
   - **Get Started with DoCloud** sends you to DoCloud to sign in. Follow its prompts. DoCloud then sends you back to the installer with your name, email, system name and a system token, and setup saves the token in `<do_cloud>` in `api/config.xml`. You need a DoCloud developer account (see [Docloud](./Docloud.md)).
   - **Setup Local** installs without DoCloud. You can add a DoCloud system token later under **Settings > System**.
5. On **Choose Setup Type**, pick **Basic Mode** or **Advanced Mode** (see below).
6. Fill in each step and click **Next**. On the database step the button is **Test Connection & Next**, and you can't continue until the connection works.
7. On the last step, click **Finish Setup**.
8. On **Congratulations - Setup Complete**, click **Login to System Admin**.

<aside>
💡 **Get Started with DoCloud** needs the server to reach DoCloud. If it can't, the installer shows "Couldn't get a response from Do cloud." Use **Setup Local** instead.

</aside>

## Basic and advanced mode

Both modes write the same files. Advanced mode adds two steps, **Apps Support** and **Security Settings**, for settings that basic mode leaves at their defaults.

| Basic mode | Advanced mode |
| --- | --- |
| 1. API Configuration | 1. API Configuration |
| | 2. Apps Support |
| 2. Database Settings | 3. Database Settings |
| 3. Error Logs Settings | 4. Error Logs Settings |
| | 5. Security Settings |
| Finish | Finish |

If you came from DoCloud, the API Configuration step is filled in from your DoCloud account and skipped.

## API Configuration

| Field | Description |
| --- | --- |
| APP Name | Your system's name. Required. Saved as `<system_name>`. |
| Admin Name | Your name. Required. |
| Admin Email | Your email. Required. The admin panel's local login sends its sign-in code to this address. |
| Site URL | Read-only. The site's origin, for example `https://your-domain`. |
| System Email | Read-only. `noreply@` followed by your domain. Used as the sender address. |
| TimeZone | The PHP time zone the system uses. Defaults to `Asia/Colombo`. |
| Charset | `UTF-8`, the only option. |

## Apps Support (advanced mode only)

| Field | Description |
| --- | --- |
| API Structure | `Apps` (the default) or `Basic`. Setup currently ignores this field and always saves `Apps`. |
| App Folder Depth | How deep the class autoloader looks inside an app folder. `level 1` is the only option. |
| App Directory | The folder that holds the apps. `apps` is the only option. |
| Email Provider | `Local` (the server's own mail), `AWS` (Amazon SES) or `SMTP`. Setup doesn't ask for credentials. Enter them afterwards under **Settings > Email**. |
| Storage Type | `Local` or `AWS`. Choose `Local`. |

<aside>
⚠️ Choosing `AWS` as the storage type has no effect. `FileManager` only switches to S3 when the type is `S3`, which setup can't save. To store files in S3, finish setup with `Local`, then pick **S3** and enter the bucket details under **Settings > Storage**.

</aside>

## Database Settings

| Field | Description |
| --- | --- |
| SQL Database Host | The database server. Defaults to `localhost`. |
| Database Name | The database you created for the framework. |
| Database Username | A user that can create tables in that database. |
| Database Password | That user's password. |

**Test Connection & Next** connects with these details and only moves on if the connection works.

## Error Logs Settings

| Field | Description |
| --- | --- |
| Logs Directory | The folder for the log file. Setup currently ignores this field and always uses `logs`. |
| Log File Name | The name of the log file. Setup currently ignores this field and always uses `log.txt`. |
| Log Level | `0` or `1`. Saved as `<log_level>`, which the framework doesn't currently read. |
| Save Logs to Database | Saved as `<log_db>`. When it's on, module health-check errors are logged, and API responses include the request's log entries in an `errors` field (see [Architecture](./Architecture.md)). Log entries always go to the local SQLite database either way. |
| Email Errors | Whether log entries are emailed to the admin email. |
| Which Emails you want to receive via email? | Shown when **Email Errors** is on. Pick any of `CRITICAL`, `EXCEPTION`, `NOTICE`, `WARNING` and `ERROR`. Defaults to `CRITICAL`. |

See [Logging](./Essentials/Logging.md) for the log types.

## Security Settings (advanced mode only)

| Field | Description |
| --- | --- |
| Encryption Method | `SHA256`, the only option. |
| Encryption Key | The key for sign-in tokens and the `Encryption` module. |
| Password Encryption Algorithm | `SHA256`, the only option. |
| API Key | A key used when building auth tokens. |

<aside>
⚠️ Setup doesn't save anything from this step. Every install starts with the default encryption key and API key from the config template. You can change them afterwards under **Settings > Security**. Changing the encryption key invalidates existing sign-in tokens, so users have to sign in again.

</aside>

## Setup Complete

The last screen shows:

| Item | Value |
| --- | --- |
| Web Application URL | `https://your-domain` |
| API Path | `https://your-domain/api` |
| System Admin URL | `https://your-domain/api/admin` |
| System Admin Email | The admin email you entered. |

**Login to System Admin** signs you straight in if you installed with DoCloud. After **Setup Local** it opens the admin panel's sign-in page. There, click **Login Local**, enter the admin email, click **Send Auth Code** and enter the code from the email. You can also click **Sign in with DoCloud** once a system token is set.

<aside>
💡 With **Setup Local**, setup doesn't ask for a password for the web app's admin user account. The admin panel doesn't need one: it signs you in with the emailed code.

</aside>

## What setup writes

When you click **Finish Setup**, setup:

1. Writes `api/config.development.xml` from your answers, and `api/config.staging.xml` and `api/config.production.xml` with default values.
2. Sets `<system_environment>` in `api/config.xml` to `development`.
3. Creates the tables of the built-in apps and fills in the default roles, the admin user and the admin panel permissions.
4. Records the install time in `<installed_at>` in `api/config.xml`, as its last step.

While `<installed_at>` has a value, setup refuses to run again and answers "Already installed". To run it again on purpose, see [Configuration Files](./Essentials/Configuration%20Files.md), which also describes every file above.

---

# After installing

## Switch the environment

Setup leaves `<system_environment>` set to `development`. In that mode the admin panel's local login returns the sign-in code in its response, so anyone who knows the admin email can sign in. The framework also links apps from `dev/` when that folder exists. Before other people can reach the server, switch to `staging` or `production`.

The staging and production overlays only hold default values: no database, no admin email. Fill in the one you're switching to first, or the system loses its database connection as soon as you switch.

1. Copy `api/config.development.xml` to `api/config.production.xml` (or `api/config.staging.xml`). Change any values that should differ.
2. In the admin panel, open **Settings > API**.
3. Set **App Environment** to `production` (or `staging`) and click **Update**.

The setting is `<system_environment>` in `api/config.xml`. See [Configuration Files](./Essentials/Configuration%20Files.md) for how the environment picks the overlay, and for the `APP_CONFIG_ENV` override.

## Set the cron job for the heartbeat

Scheduled tasks, including the framework's own, run only when a cron job calls the heartbeat once a minute:

```bash
* * * * * php /path/to/api/heartbeat.php
```

See [Scheduler (Heartbeat)](./Essentials/Scheduler%20(Heartbeat).md).

## Review the allowed domains

`<allowed_domains>` in `api/config.xml` lists the hosts that may call the API from a browser on another origin (CORS). The template lists only the DoCloud host. Add the bare host name of every front end that calls this API from another domain. See [Configuration Files](./Essentials/Configuration%20Files.md).

---

# Setting up for app development

To build apps on this install, keep it in `development` and create a `dev/` folder next to `api/` and `apps/`. Each app then lives in one folder, `dev/<app>/`, which the framework links into place.

- [Dev Workspace](./Building%20Apps/Dev%20Workspace.md) explains the workspace and how the links work.
- The [Todo App](./Todo%20App.md) tutorial builds a complete app, starting with signing in to the admin panel without email.
