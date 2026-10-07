---
sidebar_position: 75
title: Upgrading The Framework
sidebar_label: Upgrading The Framework
---

# Upgrading The Framework

# Introduction

This page is for whoever updates a running system to a newer framework release. It explains how an update runs, whether you can skip releases, and the manual steps some updates still need. Most updates from 0.0.41 or newer need nothing but logging in again. Older installs need more.

You start an update in the admin panel, under **Settings > System**, in the **System Update** section: from DoCloud, or from an uploaded zip. [Admin Panel](./Admin%20Panel.md) covers the buttons.

## How an update runs

1. The package is saved under `temp/archives/framework_updates/`, and DoCloud checks its hash.
2. The system goes into maintenance, and a full backup is taken.
3. The package is unpacked into `temp/framework_update_temp/`. The live config files are removed from it (`api/config.xml`, `xp-config.json`, `api/admin/xp-config.json`, `manifest.json`, `installScript.class.php`), From an installed 0.0.41 or newer, the system apps' manifests in it are merged with the installed ones. The rest is copied over the installation.
4. The package's `api/apps/system_admin_app/updateScript.class.php` runs once and deletes itself.
5. From an installed 0.0.41 or newer, each system app whose manifest changed is reinitialized, `xp_users` first.
6. The system status from before the update is set back.

**Steps 1 to 5 run the installed version's updater, not the target's.** A fix to the updater takes effect from the update after the one that installs it. Several of the manual steps below exist only because of this.

## Skipping releases

You can update straight to the target release. Stepping through each release in between gains nothing:

- **No update step is skipped.** The update script carries the same steps in every release from 0.0.22 on.
- **The permission migrations of 0.0.35 to 0.0.39 are backfills.** They run on every reinitialization of `xp_users`, do nothing once done, and read legacy data that later releases still keep.
- **Schema changes come from the app manifests and migrations,** and are applied on reinitialization, whatever the starting version.
- **Stepping doesn't avoid the manual steps.** Every update run by a 0.0.40-or-older updater still needs them.

---

# How to prepare for an update

- **The web server's user must be able to write the whole installation.** The update creates `temp/` in the root and copies over every file. When it can't, the update reports **"Failed to download system update."**, even though the package downloaded: saving it is what failed. The Apache error log shows `mkdir(): Permission denied`.

  On a development checkout, give the tree to the web server's group:

  ```bash
  find . -path ./.git -prune -o -user "$USER" ! -type l -print0 | xargs -0 chgrp www-data
  find . -path ./.git -prune -o -user "$USER" ! -type l -print0 | xargs -0 chmod g+rwX
  find . -path ./.git -prune -o -user "$USER" -type d -print0 | xargs -0 chmod g+s
  ```

- **Back up the database yourself as well.** The built-in backup is stored on the same server.

---

# What to do after an update

Each step depends on the version that **runs** the update (the installed one) and the version it updates **to**. Do the steps in order, straight after the update.

