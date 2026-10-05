---
title: Scheduler (Heartbeat)
sidebar_label: Scheduler
---

# Scheduler (Heartbeat)

Owner: Nuwan Danushka

# Introduction

The heartbeat runs background tasks on a schedule. A server cron job calls `api/heartbeat.php` once a minute. Each run checks the scheduled tasks and executes the ones that are due.

There are two kinds of task:

- **Application tasks** belong to an app. The app declares them in a scheduler class, and the heartbeat picks them up automatically. This is the kind you write when building an app.
- **System tasks** are static methods of the framework's `HeartbeatFunctions` class, such as `local_database_backup` and `health_check`. They are part of the framework, not of any app.

The heartbeat needs `db_access` set to `true` in the system configuration. Without it, nothing runs.

---

# How to run the heartbeat

Add one cron entry on the server:

```bash
* * * * * php /path/to/api/heartbeat.php
```

Each run records its trigger time, syncs every app's scheduler class into the task table, then runs each task whose last run plus its frequency is now in the past.

---

# How to schedule a task from your app

1. Create `<app_name>Scheduler.class.php` in the app's backend folder, next to its controller: `api/apps/myapp/myappScheduler.class.php` (or `dev/myapp/backend/myapp/` in the dev workspace).
2. Declare a class named `<app_name>Scheduler` that extends `DoScheduler`.
3. Register each task in the static `tasks()` method with `self::job()`, and implement each task as a static method of the same name.

```php
<?php

class myappScheduler extends DoScheduler
{
    public static function tasks()
    {
        self::job('send_daily_report')
            ->frequency('1 day');

        self::job('sync_orders')
            ->frequency('15 minutes')
            ->before('open_connection')
            ->then('close_connection')
            ->setAdminPanel(true);
    }

    public static function send_daily_report()
    {
        // ... your logic ...
        return true;
    }

    public static function sync_orders()
    {
        // ... your logic ...
        self::log('sync_orders', 'Synced 42 orders.', self::$EXECUTION_STAGE);
        return ['synced' => 42];
    }

    public static function open_connection() { /* ... */ }

    public static function close_connection() { /* ... */ }
}
```

The class and file names must match the app name exactly. The heartbeat derives the app name from the class name by dropping the `Scheduler` suffix, and finds the file by looking for `<app_name>Scheduler.class.php` (or `<app_name>Scheduler.php`) in each app folder.

On the next run the task is saved as a recurrent application task. If you remove a task from `tasks()`, or remove the scheduler class, the heartbeat deletes the task on its next run.

<aside>
💡 The frequency is parsed with PHP's relative date formats, as in `date_interval_create_from_date_string()`. Use values such as `'30 seconds'`, `'15 minutes'`, `'2 hours'` or `'1 day'`. A task with no frequency runs every minute.

</aside>

---

# How to change a task from the admin panel

The admin panel's **Heartbeat** page lists every task, with its type, frequency, status and last result. From there an admin can add, edit and delete tasks, and read each task's execution log.

On every run the heartbeat rewrites an application task's frequency and status from the scheduler class. So an admin's edits to an app's task last only if the app calls `->setAdminPanel(true)` on that task. Then the heartbeat keeps the frequency and status saved in the database, and uses the class's frequency only when it first creates the task.

---

# How to manage tasks from the command line

`php api/heartbeat.php <command>`:

| Command | What it does |
| --- | --- |
| _(no command)_ | Runs every due task. This is what cron calls. |
| `view` | Lists the tasks: id, action, type, frequency, status, start date, last result and last run. |
| `add <function> <type> <status> <n> <unit>` | Adds a task for a `HeartbeatFunctions` method. `type` is `system` or `application`, `status` is `undone` (run once) or `recurrent`, and `unit` is one of `year`, `months`, `day`, `hours`, `minutes` or `seconds`. |
| `edit <id> <n> <unit> <status>` | Changes a task's frequency and status. |
| `remove <id>` | Removes a task. System tasks can't be removed. |
| `functions` | Lists the methods of `HeartbeatFunctions`. |
| `healthcheck` | Runs the heartbeat health check. |
| `config` | Prints the main system configuration. |

```bash
php api/heartbeat.php add local_database_backup system recurrent 1 day
php api/heartbeat.php view
php api/heartbeat.php edit 3 6 hours recurrent
```

`add` only accepts methods of `HeartbeatFunctions`. Schedule an app's own work with a scheduler class instead, as described above.

<aside>
⚠️ On every run the heartbeat deletes any `application` task that no scheduler class declares. That includes one added with `add … application …` or from the admin panel. Tasks you add by hand should be `system` tasks.

</aside>

---

# Methods

### job

Description:

The **`job`** method registers a task in the scheduler. Call it inside `tasks()`. The name must be the name of a static method on the same class.

Syntax:

```php
self::job('send_daily_report');
```

**Parameters:**

- **`$taskName`**: The task name, which is also the name of the static method that runs it.

**Return Value:**

- **`DoScheduledTask`**: The task, so the calls below can be chained. Registering the same name twice returns the existing task.

---

### frequency

Description:

The **`frequency`** method sets how often the task runs.

Syntax:

```php
self::job('sync_orders')->frequency('15 minutes');
```

**Parameters:**

- **`$frequency`**: A relative interval such as `'15 minutes'` or `'1 day'`. The default is `'1 minute'`.

**Return Value:**

- **`DoScheduledTask`**: The same task.

---

### before

Description:

The **`before`** method names a static method of the scheduler class to call before the task runs.

Syntax:

```php
self::job('sync_orders')->before('open_connection');
```

**Parameters:**

- **`$callback`**: The name of a static method on the same class.

**Return Value:**

- **`DoScheduledTask`**: The same task.

---

### then

Description:

The **`then`** method names a static method of the scheduler class to call after the task runs.

Syntax:

```php
self::job('sync_orders')->then('close_connection');
```

**Parameters:**

- **`$callback`**: The name of a static method on the same class.

**Return Value:**

- **`DoScheduledTask`**: The same task.

---

### setAdminPanel

Description:

The **`setAdminPanel`** method lets admin-panel edits to the task's frequency and status take effect. Without it, the heartbeat resets both from the scheduler class on every run.

Syntax:

```php
self::job('sync_orders')->setAdminPanel(true);
```

**Parameters:**

- **`$flag`**: `true` to keep the frequency and status saved in the database.

**Return Value:**

- **`DoScheduledTask`**: The same task.

---

### log

Description:

The **`log`** method adds an entry to the task's execution log, which the admin panel's Heartbeat page shows. The heartbeat already logs the start and end of each run, each callback, and the task method's return value.

Syntax:

```php
self::log('sync_orders', 'Synced 42 orders.', self::$EXECUTION_STAGE, 'info');
```

**Parameters:**

- **`$job_name`**: The task name.
- **`$message`**: The log message.
- **`$stage`** (optional): `self::$BEFORE_EXECUTION_STAGE`, `self::$EXECUTION_STAGE` or `self::$AFTER_EXECUTION_STAGE`.
- **`$type`** (optional): The log type. The default is `'info'`.

**Return Value:**

- None.

---
