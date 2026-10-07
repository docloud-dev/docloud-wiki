---
sidebar_position: 30
title: Core Classes
sidebar_label: Core Classes
---

# Core Classes

Owner: Thilina Deepal

# Introduction

The core classes live in `api/core/classes/`. The framework loads them on every request, so you use them without any `require`. These are the ones app code works with:

| Class | File | What it does |
| --- | --- | --- |
| `Controller` | `Controller.class.php` | Base class for your app's API controller |
| `Request` | `Request.class.php` | The incoming request: controller, action, method, data and files |
| `Response` | `Response.class.php` | Builds the JSON response |
| `database` | `db.class.php` | PDO wrapper for the MySQL database |
| `Sqlitedb` | `Sqlitedb.class.php` | Wrapper for the local SQLite database |
| `system_config` | `system_config.class.php` | Reads and writes the backend config files |
| `System` | `System.class.php` | Writes the error log and the access log |
| `App` | `App.class.php` | Base class for your app's main class |
| `Module` | `Module.class.php` | Base class for framework modules |

For how a request reaches your controller, see [Architecture](Architecture.md). The [Todo App](Todo%20App.md) tutorial uses all of these classes in one app.

---

# How to write a controller

Your app's backend gets one controller, `api/apps/myapp/myappController.class.php`. The framework builds the class name from the URL: a request to `/api/myapp/get_items` loads `myappController` and calls it with the action `get_items`.

A controller extends `Controller` and implements two methods:

- `authenticate()` decides whether the request may run. Return `true` or `false`.
- `Render()` handles the request and echoes a response.

The framework calls `authenticate()` first. When it returns `false`, the client gets `401 Not Authorized` and `Render()` never runs.

```php
<?php

class myappController extends Controller
{
    public function authenticate()
    {
        $action = $this->getRequest()->getAction();
        $controller = $this->getRequest()->getController();

        // Actions anyone can call without logging in
        $publicEndpoints = array();

        return auth::appUserPermission($action, $controller, $publicEndpoints);
    }

    public function Render()
    {
        switch ($this->getRequest()->getType()) {
            case 'POST':
                $this->PostHandler();
                break;
            case 'GET':
                $this->GetHandler();
                break;
            default:
                echo Response::badRequest();
                break;
        }
    }

    private function GetHandler()
    {
        switch ($this->getRequest()->getAction()) {
            case 'get_items':
                $this->get_items();
                break;
            default:
                $this->notSupported();
                break;
        }
    }

    private function PostHandler()
    {
        switch ($this->getRequest()->getAction()) {
            case 'add_item':
                $this->add_item();
                break;
            default:
                $this->notSupported();
                break;
        }
    }

    private function notSupported()
    {
        $res = new Response();
        echo $res->create(501, 'Not Supported yet.', false);
    }

    private function get_items()
    {
        $res = new Response();

        try {
            $data = $this->getRequest()->getData();
            $status = $data['status'] ?? 'open';

            $res->setData(myappDAO::getItems($status));
            echo $res->create(200, 'Items loaded.', true);
        } catch (Exception $e) {
            System::errorlog(Loging::log($e->getMessage(), 'myappController:get_items', LOG_WARN));
            echo $res->create(200, 'Something went wrong.', false);
        }
    }

    private function add_item()
    {
        // ...
    }
}
```

This is the same pattern as the `helloworld` app that ships with the framework. [Authentication](Essentials/Authentication.md) explains `auth::appUserPermission()` and public actions.

<aside>
⚠️ Don't rely on the base `Controller::authenticate()`. It only calls `SessionManager::validateSession()`, which checks that the session has a non-empty `USER_ID`, `COMPANY_ID`, `EMAIL` and `ROLE`. It refuses a user without a company and checks no permissions. Always override it.

</aside>

---

# How to read the request

Inside the controller, `$this->getRequest()` returns the `Request` object. For a call like this:

```text
GET https://www.example.com/api/myapp/get_items?page=1&per_page=10
```

