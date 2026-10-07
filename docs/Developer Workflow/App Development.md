---
sidebar_position: 1
title: App Development
sidebar_label: App Development
---

# App Development

# Introduction

This page walks through the life of a DoFramework app: set up a development install, create the app in its own repository, build it, test it, version it and ship it. Each step is short and links to the page with the details.

The workflow rests on two ideas:

- **An app lives in one folder while you build it.** In production an app is split across `apps/`, `api/apps/` and `api/admin/apps/`. On a development install you keep the whole app in `dev/<app>/` and the framework links it into place (see [Dev Workspace](../framework/Building%20Apps/Dev%20Workspace.md)).
- **An app ships as a zip.** You don't copy files to a server. You export the app, or zip its repository, and install that zip from the admin panel (see [Packaging And Updates](../framework/Building%20Apps/Packaging%20And%20Updates.md)).

The [Todo App](../framework/Todo%20App.md) tutorial follows this workflow step by step with a complete example.

---

# How to set up a development install

1. Install the framework on a server or local machine with HTTPS, as described in [Get Started](../framework/Get%20Started.md). Setup leaves `<system_environment>` in `api/config.xml` set to `development`. Keep it that way.
2. Create a `dev/` folder at the framework root, next to `api/` and `apps/`, if it isn't there.
3. Make sure the web server's PHP user can create entries in `apps/`, `api/apps/` and `api/admin/apps/`. The framework puts the links there.
4. Log in to the admin panel at `https://your-site/api/admin/`. On a development install you can use **Login Local** instead of DoCloud (see the [Todo App](../framework/Todo%20App.md) tutorial, Step 3).

Use a separate install for development. Development mode returns the admin login code in the browser, so it must never be reachable by other people.

<aside>
⚠️ Never develop on a production install. Development mode turns on the `dev/` links and the local login, and a production install should run real app folders, not links.

</aside>

---

# How to start an app

1. Pick the app name. Use lowercase letters, digits and `_`. The name is used everywhere: the folder names, the manifest's `<app_name>`, the class name prefixes (`myappController`) and the table prefix (`myapp_`).
2. Create the folders:

   ```bash
   mkdir -p dev/myapp/backend/myapp dev/myapp/frontend/myapp/components
   ```

   Add `dev/myapp/adminpanel/myapp/` only if the app has [admin pages](../framework/Building%20Apps/Admin%20Pages.md).

3. Write the manifest, `dev/myapp/backend/myapp/myapp.xml` (see [App Manifest](../framework/Building%20Apps/App%20Manifest.md)), and the frontend config, `dev/myapp/frontend/myapp/app-config.json` (see [App Frontend Config](../framework/Building%20Apps/App%20Frontend%20Config.md)). The built-in `helloworld` app has a working example of every file.
4. Make the app its own git repository:

   ```bash
   cd dev/myapp
   git init
   echo ".DS_Store" > .gitignore
   git add .
   git commit -m "feat: initial myapp skeleton"
   git remote add origin git@github.com:your-org/docloud-app-myapp.git
   git push -u origin main
   ```

5. Load any page of the site, then reload it. The first API request creates the links, and the app appears on the admin panel's **Apps** page. The framework's `.gitignore` already keeps the links out of the framework checkout's `git status`.
6. Create the app's tables in a migration, from the framework root:

   ```bash
   php api/migrate.php make myapp create_tables
   ```

   This writes `dev/myapp/backend/myapp/migrations/<YYYYMMDDHHMMSS>_create_tables.php`. Put your `CREATE TABLE` statements in its `up()` and the matching `DROP TABLE` in its `down()`. Use migrations, not `<createTables>`, for every new app. See [Database Migrations](../framework/Building%20Apps/Database%20Migrations.md).
