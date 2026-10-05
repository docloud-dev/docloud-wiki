---
title: Logging
sidebar_label: Logging
---

# Logging

Owner: Nuwan Danushka

# Introduction

The framework keeps four logs:

| Log | Written by | Stored in | Viewed in |
| --- | --- | --- | --- |
| Error log | `System::errorlog()` | The `error_log` table of the SQLite file `api/db/do.db` | Admin panel, **Logs > Errors** |
| Access log | `System::acesslog()` | The `access_log` table of the main database | No viewer. Query the table. |
| Admin activity log | The framework, for admin-panel `POST` requests | The main database | Admin panel, **Logs > Admin activity** |
| PHP debug log | PHP's `error_log()` and PHP errors | `api/logs/debug.log` | The file |

---

# Log types

Pass one of these constants as the type of an error log entry. Each stores the string shown.

| Constant | Stored as | Use it for |
| --- | --- | --- |
| `LOG_NOTICES` | `NOTICE` | Information about normal operation. |
| `LOG_WARN` | `WARNING` | A problem that doesn't stop the request. |
| `LOG_ERROR` | `ERROR` | A failure that affects what the request does. |
| `LOG_EXCEPTION` | `EXCEPTION` | A caught exception. |
| `LOG_CRITICAL` | `CRITICAL` | A failure that needs attention now. |

---

# How to log errors

Create the entry with `Loging::log()` and save it with `System::errorlog()`. `Loging::log()` on its own only builds the entry; nothing is saved until you pass it to `System::errorlog()`.

```php
try {
    // code that can fail
} catch (Exception $e) {
    System::errorlog(Loging::log($e->getMessage(), 'myappController:save_order', LOG_WARN));
    return;
}
```

The entry goes into the `error_log` table of `api/db/do.db` with the class name, message, type and time. The table's file column always holds the path of the framework's `Loging` class, not your file, so make the class name say where the error happened (`class:method` works well).

When `<log_db>` is on, the entries a request logs are also added to its JSON response under `errors`. See [Architecture](../Architecture.md).

<aside>
⚠️ `System::log()` is deprecated. It writes to the text file set by `<logs_dir>` and `<log_file>` (`api/logs/log.txt` by default), which nothing else uses and the admin panel doesn't show. Use `System::errorlog()`.

</aside>

---

# How to get errors by email

The framework can email each error log entry of chosen types to the admin.

1. In the admin panel, open **Settings > Logs**.
2. Set **Mail The Errors** to **Yes**.
3. Tick the types to send, for example `CRITICAL`.
4. Click **Update**.

The email goes to `<admin_email>` under `<admin>` in `api/config.<environment>.xml`, from `<system_email>`. It's sent with PHP's `mail()`, whatever `<email_provider>` is set to, so the server must be able to send mail. One email is sent per entry.

---

# How to view logs

- **Errors**: in the admin panel, open **Logs**. The **Errors** tab lists the error log with class name, message, type and date. You can search it and sort it by column.
- **Admin activity**: the **Admin activity** tab of the same page. It shows only to admins with the `get_admin_activity` permission.
- **PHP errors**: read `api/logs/debug.log` on the server. API requests send PHP's `error_log()` output there. Errors raised outside an API request, for example in the shell or heartbeat, go wherever PHP's own `error_log` setting points.

---

# Access log

The access log records what users did, for auditing. Each entry holds the action, the action type, a message, the client IP, device details and the session's user ID.

```php
System::acesslog(Loging::AccessLog('Create Task', 'create', 'Task created'));
```

**Parameters:**

- **`$action`**: What happened, for example `Create Task`.
- **`$actionType`**: The kind of action, such as `create`, `update` or `delete`.
- **`$message`**: A description of the outcome.

The user ID comes from the session key named in `<system_access_log_session_id>` (`USER_ID` by default). Entries go into the `access_log` table of the main database, so the system needs `<db_access>` on.