| Call | Returns |
| --- | --- |
| `getController()` | `myapp` |
| `getAction()` | `get_items` |
| `getType()` | `GET` |
| `getData()` | `['page' => '1', 'per_page' => '10']` |

What `getData()` holds depends on the method:

- **`GET`**: the query string (`$_GET`).
- **`POST`** with a form or multipart body: the form fields (`$_POST`).
- **`POST`** with `Content-Type: application/json`: the decoded JSON body. A body that isn't valid JSON gives `null`, so check before you index into it.
- **Any other method** (`PUT`, `PATCH`, `DELETE`): an array holding the single string `Request Type Not Supported By API`. Use `GET` and `POST` only.
- **Shell runs**: the `key=value` pairs from the command line. See [Architecture](Architecture.md).

```php
$data = $this->getRequest()->getData() ?? [];
$name = trim($data['name'] ?? '');
```

Uploaded files come from `getFiles()`, which returns `$_FILES` for a `POST`:

```php
$files = $this->getRequest()->getFiles();
$upload = $files['attachment'] ?? null;
```

<aside>
⚠️ `getFiles()` throws an `Error` ("must not be accessed before initialization") on a `GET` request and on a shell run, because the files are only set for `POST`. Call it only in your `POST` handlers.

</aside>

On the command line `getType()` returns `cli`, not `GET` or `POST`. The `Request` constructor also stops any web request that didn't arrive over HTTPS with `497 Please Use HTTPS!`, and any request whose body was over PHP's `post_max_size` with `413`. PHP drops such a body, so without this the action would report its fields and files as missing.

---

# How to send a response

Every action answers with a `Response`. Create it, set the data if there is any, then echo the JSON that `create()` returns:

```php
$res = new Response();
$res->setData($items);
echo $res->create(200, 'Items loaded.', true);
```

The client receives:

```json
{
    "response": {
        "statusCode": 200,
        "statusMsg": "Items loaded.",
        "success": true
    },
    "data": [
        { "id": 1, "name": "First item" }
    ]
}
```

- `create()` sets the HTTP status line from the code. A code the framework doesn't know is sent as `999 API Error`.
- `data` is left out when the data is empty or falsy (`[]`, `""`, `0`, `false`, `null`).
- `errors` is added when the request logged errors through `System::errorlog()` and `<log_db>` is `true` in the config.

