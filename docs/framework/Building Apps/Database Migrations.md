---
sidebar_position: 7
title: Database Migrations
sidebar_label: Database Migrations
---

# Database Migrations

# Introduction

An app builds its tables in one of two ways, never both:

- **`<createTables>`** in its manifest (see [App Manifest](./App%20Manifest.md)). Install and every reinit converge the database to it: they create tables, add columns, and adjust types and keys. They never rename, drop or move data.
- **Migrations**: PHP files in the app's `migrations/` folder. Each file makes one change, runs once, can change data as well as structure, and can be undone.

Use migrations when a change needs more than "add what's missing": renaming a column, dropping one, splitting a table, backfilling data. Start new apps on migrations.

The folder sits next to the manifest: `api/apps/<app>/migrations/` in production, `dev/<app>/backend/<app>/migrations/` while you develop. **As soon as that folder holds one migration, the app uses migrations only.** Its `<createTables>` is ignored, and every reinit logs a warning while it's still in the manifest. Every `.php` file directly in the folder counts as a migration, except `reset.php` (see Resetting an app below). Subfolders are ignored, so keep other PHP files out of `migrations/`.

Every app is in one of three modes, which `migrate.php status` and the Migrations page show:

| Mode | Meaning | To give it migrations |
| --- | --- | --- |
| Migrations | At least one migration file. Migrations own the schema. | — |
| XML | No migrations, and `<createTables>` declares tables. | `make:baseline` |
| No tables | No migrations, and no tables in `<createTables>`. | `make` |

## When migrations run

Migrations run:

- when the app is installed, from the admin panel's Apps page or at system install;
- on every reinitialize: the admin panel's Reinitialize button, the reinit after a system update, and the test harness's `reinit_apps`;
- on demand, with `php api/migrate.php migrate <app>` or **Run pending** on the Migrations page.

Each run takes every migration that hasn't run yet, in filename order, as **one new batch**. The order is a plain string sort of the filenames. `make` names files `YYYYMMDDHHMMSS_<name>.php`, so they sort by creation time. If you name files by hand, pad the numbers: `10_` sorts before `9_`.

## How runs are recorded

The `system_migrations` table records each migration that has run, one row per app and filename:

| Column | Holds |
| --- | --- |
| `app`, `migration` | The app name and the filename without `.php`. Unique together, compared byte for byte. |
| `batch` | The run it belonged to: 1, 2, 3… per app. |
| `executed_at` | When it ran. |
| `source`, `run_by` | Who ran it: `cli` with the OS user, or `web` with the admin-panel admin as `Name <email>`. Empty for rows from 0.0.43. |

The framework creates the table on first use, and adds `source` and `run_by` to a table created by 0.0.43. There is no setup step.

Because a migration is recorded by filename, **renaming a file after it has run makes it a new, pending migration**, and the old row shows as Missing.

Migrations run on the same database a reinit builds on: the session's database, or the one in the config file while `AppManager::useCoreDatabase()` is in effect.

Each app's runs hold a MySQL named lock, so a system update and an admin reinit can't run the same migrations at once. A run that finds the lock taken does nothing and reports `Migrations skipped: already running`.

---

# How to give a new app its tables

Create a migration:

```bash
php api/migrate.php make myapp create_tables
```

This writes `migrations/<YYYYMMDDHHMMSS>_create_tables.php`, creating the folder if needed (for a `dev/` app, load the site once first so the app is linked; see the command reference), with an empty `up()` and `down()`. Migration names are lowercase letters, digits and underscores. Fill it in:

```php
<?php

return new class extends Migration {
    public function up(): void
    {
        $this->execute(<<<'SQL'
            CREATE TABLE IF NOT EXISTS myapp_items (
                id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                title varchar(255) NOT NULL,
                status int(5) NULL,
                created_date datetime NOT NULL,
                PRIMARY KEY (id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            SQL);
    }

    public function down(): void
    {
        $this->dropTableIfExists('myapp_items');
    }
};
```

Migrations don't prefix table names. Write the full `<app>_<name>` name yourself, because the [App Manager](../Modules/App%20Manager.md) table helpers expect that prefix.

Then run it, either by reinitializing the app or from the command line:

```bash
php api/migrate.php migrate myapp
php api/migrate.php status myapp
```

Commit the migration file with the code that needs it. Every other environment runs it on its next reinit.

<aside>
⚠️ `make` refuses on an app that still declares tables in `<createTables>`: `myapp uses <createTables>; run make:baseline first to convert it`. One migration file would switch the app to migrations and leave its existing tables unmanaged. Convert it first (below).

</aside>

---

# How to write a migration

