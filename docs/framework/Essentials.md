# Essentials

Owner: Nuwan Danushka

---

# Introduction

Essentials, the cornerstone of Do Framework, brings together a suite of indispensable tools designed to elevate your development experience. This comprehensive package comprises key functionalities essential for crafting robust and feature-rich applications. Let's delve into its core components.

---

## Notification

Keep your users informed and engaged with seamless notification capabilities. Whether it's alerts, updates, or reminders, the Notification module empowers you to deliver timely messages to your audience, enhancing user experience and interaction.

---

## Email

Streamline communication and outreach with the Email module. From transactional emails to marketing campaigns, this feature-rich component provides the tools you need to effortlessly send and manage email communications, ensuring reliable delivery and engagement.

---

## Authentication

Authentication covers how users log in (password and two-factor), log out, reset a forgotten password and stay logged in with remember-me. It explains how sessions work, what `validate_session` returns to the SPA, and how a controller protects its actions with `authenticate()` and `auth::appUserPermission()`.

---

## Roles And Permissions

Roles And Permissions explains how DoFramework controls who can do what. Apps declare permissions in their XML manifest, and roles hold grants for them. A user can hold several roles, whose grants combine in the session. Apps can create roles with default grants from the manifest. Changes made on the admin panel's Roles page reach logged-in users on their next request, with no new login. The page shows how to check permissions in controllers and in the SPA. It also covers scoped grants, which limit a grant to part of an app's data through a resolver class.

---

## Logging

Gain valuable insights into your application's behavior and performance with the Logging module. By capturing and analyzing logs, you can identify issues, track user actions, and optimize your application for peak efficiency, facilitating proactive maintenance and improvement.

---

## Localization

Reach a global audience and tailor your application to diverse languages and regions with the Localization module. From translating content to adapting formats and conventions, this versatile tool empowers you to create a truly inclusive and accessible user experience.

---

## Configuration Files

Configuration Files explains which file each DoFramework setting lives in: `api/config.xml`, the per-environment overlay `api/config.<environment>.xml`, and the two `xp-config.json` files. It covers how `<system_environment>` and the `APP_CONFIG_ENV` override choose the overlay, and how the `.dist` templates create the live files and reset release-owned keys. It also covers maintenance mode, CORS `<allowed_domains>`, the `<installed_at>` setup marker and the module health check, with an annotated example of each file.

---

## Config Handlers

Config Handlers shows how to read and change configuration from code. `system_config` reads and writes the backend XML files. `DoFrontendConfigHandler` edits `xp-config.json`, `DoFrontendAppConfigHandler` edits an app's `app-config.json`, and `AppConfigHandler` edits an app's XML manifest. Changes to the JSON files are saved only when you call `commit_modification_to_config()`.

---

## App Options

App Options are named settings that an app keeps in its own table, such as a display name or a feature flag. The app declares them in an `<app_options>` block in its manifest, the framework seeds their defaults on every app initialization, and the `app_options` class and `XP.app_options` read and write them. Allowed options are readable without login, so they must never hold secrets.

---

## Scheduler (Heartbeat)

The Scheduler runs background tasks from a cron job that calls `api/heartbeat.php` every minute. An app schedules its own work by adding a `<app_name>Scheduler` class that extends `DoScheduler` and registers tasks with `self::job()->frequency()`. The page also covers the admin panel's Heartbeat page and the `heartbeat.php` commands.

---

## Service Worker

Service Worker explains how to turn on the service worker and PWA support through the `service_worker` block in `xp-config.json`.

---

## User Device Detection

User Device Detection covers the `DeviceDetect` module, which tells mobile, tablet and desktop apart on the server, and the device classes the framework adds to the page body.

---

## Moving DoFramework to another development environment

To move the **DoFramework** from one server to another or create a backup, follow these simplified steps:

### 1. **Copy the Framework Files**

- **What to do**: Make a copy of the entire working framework, including these important folders:
  - **api**
  - **apps**
  - **assets**
  - **storage**
  - All other essential files are in the public directory.
- **How**: You can zip the entire framework directory.

### 2. **Export the Database**

- **What to do**: Export the database using a tool like **PHPMyAdmin** or **Direct Admin Databases**.
- **How**:
  - In **PHPMyAdmin** or your database manager, go to your database.
  - Choose the **Export** option and download the SQL file.

### 3. **Update Configuration Files**

- **File to update**: `api/config.<environment>.xml`, where `<environment>` is the value of `<system_environment>` in `api/config.xml` (for example `api/config.development.xml`).
- **What to change**:
  - **Database settings**: Update the database connection details under the `<database>` section: `host`, `dbname`, `username` and `password`.
  - **System settings**: Update `system_site_path` in the `<system>` section (the path where the system is installed on the new server).
  - **System email**: Update `system_email` in the `<system>` section, the address used for system notifications.

### 4. **Change Email Settings (If Necessary)**

- **What to do**: If you need to change how the system sends emails, update the **SMTP settings**.
- **Where**: In the `<smtp>` section of `<email>` in the same `api/config.<environment>.xml` file.
  - You might need to change `smtp_host`, `smtp_port`, `smtp_user_name` or `smtp_password`, depending on your email provider.

### 5. **Change System Token (If Necessary)**

- **What to do**: If you need to change how the DoCloud identifies the application, update the **System Token**.
- **Where**: In the `<system_token>` section of the `<do_cloud>` in the `api/config.xml` file.
  - Update the system token tag `<system_token> token here </system_token>`

### Final Steps:

- **Upload the zipped framework** to the new server.
- **Import the SQL file** to the new database.
- **Update the configuration file** with new server settings.

That's it! Your DoFramework should now be set up on the new server.

---
