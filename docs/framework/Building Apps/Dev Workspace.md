---
sidebar_position: 1
title: Dev Workspace
sidebar_label: Dev Workspace
---

# Dev Workspace

# Introduction

In production an app is split across three framework folders:

| Part | Framework folder |
| --- | --- |
| Frontend (Vue) | `apps/<app>/` |
| Backend (PHP) | `api/apps/<app>/` |
| Admin pages | `api/admin/apps/<app>/` |

The split lets the frontend and backend be deployed on separate servers. While you develop, it means one app lives in three places, which makes version control awkward.

The dev workspace fixes this. You keep the whole app in one folder, `dev/<app>/`, and make that folder its own git repository. On a development server the framework links the three framework folders to the matching parts of `dev/<app>/`, so it finds the app where it expects it while you work in one place.

The dev workspace is for development servers only. Don't deploy `dev/` to staging or production.

---

# How to turn on the dev workspace

The framework links `dev/` apps when both of these are true:

1. `<system_environment>` in `api/config.xml` is exactly `development`.
2. A `dev/` folder exists in the project root.

```xml
<system>
    <system_environment>development</system_environment>
    ...
</system>
```

The value is always read from `api/config.xml`. `APP_CONFIG_ENV` doesn't change it, so a test site that sets `APP_CONFIG_ENV=testing` on the same checkout still links `dev/` apps. With any other value (`production`, `staging`) the framework ignores `dev/` completely. See [Configuration Files](../Essentials/Configuration%20Files.md) for how the environment is chosen.

<aside>
⚠️ Setup leaves `<system_environment>` set to `development`. In that mode the admin panel's login also returns the emailed login code in the `send_auth_code` response (`dev_auth_code`), so anyone who knows the admin email can log in. Change the environment before a server is reachable by other people.

</aside>

---

# How to lay out an app in `dev/`

Use this layout. The inner folders are named after the app:

```
dev/
    myapp/
        frontend/
            myapp/
                app-config.json
                route.js
                services.js
                components/
                assets/
        backend/
            myapp/
                myapp.xml
                myapp.class.php
                myappController.class.php
                myappDAO.class.php
                myappModel.class.php
        adminpanel/
            myapp/
                app-config.json
                route.js
                service.js
                components/
                assets/
```

- **The app name comes from the manifest.** The framework reads `<info><app_name>` and names the links after it, not after the folder. The inner folders `frontend/<app_name>/`, `backend/<app_name>/` and `adminpanel/<app_name>/` must use that name.
- **Name the outer folder after the app too.** The framework looks for the manifest at `dev/<folder>/backend/<folder>/<folder>.xml`. The outer folder can have another name, such as `docloud-app-myapp`, only if the repo has a `config.xml` at its root (the file an app export generates).
- **Every part is optional.** A part whose folder doesn't exist isn't linked. Create `adminpanel/` only if the app has admin pages.

The app name must also match the class name prefixes (`myappController`) and the table prefix. See [App Manifest](./App%20Manifest.md).

## Put the app under git

Each app in `dev/` is its own repository, separate from the framework's:

```bash
cd dev/myapp
git init
echo ".DS_Store" > .gitignore
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:your-org/docloud-app-myapp.git
git push -u origin main
```

The framework's `.gitignore` ignores everything in `dev/`. It doesn't ignore the links your app creates in `apps/`, `api/apps/` and `api/admin/apps/`, so they show up as untracked files in the framework checkout. Add them to that checkout's `.git/info/exclude`, which isn't committed:

```bash
printf '/apps/myapp\n/api/apps/myapp\n/api/admin/apps/myapp\n' >> .git/info/exclude
```

---

# How the links are created

`Framework::run()` calls `setup_dev_links()` on every API request, before any autoloader runs. For each folder in `dev/` (folders whose names start with a dot are skipped), it:

1. Reads the app name from `dev/<folder>/config.xml`, or, if that file doesn't exist, from `dev/<folder>/backend/<folder>/<folder>.xml`. A folder with no readable `<info><app_name>` is skipped.
2. Works through three links:

   | Link | Target |
   | --- | --- |
   | `apps/<app_name>` | `dev/<folder>/frontend/<app_name>` |
   | `api/apps/<app_name>` | `dev/<folder>/backend/<app_name>` |
   | `api/admin/apps/<app_name>` | `dev/<folder>/adminpanel/<app_name>` |

3. For each link:
   - If the target folder doesn't exist, it does nothing.
   - If a link already exists and points to a folder that exists, it leaves it alone.
   - If a link exists but its target is gone, it deletes the link and creates it again.
   - If a real folder (not a link) is already at that path, it leaves it alone and doesn't link the dev copy.
   - Otherwise it creates the link. Links use absolute paths.

Only API requests create links. The page itself (`index.php`) doesn't, and neither do command-line runs (`api/shell.php`, `api/heartbeat.php`, `api/migrate.php`): on the command line the web server's document root is empty, so the framework can't find `dev/`. After you add a new app to `dev/`, load the site once and then reload it. The first load collects frontend files before its API calls have created the links.

<aside>
⚠️ A real folder blocks the link. If `api/apps/myapp/` is a normal folder, for example because the app was installed earlier from the admin panel, the framework keeps using that folder and ignores `dev/myapp/` without any error. Move the real folder out of the way first.

</aside>

---

# How to check the links

From the project root:

```bash
ls -la apps/ | grep myapp
ls -la api/apps/ | grep myapp
ls -la api/admin/apps/ | grep myapp
```

A working link looks like this:

```
lrwxr-xr-x  1 www  staff  52 Oct  5 10:07 myapp -> /var/www/site/dev/myapp/backend/myapp
```