<aside>
⚠️ `System::acesslog()` always returns `false`, even when the entry was saved. Don't use its return value. If saving fails, the reason is written to the error log.

</aside>

---

# Admin activity log

The admin panel records every state-changing request an admin makes: the admin, the app and action, the outcome and the request fields, with secrets masked. `POST` requests that your admin pages send with `fetch()` are recorded automatically. Call `AdminActivity::describe()` in your action to add a line saying what changed:

```php
AdminActivity::describe('Archived order ' . $order_id);
```

Admins read the log on the **Admin activity** tab of the Log Viewer. Entries are kept for `<admin_activity_retention_days>` days under `<logs>`, 365 by default, set on **Settings > Logs**.

See [Admin Pages](../Building%20Apps/Admin%20Pages.md#what-is-recorded) for what is recorded and what isn't.

---

# Log settings

The `<logs>` block of `api/config.<environment>.xml` holds the log settings. Most can be changed on **Settings > Logs** in the admin panel. See [Configuration Files](./Configuration%20Files.md).

```xml
<logs>
  <logs_dir>logs</logs_dir>
  <log_file>log.txt</log_file>
  <log_level>1</log_level>
  <log_db>true</log_db>
  <mail_logs>true</mail_logs>
  <email_log_type>
    <log_type>CRITICAL</log_type>
  </email_log_type>
  <local_db_log_dir>db</local_db_log_dir>
  <local_db_log_file>do.db</local_db_log_file>
  <admin_activity_retention_days>365</admin_activity_retention_days>
</logs>
```

| Key | Admin panel label | Effect |
| --- | --- | --- |
| `<logs_dir>`, `<log_file>` | Logs Directory, Log File Name | The text log written by the deprecated `System::log()`, relative to `api/`. |
| `<log_level>` | Log Level | Stored, but not read by the framework. |
| `<log_db>` | Save Logs to DB | When on, a request's logged entries are added to its API response under `errors`, and module health-check errors are logged. Error log entries are saved to SQLite either way. |
| `<mail_logs>` | Mail The Errors | Email error log entries to the admin. |
| `<email_log_type>` | The type checkboxes | One `<log_type>` per type to email: `NOTICE`, `WARNING`, `ERROR`, `EXCEPTION` or `CRITICAL`. |
| `<local_db_log_dir>`, `<local_db_log_file>` | | The SQLite file for the error log, relative to `api/`. |
| `<admin_activity_retention_days>` | Keep admin activity for (days) | How long admin activity entries are kept. |

<aside>
⚠️ Turn `<log_db>` off in production. While it's on, every API response that logged something carries the log messages, including exception text, to the browser.

</aside>

---

# Methods

### Loging::log

Description:

The **`Loging::log`** method builds an error log entry. Pass it to `System::errorlog()` to save it.

Syntax:

```php
$log = Loging::log('Payment failed', 'myappController:pay', LOG_ERROR);
```

**Parameters:**

- **`$text`**: The message.
- **`$className`**: Where it happened.
- **`$type`**: One of the log type constants.

**Return Value:**

- **`Log`**: The entry.

---

### System::errorlog

Description:

The **`System::errorlog`** method saves an entry to the error log, adds it to the request's log list and, when `<mail_logs>` is on and the type is selected, emails it to the admin.

Syntax:

```php
System::errorlog(Loging::log($e->getMessage(), 'myappController:pay', LOG_EXCEPTION));
```

**Parameters:**

- **`$log`**: A `Log` from `Loging::log()`.

**Return Value:**

- **`Boolean`**: `true`.

---

### System::acesslog

Description:

The **`System::acesslog`** method saves an entry to the access log.

Syntax:

```php
System::acesslog(Loging::AccessLog('Delete Task', 'delete', 'Task 42 deleted'));
```

**Parameters:**

- **`$log`**: An `AccessLog` from `Loging::AccessLog($action, $actionType, $message)`.

**Return Value:**

- **`Boolean`**: Always `false`. See the note above.

---