A migration file returns an anonymous class that extends `Migration`. Write SQL with `$this->execute()` and the helpers in the methods reference below.

```php
<?php

return new class extends Migration {
    public function up(): void
    {
        $this->renameColumn('myapp_items', 'status', 'state');
    }

    public function down(): void
    {
        $this->renameColumn('myapp_items', 'state', 'status');
    }
};
```

## up() and down()

Both are optional, but a file must define at least one:

| Defines | On migrate | On rollback |
| --- | --- | --- |
| `up()` and `down()` | Runs `up()` | Runs `down()` |
| `up()` only | Runs `up()` | Removes the record. The changes stay. |
| `down()` only | Records it without running anything | Runs `down()` |
| Neither | Fails: `… defines neither up() nor down()` | — |

An up-only migration suits a data fix that has nothing sensible to undo:

```php
<?php

return new class extends Migration {
    public function up(): void
    {
        $this->execute('UPDATE myapp_items SET state = :new WHERE state = :old', [':new' => 2, ':old' => 0]);
    }
};
```

## Transactions

Each migration runs in a transaction, together with the row that records it. To opt out, declare `public bool $withinTransaction = false;` in the class.

MySQL commits DDL (`CREATE`, `ALTER`, `DROP`, `RENAME`) implicitly, so **a transaction only protects data changes**. If a migration throws after an `ALTER TABLE`, that change stays. So:

- Make one schema change per migration.
- Prefer the `IfExists` helpers and the `tableExists` / `columnExists` / `indexExists` checks, so a rerun after a half-applied failure is safe.
- Run one statement per `execute()` call. A string with several statements runs them all, and an error in any one fails the migration, but the row count and the error message then belong to the first statement.

## When a migration fails

- The app's run stops at the failing migration, which is not recorded. The migrations before it in the same run stay recorded, in that batch.
- The error is logged as critical, with the source `Migrator:migrate`.
- A reinit still applies the rest (options, permissions, roles, `<run>` scripts), and the admin panel reports `Migration <name> failed: <error>`. The CLI prints the same line and exits with 1. A syntax error in the file reads `Parse error: … (line N)`.
- The next run retries it. Fix the file and reinitialize, or run `migrate`.

---

# How to convert an app from `<createTables>`

An app on `<createTables>` moves to migrations with a **baseline**: a first migration that creates the tables the manifest declares today.

Before you start:

- Every environment must have reinitialized on the app's last XML version. A baseline records the schema as the manifest describes it; it can't repair drift.
- The conversion commit must not change the schema. Make schema changes in later migrations.

Then:

1. Run `make:baseline`:

   ```bash
   php api/migrate.php make:baseline myapp
   ```

   It refuses an app that already has migrations, or whose manifest declares no tables. Otherwise it asks two questions, both defaulting to no:

   ```
   Include a down() that drops every table? Rolling the baseline back would then delete the app's data. [y/N]
   Delete <createTables> from …/myapp.xml after writing the baseline? [y/N]
   ```

2. It writes `migrations/<YYYYMMDDHHMMSS>_baseline.php`, with one `CREATE TABLE IF NOT EXISTS` per table, including every key, and the charset and collation from `<createTables>`.
3. If you said yes to the second question, it cuts the `<createTables>` element out of the manifest as text, so the rest of the file keeps its formatting and comments. If the manifest has more than one `<createTables>` (a commented-out copy counts), it refuses and you delete it by hand. Without a terminal, for example from a script, it writes no `down()` and only reminds you to delete `<createTables>`.
4. Commit the baseline and the manifest change **in the same commit**.

When that commit reaches an existing install, the next reinit runs the baseline. The tables already exist, so nothing changes; the baseline is just recorded. A fresh install builds the tables from it.

## Choosing whether the baseline has a down()

| | Rolling back past the baseline, or resetting without `reset.php` | Removing the app with its tables |
| --- | --- | --- |
| **No `down()`** (the default) | The tables and their data stay, and are reported as left in place. | The tables stay. |
| **With `down()`** | Every table the baseline created is dropped, with its data. | The tables are dropped. |

Without a `down()`, ship a `reset.php` if the app needs a clean teardown. The built-in `helloworld` app is a worked example: its `migrations/20261007134403_baseline.php` was converted from its old `<createTables>` with a `down()`.

---

# How to roll back

```bash
php api/migrate.php rollback myapp                                  # the last batch
php api/migrate.php rollback myapp step=2                           # the last 2 migrations
php api/migrate.php rollback myapp to=20261007134403_create_tables  # everything after it
```

