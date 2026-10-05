---
title: Roles And Permissions
sidebar_label: Roles And Permissions
---

# Roles And Permissions

# Introduction

DoFramework controls access with permissions, roles and grants:

- A **permission** is one action an app declares in its XML manifest, such as `myapp/list_orders`. It usually matches an API action, `api/myapp/list_orders`.
- A **role** is a named group of grants, such as `system_admin` or `myapp_operator`. Admins manage roles on the admin panel's Roles page. Apps can also create roles from their manifest.
- A **grant** gives one permission to one role. Grants are stored in the `xp_users_role_permissions` table.
- A **user** holds one or more roles. Their session carries every action their roles grant.

The backend enforces permissions in each controller's `authenticate()` method. The frontend uses them to hide routes and buttons. Changes an admin makes to roles reach logged-in users on their next request, with no new login needed.

Grants can also be **scoped**: limited to part of an app's data, such as one branch, for users who hold the role for that branch. Scopes are optional. Nothing changes until an app declares them.

For login, sessions and `authenticate()` itself, see [Authentication](./Authentication.md).

<aside>
💡 Before 0.0.36, each user had a copy of their permissions in the `permissions` column of `xp_users_user`. That column is no longer read at login, and a per-user copy that differs from the user's roles has no effect. Grant permissions to roles. Don't read or write that column.

</aside>

---

# How to declare permissions

Declare your app's permissions in its manifest, `api/apps/myapp/myapp.xml`:

```xml
<user_permissions name="myapp">
    <category name="basic_permissions" display_name="My App">
        <permission display_name="View the app" name="view" auto_update="true"/>
        <permission display_name="Get data" name="get_data" auto_update="true"/>
    </category>
    <category name="order_permissions" display_name="Orders">
        <permission display_name="List orders" name="list_orders"/>
        <permission display_name="Edit an order" name="edit_order" info="Change an order's status and lines."/>
    </category>
</user_permissions>
```

