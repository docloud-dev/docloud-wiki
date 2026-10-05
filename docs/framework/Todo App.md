---
sidebar_position: 80
title: Todo App
sidebar_label: Todo App
---

# Todo App

Owner: Nuwan Danushka

# Introduction

This tutorial builds a small todo app from start to finish. When you're done, the app has:

- a **Todo** entry in the sidebar menu
- a list page that shows every todo, marks one complete or active, and deletes one after a confirmation
- a form page that adds a todo or edits one
- an API at `api/todo/<action>` that checks a permission for every action
- a database table, `todo_items`, created by the framework
- a `todo_user` role you can give to users

You start from an installed framework and work in a dev workspace, `dev/todo/`. Every file follows the shape of the built-in `helloworld` app, so open its files next to yours if something is unclear. They are in `api/apps/helloworld/` and `apps/helloworld/`.

You'll write these files:

```text
dev/
    todo/
        backend/
            todo/
                todo.xml                   the manifest
                todo.class.php             the app class
                todoModel.class.php        one todo, and its validation
                todoDAO.class.php          database reads and writes
                todoController.class.php   the API actions
        frontend/
            todo/
                app-config.json            menu entry and scripts
                route.js                   the pages
                services.js                calls to the API
                components/
                    todo.js                the list page
                    todo_form.js           the add and edit page
```

The tutorial explains only what the app needs. Each step links to the reference page for the rest.

---

# How to prepare the framework

## Step 1: Install the framework

Install the framework on a server with HTTPS, as described in [Get Started](./Get%20Started.md). The API refuses plain HTTP requests with `497 Please Use HTTPS!`.

Setup writes `api/config.xml` and sets `<system_environment>` to `development`. Keep it that way while you build the app.

## Step 2: Check the development settings

The dev workspace works only when both of these are true:

- `<system_environment>` in `api/config.xml` is exactly `development`. You can also change it in the admin panel under **Settings > API > App Environment**. The `APP_CONFIG_ENV` override doesn't count here: the links read `api/config.xml` itself.
- A `dev/` folder exists at the framework root, next to `api/` and `apps/`. Create it if it's missing.

The web server's PHP user must also be able to create entries in `apps/`, `api/apps/` and `api/admin/apps/`, because the framework puts the links there.

See [Dev Workspace](./Building%20Apps/Dev%20Workspace.md) for how the links work, and [Configuration Files](./Essentials/Configuration%20Files.md) for the environment settings.

## Step 3: Log in to the admin panel

Open `https://your-site/api/admin/` and sign in with DoCloud.

In development you can also log in without DoCloud (since 0.0.23):

1. Click **Login Local**.
2. Enter the admin email you gave during setup. It's `<admin_email>` in `api/config.development.xml`.
3. Click **Send Auth Code**.
4. Open your browser's developer tools, **Network** tab, and select the `send_auth_code` request. In development its response holds the code in `data.dev_auth_code`.
5. Enter the code and click **Login**.

<aside>
💡 The code is returned only when `<system_environment>` is `development` and the email matches the admin email. For any other email the page still says "Authentication code sent.", but no code is created.

</aside>

---

# How to build the backend

## Step 4: Create the app workspace

Create the folders:

```bash
mkdir -p dev/todo/backend/todo dev/todo/frontend/todo/components
```

The app's name is `todo`. The outer folder, both inner folders, the manifest's file name, `<app_name>` and the class name prefixes must all be exactly `todo`.

`dev/` is ignored by the framework's git repository, so the app can be its own repository:

```bash
cd dev/todo
git init
```

## Step 5: Write the manifest

Create `dev/todo/backend/todo/todo.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<app>
    <app_register active="true"/>
    <info>
        <app_name>todo</app_name>
        <app_author>Your Name</app_author>
        <display_name>Todo</display_name>
        <app_version>1.0.0</app_version>
        <api_version>0.0.42</api_version>
        <app_icon>fa-regular fa-circle-check</app_icon>
        <app_type>custom</app_type>
        <status>active</status>
        <release_date>2026-10-05</release_date>
        <description>A simple todo list.</description>
        <changelog>First release.</changelog>
    </info>

    <!-- Lets the global search call this app's search() method -->
    <app_permissions>
        <permission app_name="xp_system"/>
    </app_permissions>

    <!-- One permission per API action, plus "view" for the menu and pages -->
    <user_permissions name="todo">
        <category name="todo_permissions" display_name="Todo">
            <permission display_name="Open the todo app" name="view" auto_update="true"/>
            <permission display_name="List todos" name="list_todos" auto_update="true"/>
            <permission display_name="View a todo" name="get_todo" auto_update="true"/>
            <permission display_name="Add a todo" name="add_todo" auto_update="true"/>
            <permission display_name="Edit a todo" name="update_todo" auto_update="true"/>
            <permission display_name="Delete a todo" name="delete_todo" auto_update="true"/>
        </category>
    </user_permissions>

    <!-- A role for users of the app, created on reinitialize -->
    <roles>
        <role name="todo_user" display_name="Todo User">
            <grant app="todo" actions="*"/>
            <grant app="auth" actions="logout"/>
        </role>
    </roles>

    <!-- Created as todo_items -->
    <createTables>
        <table name="items">
            <column name="id" type="bigint" size="20" default="" attributes="UNSIGNED" null="false" autoincrement="true" primarykey="true"/>
            <column name="title" type="varchar" size="255" default="" attributes="" null="false"/>
            <column name="description" type="text" size="" default="" attributes="" null="true"/>
            <column name="status" type="varchar" size="20" default="active" attributes="" null="false"/>
            <column name="priority" type="varchar" size="20" default="normal" attributes="" null="false"/>
            <column name="created_date" type="datetime" size="" default="" attributes="" null="false"/>
            <column name="created_by" type="bigint" size="20" default="" attributes="UNSIGNED" null="true"/>
            <column name="updated_date" type="datetime" size="" default="" attributes="" null="true"/>
            <column name="updated_by" type="bigint" size="20" default="" attributes="UNSIGNED" null="true"/>
        </table>
    </createTables>
</app>
```