If a link is missing, check that:

1. `<system_environment>` in `api/config.xml` is exactly `development`, and `dev/` exists.
2. The manifest is at `dev/myapp/backend/myapp/myapp.xml` and has `<info><app_name>myapp</app_name></info>`.
3. The inner folder names match `<app_name>`.
4. No real folder is in the way at the link's path.
5. You made an API request after creating the folders (load any page of the site).

---

# How to fix stale or broken links

- **You moved or renamed the `dev/` folder but kept the app name.** Nothing to do. The old links now point nowhere, and the next API request replaces them.
- **You deleted the `dev/` folder or changed `<app_name>`.** The framework only looks at folders that exist in `dev/`, so links for the old name stay behind, pointing nowhere. Delete them by hand:

  ```bash
  rm apps/oldname api/apps/oldname api/admin/apps/oldname
  ```

  Write the paths without a trailing `/`. `rm` then removes the link itself. Never use `rm -r` on a link path that ends in `/`: that deletes the files in your `dev/` folder.

- **A link points to the wrong place.** A link whose target exists is never corrected. Delete it with `rm` as above, then make an API request.

---

# What not to do

- **Don't create the links yourself.** The framework creates and repairs them. A link you make by hand that points somewhere valid is never checked again, so a mistake in it stays.
- **Don't edit through `apps/`, `api/apps/` or `api/admin/apps/`.** Open `dev/myapp/` in your editor and run git there. The framework locations are only the links, and if a tool ever replaces a link with a real folder, the framework keeps that folder and stops using your repo.
- **Don't deploy `dev/`.** Production servers use real folders in the framework locations. Install the app there from an export instead (see [Packaging And Updates](./Packaging%20And%20Updates.md)).

---

# How to install an app into `dev/`

On a development server, the admin panel can install an uploaded app into `dev/<app>/` instead of the standard folders, and link it straight away. Choose **dev/ workspace** under **Install location** when you install. The new folder isn't a git repository yet, so run `git init` in it. [Packaging And Updates](./Packaging%20And%20Updates.md) explains install locations.

---

# How to remove an app that lives in `dev/`

Remove it from the admin panel as usual (**Apps**, open the app, then the delete button). For an app linked from `dev/<app>/`, removal:

1. Drops the app's tables, if you ticked **Remove database records and tables**.
2. Deletes the three links. It doesn't follow them into your folder.
3. Moves `dev/<app>/` to `dev/.removed/<app>-<YYYYMMDD-HHMMSS>/`, with its git history and uncommitted work intact. If two removals happen in the same second, a `-2`, `-3` … suffix is added.

The framework ignores `dev/.removed/` because its name starts with a dot. To restore the app, move its folder back to `dev/<app>/`, make an API request so the links are created, and reinitialise the app.

If the folder can't be moved, the response says so and the removal is reported as failed. The links are gone, but the folder is still in `dev/`, so the next API request links the app again. Move or delete the folder yourself.

This needs DoFramework 0.0.41 or later. Older versions followed the links and deleted the files inside `dev/<app>/`.

---

# How to run controllers from the command line

Run a controller action with `api/shell.php`. Run it from the `api/` folder:

```bash
cd api
REQUEST_METHOD=GET php shell.php myapp get_items status=active,limit=20
```

- **`REQUEST_METHOD`** sets what `$this->getRequest()->getType()` returns. Without it, the type is `cli`, and a controller that switches on `GET` and `POST` answers `400 Bad request`. Use the method the action is written for.
- **`APP_CONFIG_ENV`** picks the database and settings. Without it, the run uses the overlay named by `<system_environment>`, normally `api/config.development.xml`. To work against a test database, create `api/config.testing.xml` and prefix the command:

  ```bash
  APP_CONFIG_ENV=testing REQUEST_METHOD=POST php shell.php myapp rebuild_index from=2026-01-01
  ```

- **Run from `api/`.** Some app lookups, for example the permission step of `AppManager::initialize_app()`, use the relative path in `<system_app_directory>` (`apps`). From the project root that path finds the frontend folder `apps/` instead of `api/apps/`, and those steps quietly find nothing.
- **Make an API request first.** Command-line runs don't create dev links, so a new `dev/` app isn't visible to the shell until the site has linked it.
- **There is no session.** The controller's `authenticate()` must let command-line runs through. Test `php_sapi_name() === 'cli'`, not `is_shell()`.

[Architecture](../Architecture.md) describes the shell entry point and lists the other differences from HTTP requests.

---

# Methods

### Framework::dev_links_enabled

Description:

The **`dev_links_enabled`** method tells you whether this installation links `dev/` apps: `<system_environment>` in `api/config.xml` is `development` and a `dev/` folder exists.

Syntax:

```php
if (Framework::dev_links_enabled()) {
    // dev/ apps are linked on this system
}
```

**Parameters:**

- None.

**Return Value:**

- **`Boolean`**: `true` when both conditions hold. `false` otherwise, including when `api/config.xml` doesn't exist.

---

### Framework::link_dev_repo

Description:

The **`link_dev_repo`** method links one `dev/` folder into the framework locations, using the rules in How the links are created. `setup_dev_links()` calls it for every folder in `dev/`. The admin panel calls it after installing an app into `dev/`, so the app works without waiting for the next request. It doesn't check `dev_links_enabled()` itself.

Syntax:

```php
Framework::link_dev_repo(RDIR . DS . 'dev' . DS . 'myapp');
```

**Parameters:**

- **`$repo_path`**: Absolute path of the `dev/<folder>` directory.

**Return Value:**

- **`void`**: Nothing. A folder without a readable app name is skipped silently.

---