- **`<user_permissions name>`**: the key the permissions are stored and checked under. Use your controller name, the `<controller>` part of `api/<controller>/<action>`. For most apps it is the app name. `auth::appUserPermission()` looks the action up under the controller name, so a different key never matches. A manifest can hold more than one `<user_permissions>` block, each with its own name, when it has more than one controller.
- **`<category>`**: groups permissions on the Roles page. `display_name` is the group's label. Without it, the label is the `name` with `_` turned into spaces and a trailing `_permissions` dropped.
- **`<permission name>`**: the action. Match the action names your controller handles.
- **`display_name`**: the label on the Roles page. **`info`** is an optional longer description.
- **`auto_update="true"`**: on install and on every reinitialization, the action is granted to the `system_admin` role.
- **`scopable="true"`**: the grant may be limited to a scope. See [How to scope grants](#declare-scopes).

`auto_update` only adds grants. A reinit never removes an action an admin granted by hand (fixed in 0.0.35). It also never brings back a grant an admin removed from `system_admin` (since 0.0.36).

<aside>
⚠️ `auto_update` grants are stored under the app's folder name (`myapp` for `api/apps/myapp/`), not under `<user_permissions name>`. If the two differ, `system_admin` gets the grants under a key no controller checks. Keep the name equal to the folder name, or grant those actions on the Roles page.

</aside>

## Admin panel permissions

Pages your app adds to the admin panel use a separate set of permissions:

```xml
<admin_panel_permissions>
    <category name="basic_permissions">
        <permission display_name="View settings page" name="view" auto_update="true"/>
        <permission display_name="Get settings" name="get_settings" auto_update="true"/>
    </category>
</admin_panel_permissions>
```

`<admin_panel_permissions>` takes no `name` attribute. Its permissions are stored under the app's folder name. Declare one block per manifest.

The admin panel has a single permission set, shared by every admin login. Admins edit it under **Settings > Permissions**. With `auto_update="true"`, the permission is added to that set on install and on every reinit. A reinit also adds back an `auto_update` admin permission that was unticked in Settings.

`auth::appUserPermission()` accepts admin-panel permissions too. An admin-panel session that holds `myapp/get_settings` can call `api/myapp/get_settings`.

---

# How to create roles from the manifest

An app can create roles and give them default grants with a `<roles>` block:

```xml
<roles>
    <role name="myapp_operator" display_name="Operator">
        <grant app="myapp" actions="*"/>
        <grant app="xp_notification" actions="list,mark_read"/>
        <grant app="auth" actions="logout"/>
    </role>
</roles>
```

- **`<role name>`**: the role's system name. If no role has that name, it is created with the next free priority. `display_name` is the label. It is filled only while the role's label is empty, so the first app to create a role names it.
- **`<grant app>`**: a `<user_permissions name>` from any installed app, not only your own. An extension app can add its actions to a role another app owns.
- **`actions`**: a comma-separated list, or `*` for every action that `<user_permissions>` block declares (with or without `auto_update`).
- **`reach`**: optional, `global` (the default) or `scoped`. See [How to scope grants](#declare-scopes).

Every reinit of the app provisions its roles. It creates missing roles and inserts each grant with `INSERT IGNORE`, so a grant that already exists is left alone. Each role also gets `dashboard/view`, so its users can open the dashboard after login. Unknown apps and actions are logged and skipped.

Provisioning only adds. When an admin unticks a grant on the Roles page, the grant row is kept with `revoked_at` set. A later reinit sees the row and doesn't grant it again. Removing a role or a grant from the manifest doesn't remove it from the database.

<aside>
⚠️ New roles get `dashboard/view` and nothing else. Add `auth/logout` to every role you declare, as in the example above. Without it, the role's users can't log out on the server. See [Authentication](./Authentication.md).

</aside>

---

# How to apply permission changes

**After changing a manifest** (new permissions, `auto_update`, `<roles>` or `<scopes>`), reinitialize the app: in the admin panel, open **Apps**, open the app and click **Reinitialize**. From code, call `AppManager::initialize_app('myapp')`. The Roles page reads the manifests directly, so it lists new permissions straight away. But `auto_update` grants, `<roles>` and the scope checks are applied only by the reinit.

**After an admin changes a role's grants or members**, logged-in users pick up the change on their next API request. No new login is needed. This works with a version stamp:

1. Each role has a `permissions_version` in `xp_users_roles`, raised whenever its grants change. Each user has a `roles_version` in `xp_users_user`, raised whenever their roles change.
2. At login the session stores the sum of the user's role versions plus their `roles_version` as `PERMISSIONS_VERSION`.
3. On every request, `auth::syncSession()` reads the current stamp with one query. If it differs, it rebuilds the session's permissions. If the user was disabled or removed, it ends the session.
4. The SPA router calls `api/auth/validate_session` on every navigation and sends the stamp it holds. When the stamp has changed, the response carries the new permissions, and the router writes them to local storage.

**After admin-panel permissions change**, including through a reinit, admins must log out of the admin panel and log in again. The admin panel's permission set is not synced live.

---

# How to check permissions on the backend

Protect every action in your controller's `authenticate()` method:

```php
public function authenticate(): bool
{
    $action = $this->getRequest()->getAction();
    $controller = $this->getRequest()->getController();
    $publicEndpoints = array();

    return auth::appUserPermission($action, $controller, $publicEndpoints);
}
```

A request to `api/myapp/edit_order` then passes only if one of the user's roles grants `myapp/edit_order`, or the admin-panel session holds it.

Inside an action, `auth::checkPermissions('edit_order', 'myapp')` checks one more permission against the session. For scoped grants use `auth::can()` and `auth::scopesFor()`, described below.

To find who holds a role, read the role membership, not `xp_users_user.role`:

```php
$userIds = xp_userRoleMembership::userIdsIn($roleId);   // members of a role
$roleIds = xp_userRoleMembership::roleIdsFor($userId);  // roles of a user
```

---

# How to check permissions on the frontend

Frontend checks only decide what the user sees. The server still checks every request.

**Routes.** Give every route that needs a login a `meta.permissions` object. The router calls `validate_session` and also checks the permission locally. If the user lacks it, the router sends them to the dashboard.

```jsx
Router.addRoute({
    path: "/myapp",
    name: "myapp",
    component: () => XP.import("/apps/myapp/components/myapp.js"),
    meta: {
        title: "My App",
        requiresAuth: true,
        permissions: { name: "myapp", action: "view" },
    },
});
```

**Components.** `XP.checkPermission()` reads the permissions saved in local storage at login:

```jsx
export default {
    template: `
        <button v-if="canEdit" class="dcui-button" @click="edit">Edit</button>
    `,
    computed: {
        canEdit() {
            return XP.checkPermission({ name: "myapp", action: "edit_order" });
        },
    },
    methods: {
        edit() {
            // ...
        },
    },
};
```

**Admin panel pages** use `XP.checkAdminPermission()` with the same `{ name, action }` object. It reads the admin panel's permission set. `name` is the app's folder name.

---

# How grants and roles are stored

| Table | Holds |
| --- | --- |
| `xp_users_roles` | One row per role: `name`, `display_name`, `priority`, `permissions_version`. |
| `xp_users_role_permissions` | One row per grant: `role_id`, `app`, `action`, `reach` and `revoked_at`. Unique on role, app and action. A row with `revoked_at` set is not a live grant. |
| `xp_users_user_roles` | One row per membership: `user_id`, `role_id` and an optional scope (`scope_type`, `scope_id`). |
| `xp_users_user` | `role` is a copy of the user's main role. `roles_version` changes with their memberships. |

A user can hold several roles, and always holds at least one. The session carries the combined grants of all of them. The Users app edits a user's roles as a checklist.

`xp_users_user.role` is derived, for code that expects a single role. It is the user's first role in priority order: lowest priority number first, the default role last. Never write it yourself. Only `xp_userPermissionStore` writes grants and only `xp_userRoleMembership` writes memberships, and they keep the version stamps and the derived role correct.

The session stores the combined grants in this shape:

```json
{
    "permissions": {
        "dashboard": ["view"],
        "myapp": ["edit_order", "list_orders", "view"]
    }
}
```

---

# How to scope grants

A scope limits a grant to part of an app's data. For example, a branch manager may edit orders only in the branches they manage.

Three things combine:

- The app declares **scope types**, such as `region` and `branch`, and marks which permissions are **scopable**.
- Each grant has a **reach**: `global` (everywhere, the default) or `scoped`.
- Each role membership can carry a **scope**, such as branch 4. A user can hold the same role for several scopes.

A scope is written as `<app>.<type>:<id>`, for example `myapp.branch:4`. `<app>` is the `<user_permissions name>`. The app name and the type may contain only lower-case letters, digits and `_`. The id is a positive integer.

What a membership contributes:

| Membership | `global` grant | `scoped` grant |
| --- | --- | --- |
| No scope | Everywhere | Nothing |
| Scoped to S | Everywhere | Only in S |

A grant that reaches everywhere through any of the user's memberships wins over any scope list. Admin-panel sessions are never scoped.

<aside>
⚠️ A scoped grant still passes `auth::appUserPermission()` and `XP.checkPermission()`. Both only ask whether the user holds the action anywhere. Your action must call `auth::can()` or `auth::scopesFor()` to limit which records it touches.

</aside>

## Declare scopes

Add a `<scopes>` block to your `<user_permissions>` and mark the permissions that may be scoped:

```xml
<user_permissions name="myapp">
    <scopes resolver="myappScopeResolver">
        <scope type="region" display_name="Region"/>
        <scope type="branch" display_name="Branch" parent="region"/>
    </scopes>
    <category name="order_permissions" display_name="Orders">
        <permission display_name="View the app" name="view"/>
        <permission display_name="List orders" name="list_orders" scopable="true"/>
        <permission display_name="Edit an order" name="edit_order" scopable="true"/>
    </category>
</user_permissions>

<roles>
    <role name="myapp_branch_manager" display_name="Branch Manager">
        <grant app="myapp" actions="view"/>
        <grant app="myapp" actions="list_orders,edit_order" reach="scoped"/>
        <grant app="auth" actions="logout"/>
    </role>
</roles>
```

- **`resolver`**: the class that implements `xp_scopeResolver` for this app.
- **`<scope type>`**: a scope type. `display_name` is its label. `parent` names another type in the same block. On the Roles page, the admin then picks the parent first, for example the region before the branch.
- **`scopable="true"`**: only these permissions can have a `scoped` reach.
- **`reach="scoped"`** on a `<grant>`: the grant's starting reach. It applies only when the reinit creates the grant row. After that, the reach is managed on the Roles page.

The reinit checks the declaration. A missing resolver class, an invalid type or an unknown parent makes the app's whole `<scopes>` block unusable, and the error is logged. A grant with an unknown `reach`, or `scoped` on an action that isn't scopable, is skipped and logged. It is never granted everywhere instead.

## Borrow another app's scopes

An app that acts on another app's data can use that app's scope types and resolver:

```xml
<user_permissions name="myapp_reports">
    <scopes from="myapp"/>
    <category name="report_permissions">
        <permission display_name="Branch report" name="branch_report" scopable="true"/>
    </category>
</user_permissions>
```

`from` names the lender's `<user_permissions name>`. The borrower declares no resolver and no types. A membership scoped to `myapp.branch:4` then limits the borrower's scoped grants too, because a membership's scope applies to every scoped grant of its role, whatever the app. Only an app with its own working `<scopes>` can lend.

## Write a resolver

The resolver is the only code that knows what a scope contains. Put it in your app's backend folder, for example `api/apps/myapp/myappScopeResolver.class.php`. This example has regions, branches inside regions, and orders that belong to a branch:

```php
<?php

class myappScopeResolver implements xp_scopeResolver
{
    private const TABLES = [
        'myapp.region' => 'myapp_regions',
        'myapp.branch' => 'myapp_branches',
    ];

    public function chain(string $resourceType, int $id): ?array
    {
        $db = new database();
        if ($resourceType === 'order') {
            $db->query('SELECT b.id AS branch_id, b.region_id FROM myapp_orders o
                        JOIN myapp_branches b ON b.id = o.branch_id WHERE o.id = :id');
        } elseif ($resourceType === 'branch') {
            $db->query('SELECT id AS branch_id, region_id FROM myapp_branches WHERE id = :id');
        } else {
            return null;
        }
        $db->bind(':id', $id);
        $row = $db->single();
        if (!$row) {
            return null;
        }
        // Nearest scope first
        return [
            'myapp.branch:' . (int) $row['branch_id'],
            'myapp.region:' . (int) $row['region_id'],
        ];
    }

    public function filterSql(string $resourceType, array $scopes, string $alias): string
    {
        $columns = ['order' => "$alias.branch_id", 'branch' => "$alias.id"];
        if (!isset($columns[$resourceType])) {
            return '1 = 0';
        }
        $column = $columns[$resourceType];

        $branchIds = $this->idsOfType($scopes, 'myapp.branch');
        $regionIds = $this->idsOfType($scopes, 'myapp.region');

        $parts = [];
        if ($branchIds) {
            $parts[] = "$column IN (" . implode(',', $branchIds) . ')';
        }
        if ($regionIds) {
            $parts[] = "$column IN (SELECT id FROM myapp_branches WHERE region_id IN (" . implode(',', $regionIds) . '))';
        }
        return $parts ? '(' . implode(' OR ', $parts) . ')' : '1 = 0';
    }

    public function exists(string $scopeType, int $id): bool
    {
        $table = self::TABLES[$scopeType] ?? null;
        if ($table === null) {
            return false;
        }
        $db = new database();
        $db->query("SELECT 1 FROM $table WHERE id = :id");
        $db->bind(':id', $id);
        return (bool) $db->single();
    }

    public function options(string $scopeType, ?string $parentScope, string $q, int $limit, int $offset): array
    {
        $table = self::TABLES[$scopeType] ?? null;
        if ($table === null) {
            return [];
        }
        $sql = "SELECT id, name FROM $table WHERE name LIKE :q";
        $parent = $parentScope !== null ? xp_userScopes::parse($parentScope) : null;
        if ($scopeType === 'myapp.branch' && $parent !== null) {
            $sql .= ' AND region_id = ' . (int) $parent['id'];
        }
        $sql .= ' ORDER BY name LIMIT ' . (int) $limit . ' OFFSET ' . (int) $offset;

        $db = new database();
        $db->query($sql);
        $db->bind(':q', '%' . $q . '%');
        $rows = [];
        foreach ($db->resultset() as $row) {
            $rows[] = ['scope' => $scopeType . ':' . (int) $row['id'], 'label' => $row['name']];
        }
        return $rows;
    }

    public function labels(array $scopes): array
    {
        $labels = [];
        foreach ($scopes as $scope) {
            $parsed = xp_userScopes::parse((string) $scope);
            $table = $parsed ? (self::TABLES[$parsed['type']] ?? null) : null;
            if ($table === null) {
                continue;
            }
            $db = new database();
            $db->query("SELECT name FROM $table WHERE id = :id");
            $db->bind(':id', $parsed['id']);
            $row = $db->single();
            if ($row) {
                $labels[$scope] = $row['name'];
            }
        }
        return $labels;
    }

    /** The ids of the scopes of one type, as integers */
    private function idsOfType(array $scopes, string $type): array
    {
        $ids = [];
        foreach ($scopes as $scope) {
            $parsed = xp_userScopes::parse((string) $scope);
            if ($parsed !== null && $parsed['type'] === $type) {
                $ids[] = (int) $parsed['id'];
            }
        }
        return $ids;
    }
}
```

`chain()` and `filterSql()` take your own resource names (`order`, `branch`). `exists()` and `options()` take the full scope type (`myapp.branch`).

## Check scopes in an action

To check one record, use `auth::can()`:

```php
$orderId = (int) ($this->getRequest()->getData()['id'] ?? 0);

if (!auth::can('myapp', 'edit_order', 'order', $orderId)) {
    echo $res->create(403, 'You cannot edit this order.', false);
    return;
}
```

To list records, put the resolver's filter in the query, before `LIMIT`:

```php
$scopes = auth::scopesFor('myapp', 'list_orders');

$where = '1 = 1';                       // null: held everywhere
if ($scopes !== null) {
    $resolver = xp_userScopes::resolverForApp('myapp');
    $where = $resolver->filterSql('order', $scopes, 'o');   // '1 = 0' for []
}

$db = new database();
$db->query("SELECT o.* FROM myapp_orders o WHERE $where ORDER BY o.id DESC LIMIT 50");
$orders = $db->resultset();
```

On the frontend, `XP.permissionScopes()` tells you where the user holds an action, for example to fill a branch picker:

```jsx
const scopes = XP.permissionScopes({ name: "myapp", action: "list_orders" });

if (scopes === "*") {
    // held everywhere
} else if (scopes.length > 0) {
    // only in these scopes, e.g. ["myapp.branch:4"]
} else {
    // not held
}
```

## When scopes disappear

On every reinit of any app, the framework checks each scoped membership. If its scope type is no longer declared, or the resolver's `exists()` says the scope is gone, the membership becomes unscoped. If the user already holds that role unscoped, the scoped copy is removed. The user keeps the role's global grants either way.

A membership is kept, and the problem logged, while its app's `<scopes>` block is broken or its resolver throws. Nothing is pruned in a reinit where any manifest fails to parse.

---

# How to manage roles in the admin panel

The admin panel's **Roles** page has two tabs.

**Permissions** shows a grid of every app's permissions, grouped by app and category, with a column per role. Tick a cell to grant the permission to the role, then click **Save Permissions**. Unticking keeps the grant row with `revoked_at` set, so a reinit doesn't bring it back. On a ticked scopable cell, a reach button switches the grant between everywhere and scoped. Before saving, the confirmation names the unscoped members who would lose a grant that becomes scoped.

**Members** lists the roles with their member counts. For each role you can see its members and their other roles, add members, and remove them. A user's last role can't be removed. When an app declares scopes, the member list has a **Scope** column. **Add Members** then asks for a scope: pick the type, then the scope. For a child type, pick the parent first.

The page also adds roles, sets role priorities, removes roles and moves users off the default role. The default role and `system_admin` can't be removed.

From code, `xp_userRoleMembership::addScoped($userId, $roleId, 'myapp.branch', 4)` gives a user a role for one scope. Pass `''` and `0` for no scope.

---

# Methods

### auth::can

Description:

The **`can`** method checks whether the current session may perform an action on one record.

Syntax:

```php
$allowed = auth::can('myapp', 'edit_order', 'order', $orderId);
```

**Parameters:**

- **`$app`**: The `<user_permissions name>`.
- **`$action`**: The action.
- **`$resourceType`**: A resource name your resolver's `chain()` understands.
- **`$resourceId`**: The record id.

**Return Value:**

- **`Boolean`**: `true` if the action is held everywhere, or one of the user's scopes for it is in the record's `chain()`. `false` if the action is not held, the app has no resolver, the record doesn't exist or the resolver throws.

---

### auth::scopesFor

Description:

The **`scopesFor`** method returns where the current session holds an action. Use it to filter lists.

Syntax:

```php
$scopes = auth::scopesFor('myapp', 'list_orders');
```

**Parameters:**

- **`$app`**: The `<user_permissions name>`.
- **`$action`**: The action.

**Return Value:**

- **`null`**: Held everywhere, through a global grant or an admin-panel session.
- **`Array`**: A list of scope strings, such as `["myapp.branch:4"]`. Pass it to the resolver's `filterSql()`.
- **`[]`**: Not held, or the session was ended.

---

### xp_userScopes::resolverForApp

Description:

The **`resolverForApp`** method returns a new instance of an app's resolver. For an app that borrows scopes, it returns the lender's resolver.

Syntax:

```php
$resolver = xp_userScopes::resolverForApp('myapp');
```

**Parameters:**

- **`$app`**: The `<user_permissions name>`.

**Return Value:**

- **`xp_scopeResolver`** or **`null`**: The resolver, or `null` when the app has no working `<scopes>` declaration.

---

### xp_userScopes::parse

Description:

The **`parse`** method splits a scope string into its type and id.

Syntax:

```php
$parsed = xp_userScopes::parse('myapp.branch:4');
// ['type' => 'myapp.branch', 'id' => 4]
```

**Parameters:**

- **`$scope`**: A scope string.

**Return Value:**

- **`Array`** or **`null`**: `type` and `id`. `['type' => '', 'id' => 0]` for `''` (no scope). `null` for a malformed string.

---

### xp_scopeResolver::chain

Description:

The **`chain`** method returns the scopes that contain one record. `auth::can()` calls it.

Syntax:

```php
public function chain(string $resourceType, int $id): ?array
```

**Parameters:**

- **`$resourceType`**: Your resource name, such as `order`.
- **`$id`**: The record id.

**Return Value:**

- **`Array`** or **`null`**: Scope strings, nearest first, such as `["myapp.branch:4", "myapp.region:2"]`. `null` when the record doesn't exist.

---

### xp_scopeResolver::filterSql

Description:

The **`filterSql`** method returns a SQL condition that limits a table's rows to the given scopes. Your own list queries call it with the result of `auth::scopesFor()`.

Syntax:

```php
public function filterSql(string $resourceType, array $scopes, string $alias): string
```

**Parameters:**

- **`$resourceType`**: Your resource name.
- **`$scopes`**: Scope strings.
- **`$alias`**: The table alias in the calling query. It is inserted into the SQL as is, so pass a constant from your code, never user input.

**Return Value:**

- **`String`**: A SQL condition with the ids written in as integers. `"1 = 0"` when `$scopes` is empty.

---

### xp_scopeResolver::exists

Description:

The **`exists`** method checks whether a scope still exists. The framework calls it when an admin adds a scoped member and on every reinit.

Syntax:

```php
public function exists(string $scopeType, int $id): bool
```

**Parameters:**

- **`$scopeType`**: The full scope type, such as `myapp.branch`.
- **`$id`**: The scope id.

**Return Value:**

- **`Boolean`**: `true` if the scope exists.

---

### xp_scopeResolver::options

Description:

The **`options`** method returns scopes for the Roles page's scope picker.

Syntax:

```php
public function options(string $scopeType, ?string $parentScope, string $q, int $limit, int $offset): array
```

**Parameters:**

- **`$scopeType`**: The full scope type.
- **`$parentScope`**: The chosen parent scope, such as `myapp.region:2`, when the type has a parent. `null` otherwise.
- **`$q`**: Search text to match against the labels.
- **`$limit`** and **`$offset`**: The page to return.

**Return Value:**

- **`Array`**: A list of `['scope' => 'myapp.branch:4', 'label' => 'Main Street']` entries.

---

### xp_scopeResolver::labels

Description:

The **`labels`** method returns display labels for scope strings, for example for the Members tab.

Syntax:

```php
public function labels(array $scopes): array
```

**Parameters:**

- **`$scopes`**: Scope strings.

**Return Value:**

- **`Array`**: A label per scope string. Leave out scopes you don't know.

---

### XP.checkPermission

Description:

The **`checkPermission`** method checks whether the logged-in user holds an action, using the permissions saved in local storage.

Syntax:

```jsx
const allowed = XP.checkPermission({ name: "myapp", action: "edit_order" });
```

**Parameters:**

- **`name`**: The `<user_permissions name>`.
- **`action`**: The action.

**Return Value:**

- **`Boolean`**: `true` if the user holds the action anywhere, scoped or not.

---

### XP.checkAdminPermission

Description:

The **`checkAdminPermission`** method checks the admin panel's permission set. Use it on admin panel pages.

Syntax:

```jsx
const allowed = XP.checkAdminPermission({ name: "myapp", action: "view" });
```

**Parameters:**

- **`name`**: The app's folder name.
- **`action`**: The action declared in `<admin_panel_permissions>`.

**Return Value:**

- **`Boolean`**: `true` if the admin panel's permission set holds the action.

---

### XP.permissionScopes

Description:

The **`permissionScopes`** method returns where the logged-in user holds an action. Use it to offer only what the user may act on. The server still checks each request.

Syntax:

```jsx
const scopes = XP.permissionScopes({ name: "myapp", action: "list_orders" });
```

**Parameters:**

- **`name`**: The `<user_permissions name>`.
- **`action`**: The action.

**Return Value:**

- **`"*"`**: Held everywhere.
- **`Array`**: The scope strings where it is held.
- **`[]`**: Not held.

---