What each part does:

- **`<info>`**: the app's identity. The admin panel's **Apps** page shows it. `<api_version>` is the lowest framework version the app supports. `<app_type>` is any value except `system_app`, which is reserved for apps that ship with the framework.
- **`<user_permissions name="todo">`**: the name must be the controller name, the `todo` in `api/todo/<action>`. Each `<permission name>` must be an action your controller handles. The framework checks `todo/<action>` on every request. `auto_update="true"` grants the permission to the `system_admin` role when the app is reinitialized.
- **`<roles>`**: creates the `todo_user` role with every `todo` permission (`*`) and `auth/logout`, so you don't have to tick them on the Roles page.
- **`<createTables>`**: table names get the app's name as a prefix, so `items` becomes `todo_items`. Write every column attribute, even when it's empty, as `helloworld` does.

The file must be valid XML. Use `<!-- -->` comments only. A manifest that doesn't parse is skipped without an error on screen.

See [App Manifest](./Building%20Apps/App%20Manifest.md) for every element, [Roles And Permissions](./Essentials/Roles%20And%20Permissions.md) for permissions and roles, and [App Manager](./Modules/App%20Manager.md) for the column attributes.

## Step 6: Write the app class

Create `dev/todo/backend/todo/todo.class.php`. The framework creates one instance of it on every request. The class must be named after the app folder and extend `App`:

```php
<?php

/**
 * Todo app class
 */
class todo extends App
{
    function register(): bool
    {
        return true;
    }

    function init()
    {
        // Runs on every request. Keep it empty or cheap.
    }

    function search($search_text)
    {
        // Results for the global search. This app has none.
        return null;
    }
}
```

Backend classes load by file name: `<ClassName>.class.php`. Class names are shared by every app, so prefix yours with the app name, as in `todoModel` and `todoDAO`.

## Step 7: Write the model

Create `dev/todo/backend/todo/todoModel.class.php`. It holds one todo and checks the fields a client sends:

```php
<?php

/**
 * Todo model: one row of todo_items
 */
class todoModel
{
    public const STATUSES = array('active', 'completed');
    public const PRIORITIES = array('low', 'normal', 'high');

    private $id;
    private $title;
    private $description;
    private $status;
    private $priority;
    private $created_date;
    private $created_by;
    private $updated_date;
    private $updated_by;

    public function __construct($data = null)
    {
        if ($data) {
            if (isset($data['id'])) {
                $this->id = (int) $data['id'];
            }
            if (isset($data['title'])) {
                $this->title = trim($data['title']);
            }
            if (isset($data['description'])) {
                $this->description = trim($data['description']);
            }
            if (isset($data['status'])) {
                $this->status = $data['status'];
            }
            if (isset($data['priority'])) {
                $this->priority = $data['priority'];
            }
        }
    }

    /**
     * Check the fields a client sends
     * @param string $type 'add' or 'update'
     * @return array Error messages. Empty when the data is valid.
     */
    public function validate(string $type = 'add'): array
    {
        $errors = array();

        if ($type === 'update' && empty($this->id)) {
            $errors[] = 'Id is required.';
        }
        if ($this->title === null || $this->title === '') {
            $errors[] = 'Title is required.';
        } elseif (mb_strlen($this->title) > 255) {
            $errors[] = 'Title must be 255 characters or fewer.';
        }
        if (!in_array($this->status, self::STATUSES, true)) {
            $errors[] = 'Status must be active or completed.';
        }
        if (!in_array($this->priority, self::PRIORITIES, true)) {
            $errors[] = 'Priority must be low, normal or high.';
        }

        return $errors;
    }

    public function getId() {
        return $this->id;
    }

    public function getTitle() {
        return $this->title;
    }

    public function getDescription() {
        return $this->description;
    }

    public function getStatus() {
        return $this->status;
    }

    public function getPriority() {
        return $this->priority;
    }

    public function getCreated_date() {
        return $this->created_date;
    }

    public function getCreated_by() {
        return $this->created_by;
    }

    public function getUpdated_date() {
        return $this->updated_date;
    }

    public function getUpdated_by() {
        return $this->updated_by;
    }

    public function setCreated_date($created_date): void {
        $this->created_date = $created_date;
    }

    public function setCreated_by($created_by): void {
        $this->created_by = $created_by;
    }

    public function setUpdated_date($updated_date): void {
        $this->updated_date = $updated_date;
    }

    public function setUpdated_by($updated_by): void {
        $this->updated_by = $updated_by;
    }
}
```

## Step 8: Write the DAO

Create `dev/todo/backend/todo/todoDAO.class.php`. It runs the SQL with bound values. Use the full table name, `todo_items`:

