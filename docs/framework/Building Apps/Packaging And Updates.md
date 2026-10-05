---
sidebar_position: 6
title: Packaging And Updates
sidebar_label: Packaging And Updates
---

# Packaging And Updates

# Introduction

An app moves between systems as a zip file. You export it from the admin panel of the system where it runs, and install that zip on another system. A system can also install an app from a zip of its repository, or from the DoCloud App Library.

Installing and updating are the same operation. When the app is already installed, the package's files replace the installed ones and the manifests are merged, so the installation keeps its own state.

All of this happens in the admin panel under **Apps**, which has three tabs: **Installed Apps**, **DoCloud App Store** and **Upload App**. Every step needs the PHP zip extension (see Requirements below).

---

# How to export an app

Open **Apps > Installed Apps**, open the app and click **Download App**. The admin panel calls `system_admin_app/export_app`, which:

1. Copies `api/apps/<app>/`, `apps/<app>/` and `api/admin/apps/<app>/` into a temporary folder. The backend folder is required. The other two are copied when they exist.
2. Copies the SQL file named in the manifest's `<run><sql>`, if there is one, from the backend folder into `database/`.
3. Strips old cache-busting parameters (`?ver=`, `&lpt=`, `?v=`) from the JS imports in the copy. The installed files aren't changed.
4. Generates `config.xml` from the manifest (see below).
5. Zips the result to `downloads/exports/<app>.zip` and returns its URL, which the browser downloads.

The zip looks like this:

```
myapp.zip
    config.xml
    backend/
        myapp/
            myapp.xml
            myappController.class.php
            ...
    frontend/
        myapp/
            app-config.json
            ...
    adminpanel/
        myapp/
            app-config.json
            ...
    database/
        myapp_seed.sql
```

Everything in the three folders is included, hidden files too. Remove notes, test data and local files from them before you export.

<aside>
⚠️ The zip stays at `downloads/exports/<app>.zip` in the web root after the download, and anyone who knows the URL can fetch it. It holds the app's full source. Delete it once you have your copy.

</aside>

## The generated `config.xml`

`config.xml` is what the install step reads first. It is a projection of the manifest, `backend/<app>/<app>.xml`:

| Element | Content |
| --- | --- |
| `<info>` | Copied whole from the manifest. |
| `<user_permissions>` | Only the permissions with `auto_update="true"`, as a flat list without `<category>` groups. |
| `<admin_panel_permissions>` | The same, for admin permissions. |
| `<user_notifications>` | Only the notifications with `default_enabled="true"`, as a flat list. |
| `<run>` | Copied whole, or empty. |
| `<prerequisites>` | Copied whole, or empty. |
| `<paths>` | Always `frontend`, `backend`, `database` and `adminpanel`. |

For the `helloworld` app it looks like this (the `<info>` block is shortened):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<app>
  <info>
    <app_name>helloworld</app_name>
    <display_name>Hello World</display_name>
    <app_version>1.1.2</app_version>
    <api_version>0.0.21</api_version>
    <status>active</status>
    <release_date>2026-10-02</release_date>
  </info>
  <user_permissions>
    <permission display_name="Get hello world data" name="get_hello_data" auto_update="true"/>
    <permission display_name="View hello world app" name="view" auto_update="true"/>
  </user_permissions>
  <admin_panel_permissions>
    <permission display_name="view setting page" name="view" auto_update="true"/>
    <permission display_name="Get hello world data" name="get_hello_data" auto_update="true"/>
  </admin_panel_permissions>
  <user_notifications>
    <notification name="test" display_name="test notification" description="test notification" default_enabled="true">
      <email active="false"/>
      <push active="false"/>
      <sms active="false"/>
    </notification>
  </user_notifications>
  <run/>
  <prerequisites/>
  <paths>
    <frontend>frontend</frontend>
    <backend>backend</backend>
    <database>database</database>
    <adminpanel>adminpanel</adminpanel>
  </paths>