- A rollback undoes migrations newest first, running each one's `down()`. A row is removed only once its `down()` succeeds, and the rollback stops at the first failure.
- With `to=`, the named migration stays applied. It must be one that has run.
- `step=` and `to=` can't be combined, and `step` must be a positive whole number.
- A migration without `down()` loses its record and keeps its changes: `Skipped <name> (no down(); its changes stay)`.
- A Missing migration (its file is gone) stops the rollback with `Missing file <name>.php`. Restore the file to roll back past it.

<aside>
⚠️ A rollback changes only the database. The migration files are still there, so **the next reinit, including the one after any system update, runs them again**. Follow a rollback by deploying code without those migrations, or by fixing them.

</aside>

## Resetting an app

```bash
php api/migrate.php reset myapp
```

`reset` tears the app's schema down:

- If the app has `migrations/reset.php`, it runs that file's `up()`, then deletes all of the app's `system_migrations` rows. `reset.php` is written like a migration but is never run by `migrate` and isn't listed in `status`. It must define `up()`, and it must be safe to run twice: its DDL commits before the rows are deleted, so a failure in between leaves it to run again.
- Without `reset.php`, it rolls back every migration the app has run.

```php
<?php

// migrations/reset.php
return new class extends Migration {
    public function up(): void
    {
        $this->dropTableIfExists('myapp_items_meta');
        $this->dropTableIfExists('myapp_items');
    }
};
```

## Removing an app

When an admin removes an app with **Remove database records and tables** ticked, a migrations app is reset as above, instead of having its `<createTables>` tables dropped.

- If the reset fails, the removal stops: `App not removed. <error>`. The app's files, its remaining tables and its tracking rows stay, and running the removal again continues from there.
- Migrations without a `down()` are named in the success message: `Left in place (no down()): …`.
- With the option unticked, the tables and the `system_migrations` rows both stay. Reinstalling the app later runs only the migrations it hasn't run yet.

## In production

When the environment is `production` (`system_environment` in `api/config.xml`, or `APP_CONFIG_ENV` when set), `rollback` and `reset` ask you to type the app name first:

```
This is production. Type the app name (myapp) to continue:
```

Pass `--force` to skip the prompt, for example in a deploy script.

---

# How to use the Migrations page

The admin panel has a **Migrations** page in the sidebar. It lists every installed app: first the apps with migrations, each with its status (Up to date, `N pending`, `N missing` or Error), then a collapsible **No migrations** group with the rest, tagged XML or No tables.

For a selected migrations app it shows a summary line and a table of its migrations: name, status (Ran, Pending or Missing), batch, time, and who ran it (CLI and the OS user, or Web and the admin; a dash for rows from 0.0.43). From there you can:

- **Run pending**: the same as `migrate`. A dialog lists what will run, in order, as one batch. If other migrations became pending since the page loaded, the run is refused (`The migrations changed since the page loaded. Review them again.`) and the list reloads.
- **Roll back**: the last batch, the last N, or back to a chosen migration, which stays applied. Each applied row also has a **Roll back to here** link. The dialog lists exactly what will be undone, newest first, and flags migrations without `down()` and missing files. In production you type the app name, and the server checks it. If the migrations changed since the preview, the rollback is refused and previewed again.

For an XML app the page shows the `make:baseline` command and a **Sync tables** action. Sync tables is the table step of Reinitialize on its own: it creates missing tables and brings columns, keys and collation in line with `<createTables>`, never dropping or renaming. It leaves options, permissions, roles and `<run>` scripts alone, and reports which tables it created or changed. For a No tables app the page shows the `make` command.

`reset`, `make` and `make:baseline` are CLI only.

## Permissions

Each part of the page needs its own admin permission in `system_admin_app`:

| Permission | Allows |
| --- | --- |
| `get_migrations` | Opening the page (also its menu entry) |
| `get_rollback_plan` | The rollback preview |
| `run_migrations` | Run pending |
| `rollback_migrations` | Roll back |
| `sync_app_tables` | Sync tables |

All five are `auto_update` permissions. If the menu entry is missing after an update, reinitialize `system_admin_app` and log in to the admin panel again.

---

# Command reference

```bash
php api/migrate.php status <app>                          # each migration: Ran, Pending or Missing (file gone)
php api/migrate.php migrate <app>                         # run the pending migrations as one batch
php api/migrate.php rollback <app> [step=N | to=<name>]   # the last batch, the last N, or all after <name>
php api/migrate.php reset <app>                           # reset.php, else roll back everything
php api/migrate.php make <app> <name>                     # write migrations/<YYYYMMDDHHMMSS>_<name>.php
php api/migrate.php make:baseline <app>                   # write a baseline from <createTables>
```