```php
<?php

/**
 * Todo DAO: reads and writes todo_items
 */
class todoDAO
{
    /**
     * All todos, newest first
     * @return array|false
     */
    public static function get_todos()
    {
        try {
            $database = new Database();
            $database->query("SELECT * FROM todo_items ORDER BY id DESC");
            return $database->resultset();
        } catch (Exception $exc) {
            System::errorlog(Loging::log($exc->getMessage(), 'todoDAO:get_todos', LOG_CRITICAL));
            return false;
        }
    }

    /**
     * One todo
     * @return array|false The row, or false if there is none
     */
    public static function get_todo(int $id)
    {
        try {
            $database = new Database();
            $database->query("SELECT * FROM todo_items WHERE id = :id");
            $database->bind(':id', $id);
            return $database->single();
        } catch (Exception $exc) {
            System::errorlog(Loging::log($exc->getMessage(), 'todoDAO:get_todo', LOG_CRITICAL));
            return false;
        }
    }

    /**
     * Insert a todo
     * @return string|false The new id
     */
    public static function add_todo(todoModel $todo)
    {
        try {
            $database = new Database();
            $database->query("INSERT INTO todo_items (title, description, status, priority, created_date, created_by)
                              VALUES (:title, :description, :status, :priority, :created_date, :created_by)");
            $database->bind(':title', $todo->getTitle());
            $database->bind(':description', $todo->getDescription());
            $database->bind(':status', $todo->getStatus());
            $database->bind(':priority', $todo->getPriority());
            $database->bind(':created_date', $todo->getCreated_date());
            $database->bind(':created_by', $todo->getCreated_by());
            $database->execute();
            return $database->lastInsertId();
        } catch (Exception $exc) {
            System::errorlog(Loging::log($exc->getMessage(), 'todoDAO:add_todo', LOG_CRITICAL));
            return false;
        }
    }

    /**
     * Update a todo
     * @return bool
     */
    public static function update_todo(todoModel $todo): bool
    {
        try {
            $database = new Database();
            $database->query("UPDATE todo_items
                              SET title = :title, description = :description, status = :status,
                                  priority = :priority, updated_date = :updated_date, updated_by = :updated_by
                              WHERE id = :id");
            $database->bind(':title', $todo->getTitle());
            $database->bind(':description', $todo->getDescription());
            $database->bind(':status', $todo->getStatus());
            $database->bind(':priority', $todo->getPriority());
            $database->bind(':updated_date', $todo->getUpdated_date());
            $database->bind(':updated_by', $todo->getUpdated_by());
            $database->bind(':id', $todo->getId());
            return $database->execute();
        } catch (Exception $exc) {
            System::errorlog(Loging::log($exc->getMessage(), 'todoDAO:update_todo', LOG_CRITICAL));
            return false;
        }
    }

    /**
     * Delete a todo
     * @return bool
     */
    public static function delete_todo(int $id): bool
    {
        try {
            $database = new Database();
            $database->query("DELETE FROM todo_items WHERE id = :id");
            $database->bind(':id', $id);
            return $database->execute();
        } catch (Exception $exc) {
            System::errorlog(Loging::log($exc->getMessage(), 'todoDAO:delete_todo', LOG_CRITICAL));
            return false;
        }
    }
}
```

`Database` throws an exception when a query fails, so each method catches it, logs it and returns `false`.

## Step 9: Write the controller

Create `dev/todo/backend/todo/todoController.class.php`. A request to `api/todo/<action>` runs `todoController`. The framework calls `authenticate()` first. Only if it returns `true` does it call `Render()`, which picks a handler by the HTTP method and then the action:

```php
<?php

/**
 * Todo controller: handles api/todo/<action>
 */
class todoController extends Controller
{
    /**
     * Allow the request only if the user holds the todo/<action> permission
     * @return bool
     */
    public function authenticate()
    {
        $action = $this->getRequest()->getAction();
        $controller = $this->getRequest()->getController();

        // Actions anyone may call without logging in. Keep it empty.
        $publicEndpointsAry = array();

        return auth::appUserPermission($action, $controller, $publicEndpointsAry);
    }

    /**
     * Send the request to the handler for its HTTP method
     * @return void
     */
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
            case 'list_todos':
                $this->list_todos();
                break;
            case 'get_todo':
                $this->get_todo();
                break;
            default:
                $this->notsupported();
                break;
        }
    }

    private function PostHandler()
    {
        switch ($this->getRequest()->getAction()) {
            case 'add_todo':
                $this->add_todo();
                break;
            case 'update_todo':
                $this->update_todo();
                break;
            case 'delete_todo':
                $this->delete_todo();
                break;
            default:
                $this->notsupported();
                break;
        }
    }

    private function notsupported()
    {
        $res = new Response();
        echo $res->create(501, 'Not Supported yet.', false);
    }

    /**
     * GET api/todo/list_todos
     */
    private function list_todos()
    {
        $res = new Response();

        try {
            $todos = todoDAO::get_todos();

            if ($todos === false) {
                echo $res->create(500, 'Could not load the todos.', false);
                return;
            }

            $res->setData(array(
                'list' => $todos,
                'total_count' => count($todos),
            ));
            echo $res->create(200, 'Todo list.', true);
        } catch (Exception $ex) {
            System::errorlog(Loging::log($ex->getMessage(), 'todoController:list_todos', LOG_WARN));
            echo $res->create(500, 'Something went wrong.', false);
        }
    }

    /**
     * GET api/todo/get_todo?id=1
     */
    private function get_todo()
    {
        $res = new Response();

        try {
            $data = $this->getRequest()->getData();
            $id = (int) ($data['id'] ?? 0);

            if ($id <= 0) {
                echo $res->create(400, 'Following field is required: id', false);
                return;
            }

            $todo = todoDAO::get_todo($id);

            if (empty($todo)) {
                echo $res->create(404, 'Todo not found.', false);
                return;
            }

            $res->setData($todo);
            echo $res->create(200, 'Todo.', true);
        } catch (Exception $ex) {
            System::errorlog(Loging::log($ex->getMessage(), 'todoController:get_todo', LOG_WARN));
            echo $res->create(500, 'Something went wrong.', false);
        }
    }

    /**
     * POST api/todo/add_todo with title, description, status, priority
     */
    private function add_todo()
    {
        $res = new Response();

        try {
            $todo = new todoModel($this->getRequest()->getData());

            $errors = $todo->validate('add');
            if (!empty($errors)) {
                echo $res->create(400, implode(' ', $errors), false);
                return;
            }

            $todo->setCreated_by(authSession::getUserID());
            $todo->setCreated_date(Util::DateAndTimeManager()::get_system_datetime());

            $id = todoDAO::add_todo($todo);

            if (empty($id)) {
                echo $res->create(500, 'Could not add the todo.', false);
                return;
            }

            $res->setData(array('id' => (int) $id));
            echo $res->create(200, 'Todo added.', true);
        } catch (Exception $ex) {
            System::errorlog(Loging::log($ex->getMessage(), 'todoController:add_todo', LOG_WARN));
            echo $res->create(500, 'Something went wrong.', false);
        }
    }

    /**
     * POST api/todo/update_todo with id, title, description, status, priority
     */
    private function update_todo()
    {
        $res = new Response();

        try {
            $todo = new todoModel($this->getRequest()->getData());

            $errors = $todo->validate('update');
            if (!empty($errors)) {
                echo $res->create(400, implode(' ', $errors), false);
                return;
            }

            if (empty(todoDAO::get_todo($todo->getId()))) {
                echo $res->create(404, 'Todo not found.', false);
                return;
            }

            $todo->setUpdated_by(authSession::getUserID());
            $todo->setUpdated_date(Util::DateAndTimeManager()::get_system_datetime());

            if (!todoDAO::update_todo($todo)) {
                echo $res->create(500, 'Could not update the todo.', false);
                return;
            }

            echo $res->create(200, 'Todo updated.', true);
        } catch (Exception $ex) {
            System::errorlog(Loging::log($ex->getMessage(), 'todoController:update_todo', LOG_WARN));
            echo $res->create(500, 'Something went wrong.', false);
        }
    }

    /**
     * POST api/todo/delete_todo with id
     */
    private function delete_todo()
    {
        $res = new Response();

        try {
            $data = $this->getRequest()->getData();
            $id = (int) ($data['id'] ?? 0);

            if ($id <= 0) {
                echo $res->create(400, 'Following field is required: id', false);
                return;
            }

            if (empty(todoDAO::get_todo($id))) {
                echo $res->create(404, 'Todo not found.', false);
                return;
            }

            if (!todoDAO::delete_todo($id)) {
                echo $res->create(500, 'Could not delete the todo.', false);
                return;
            }

            echo $res->create(200, 'Todo deleted.', true);
        } catch (Exception $ex) {
            System::errorlog(Loging::log($ex->getMessage(), 'todoController:delete_todo', LOG_WARN));
            echo $res->create(500, 'Something went wrong.', false);
        }
    }
}
```

`auth::appUserPermission()` passes the request only if one of the user's roles grants `todo/<action>`. An action that isn't declared in the manifest is refused with `401 Not Authorized`, even when the controller handles it. Anything in `$publicEndpointsAry` skips the check and is open to anyone, so leave it empty.

`getData()` returns the query string for a GET request and the form fields for a POST. Every response is the framework's JSON shape: `response.statusCode`, `response.statusMsg`, `response.success` and, when there is data, `data`. See [The API response](./Architecture.md) in Architecture, and [Authentication](./Essentials/Authentication.md) for sessions and `authenticate()`.

---

# How to register the app

## Step 10: Find the app on the Apps page

Load any page of the site or the admin panel. On every request in development, the framework reads `dev/todo/backend/todo/todo.xml` and links the app into place:

| Link | Points to |
| --- | --- |
| `api/apps/todo` | `dev/todo/backend/todo` |
| `apps/todo` | `dev/todo/frontend/todo` |
| `api/admin/apps/todo` | `dev/todo/adminpanel/todo`, only if that folder exists |

Check the links from the framework root:

```bash
ls -la api/apps/ apps/ | grep todo
```

There is no install step for an app in `dev/`. The admin panel's **Apps** page lists every folder in `api/apps/` that has a manifest with an `<info>` block, so **Todo** now appears under **Installed**. Its API is live too: the framework finds `todoController` by its file name on every request.

## Step 11: Reinitialize the app

Two things don't exist yet: the `todo_items` table and the permission grants. Both are created when the app is reinitialized.

1. In the admin panel, open **Apps**.
2. Click the gear icon on the **Todo** card.
3. Click **Reinitialize**.

The reinitialize:

- creates `todo_items` from `<createTables>`
- grants every `auto_update="true"` permission to the `system_admin` role
- creates the `todo_user` role from `<roles>` with its grants, plus `dashboard/view`