7. Reinitialize the app (**Apps**, the gear icon on the app's card, **Reinitialize**). This runs its migrations and grants its permissions to the `system_admin` role.

To work on an existing app, clone its repository into `dev/` instead of steps 2 to 4, and name the clone folder after the app:

```bash
git clone git@github.com:your-org/docloud-app-myapp.git dev/myapp
```

---

# How to work on an app day to day

Open `dev/myapp/` in your editor and run git there. Never edit through `apps/`, `api/apps/` or `api/admin/apps/`: those are only links.

What you do after an edit depends on what you changed:

| You changed | Then |
| --- | --- |
| A frontend file (`route.js`, a component, `services.js`, CSS) | Reload the page. There is no build step: the framework rebuilds its bundles on every page load. |
| A backend class (controller, model, DAO) | Call the endpoint again. PHP reads the file on every request. |
| `app-config.json` (menus, resources, widgets) | Reload the page. |
| The schema | Add a new migration (`php api/migrate.php make myapp <name>`), then reinitialize the app or run `php api/migrate.php migrate myapp`. Don't edit a migration that has already run: it won't run again. |
| The manifest's permissions or roles | Reinitialize the app, then log out of the admin panel and back in if you changed admin permissions. |

A reinitialize runs the app's pending migrations and grants new `auto_update` permissions, but it never takes back a grant. Each schema change, including a rename or a drop, is a migration of its own. See [Database Migrations](../framework/Building%20Apps/Database%20Migrations.md) and [App Manager](../framework/Modules/App%20Manager.md) for what a reinitialize does.

Commit in small steps, each with a conventional subject:

```bash
git commit -m "feat: add the invoice approval endpoint"
git commit -m "fix: list_invoices ignores the status filter"
```

Use `feat:` for new behaviour, `fix:` for bugs, `refactor:` for changes that keep behaviour the same, `docs:` for documentation and `chore:` for version bumps and housekeeping.

---

# How to test an app

- **Call the API from the browser.** Log in to the web app, then open `https://your-site/api/myapp/<action>`. The response is the JSON described in [Architecture](../framework/Architecture.md). A `401` means your user doesn't hold `myapp/<action>`.
- **Run controller actions from the command line** with `api/shell.php`, from the `api/` folder:

  ```bash
  cd api
  REQUEST_METHOD=GET php shell.php myapp list_invoices status=open
  ```

  Set `REQUEST_METHOD` to the method the action expects, or the controller sees `cli` and answers `400`. See [Dev Workspace](../framework/Building%20Apps/Dev%20Workspace.md) for the other rules.

- **Use a separate test database** for anything that writes data. Create `api/config.testing.xml` with the test database settings and prefix commands with `APP_CONFIG_ENV=testing`. See [Configuration Files](../framework/Essentials/Configuration%20Files.md).
- **Check the error log.** Write errors with `System::errorlog()` and read them in the admin panel under **Logs > Errors**. See [Logging](../framework/Essentials/Logging.md).
- **Test as a normal user,** not only as `system_admin`. Give a test user only the role the app declares and check that the menus and actions they should see work, and the others are refused. See [Roles And Permissions](../framework/Essentials/Roles%20And%20Permissions.md).

---

# How to release a version

1. Raise the version and release date in all three places, to the same values:

   | File | Fields |
   | --- | --- |
   | `backend/myapp/myapp.xml` | `<info><app_version>` and `<info><release_date>` |
   | `frontend/myapp/app-config.json` | `version` and `release_date` |
   | `adminpanel/myapp/app-config.json` | `version` and `release_date` |

   Set `<api_version>` to the oldest framework version the app works with. Use `x.y.z` everywhere. Versions are compared number by number.

2. Remove notes, test data and local files from the app folders. An export includes everything in them, hidden files too.
3. Commit the bump and tag it:

   ```bash
   git commit -am "chore: bump myapp to 1.2.0"
   git tag v1.2.0
   git push origin main v1.2.0
   ```

See How to set the version fields in [Packaging And Updates](../framework/Building%20Apps/Packaging%20And%20Updates.md) for which parts of the system read which file.

---

# How to ship an app

Pick one of these:

- **Export it.** In the admin panel of the development install, open **Apps > Installed Apps**, open the app and click **Download App**. Delete the copy the export leaves in `downloads/exports/` afterwards.
- **Zip the repository.** A zip of the repository, such as GitHub's **Download ZIP** for your tag, installs directly. The repository needs the `dev/` layout, which it already has.
- **Publish it to the DoCloud App Library.** Add the exported zip in DoCloud (see [Docloud](../framework/Docloud.md)). Systems then install and update the app from **Apps > DoCloud App Store**.

On the target system, install the zip from **Apps > Upload App**, check the versions the panel shows, click **Install**, then **reinitialize the app** and log out of the admin panel and back in. An install doesn't add new columns or provision roles. Only the reinitialize does.

An update is the same steps with a newer zip. The update keeps the installation's own state, such as the app's status and permissions an admin added. See [Packaging And Updates](../framework/Building%20Apps/Packaging%20And%20Updates.md) for exactly what an install and an update change.

---

# Checklist

Before you ship a release:

- [ ] The version and release date match in the manifest and both `app-config.json` files.
- [ ] `<api_version>` is no newer than the framework on the systems you ship to.
- [ ] The app works for a user who holds only the app's role.
- [ ] Every table change is in `<createTables>`, and you checked it on a fresh database with a reinitialize.
- [ ] No notes, test data or credentials are in the app folders.
- [ ] The release commit is tagged and pushed.

---