- It refuses to run as a web request.
- It uses the database of the current config environment. Prefix `APP_CONFIG_ENV=testing` to use the test database.
- It works on `api/apps/<app>/`. For an app in `dev/`, that's the link to `dev/<app>/backend/<app>/`, so `make` writes into your workspace. The command line doesn't create links, so load the site once after adding a new app to `dev/`; until then `migrate.php` says `No app directory for <app>`.
- `migrate`, `rollback` and `reset` refuse an app without migrations: `myapp has no migrations; it uses <createTables>.`
- Exit codes: `0` done, `1` failed or refused, `2` usage error.

`status` prints the app's mode, then one line per migration:

```
myapp: migrations
Ran      batch 1   2026-10-07 13:56:12  20261007134403_create_tables  [cli: nipun]
Ran      batch 2   2026-10-08 09:20:41  20261008091500_rename_status  [web: Admin <admin@example.com>]
Pending                                 20261009104000_backfill_state
```

The first line can also read `myapp: migrations, reset.php`, `myapp: xml (<createTables>), no migrations` or `myapp: no migrations, no tables`.

---

# Methods reference

These are the protected methods a migration calls on `$this`. Table, column and index names must be plain names (letters, digits and underscores). Anything else throws `InvalidArgumentException`. `$this->db` is the migration's `database` connection, for anything the helpers don't cover.

### execute

Description:

The **`execute`** method runs SQL on the migration's connection and returns the number of rows the first statement affected.

Syntax:

```php
$rows = $this->execute('UPDATE myapp_items SET state = :state WHERE id = :id', [':state' => 1, ':id' => 42]);
```

**Parameters:**

- **`$sql`**: The SQL to run. Prefer one statement per call.
- **`$params`** (optional): Values for the placeholders in `$sql`.

**Return Value:**

- **`Integer`**: The first statement's affected row count.

---

### tableExists

Description:

The **`tableExists`** method checks whether a table exists in the current database.

Syntax:

```php
if (!$this->tableExists('myapp_items')) {
    // ...
}
```

**Parameters:**

- **`$table`**: The full table name.

**Return Value:**

- **`Boolean`**: `true` if the table exists.

---

### columnExists

Description:

The **`columnExists`** method checks whether a table has a column.

Syntax:

```php
if (!$this->columnExists('myapp_items', 'priority')) {
    $this->execute('ALTER TABLE myapp_items ADD COLUMN priority int(5) NOT NULL DEFAULT 0');
}
```

**Parameters:**

- **`$table`**: The full table name.
- **`$column`**: The column name.

**Return Value:**

- **`Boolean`**: `true` if the column exists.

---

### indexExists

Description:

The **`indexExists`** method checks whether a table has an index or key with the given name.

Syntax:

```php
if (!$this->indexExists('myapp_items', 'idx_state')) {
    $this->execute('ALTER TABLE myapp_items ADD INDEX idx_state (state)');
}
```

**Parameters:**

- **`$table`**: The full table name.
- **`$index`**: The index name (`PRIMARY` for the primary key).

**Return Value:**

- **`Boolean`**: `true` if the index exists.

---

### renameColumn

Description:

The **`renameColumn`** method renames a column with `ALTER TABLE … RENAME COLUMN`, keeping its type and data.

Syntax:

```php
$this->renameColumn('myapp_items', 'status', 'state');
```

**Parameters:**

- **`$table`**: The full table name.
- **`$from`**: The current column name.
- **`$to`**: The new column name.

**Return Value:**

- **`void`**

---

### dropColumnIfExists

Description:

The **`dropColumnIfExists`** method drops a column if the table has it, and does nothing otherwise.

Syntax:

```php
$dropped = $this->dropColumnIfExists('myapp_items', 'priority');
```

**Parameters:**

- **`$table`**: The full table name.
- **`$column`**: The column to drop.

**Return Value:**

- **`Boolean`**: `true` if there was a column to drop.

---

### dropTableIfExists

Description:

The **`dropTableIfExists`** method drops a table with `DROP TABLE IF EXISTS`.

Syntax:

```php
$this->dropTableIfExists('myapp_items');
```

**Parameters:**

- **`$table`**: The full table name.

**Return Value:**

- **`void`**

---

### withinTransaction

Description:

The **`withinTransaction`** property decides whether the migration runs in a transaction. It defaults to `true`. On MySQL a transaction only protects data changes, because DDL commits implicitly.

Syntax:

```php
return new class extends Migration {
    public bool $withinTransaction = false;

    public function up(): void
    {
        // ...
    }
};
```

**Return Value:**

- **`Boolean`**: `true` (the default) to run in a transaction.