Reinitialize again whenever you change `<createTables>`, the permissions or `<roles>`. A reinitialize only adds: it never drops a table or column, and never takes back a grant. The Roles page lists new permissions straight away, but they're granted only by the reinitialize.

See [How to install and reinitialise an app](./Modules/App%20Manager.md) in App Manager for exactly what runs.

## Step 12: Test the API

Open the web app at `https://your-site/` and log in with a user that holds the `system_admin` role. Setup gives that role to the admin user it creates.

In the same browser, open:

```text
https://your-site/api/todo/list_todos
```

You should see:

```json
{
    "response": {
        "statusCode": 200,
        "statusMsg": "Todo list.",
        "success": true
    },
    "data": {
        "list": [],
        "total_count": 0
    }
}
```

`401 Not Authorized` means your user doesn't hold `todo/list_todos`. Check that you reinitialized the app and that you're logged in to the web app, not only the admin panel. The other actions are tested from the pages you build next.

---

# How to build the frontend

The frontend is Vue 3. Components are ES modules with a string `template`, loaded by the browser with no build step.

## Step 13: Write the frontend config

Create `dev/todo/frontend/todo/app-config.json`:

```json
{
    "version": "1.0.0",
    "release_date": "2026-10-05",
    "app_name": "todo",
    "app_type": "custom",
    "status": "active",
    "description": "A simple todo list.",

    "resources": {
        "scripts": [
            { "url": "route.js" }
        ]
    },

    "menus": [
        {
            "label": "Todo",
            "icon": "fa-regular fa-circle-check",
            "path_name": "todo",
            "description": "Your todo list.",
            "position": { "sidebar": true, "sidebar_priority": 100, "megabar": true, "megabar_priority": 100 },
            "permission": {
                "name": "todo",
                "action": "view"
            }
        }
    ],

    "_public": [
        "version", "release_date", "app_name", "status", "description", "menus"
    ]
}
```

- **`resources.scripts`**: files the framework bundles into every page. `route.js` must be listed here, or your pages don't exist.
- **`menus`**: the sidebar entry. `path_name` is the route **name** from `route.js`, not a URL. The entry shows only to users who hold `permission`, and an entry without a `permission` never shows. The entry stays highlighted on every page whose path starts with `/todo`.
- **`_public`**: the fields sent to the browser. `menus` must be in it.
- Keep `version` and `release_date` the same as `<app_version>` and `<release_date>` in the manifest.

The file must be valid JSON, with no comments. If it doesn't parse, the app is skipped: no menu, no routes, and no error on screen.

See [App Frontend Config](./Building%20Apps/App%20Frontend%20Config.md) for every field.

## Step 14: Write the API calls

Create `dev/todo/frontend/todo/services.js`. Each function calls one action and returns the parsed JSON:

```jsx
/*
   Endpoints of the todo app
 */

const api_url = XP.getApiUrl();

export const todo_services = {

    list_todos: async function () {
        let response = await fetch(api_url + "/todo/list_todos", {
            method: "GET",
            credentials: "include",
        });
        return await response.json();
    },

    get_todo: async function (data) {
        let response = await fetch(api_url + "/todo/get_todo?" + new URLSearchParams(data), {
            method: "GET",
            credentials: "include",
        });
        return await response.json();
    },

    add_todo: async function (data) {
        let response = await fetch(api_url + "/todo/add_todo", {
            method: "POST",
            body: data,
            credentials: "include",
        });
        return await response.json();
    },

    update_todo: async function (data) {
        let response = await fetch(api_url + "/todo/update_todo", {
            method: "POST",
            body: data,
            credentials: "include",
        });
        return await response.json();
    },

    delete_todo: async function (data) {
        let response = await fetch(api_url + "/todo/delete_todo", {
            method: "POST",
            body: data,
            credentials: "include",
        });
        return await response.json();
    },
};
```

`credentials: "include"` sends the session cookie. The POST functions take a `FormData`, which the pages build with `XP.readyFormData()`.

## Step 15: Add the routes

Create `dev/todo/frontend/todo/route.js`:

```jsx
/*
   Routes of the todo app
 */

const Todo_ListPage = () => XP.import("/apps/todo/components/todo.js");
const Todo_FormPage = () => XP.import("/apps/todo/components/todo_form.js");

Router.addRoute({
    path: "/todo",
    name: "todo",
    component: Todo_ListPage,
    meta: {
        title: "Todo",
        requiresAuth: true,
        permissions: { name: "todo", action: "view" },
    },
});

Router.addRoute({
    path: "/todo/add",
    name: "todo_add",
    component: Todo_FormPage,
    meta: {
        title: "Add todo",
        requiresAuth: true,
        permissions: { name: "todo", action: "add_todo" },
    },
});

Router.addRoute({
    path: "/todo/:id/edit",
    name: "todo_edit",
    component: Todo_FormPage,
    meta: {
        title: "Edit todo",
        requiresAuth: true,
        permissions: { name: "todo", action: "update_todo" },
    },
});

Router.replace(Router.currentRoute.value.fullPath);
```

The router sends a user who lacks a route's permission to the dashboard. End the file with the `Router.replace(...)` line, as every framework app does.

<aside>
⚠️ Every app's `route.js` is joined into one module, `assets/app-scripts.js`. Two apps that declare the same top-level name, such as `const ListPage`, break the routes of every app. Prefix your names with the app name, and use absolute paths in `XP.import()`.

</aside>

See [How to register routes in route.js](./Frontend%20Runtime%20(XP).md) in Frontend Runtime (XP) for the rest of the rules.