| # | Step | Needed when | First target that needs it |
| --- | --- | --- | --- |
| 1 | [Copy the system app manifests](#1-copy-the-system-app-manifests) | Installed 0.0.40 or older | Any. Critical from 0.0.36 |
| 2 | [Reinitialize `xp_users` before any other app](#2-reinitialize-xp_users-before-any-other-app) | Installed 0.0.40 or older | 0.0.36, again for 0.0.38 and 0.0.39 |
| 3 | [Reinitialize `system_admin_app`, then the other apps](#3-reinitialize-system_admin_app-then-the-other-apps) | Installed 0.0.40 or older | 0.0.38 |
| 4 | [Log out and back in](#4-log-out-and-back-in) | Any update that adds admin permissions | 0.0.38 |

From an installed 0.0.41 or newer, the updater does steps 1 to 3 itself: it merges the system app manifests and reinitializes the changed system apps, `xp_users` first. Step 4 still applies.

## 1. Copy the system app manifests

**Needed:** the installed version is 0.0.40 or older.

Updaters 0.0.22 to 0.0.40 delete every system app's manifests from the package before copying it in:

- `api/apps/<app>/<app>.xml`
- `apps/<app>/app-config.json`

So the installation keeps the manifests its first install wrote, however many updates it takes, and the new code runs against old manifests:

| Target | What a stale manifest breaks |
| --- | --- |
| 0.0.36 | `xp_users.xml` lacks `role_permissions`, so a reinit can't create the role permission table that login reads. |
| 0.0.38 | `xp_users.xml` lacks `user_roles` (several roles per user). |
| 0.0.39 | `xp_users.xml` lacks the scope columns. Requests from existing sessions fail with a `500` until `xp_users` is reinitialized with them. |
| 0.0.40 | `apps/xp_system/app-config.json` lacks the default dashboard widgets, so the dashboard shows the greeting and nothing under it. |
| 0.0.41 | `system_admin_app.xml` lacks newer admin actions, such as `change_environment`. They can't be granted, and every call to them is refused. |

For each system app (`auth`, `helloworld`, `system_admin_app`, `xp_email`, `xp_notification`, `xp_system`, `xp_users`), do what the 0.0.41 updater does:

- **`api/apps/<app>/<app>.xml`:** take the target release's file, then put back from the installed one:
  - `<info><status>`;
  - any permission in `<user_permissions>` or `<admin_panel_permissions>` that has no `auto_update="true"` and that the target doesn't ship. Those were added on this installation.
- **`apps/<app>/app-config.json`:** take the target release's file, and keep only the installed `"status"`.

The target's files are in the framework repository at its tag:

```bash
git -C <framework-repo> show v0.0.44:api/apps/xp_users/xp_users.xml > api/apps/xp_users/xp_users.xml
```

To see which manifests are stale, compare each installed file with the tag:

```bash
for a in auth helloworld system_admin_app xp_email xp_notification xp_system xp_users; do
  git -C <framework-repo> show v0.0.44:api/apps/$a/$a.xml | cmp -s - api/apps/$a/$a.xml || echo "stale: $a.xml"
  [ -f apps/$a/app-config.json ] && { git -C <framework-repo> show v0.0.44:apps/$a/app-config.json | cmp -s - apps/$a/app-config.json || echo "stale: $a app-config.json"; }
done
```

A file that differs only in `<status>`, or in permissions added on this installation, is fine.

## 2. Reinitialize xp_users before any other app

**Needed:** the update crosses 0.0.36, 0.0.38 or 0.0.39, run by a 0.0.40-or-older updater.

Reinitializing `xp_users` creates the new tables and then runs the backfills:

| Release | Backfill |
| --- | --- |
| 0.0.36 | Role grants are copied from the legacy role blobs (`xp_users_permissions`) into `xp_users_role_permissions`, which login reads. |
| 0.0.38 | Each user's `xp_users_user.role` is copied into `xp_users_user_roles`. |
| 0.0.39 | The old (user, role) unique key is replaced by one that includes the scope. |

**Do it before you reinitialize anything else.** From 0.0.36 on, reinitializing any app with `auto_update` permissions writes that app's grants for the admin role into `xp_users_role_permissions`, then rewrites that role's legacy blob, and every member's copy, from that table. The backfill skips a role that already has rows there. So if another app goes first, the admin role is left with only that app's grants, and the legacy copies it could be restored from are overwritten too.

Use **Apps > Reinitialize** on `xp_users`, or the command line (below) if the admin panel fails. Then check that every role with a legacy blob has rows in the new table. This should return no rows:

```sql
SELECT p.role_id FROM xp_users_permissions p
WHERE NOT EXISTS (SELECT 1 FROM xp_users_role_permissions rp WHERE rp.role_id = p.role_id)
  AND p.permissions IS NOT NULL AND p.permissions NOT IN ('', '{}', '{"permissions":[]}', '{"permissions":{}}');
```

The reinit also logs `role permission pivot backfill inserted N rows` and `role membership backfill inserted N rows` (class `xp_users:run`, notice level). Until the backfill has run, login falls back to each user's legacy copy, so nobody is locked out in the meantime.

## 3. Reinitialize system_admin_app, then the other apps

**Needed:** the installed version is 0.0.40 or older.

Once step 2 checks out, reinitialize `system_admin_app`. Without it, the Roles page's Members tab gets `401`s on its admin actions (0.0.38), and admin actions added since the first install can't be granted. Then reinitialize your other apps, in any order.

## 4. Log out and back in

**Needed:** the update adds admin permissions, as 0.0.38, 0.0.39 and 0.0.44 do.

The admin panel reads an admin's permissions at login, so other admins log out of the admin panel and back in. For example, the Migrations page of 0.0.44 adds five admin permissions. They reach the admin role when `system_admin_app` is reinitialized, and the **Migrations** menu shows after the next login.

Users of the main site pick up permission changes without logging in again from 0.0.37 on: their first request after the `xp_users` reinit rebuilds their session.

---

# How to reinitialize an app from the command line

`api/shell.php` dispatches through each controller's admin-session check, so it can't run an admin-panel action. This runs the same `AppManager::initialize_app()` that **Apps > Reinitialize** calls. Run it from the installation root, ideally as the web server's user so the files it writes stay owned by that user:

```bash
REQUEST_METHOD=GET php -d display_errors=stderr <<'PHP'
<?php
chdir('api');
require 'core/ConfigTemplates.php'; ConfigTemplates::sync();   // 0.0.41+; drop this line on older releases
require 'Config.php';
require 'core/Constants.php';
require_once 'core/functions.php';
require_once 'core/Framework.php';
require_once 'core/classes/system_config.class.php';
require_once 'core/classes/db.class.php';
// The loaders api/shell.php runs, without its controller dispatch.
foreach (['core_autoload', 'controller_autoload', 'app_autoload', 'module_autoload', 'app_module_autoload', 'Load_SDKs'] as $step) {
    $m = new ReflectionMethod('Framework', $step);
    $m->setAccessible(true);
    $m->invoke(null);
}
var_export(AppManager::initialize_app('xp_users'));
PHP
```

For an app with migrations you can also run just its migrations with `php api/migrate.php migrate <app>` (see [Database Migrations](./Building%20Apps/Database%20Migrations.md)).

---

# Log entries to expect

| Entry | When | Effect |
| --- | --- | --- |
| `updateScript:alter_table`: `Duplicate column name 'status'` | Every update into 0.0.22 to 0.0.42 after the first | None. The update script added `xp_system_custom_fields.status` without checking for it. From 0.0.43 it checks first. |
| `AppManagerDatabaseFunctions:update_column`: `near 'UNSIGNED NULL'`, `Invalid default value` | Any reinit on 0.0.22 | None. The `ALTER` fails and the column is unchanged. Fixed in 0.0.23. |
