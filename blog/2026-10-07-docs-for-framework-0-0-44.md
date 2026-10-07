---
slug: docs-for-framework-0-0-44
title: The docs now cover DoFramework 0.0.44
authors: nipun
tags: [update, docs]
---

These docs now cover DoFramework 0.0.44. The biggest change in 0.0.43 and 0.0.44 is database migrations: an app can now keep its schema in PHP migration files instead of `<createTables>`, and the admin panel has a page for running and rolling them back.

{/* truncate */}

## What's new in the docs

- **[Database Migrations](/docs/framework/Building%20Apps/Database%20Migrations).** A new page on when migrations run and how they're recorded, writing `up()` and `down()`, converting an existing app with `make:baseline`, rolling back and resetting, the `php api/migrate.php` command, and the admin panel's Migrations page.
- **[Upgrading The Framework](/docs/framework/Upgrading%20The%20Framework).** A new page on how a framework update runs, why you can skip releases, and the manual steps an update from 0.0.40 or older still needs.
- **[Todo App](/docs/framework/Todo%20App).** The tutorial now creates its table with a migration.
- **[App Manifest](/docs/framework/Building%20Apps/App%20Manifest)** now describes what `<uninstallConfiguration>` does. It used to say nothing reads it.
- **[App Manager](/docs/framework/Modules/App%20Manager)** documents `syncTablesFromXml` and `show_create_table`, and how install and reinitialize treat an app with migrations.

## Framework changes in 0.0.43 and 0.0.44

- **App migrations.** Files in an app's `migrations/` folder run once each, in filename order, on install and on every reinitialize. An app with one migration file uses migrations only. Start new apps on migrations.
- **A Migrations page in the admin panel.** It lists every app's migrations, runs the pending ones and rolls back, with a preview of what will be undone. Apps still on `<createTables>` get a **Sync tables** action. It needs five new admin permissions, which reach the admin role when `system_admin_app` is reinitialized; log in to the admin panel again to see the menu.
- **`helloworld` uses migrations.** Its `<createTables>` became a baseline migration, so it's now the worked example for both.
- **Enum columns survive a reinitialize.** An enum's list goes in `values` only. A reinitialize used to build a bare `enum` and fail.
- **An upload over `post_max_size` is answered with `413`,** naming the limit, instead of the action reporting its fields missing.
- **No redirect loop for a user refused the dashboard.** They get the error page with a `403`.
- **Dev links stay out of `git status`.** The framework's `.gitignore` now tracks only the bundled apps in the app folders, so a dev app needs no entry.
- **`./bump-version` checks the system app versions** before a release.
- **Popups taller than the window scroll,** and a date picker's calendar shows in full inside a popup.

See [Upgrading The Framework](/docs/framework/Upgrading%20The%20Framework) before you update an older install.