## Step 16: Build the list page

Create `dev/todo/frontend/todo/components/todo.js`:

```jsx
import DC_Sidebar from "../../xp_system/components/navigation/dc_sidebar.js";
import { Data_Loader } from "../../xp_system/components/helpers.js";
import {
    DcAjaxLoader,
    DcAjaxNotice,
    DcButton,
    DcCard,
    DcEmptyState,
    DcIconButton,
    DcPopup,
    DcTable,
} from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { XP_Util } from "../../xp_system/util.js";
import { todo_services } from "../services.js";

export default {
    components: {
        DC_Sidebar,
        Data_Loader,
        DcAjaxLoader,
        DcAjaxNotice,
        DcButton,
        DcCard,
        DcEmptyState,
        DcIconButton,
        DcPopup,
        DcTable,
    },
    data() {
        return {
            todos: [],
            selected_todo: null,
            headers: [
                { label: "Title", key: "title" },
                { label: "Status", key: "status" },
                { label: "Priority", key: "priority" },
                { label: "Created", key: "created_date" },
                { label: "Actions", key: "actions" },
            ],
            ui: {
                data_loading: true,
                doing_ajax_delete: false,
                notice: { show: false, type: "", text: "" },
            },
        };
    },
    template: `
<DC_Sidebar />
<div class="dc-app-container">
    <div class="dcui-flex-item dcui-justify-space-between dcui-align-center">
        <div class="dc-big-heading">
            <h1 class="dc-bh-heading">Todo</h1>
        </div>
        <dc-button v-if="can_add" @click="$router.push({ name: 'todo_add' })">
            <span class="dcui-b-icon"><i class="fa-regular fa-plus"></i></span>
            Add todo
        </dc-button>
    </div>

    <dc-card class="dcui-m-t-25">
        <div class="relative">
            <dc-table :headers="headers" :items="todos">
                <template v-slot:table-data="{ item }">
                    <td>{{ item.title }}</td>
                    <td>{{ label(item.status) }}</td>
                    <td>{{ label(item.priority) }}</td>
                    <td>{{ item.created_date }}</td>
                    <td>
                        <div class="dcui-flex-item">
                            <dc-icon-button v-if="can_edit" @click="toggle_status(item)"
                                :icon="item.status === 'completed' ? 'fa-solid fa-square-check' : 'fa-regular fa-square'">
                            </dc-icon-button>
                            <dc-icon-button v-if="can_edit" icon="fa-solid fa-pen-to-square"
                                @click="$router.push({ name: 'todo_edit', params: { id: item.id } })">
                            </dc-icon-button>
                            <dc-icon-button v-if="can_delete" icon="fa-solid fa-trash" @click="confirm_delete(item)">
                            </dc-icon-button>
                        </div>
                    </td>
                </template>
            </dc-table>
            <dc-empty-state v-if="no_todos">No todos yet.</dc-empty-state>
            <Data_Loader :transparent="true" v-if="ui.data_loading" />
        </div>
    </dc-card>
</div>

<dc-popup ref="delete_popup" title="Delete todo">
    <template v-slot:content>
        <p>Delete "{{ selected_todo ? selected_todo.title : '' }}"? This can't be undone.</p>
        <div class="dcui-flex-item dcui-justify-flex-end">
            <dc-button @click="close_delete">Cancel</dc-button>
            <dc-button class="dcui-button-no-fill dcui-m-l-10" :class="{ 'doing-ajax': ui.doing_ajax_delete }" @click="delete_todo">
                Delete <dc-ajax-loader theme="dc" v-if="ui.doing_ajax_delete" />
            </dc-button>
        </div>
    </template>
</dc-popup>

<Transition name="fade-up">
    <dc-ajax-notice theme="dc" v-bind="ui.notice" v-if="ui.notice.show" @dismiss_notice="ui.notice.show = false" />
</Transition>
`,
    computed: {
        can_add() {
            return XP.checkPermission({ name: "todo", action: "add_todo" });
        },
        can_edit() {
            return XP.checkPermission({ name: "todo", action: "update_todo" });
        },
        can_delete() {
            return XP.checkPermission({ name: "todo", action: "delete_todo" });
        },
        no_todos() {
            return !this.ui.data_loading && this.todos.length === 0;
        },
    },
    methods: {
        label(value) {
            return value ? XP_Util.firstLetterToUpperCase(value) : "";
        },
        show_notice(type, text) {
            this.ui.notice = { show: true, type: type, text: text };
        },
        async load_todos() {
            this.ui.data_loading = true;
            try {
                const res = await todo_services.list_todos();
                if (res.response.success) {
                    this.todos = res.data?.list || [];
                } else {
                    this.show_notice("error", res.response.statusMsg);
                }
            } catch (error) {
                this.show_notice("error", "Could not load the todos.");
            } finally {
                this.ui.data_loading = false;
            }
        },
        async toggle_status(item) {
            const form_data = {
                id: item.id,
                title: item.title,
                description: item.description || "",
                status: item.status === "completed" ? "active" : "completed",
                priority: item.priority,
            };
            try {
                const res = await todo_services.update_todo(XP.readyFormData(form_data));
                this.show_notice(res.response.success ? "success" : "error", res.response.statusMsg);
                if (res.response.success) {
                    this.load_todos();
                }
            } catch (error) {
                this.show_notice("error", "Could not update the todo.");
            }
        },
        confirm_delete(item) {
            this.selected_todo = item;
            this.$refs.delete_popup.show();
        },
        close_delete() {
            this.$refs.delete_popup.hide();
        },
        async delete_todo() {
            if (!this.selected_todo) {
                return;
            }
            this.ui.doing_ajax_delete = true;
            try {
                const res = await todo_services.delete_todo(XP.readyFormData({ id: this.selected_todo.id }));
                this.show_notice(res.response.success ? "success" : "error", res.response.statusMsg);
                if (res.response.success) {
                    this.close_delete();
                    this.selected_todo = null;
                    this.load_todos();
                }
            } catch (error) {
                this.show_notice("error", "Could not delete the todo.");
            } finally {
                this.ui.doing_ajax_delete = false;
            }
        },
    },
    created() {
        this.load_todos();
    },
};
```