</app>
```

Tables, options, roles and the rest of the manifest aren't in `config.xml`. The install reads them from the packaged `backend/<app>/<app>.xml`.

---

# How to install an app

Installing has two steps. First the system receives the zip, extracts it to `temp/apps/extracted/<zip name>/` and checks it. Then the admin confirms and the system installs it with `system_admin_app/update_app`.

## From an export

Open **Apps > Upload App** and choose the zip. Only `.zip` files are accepted. The panel shows the app's details and an **Install** button.

The check (`check_app_zip`) reports:

- **API compatible**: the system's `api_version` is the same as or newer than the app's `<api_version>`.
- **App exists**: the app is already installed, so this is an update.
- **Update compatible**: the package's `<app_version>` is the same as or newer than the installed one.

<aside>
⚠️ The **Upload App** tab installs whatever you confirm. It doesn't stop you from installing an app that needs a newer framework, or an older version over a newer one. Check the versions it shows before you click **Install**. An app with no `<api_version>` is always reported as not compatible.

</aside>

## From a repository zip

Since 0.0.30 you can install a zip of the app's repository, such as GitHub's **Download ZIP**, without exporting it first. The repository needs the dev workspace layout (see [Dev Workspace](./Dev%20Workspace.md)), with the manifest at `backend/<app>/<app>.xml`.

On upload the system normalises the archive:

1. **A wrapping folder is fine.** If the zip holds one folder (ignoring `__MACOSX`) and that folder contains `config.xml` or a `backend/` folder, its contents are moved up. This also covers `zip -r myapp.zip myapp/`.
2. **`config.xml` is created if missing.** If the app ships a `config.xml` next to its backend code (`backend/<app>/config.xml`), that file is used. Otherwise one is generated from the manifest, exactly as an export does.
3. **Old cache-busting parameters are stripped** from the JS imports in `frontend/` and `adminpanel/`.
4. **The SQL file is mirrored.** The file named in `<run><sql>` is copied between `database/` and `backend/<app>/`, whichever is missing, so the app installs and later exports the same way.

An archive that already has `config.xml` at its root is installed as it is.

## From the DoCloud App Library

Open **Apps > DoCloud App Store**, pick an app and a version. The system downloads the zip from DoCloud (`install_app_from_docloud`), normalises it as above and shows the install popup. Here **Install** is disabled unless the app is compatible.

For an installed app, the app's update list in **Installed Apps** shows the versions in the library. **Get the update** takes the same route.

To publish your app to the library, export it and add the zip in DoCloud. See [Docloud](../Docloud.md).

---

# How to choose the install location

On a development system, the install screens offer an **Install location**. It appears when `<system_environment>` is `development` and `dev/` exists, or when the app already lives in `dev/`.

- **Standard directories**: the files go to `apps/<app>/`, `api/apps/<app>/` and `api/admin/apps/<app>/`.
- **dev/ workspace**: the files go to `dev/<app>/frontend/`, `dev/<app>/backend/` and `dev/<app>/adminpanel/`, and the framework links them in straight away. Only the parts the package contains get a folder.

An installed app is always updated where it already lives:

- an app in `dev/<app>/` can't be updated into the standard directories,
- an app in the standard directories can't be installed into `dev/`, and
- an app linked from somewhere other than `dev/<app>/` can't be installed into `dev/`.

To move an app between locations, remove it and install it again. `update_app` takes `install_location` (`standard` or `dev`). Without it, the app's current location is used, and `standard` for a new app. This needs DoFramework 0.0.41 or later.

An app installed into `dev/` isn't a git repository. Run `git init` in `dev/<app>/` if you want to work on it.

<aside>
⚠️ Updating an app that lives in `dev/<app>/` writes the package's files into that folder, which is your working copy. Commit or stash your changes first.

</aside>

---

# What an install does

`update_app` runs these steps, in this order:

1. If the app is installed, merges the packaged manifest and both `app-config.json` files with the installed ones (next section).
2. Copies the package's `backend/`, `adminpanel/` and `frontend/` folders over the target folders. Files are added and overwritten, never deleted, so a file that a new release dropped stays on the system.
3. For a `dev/` install, creates the links.
4. Creates each `<createTables>` table that doesn't exist yet (`CREATE TABLE IF NOT EXISTS`). Existing tables aren't changed.
5. Seeds the app's `<app_options>`.
6. Runs the `<run>` SQL file from the package's `database/` folder, and the `<run>` script.
7. Sets the app's entry in the admin panel permission set to the `auto_update` admin permissions in `config.xml`.
8. Updates the frontend cache.

An install doesn't do everything a reinitialise does. It doesn't add new columns to existing tables, provision `<roles>`, or add the `auto_update` user permissions to the `system_admin` role. **Reinitialise the app after every install and update**, then log out of the admin panel and back in.

<aside>
⚠️ Step 7 replaces the app's admin permissions with the package's `auto_update` list. Admin permissions for that app that someone ticked by hand under Settings are removed by an update. Tick them again afterwards.

</aside>

---

# How an update merges the manifests

Since 0.0.33, the package owns the app's manifest and the installation owns only a little state. Before the files are copied, the installed files are rewritten:

**`api/apps/<app>/<app>.xml`**

- The packaged manifest is the base, so new tables, options, notifications, `<app_permissions>`, `<run>` entries and permissions all arrive with the update.
- `<info><status>` is taken from the installed manifest, so an app disabled on this system stays disabled.
- In `<user_permissions>` and `<admin_panel_permissions>`, an installed permission is kept when the package doesn't ship a permission of that name **and** it doesn't have `auto_update="true"`. It goes back into the category of the same name, which is created if needed.
- An installed `auto_update="true"` permission that the package dropped is removed.
- If the packaged manifest has no permission block, or an empty one, the installed block is kept whole. A broken package can't wipe the installation's permissions.

**`apps/<app>/app-config.json` and `api/admin/apps/<app>/app-config.json`**

- The packaged file replaces the installed one, so new resources, menus and widgets ship.
- `status` is taken from the installed file, when both files have it.

Since 0.0.41 a system update merges the system apps' manifests the same way.

---

# Reinitialise or update?

| | Install or update | Reinitialise |
| --- | --- | --- |
| Copies files, merges manifests | Yes | No |
| Creates missing tables | Yes | Yes |
| Adds missing columns, changes columns, adds keys | No | Yes |
| Seeds `<app_options>` | Yes | Yes |
| Runs `<run>` | Yes | Yes |
| Adds `auto_update` user permissions to `system_admin` | No | Yes |
| Admin panel permissions | Replaces the app's entry with the package's list | Adds the `auto_update` ones |
| Provisions `<roles>` | No | Yes |

Reinitialise when you changed the manifest on the system itself, for example while developing in `dev/`. Update when you have a new package. After an update, reinitialise too. Reinitialise is **Apps > Installed Apps**, open the app, **Reinitialize**, or `AppManager::initialize_app('myapp')`. See [App Manager](../Modules/App%20Manager.md) for what it does in detail.

---

# How to set the version fields

Each release has its version in three places. Change all of them together:

| File | Fields |
| --- | --- |
| `api/apps/<app>/<app>.xml` | `<info><app_version>` and `<info><release_date>` |
| `apps/<app>/app-config.json` | `version` and `release_date` |
| `api/admin/apps/<app>/app-config.json` | `version` and `release_date` |

Nothing checks that they agree, but different parts of the system read different files. The admin panel's app list and the install check use the manifest. The browser gets the `app-config.json` values.

```xml
<info>
    <app_name>myapp</app_name>
    <app_version>1.2.0</app_version>
    <api_version>0.0.42</api_version>
    <release_date>2026-10-05</release_date>
