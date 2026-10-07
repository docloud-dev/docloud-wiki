---
sidebar_position: 70
title: Admin Panel
sidebar_label: Admin Panel
---

# Admin Panel

Owner: Thilina Deepal

# Introduction

The admin panel is where you run a DoFramework system. It lives at `https://your-domain/api/admin/`. Until setup has run, every admin panel page sends you to the installer (see [Get Started](./Get%20Started.md)).

The sidebar has these menus:

| Menu | What it's for |
| --- | --- |
| Dashboard | Server and PHP details. |
| Logs | The error log and the admin activity log. |
| Apps | Install, update, reinitialise, export and remove apps. |
| Migrations | Each app's database migrations: run, roll back, or sync an app's tables. |
| Scheduler | The heartbeat's scheduled tasks. |
| Roles | User roles, their permissions and their members. |
| Notifications | Which notifications each role gets, and how. |
| Backups | Create, download, restore and delete backups. |
| Settings | System configuration, admin permissions and system updates. |

Each menu, and each Settings tab, shows only when the admin panel's permission set includes its view permission (see [Settings > Permissions](#permissions)). Installed apps can add their own menus. Developers who want to add one should read [Admin Pages](./Building%20Apps/Admin%20Pages.md).

The sidebar also has a **Search** item. It doesn't return any results yet.

---

# How to log in

The login screen offers two methods:

- **Sign in with DoCloud** sends you to DoCloud and back. You're logged in under your DoCloud name and email.
- **Login Local** asks for an email and sends a sign-in code to it. Enter the code to log in. A code is sent only when the email matches the Admin Email in [Settings > Admin](#admin). Any other email gets the same "Authentication code sent." reply, but no code.

The panel has one admin account. Its name and email come from `<admin_name>` and `<admin_email>` under `<admin>` in the config file, and you change them on Settings > Admin.

When `<system_environment>` in `api/config.xml` is `development`, the `send_auth_code` response also carries the code as `dev_auth_code`. The login screen doesn't show it. Read it from the browser's network tab. This lets you log in on a local machine that can't send email.

<aside>
⚠️ In `development`, anyone who knows the admin email can read the code from the response and log in. Setup leaves the environment on `development`. Switch to `staging` or `production` (Settings > API) before other people can reach the server. See [Dev Workspace](./Building%20Apps/Dev%20Workspace.md).

</aside>

The admin panel's permissions are read once, at login. When they change (on Settings > Permissions, or when an app reinit adds new ones), other admin sessions keep their old permissions until they log out and log in again.

---

# What the dashboard shows

The **Dashboard** lists the PHP version, the server software, PHP's memory limit, the memory the request used and the server's `php_uname()` string. Right after you sign in with DoCloud, it also checks DoCloud for a framework update and shows a notice when one is available.

---

# How to manage apps

**Apps** has three tabs.

**Installed Apps** shows a card for each app, with a search on the app's display name. Click an app's gear to open **Manage App**:

- **Reinitialize** reruns the app's install steps on the system (tables or migrations, options, permissions, roles). It runs straight away, without a confirmation. If one of the app's migrations fails, the rest still runs and the panel shows `Migration <name> failed: <error>`.
- **Check for update** lists the app's versions on DoCloud. **Get the update** downloads one and opens the install screen.
- **Download App** exports the app as a zip.
- The trash icon removes the app. The confirmation has one option, **Remove database records and tables**, unticked by default. Leave it unticked to keep the app's tables and data. For an app with migrations, ticking it resets the app's migrations instead of dropping its `<createTables>` tables.

**DoCloud App Store** lists the apps in the DoCloud App Library. Pick a version to install. The install button stays disabled unless the app is compatible with the system.

**Upload App** installs an app from a zip. The panel shows the app's details and compatibility first, then installs it when you click **Install**. Uploading an app that is already installed updates it.

An app is compatible when its API version is no higher than the system's, and its version is no lower than the installed one. On a development system the install screens also ask for an **Install location**: the standard directories or the `dev/` workspace.

For what install, update, reinitialise, export and remove each do, see [Packaging And Updates](./Building%20Apps/Packaging%20And%20Updates.md).

<aside>
⚠️ Don't remove the system apps: `auth`, `xp_users`, `xp_system`, `xp_notification`, `xp_email` and `system_admin_app`. The panel doesn't stop you, and the system stops working without them.

</aside>

---

# How to manage migrations

**Migrations** lists every app with how it gets its tables. Apps with migrations come first, with their status: up to date, pending, missing or an error. The rest are grouped under **No migrations** and tagged XML (tables from `<createTables>`) or No tables.

- For an app with migrations, the page lists each migration with its batch, when it ran and who ran it. **Run pending** runs the pending ones. **Roll back** undoes the last batch, the last few migrations, or everything after a chosen one, after a preview of exactly what it will undo. In production you type the app name to confirm.
- For an XML app, **Sync tables** creates missing tables and brings columns, keys and collation in line with `<createTables>`, without the rest of a reinitialize. The page also shows the command that converts the app to migrations.

Each action needs its own admin permission. Resetting an app and writing migrations are done on the command line. See [Database Migrations](./Building%20Apps/Database%20Migrations.md) for how migrations work and what each action does.

---

# How to manage scheduled tasks

**Scheduler** lists the heartbeat's tasks with their action, type, frequency, status, last result, start date and last change. From there you can:

- add a task: pick a function, set the interval (1 to 30 years, months, days, hours, minutes or seconds) and choose a one-off or recurring run,
- edit a task's frequency or status,
- delete a system task,
- read a task's execution log, and clear it.

Tasks only run when the server's cron job calls the heartbeat. See [Scheduler (Heartbeat)](./Essentials/Scheduler%20%28Heartbeat%29.md), including when an app keeps or overwrites your edits.

---

# How to manage roles and users

**Roles** controls what the users of the main site can do. It has two tabs:

- **Permissions**: a grid of every app's user permissions, with a column per role. Tick the cells and click **Save Permissions**. Users pick up the change on their next request.
- **Members**: the roles with their member counts. Open a role to see its members, add members (with a scope when the app uses scopes) and remove them. A user's last role can't be removed.

The page header also adds roles and sets their priority. A role can be removed, except the default role and `system_admin`. Its members move to their next role, or to the default role. On the default role, **Shift Default Role Users** moves its users to another role.

See [Roles And Permissions](./Essentials/Roles%20And%20Permissions.md) for how grants, priorities and scopes work.

The admin panel has no Users page. To create, edit or disable users, log in to the main site with a role that has the `xp_users` app's `list` permission and open **Users** (`/users`). In the admin panel you can only change role membership (Roles > Members) and the admin's own name and email (Settings > Admin).

The admin panel's own permissions are a separate set. They're on [Settings > Permissions](#permissions), not on the Roles page.

---

# How to set notification defaults

**Notifications** shows a grid of roles against the notifications each app declares, with a checkbox for each delivery method. When you save, the choices are stored for each role and copied to every user in that role. This overwrites the users' own choices.

See [Notification](./Essentials/Notification.md) for how apps declare notifications and how preferences resolve.

---

# How to back up and restore

**Backups** lists every backup with its date, description, the action that made it, the file (click to download), its content type and size.

To create one, click the create button and pick a type:

| Type | Contains |
| --- | --- |
| Full Backup | The system files and a dump of the MySQL database. |
| Database backup | The MySQL dump only. |
| System backup | The system files only. |

The system files are `api/` (with the config files, the SQLite file that holds the error log, and `api/logs/`), `apps/`, `assets/`, and the root files: `index.php`, `server.php`, `gateway.php`, `xp.js`, `sw_reg.js`, `manifest.json`, `xp-config.json`, `xp-config.json.dist` and `.htaccess`.

Backups don't include `storage/` (locally stored uploads), `dev/`, `downloads/` or `temp/`. Back up `storage/` separately. Backup zips are kept in `system_backups/` in the site root.

To restore, select a backup and click **Restore**. The restore:

1. takes a new backup of the same type, labelled "backup before restore", and stops if that fails,
2. checks that the zip hasn't changed since it was made,
3. extracts the zip over the site, and
4. replays the database dump, which drops and recreates each table in it.

The admin activity log and the list of backups are kept as they are. Everything else in the backup rolls back, including the config files and the error log.

<aside>
⚠️ A restore replaces the database tables and files with the backup's copies. Anything written since the backup is lost. Files added since the backup aren't deleted, and tables created since are left alone. The restore doesn't put the system into maintenance, so set Settings > System > System Status to Maintenance first, and set it back to Up afterwards. Then check Logs > Errors for problems reported during the restore.

</aside>

On a development system, the files of apps linked from `dev/` are read through their links, so they end up in the backup. A restore writes them back through the links into `dev/<app>/`. Commit your work first.

**Delete** removes the zip and its entry in the list.

The framework also creates a full backup before every system update. It shows in the list with the action "system framework update".

---

# How to read the logs

**Logs** opens the Log Viewer, with two tabs.

**Errors** lists the error log: class name, message, type and date. Type at least three characters to search it. Click a column heading's arrows to sort.

**Admin activity** lists what each admin did in the panel: time, admin, action, app, outcome (Success, Failed, Denied or Unknown) and IP. Filter by text, app or outcome. Click a row for the details, including the browser and the request fields, with secret values masked. The tab shows only to admins with the "Get admin activity" permission.

Entries older than the retention period are deleted whenever a new entry is written. Set the period on Settings > Logs, **Keep admin activity for (days)**. It defaults to 365 days, and an empty or invalid value also means 365.

See [Logging](./Essentials/Logging.md) for how apps write to the logs, and [Admin Pages](./Building%20Apps/Admin%20Pages.md#what-is-recorded) for what is recorded.

---

# How to update the framework

The framework updates from **Settings > System**, in the **System Update** section. There are two ways:

- **Check for updates** asks DoCloud for a newer version. This needs the DoCloud token set in the same tab.
- **Choose Update Zip** uploads a framework zip. It's accepted only when DoCloud confirms its checksum.

Both run the same steps:

1. The current system status is noted, and the system goes into maintenance.
2. A full backup is taken. If it fails, the update stops with "System backup failed. Update aborted." and the status is set back.
3. The system apps' manifests in the package are merged with the installed ones, and the framework files are replaced.
4. The package's update script runs.
5. Each system app whose manifest changed is reinitialised, `xp_users` first. This runs any new migrations of those apps.
6. The status from step 1 is set back.

While the update runs, the site's API answers `503` and only the admin panel works. See [Maintenance and down mode](./Architecture.md#maintenance-and-down-mode).

<aside>
⚠️ If PHP fails with a fatal error after the files have started to be replaced, the system stays in maintenance and the panel tells you to restore the pre-update backup. Restore it from **Backups**, then set the status back to Up.

</aside>

Log in again after an update so that your session picks up any new admin permissions.

Updating an install from 0.0.40 or older needs manual steps afterwards. [Upgrading The Framework](./Upgrading%20The%20Framework.md) lists them, with the permissions an update needs and the log entries to expect.

---

# Settings

Each tab saves to the config files. Most values go to `api/config.<environment>.xml`, the file for the current environment. See [Configuration Files](./Essentials/Configuration%20Files.md).

## Admin

The admin's name and email. The email is the Login Local address, and it receives emailed error logs.

## System Branding

The system name, and the logo, sidebar and favicon images (PNG or JPEG, up to 5 MB). This name is separate from the API tab's **APP Name**.

## Mobile App Branding

The PWA manifest: app name, short name, language, theme and background colours, display, orientation and description. The app icon (PNG only) is resized into the PWA icon sizes.

## API

The app name, time zone, site URL, system email, API structure, folder depth and charset, and the **App Environment**.

- Leave **API Structure** on **Apps**. **Basic** changes how URLs are routed.
- **App Environment** (`development`, `staging` or `production`) writes `<system_environment>` in `api/config.xml`. Each environment reads its own config file, with its own database settings, so fill that file in before you switch. If the server sets `APP_CONFIG_ENV`, the dropdown has no effect. See [Get Started](./Get%20Started.md#switch-the-environment).
- If the change is refused, tick **Change environment** on the Permissions tab, then log out and in again.

## Email

The email provider: Local, AWS (SES key, secret and region) or SMTP (host, user, password and port). Port 465 uses SMTPS, other ports use STARTTLS. There's no test button. See [Email](./Essentials/Email.md).

## Database

Whether to use a database, and its host, name, user and password. **Test Connection** checks the values. **Update** tests the connection first and saves only when it works.

<aside>
⚠️ Wrong database values cut the system off from its database. Test them before you save, and keep a copy of the old ones.

</aside>

## Logs

The log directory and file name, whether to save logs to the database, whether to email errors and which types (NOTICE, WARNING, ERROR, CRITICAL, EXCEPTION), and how long to keep admin activity. Emailed errors go to the Admin Email. See [Logging](./Essentials/Logging.md).

## Permissions

A checkbox grid of every app's admin panel permissions, with **Check All**. This is the single permission set for the admin panel. It isn't per admin. Saving refreshes your own session and reloads the page. Other sessions need a new login.

<aside>
⚠️ Unticking the view permission of a menu or Settings tab, or this tab's own permissions, hides it from you too. Leave the system app permissions ticked.

</aside>

## Security

The encryption method, the encryption key, the password encryption method and the API key.

<aside>
⚠️ Changing the encryption key breaks data and tokens that were encrypted with the old key. Set it once, before the system goes live.

</aside>

## Storage

Where uploaded files are stored: Local, or S3 with the bucket, key, secret, bucket domain and region. See [File Manager](./Modules/File%20Manager.md).

## Themes

The admin panel's colour theme: Default, LV or VS. It's saved in your browser only.

## Head

Code inserted, unchanged, into the `<head>` of every page of the main site, for example an analytics snippet.

<aside>
⚠️ A script pasted here runs for every visitor. Only paste code you trust.

</aside>

## System

- **Do Cloud**: the system token and DoCloud URL.
- **System Update**: see "How to update the framework" above.
- **Export**: **Download the System** or **Download the framework**. This needs a DoCloud connection. The export uses a clean config template, so it holds no credentials.
- **System Status**: Up, Maintenance or Down. Maintenance and Down both answer `503` for every API call except the admin panel. Only the message differs. See [Maintenance and down mode](./Architecture.md#maintenance-and-down-mode).
- **System Cache Clear**: raises the asset version, so browsers load fresh copies of the frontend files.