- **Imports**: kit components come from `dc_ui_kit_registry.js`, never from a component's own file. `DC_Sidebar` and `Data_Loader` are imported from their files, as in `helloworld`. Keep imports bare, with no `?v=` on the end: the framework already gives every file a new URL when it changes.
- **`XP.checkPermission()`** hides the buttons a user can't use. It only changes what the user sees: the controller still checks every request.
- **`DcPopup`** asks before the delete and names the todo. `show()` and `hide()` open and close it.

See [Vue DC UI KIT](./Vue%20DC%20UI%20KIT/Vue%20DC%20UI%20KIT.md) for the components, and [Frontend Runtime (XP)](./Frontend%20Runtime%20(XP).md) for `XP`.

## Step 17: Build the add and edit page

Create `dev/todo/frontend/todo/components/todo_form.js`. Both `todo_add` and `todo_edit` use it. On the edit route it loads the todo first:

```jsx
import DC_Sidebar from "../../xp_system/components/navigation/dc_sidebar.js";
import { Data_Loader } from "../../xp_system/components/helpers.js";
import {
    DcAjaxLoader,
    DcAjaxNotice,
    DcButton,
    DcCard,
    DcIconButton,
    DcInputField,
    DcSelect,
    DcTextField,
} from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { validateForm, validationRules } from "../../xp_system/validator.js";
import { todo_services } from "../services.js";

export default {
    components: {
        DC_Sidebar,
        Data_Loader,
        DcAjaxLoader,
        DcAjaxNotice,
        DcButton,
        DcCard,
        DcIconButton,
        DcInputField,
        DcSelect,
        DcTextField,
    },
    data() {
        return {
            todo_id: this.$route.params.id || null,
            inputs: {
                title: "",
                description: "",
                status: "active",
                priority: "normal",
            },
            validation_config: {
                title: { rules: [validationRules.required] },
                description: { rules: [validationRules.optional] },
                status: { rules: [validationRules.required] },
                priority: { rules: [validationRules.required] },
            },
            errors: {},
            status_options: [
                { label: "Active", value: "active" },
                { label: "Completed", value: "completed" },
            ],
            priority_options: [
                { label: "Low", value: "low" },
                { label: "Normal", value: "normal" },
                { label: "High", value: "high" },
            ],
            ui: {
                data_loading: false,
                doing_ajax: false,
                notice: { show: false, type: "", text: "" },
            },
        };
    },
    template: `
<DC_Sidebar />
<div class="dc-app-container">
    <div class="dcui-flex-item dcui-align-center">
        <dc-icon-button icon="fa-solid fa-chevron-left" @click="go_to_list"></dc-icon-button>
        <div class="dc-big-heading">
            <h1 class="dc-bh-heading">{{ is_edit ? "Edit todo" : "Add todo" }}</h1>
        </div>
    </div>

    <dc-card class="dcui-m-t-25">
        <form class="relative" @submit.prevent="save">
            <div class="dcui-row">
                <div class="dcui-col-md-6">
                    <dc-input-field id="todo-fld-title" v-model="inputs.title" placeholder="What needs doing?">
                        <template v-slot:label>Title</template>
                    </dc-input-field>
                    <span class="dcui-text-danger" v-if="errors.title">{{ errors.title }}</span>
                </div>
            </div>
            <div class="dcui-row">
                <div class="dcui-col-md-3">
                    <dc-select id="todo-fld-status" v-model="inputs.status" :options="status_options">
                        <template v-slot:label>Status</template>
                    </dc-select>
                </div>
                <div class="dcui-col-md-3">
                    <dc-select id="todo-fld-priority" v-model="inputs.priority" :options="priority_options">
                        <template v-slot:label>Priority</template>
                    </dc-select>
                </div>
            </div>
            <div class="dcui-row">
                <div class="dcui-col-md-6">
                    <dc-text-field id="todo-fld-description" v-model="inputs.description" placeholder="Details (optional)">
                        <template v-slot:label>Description</template>
                    </dc-text-field>
                </div>
            </div>
            <dc-button type="submit" :disabled="ui.doing_ajax" :class="{ 'doing-ajax': ui.doing_ajax }">
                {{ is_edit ? "Save" : "Add" }} <dc-ajax-loader theme="dc" v-if="ui.doing_ajax" />
            </dc-button>
            <Data_Loader :transparent="true" v-if="ui.data_loading" />
        </form>
    </dc-card>
</div>

<Transition name="fade-up">
    <dc-ajax-notice theme="dc" v-bind="ui.notice" v-if="ui.notice.show" @dismiss_notice="ui.notice.show = false" />