</info>
```

```json
"version": "1.2.0",
"release_date": "2026-10-05",
```

- `<api_version>` is the oldest framework version the app works with. Installing on an older system is reported as not compatible.
- Versions are compared number by number, split on `.`. Use the same `x.y.z` form everywhere.

---

# How to remove an app

Open **Apps > Installed Apps**, open the app and click the delete icon. The confirmation has one option, **Remove database records and tables**.

- **Unticked**: the app's files are deleted. Its tables and data stay in the database, and are used again if you reinstall the app.
- **Ticked**: each table in `<createTables>` (`<app>_<name>`) is dropped as well. This can't be undone.

Removal also runs the meta cleanup in the manifest's `<uninstallConfiguration>`. It doesn't remove the app's grants from roles or from the admin panel permission set.

For an app in the standard directories, removal deletes `apps/<app>/`, `api/apps/<app>/` and `api/admin/apps/<app>/`. Export the app first if you have no other copy. An app that lives in `dev/<app>/` is unlinked and its folder is moved to `dev/.removed/` instead (see [Dev Workspace](./Dev%20Workspace.md)).

---

# Requirements

- **PHP zip extension (`ext-zip`).** Uploading, installing from the library and exporting all use `ZipArchive`. Without it, upload and library installs answer "The PHP zip extension is not installed on this server, so archives cannot be created or extracted." An export answers "Error creating zip." and writes a critical entry to the log.
- **`allow_url_fopen`.** Library installs download the zip with `file_get_contents()`.
- **Write access** for the web server to `temp/`, `downloads/`, the three app folders and, for `dev/` installs, `dev/`.

---

# Admin actions

These are `system_admin_app` actions. Each one needs an admin-panel session that holds the action. They answer with HTTP `200` and report failure in `response.success` and `response.statusMsg`. See [Architecture](../Architecture.md) for the response format.

### check_app_zip

Description:

The **`check_app_zip`** action receives an uploaded zip, extracts and normalises it, and reports what it holds and whether it can be installed.

Syntax:

```jsx
const form = new FormData();
form.append("app_zip", file_input.files[0]);
const res = await fetch(XP.getApiUrl() + "/system_admin_app/check_app_zip", {
    method: "POST",
    credentials: "include",
    body: form,
});
```

**Parameters:**

- **`app_zip`**: The uploaded `.zip` file.

**Return Value:**

- **`Object`**: `data.info` is the `<info>` block plus `app_size`, `temp_app_dir` (pass it to `update_app`) and, for an installed app, `current_app_version`. `data.compatibility` has `api_compatible`, `app_exist`, `app_update_compatible` and `total_compatible`. `data.install_location` has `dev_available` and `current` (`standard`, `dev`, `linked` or `null`). `data.path` and `data.prerequisites` come from `config.xml`.

---

### install_app_from_docloud

Description:

The **`install_app_from_docloud`** action downloads a zip from a URL, extracts and normalises it, and reports on it like `check_app_zip`. The admin panel passes the URL of a version in the DoCloud App Library.

Syntax:

```jsx
const form = new FormData();
form.append("app_url", version.app_url);
const res = await fetch(XP.getApiUrl() + "/system_admin_app/install_app_from_docloud", {
    method: "POST",
    credentials: "include",
    body: form,
});
```

**Parameters:**

- **`app_url`**: URL of a `.zip` file.

**Return Value:**

- **`Object`**: The same `data` as `check_app_zip`, without `app_size`.

---

### update_app

Description:

The **`update_app`** action installs or updates an app from a zip that `check_app_zip` or `install_app_from_docloud` extracted. It runs the steps in What an install does.

Syntax:

```jsx
const form = new FormData();
form.append("app_name", info.app_name);
form.append("app_temp_dir", info.temp_app_dir);
form.append("install_location", "standard");
const res = await fetch(XP.getApiUrl() + "/system_admin_app/update_app", {
    method: "POST",
    credentials: "include",
    body: form,
});
```

**Parameters:**

- **`app_name`**: The app name from the package's `<info>`.
- **`app_temp_dir`**: The `temp_app_dir` value from the check.
- **`install_location`**: Optional. `standard` or `dev`. Defaults to where the app is installed now, or `standard`.

**Return Value:**

- **`Object`**: `data` has `install_location`, `backend_copied`, `frontend_copied`, `admin_panel_copied`, `database_executed`, `app_options_executed`, and `sql_executed` and `script_executed` when the app has a `<run>` block.

---

### export_app

Description:

The **`export_app`** action packages an installed app as a zip, as described in How to export an app.

Syntax:

```jsx
const form = new FormData();
form.append("app_name", "myapp");
const res = await fetch(XP.getApiUrl() + "/system_admin_app/export_app", {
    method: "POST",
    credentials: "include",
    body: form,
});
```

**Parameters:**

- **`app_name`**: The installed app's name.

**Return Value:**

- **`Object`**: `data.download_url` is the zip's URL and `data.file_name` is `<app>.zip`.

---

### reinit_app

Description:

The **`reinit_app`** action reinitialises an installed app with `AppManager::initialize_app()`.

Syntax:

```jsx
const form = new FormData();
form.append("app_name", "myapp");
const res = await fetch(XP.getApiUrl() + "/system_admin_app/reinit_app", {
    method: "POST",
    credentials: "include",
    body: form,
});
```

**Parameters:**

- **`app_name`**: The installed app's name.

**Return Value:**

- **`Object`**: `data` is the result of `initialize_app()`.

---

### remove_app

Description:

The **`remove_app`** action removes an installed app, as described in How to remove an app.

Syntax:

```jsx
const form = new FormData();
form.append("app_name", "myapp");
form.append("remove_database_tables", "true");
const res = await fetch(XP.getApiUrl() + "/system_admin_app/remove_app", {
    method: "POST",
    credentials: "include",
    body: form,
});
```

**Parameters:**

- **`app_name`**: The app's name. Only letters, digits and `_` are accepted.
- **`remove_database_tables`**: Optional. The string `true` drops the app's tables. Anything else keeps them.

**Return Value:**

- **`Object`**: For an app in `dev/`, `data.dev_repo_moved_to` is the folder it was moved to, such as `dev/.removed/myapp-20261005-101500/`.

---