Remember to `echo` the result: `create()` only returns the string. For a handled failure, many actions send `200` with `success: false`, and the frontend checks `response.success`. See [Status codes the framework sends](Architecture.md#status-codes-the-framework-sends) in Architecture.

---

# How to query the database

`database` wraps PDO for the MySQL database set in `<database>` of `api/config.<environment>.xml`. The usual cycle is `query()` to prepare, `bind()` for each value, then `execute()`, `resultset()` or `single()`.

There are two ways to write a DAO. Create a `database` object inside each method, as `helloworld` does:

```php
class myappDAO
{
    public static function getItems(string $status): array
    {
        $db = new database();
        $db->query("SELECT * FROM myapp_items WHERE status = :status ORDER BY id DESC");
        $db->bind(':status', $status);
        return $db->resultset();
    }
}
```

Or extend `database` and call the methods on `$this`:

```php
class myappDAO extends database
{
    public function getItem(int $id): array|false
    {
        $this->query("SELECT * FROM myapp_items WHERE id = :id");
        $this->bind(':id', $id);
        return $this->single();
    }
}

$item = (new myappDAO())->getItem(5);
```

Use the full table name, with your app's prefix (`myapp_items`). [App Manager](Modules/App%20Manager.md) explains how tables are created from your manifest.

Things to know:

- **Errors throw.** The connection uses `PDO::ERRMODE_EXCEPTION`, so a failed query throws a `PDOException` rather than returning `false`. Wrap database code in `try`/`catch`.
- **A failed connection doesn't throw.** The constructor logs the error and carries on. The first `query()` then throws `Database connection not initialized.` `getError()` returns the PDO message.
- **Every setting is required.** The host, database name, user name and password in the config must all be non-empty, so a MySQL user without a password can't connect.
- **One connection per request.** Since 0.0.23, every `database` object with the same credentials shares one PDO handle for the whole request. A transaction opened on one object covers the queries of every other object, including the ones that `AppManager` helpers create.
- **Timestamps match PHP.** Each new connection sets the MySQL session time zone to PHP's, so `CURRENT_TIMESTAMP` agrees with `date()`.

## Use a transaction

```php
$db = new database();

try {
    $db->beginTransaction();

    $db->query("INSERT INTO myapp_orders (customer_id) VALUES (:customer_id)");
    $db->bind(':customer_id', $customer_id);
    $db->execute();
    $order_id = $db->lastInsertId();

    foreach ($lines as $line) {
        $db->query("INSERT INTO myapp_order_lines (order_id, item_id, qty) VALUES (:order_id, :item_id, :qty)");
        $db->bind(':order_id', $order_id);
        $db->bind(':item_id', $line['item_id']);
        $db->bind(':qty', $line['qty']);
        $db->execute();
    }

    $db->endTransaction();
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->cancelTransaction();
    }
    System::errorlog(Loging::log($e->getMessage(), 'myappDAO:createOrder', LOG_ERROR));
    return false;
}
```

Because the handle is shared, a helper that calls `beginTransaction()` while its caller already has a transaction open gets a `PDOException` ("There is already an active transaction"). A helper that might run inside someone else's transaction should only open its own when none is open:

```php
$ownsTransaction = !$db->inTransaction();
if ($ownsTransaction) {
    $db->beginTransaction();
}

// ... queries ...

if ($ownsTransaction) {
    $db->endTransaction();
}
```

## Choose where the credentials come from

The constructor takes one flag:

| Flag | Behaviour |
| --- | --- |
| `database::ENABLE_SESSION_CREDENTIALS` (default) | The first `database` in a PHP session stores the connection details, encrypted, in the session. Every later `database` in that session uses the stored details. `changeConnection()` replaces them, which is how one user's session is pointed at a different database. |
| `database::DISABLE_SESSION_CREDENTIALS` | Always reads `<database>` from the config. The session is neither read nor written. |

```php
// Always the database from the config, whatever the session holds
$db = new database(database::DISABLE_SESSION_CREDENTIALS);
```

<aside>
⚠️ With the default flag, a session keeps the credentials it stored first. If you change the database settings in the config, users who are already logged in go on using the old ones until their session ends. `resetConnection()` reloads them from the config.

</aside>

---

# How to use the local SQLite database

`Sqlitedb` opens the framework's local SQLite file, `api/db/do.db` by default (`<local_db_log_dir>` and `<local_db_log_file>` in `<logs>`). The framework keeps its error log there. The API is close to `database`:

```php
$sqlite = new Sqlitedb();
$sqlite->query("SELECT * FROM error_log WHERE ErrorType = :type ORDER BY Date DESC LIMIT 20");
$sqlite->bind(':type', LOG_CRITICAL);
$rows = $sqlite->resultset();
```

To open a different file, use `Sqlitedb::withPath('/full/path/to/file.db')`. The connection closes when the object is destroyed.

<aside>
⚠️ Two methods don't work: `checkIfTableExists()` always returns `false` (and raises a PHP warning), and `rowCount()` always returns `null`. Run your own `SELECT count(*)` with `querySingleField()` instead.

</aside>

---

# How to read and change config

`system_config` is a static class for the backend config: `api/config.xml` and the overlay `api/config.<environment>.xml`.

```php
$timezone = system_config::get('system', 'system_api_timezone');
$status = system_config::get_system_status(); // up, maintenance or down
```

[Config Handlers](Essentials/Config%20Handlers.md) documents all of its methods, and [Configuration Files](Essentials/Configuration%20Files.md) explains which file holds which setting.

---

# How to log errors

Use `System::errorlog()` with a `Log` built by `Loging::log()`:

```php
try {
    // ...
} catch (Exception $e) {
    System::errorlog(Loging::log($e->getMessage(), 'myappController:add_item', LOG_WARN));
}
```

The entry goes to the `error_log` table of the local SQLite database, where admins read it on the admin panel's Logs page. It's also added to the current response's `errors` key when `<log_db>` is `true`, and mailed when mail errors are on for that log type. The log types are `LOG_ERROR`, `LOG_WARN`, `LOG_NOTICES`, `LOG_EXCEPTION` and `LOG_CRITICAL`.

To record what a user did, use the access log:

```php
System::acesslog(Loging::AccessLog('Create item', 'create', 'Item created'));
```

This inserts a row into the `access_log` table of the MySQL database, with the session id, IP address and device details. See [Logging](Essentials/Logging.md).

---

# How to write the app class

Each app has one main class that extends `App`, for example `api/apps/myapp/myapp.class.php`. The framework creates it on every web, shell and heartbeat request, for every active app.

```php
<?php

class myapp extends App
{
    public function register(): bool
    {
        // Phase 1: set up what other apps may need from you.
        return true;
    }

    public function boot(): void
    {
        // Phase 2: every active app has run register().
    }

    public function init()
    {
        // Runs from the constructor. Keep it cheap.
    }

    public function search(string $search_text)
    {
        return null;
    }
}
```

The lifecycle, in order:

1. **`init()`** runs from the constructor. It also runs every time another app calls `AppManager::CreateAppInstance()` for your app.
2. **`register()`** runs on every active app, dependencies first.
3. **`boot()`** runs on every active app after all of them have registered, again dependencies first. It's optional: the base class has an empty one.

An exception in one app's `register()` or `boot()` is logged and doesn't stop the other apps. [App Manager](Modules/App%20Manager.md) covers dependency order, namespaced app classes and how the class is found.

## Support global search

`search()` feeds the search box in the top bar. A `POST` to `/api/system/global_search` with `search_text` calls `search()` on every app and returns what each one gives back. Return `null` to stay out of the results, or an array like this:

```php
public function search(string $search_text)
{
    $matches = myappDAO::searchItems($search_text);

    return [
        'appInfo' => [
            'label'     => 'My App',
            'icon'      => 'fal fa-box',
            'path_name' => 'myapp',
            'app_image' => '/apps/myapp/assets/app_icons/app-icon.png',
        ],
        'results' => array_map(fn ($item) => [
            'text' => $item['name'],
            'type' => 'item',
            'path' => '/myapp/items/' . $item['id'],
        ], $matches),
        'searchResults' => !empty($matches),
    ];
}
```

The search creates your app through `AppManager::CreateAppInstance()`, so your manifest's `<app_permissions>` must allow `xp_system`. `searchResults` must be `true` for the app to be listed.

---

# How modules work

`Module` is the base class of the framework modules in `api/core/Modules/` (`Util`, `Curl`, `AppManager`, `Encryption` and the rest). You use modules far more often than you write one. See [Modules](Modules/Modules.md).

A module lives in `api/core/Modules/<Name>/<Name>.class.php` and implements two methods:

```php
class MyModule extends Module
{
    public function init()
    {
        // Runs from the constructor. Constructor arguments are in $this->params.
    }

    public function healthcheck()
    {
        // Return an array of error messages, empty when all is well.
        return array();
    }
}
```

The first time a module class is used in a request, the autoloader loads it, creates one instance with no arguments and calls `healthcheck()`. Any errors are logged as warnings. So the constructor and `init()` must work without arguments. A module listed in `<modules>` of the config whose file is missing fails the health check, and every request returns `500`.

---

# Methods reference

## Controller

### authenticate

Description:

The **`authenticate`** method decides whether the request may run. The framework calls it before `Render()`. The base version returns `SessionManager::validateSession()`. Override it.

Syntax:

```php
public function authenticate()
{
    return auth::appUserPermission($this->getRequest()->getAction(), $this->getRequest()->getController(), []);
}
```

**Return Value:**

- **`Boolean`**: `true` to run `Render()`, `false` to answer `401 Not Authorized` (`500` on the command line).

---

### Render

Description:

The **`Render`** method handles the request. It's abstract, so every controller must implement it. It returns nothing: echo the response.

Syntax:

```php
public function Render()
{
    // switch on getType() and getAction()
}
```

---

### getRequest

Description:

The **`getRequest`** method returns the `Request` the controller was created with.

Syntax:

```php
$request = $this->getRequest();
```

**Return Value:**

- **`Request`**: The current request.

---

## Request

### getController / getAction

Description:

**`getController`** returns the controller segment of the URL as typed, before lower-casing. **`getAction`** returns the action segment.

Syntax:

```php
$controller = $this->getRequest()->getController(); // "myapp"
$action = $this->getRequest()->getAction();         // "get_items"
```

**Return Value:**

- **`String`**: The segment.

---

### getType

Description:

The **`getType`** method returns the HTTP method, or `cli` on the command line.

Syntax:

```php
$type = $this->getRequest()->getType();
```

**Return Value:**

- **`String`**: `GET`, `POST`, another HTTP method, or `cli`.

---

### getData

Description:

The **`getData`** method returns the request data: the query string for `GET`, the form fields or decoded JSON body for `POST`, the command-line pairs in a shell run.

Syntax:

```php
$data = $this->getRequest()->getData() ?? [];
```

**Return Value:**

- **`Array`**: The data.
- **`null`**: A JSON body that couldn't be decoded.

---

### getFiles

Description:

The **`getFiles`** method returns the uploaded files of a `POST` request, in the `$_FILES` format. On a `GET` request or a shell run it throws an `Error`.

Syntax:

```php
$files = $this->getRequest()->getFiles();
```

**Return Value:**

- **`Array`**: The uploaded files. Empty when none were sent.

---

## Response

### create

Description:

The **`create`** method sets the HTTP status line and returns the response as pretty-printed JSON. It doesn't echo it.

Syntax:

```php
$res = new Response();
echo $res->create(200, 'Saved.', true);
```

**Parameters:**

- **`$statusCode`**: The HTTP status code.
- **`$statusMsg`**: A human-readable message.
- **`$success`**: `true` or `false`, read by the frontend.

**Return Value:**

- **`String`**: The JSON response.

---

### setData

Description:

The **`setData`** method sets the value sent under `data`. You can also pass it to the constructor: `new Response($items)`.

Syntax:

```php
$res->setData(['id' => $id]);
```

**Parameters:**

- **`$data`**: Any JSON-encodable value. An empty or falsy value is left out of the response.

---

### badRequest

Description:

The static **`badRequest`** method returns a ready-made `400 Bad request` response with `success: false`. It's the only static helper. `Controller::defaultHandler()` returns the same thing.

Syntax:

```php
echo Response::badRequest();
```

**Return Value:**

- **`String`**: The JSON response.

---

### Other Response methods

`getJson()` and `getOutPutArr()` return the last result of `create()` as a string and as an array. `getStatusCode()`, `getStatusMsg()`, `getSuccess()`, `getData()` and `getResponse()` return the parts. Each has a matching setter.

---

## database

### query

Description:

The **`query`** method prepares an SQL statement. Use named placeholders for every value.

Syntax:

```php
$db->query("SELECT * FROM myapp_items WHERE id = :id");
```

**Parameters:**

- **`$query`**: The SQL.

---

### bind

Description:

The **`bind`** method binds a value to a placeholder. Without a type, it picks `PDO::PARAM_INT`, `PARAM_BOOL`, `PARAM_NULL` or `PARAM_STR` from the value. Call it after `query()`.

Syntax:

```php
$db->bind(':id', $id);
$db->bind(':code', $code, PDO::PARAM_STR);
```

**Parameters:**

- **`$param`**: The placeholder name, or its position.
- **`$value`**: The value.
- **`$type`** (optional): A `PDO::PARAM_*` constant.

---

### execute

Description:

The **`execute`** method runs the prepared statement. Use it for `INSERT`, `UPDATE` and `DELETE`. Instead of `bind()`, you can pass all the values as an array; they're then bound as strings.

Syntax:

```php
$db->execute();
$db->execute([':id' => $id]);
```

**Return Value:**

- **`Boolean`**: `true` on success. A failure throws a `PDOException`.

---

### resultset

Description:

The **`resultset`** method runs the statement and returns every row as an associative array.

Syntax:

```php
$rows = $db->resultset();
```

**Return Value:**

- **`Array`**: The rows. Empty when nothing matched.

---

### single

Description:

The **`single`** method runs the statement and returns the first row.

Syntax:

```php
$row = $db->single();
```

**Return Value:**

- **`Array`**: The row.
- **`false`**: No row matched.

---

### rowCount

Description:

The **`rowCount`** method returns the number of rows the last `INSERT`, `UPDATE` or `DELETE` changed.

Syntax:

```php
$changed = $db->rowCount();
```

**Return Value:**

- **`Integer`**: The row count.

---

### lastInsertId

Description:

The **`lastInsertId`** method returns the id of the last inserted row on the connection.

Syntax:

```php
$id = $db->lastInsertId();
```

**Return Value:**

- **`String`**: The id, as a string.

---

### beginTransaction / endTransaction / cancelTransaction

Description:

**`beginTransaction`** starts a transaction, **`endTransaction`** commits it and **`cancelTransaction`** rolls it back. The transaction is on the shared connection, so it covers every `database` object in the request.

Syntax:

```php
$db->beginTransaction();
$db->endTransaction();
$db->cancelTransaction();
```

**Return Value:**

- **`Boolean`**: `true` on success. Starting a second transaction, or committing when none is open, throws a `PDOException`.

---

### inTransaction

Description:

The **`inTransaction`** method tells you whether a transaction is open on the connection. Added in 0.0.23.

Syntax:

```php
if (!$db->inTransaction()) {
    $db->beginTransaction();
}
```

**Return Value:**

- **`Boolean`**: `true` when a transaction is open.

---

### changeConnection

Description:

The **`changeConnection`** method connects this object to a different server or database, and stores the new credentials in the session so later `database` objects in the same session use them too.

Syntax:

```php
$db->changeConnection($host, $dbname, $username, $password);
```

**Parameters:**

- **`$host`**, **`$dbname`**, **`$username`**, **`$password`**: The new connection details. All are required.

**Return Value:**

- **`Boolean`**: `true` on success, `false` on failure. `getError()` has the reason.

<aside>
⚠️ The credentials are saved in the session before they're checked. If the connection fails, the session still holds them, and every later `database` in that session fails to connect. Call `resetConnection()` to go back to the config's database.

</aside>

---

### resetConnection

Description:

The **`resetConnection`** method reconnects with the `<database>` settings from the config. With session credentials enabled, it also writes them back into the session.

Syntax:

```php
$db->resetConnection();
```

**Return Value:**

- **`Boolean`**: `true` on success.

---

### selectDatabase

Description:

The **`selectDatabase`** method runs `USE` on the connection. The connection is shared, so every `database` object in the request switches with it.

Syntax:

```php
$db->selectDatabase('other_db');
```

**Parameters:**

- **`$dbname`**: Letters, digits, `_` and `$` only.

**Return Value:**

- **`Boolean`**: `true` on success.

---

### Other database methods

- `getError()`: the last connection error message, or `null`.
- `nextRowsets()`: steps through the results of a multi-statement query, so an error in a later statement is raised.
- `debugDumpParams()`: prints the prepared statement and its bound values.
- `getDatabaseName()`, `getDatabaseUsername()`, `getDatabaseHost()`: the current connection details.

---

## Sqlitedb

### query / bind / execute / resultset

Description:

These work like their `database` counterparts. `bind()` picks `SQLITE3_INTEGER`, `SQLITE3_NULL` or `SQLITE3_TEXT` from the value. `execute()` returns an `SQLite3Result`, or `false` on failure. `resultset()` returns every row as an associative array.

Syntax:

```php
$sqlite = new Sqlitedb();
$sqlite->query("SELECT * FROM error_log WHERE ClassName = :class");
$sqlite->bind(':class', 'myappController:add_item');
$rows = $sqlite->resultset();
```

---

### Other Sqlitedb methods

- `Sqlitedb::withPath($path)`: opens the SQLite file at `$path` instead of the default one.
- `exec($sql)`: runs SQL with no result set, such as `CREATE TABLE`. Returns `true` or `false`.
- `querySingleRow($sql)`: the first row of a query, as an array.
- `querySingleField($sql)`: the first column of the first row.
- `getLastInsertRowID()`: the row id of the last insert.
- `getLastErrorCode()`, `getLastErrorMsg()`: the last SQLite error.
- `checkIfTablesExists()`: the names of all tables, as rows.
- `Sqlitedb::getEscapedString($string)`: escapes a string for use in SQL. Prefer `bind()`.

---

## System

### errorlog

Description:

The static **`errorlog`** method saves a log entry in the local SQLite database and adds it to the current response's `errors`. It mails the entry when mail errors are on for its type.

Syntax:

```php
System::errorlog(Loging::log($e->getMessage(), 'myappController:add_item', LOG_WARN));
```

**Parameters:**

- **`$log`**: A `Log` from `Loging::log($text, $className, $type)`.

**Return Value:**

- **`Boolean`**: `true`.

---

### acesslog

Description:

The static **`acesslog`** method (spelled with one "c") saves a user action in the `access_log` table of the MySQL database.

Syntax:

```php
System::acesslog(Loging::AccessLog('Create item', 'create', 'Item created'));
```

**Parameters:**

- **`$log`**: An `AccessLog` from `Loging::AccessLog($action, $actionType, $message)`.

**Return Value:**

- **`Boolean`**: Always `false`, even when the row was saved, so don't test it.

---

### log

Description:

The static **`log`** method is deprecated. Use `errorlog()`.

<aside>
⚠️ Don't call `System::log()`. It replaces the request's list of logged errors with a single entry, and once the log file exists it fails with a `TypeError`.

</aside>

---

## App

### register

Description:

The abstract **`register`** method is the first boot phase. It runs on every active app, dependencies first, on every request.

Syntax:

```php
public function register(): bool
{
    return true;
}
```

**Return Value:**

- **`Boolean`**: Return `true`. The framework doesn't use the value.

---

### boot

Description:

The optional **`boot`** method is the second boot phase. It runs after every active app has run `register()`, so it can use what other apps set up there.

Syntax:

```php
public function boot(): void
{
}
```

---

### init

Description:

The abstract **`init`** method runs from the constructor, every time the app class is created.

Syntax:

```php
public function init()
{
}
```

---

### search

Description:

The abstract **`search`** method answers the global search. See [Support global search](#support-global-search).

Syntax:

```php
public function search(string $search_text)
{
    return null;
}
```

**Parameters:**

- **`$search_text`**: What the user typed.

**Return Value:**

- **`Array`**: `appInfo`, `results` and `searchResults`.
- **`null`**: No results from this app.

---

## Module

### init

Description:

The abstract **`init`** method runs from the constructor. Arguments passed to the constructor are in `$this->params`.

Syntax:

```php
public function init()
{
}
```

---

### healthcheck

Description:

The abstract **`healthcheck`** method runs when the module is first loaded in a request.

Syntax:

```php
public function healthcheck()
{
    return array();
}
```

**Return Value:**

- **`Array`**: Error messages to log as warnings. Empty when all is well.