</Transition>
`,
    computed: {
        is_edit() {
            return !!this.todo_id;
        },
    },
    methods: {
        go_to_list() {
            this.$router.push({ name: "todo" });
        },
        show_notice(type, text) {
            this.ui.notice = { show: true, type: type, text: text };
        },
        async load_todo() {
            this.ui.data_loading = true;
            try {
                const res = await todo_services.get_todo({ id: this.todo_id });
                if (res.response.success) {
                    const todo = res.data;
                    this.inputs = {
                        title: todo.title,
                        description: todo.description || "",
                        status: todo.status,
                        priority: todo.priority,
                    };
                } else {
                    this.show_notice("error", res.response.statusMsg);
                }
            } catch (error) {
                this.show_notice("error", "Could not load the todo.");
            } finally {
                this.ui.data_loading = false;
            }
        },
        async save() {
            const { errors, isValid } = validateForm(this.inputs, this.validation_config);
            this.errors = errors;
            if (!isValid) {
                return;
            }

            this.ui.doing_ajax = true;
            try {
                let res;
                if (this.is_edit) {
                    res = await todo_services.update_todo(XP.readyFormData({ id: this.todo_id, ...this.inputs }));
                } else {
                    res = await todo_services.add_todo(XP.readyFormData(this.inputs));
                }
                if (res.response.success) {
                    this.go_to_list();
                } else {
                    this.show_notice("error", res.response.statusMsg);
                }
            } catch (error) {
                this.show_notice("error", "Could not save the todo.");
            } finally {
                this.ui.doing_ajax = false;
            }
        },
    },
    created() {
        if (this.is_edit) {
            this.load_todo();
        }
    },
};
```

`validateForm()` checks the fields in the browser so the user sees errors at once. The model's `validate()` still checks them on the server, because any client can call the API.

## Step 18: Try the app

Reload the web app. There is no build step: the framework rebuilds its bundles on every page load and gives changed files new URLs, so a reload is all you need after any edit.

1. **Todo** appears in the sidebar. Click it to open the list.
2. Click **Add todo**, fill in the form and click **Add**. The list shows the new todo.
3. Click the square icon to mark it complete, and again to mark it active.
4. Click the pen icon, change the title and click **Save**.
5. Click the trash icon and confirm. The todo is gone.

You now have a working app.

---

# How to give other users access

The `system_admin` role got every todo permission when you reinitialized, through `auto_update="true"`. Other users need a role that grants them. The manifest's `<roles>` block already created one, **Todo User**, with every todo permission and `auth/logout`.

To give it to a user:

1. In the admin panel, open **Roles** and the **Members** tab.
2. Find **Todo User** and click **Add Members**.
3. Pick the users and save.

They see the **Todo** menu after they reload the web app. No new login is needed.

To grant only some actions, change the role's grants on the **Permissions** tab, or declare a narrower role, for example one with `actions="view,list_todos,get_todo"` for read-only users. See [Roles And Permissions](./Essentials/Roles%20And%20Permissions.md).

---

# Troubleshooting

**Todo isn't on the Apps page.** The links weren't created. Check that `<system_environment>` in `api/config.xml` is `development`, that `dev/todo/backend/todo/todo.xml` exists and is valid XML, and that its `<app_name>` is `todo`. Then check that PHP can create links in `api/apps/` and `apps/`, and look for a warning from `symlink()` in the PHP error log.

**The API answers `401 Not Authorized`.** Your user doesn't hold `todo/<action>`. Check that the action name in the controller matches a `<permission name>` in the manifest, that `<user_permissions name>` is `todo`, and that you reinitialized after the last manifest change.

**The API answers `501 Not Supported yet`.** With that exact message the framework found no controller: check the file name, `todoController.class.php`, and the class name. With the message `Not Supported yet.`, the controller has no `case` for the action or uses the wrong HTTP method.

**No Todo menu.** Check that `app-config.json` is valid JSON with no comments, that `status` is `active`, that `menus` is listed in `_public`, and that the menu's `permission` is one your user holds. Then reload the page.

**Every app's routes disappeared.** A script in `assets/app-scripts.js` has an error. Open the browser console. The usual cause is a syntax error in a `route.js`, or two apps declaring the same top-level name.

**Database errors in the log.** The table doesn't exist until you reinitialize. A query that names `items` instead of `todo_items` also fails.

---

# File reference

| File | Read by | When |
| --- | --- | --- |
| `todo.xml` | Dev links, Apps page, app boot, permission checks, reinitialize | Every request. Tables, grants and roles only on reinitialize |
| `todo.class.php` | App boot, global search | Every request |
| `todoController.class.php` | The API, for `api/todo/<action>` | Every API request to the app |
| `todoModel.class.php`, `todoDAO.class.php` | Your controller | When the controller uses them |
| `app-config.json` | The page renderer | Every page load |
| `route.js` | Bundled into `assets/app-scripts.js` | Every page load |
| `services.js`, `components/*.js` | The browser, as ES modules | When a page imports them |

---

# Next steps

- [Roles And Permissions](./Essentials/Roles%20And%20Permissions.md): scoped grants, checking permissions inside an action, and managing roles.
- [Dashboard Widgets](./Building%20Apps/Dashboard%20Widgets.md): show the open todos on the dashboard.
- [Admin Pages](./Building%20Apps/Admin%20Pages.md): add a settings page for the app to the admin panel, in `dev/todo/adminpanel/todo/`.
- [Packaging And Updates](./Building%20Apps/Packaging%20And%20Updates.md): export the app and install it on another system.
