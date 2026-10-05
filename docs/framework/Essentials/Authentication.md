---
title: Authentication
sidebar_label: Authentication
---

# Authentication

Owner: Nuwan Danushka

# Introduction

The built-in `auth` app handles login, two-factor login, logout, forgotten passwords and remember-me. It keeps the logged-in user in the PHP session. The SPA keeps a copy of the user, including their permissions, in local storage.

Every API request goes to `api/<controller>/<action>`. Before the framework runs an action, it calls the controller's `authenticate()` method. If that returns `false`, the client gets a `401 Not Authorized` response. Most controllers implement `authenticate()` with `auth::appUserPermission()`, which checks the action against the permissions in the session.

This page covers logging in and out, sessions, and protecting a controller. For how permissions are declared, granted to roles and checked, see [Roles And Permissions](./Roles%20And%20Permissions.md).

All `auth` endpoints answer with HTTP 200. Check `response.success` and read the payload from `data`.

| Endpoint | Public | Fields |
| --- | --- | --- |
| `POST api/auth/login` | Yes | `email`, `password`, `rememberMe` (`"true"` to set the remember-me cookie) |
| `POST api/auth/validate2fa` | Yes | `token`, `code` |
| `POST api/auth/resendtwofa` | Yes | `token` |
| `POST api/auth/logout` | No (`auth/logout`) | none |
| `POST api/auth/forgotpassword` | Yes | `email` |
| `POST api/auth/setpassword` | Yes | `token`, `password`, `activate`, `login` |
| `POST api/auth/resetpassword` | No (`auth/resetpassword`) | `id`, `activate` |
| `POST api/auth/validate_session` | Yes | `permission[name]`, `permission[action]`, `permissions_version` |

---

# How to log a user in

Send the email and password to `api/auth/login` as form data:

```jsx
const api_url = XP.getApiUrl();

const credentials = {
    email: "user@example.com",
    password: "Secret#123",
    rememberMe: "true",
};

const res = await fetch(api_url + "/auth/login", {
    method: "POST",
    body: XP.readyFormData(credentials),
    credentials: "include",
});
const json = await res.json();

if (json.response.success && json.data["2fa"] !== "1") {
    XP.saveLocalLoggedUserData(json.data);
}
```

On success the server rotates the session id and creates the session. `data` holds the user row without the password, plus:

- **`permissions`**: a JSON string, `{"permissions": {"<app>": ["<action>", ...]}}`. It holds every action the user's roles grant.
- **`permissions_version`**: the version stamp of those permissions.
- **`permission_scopes`**: where scoped grants apply. See [Roles And Permissions](./Roles%20And%20Permissions.md).
- **`role_name`**, **`meta`**, **`avatar`** and **`login_expire`** (UTC time when the session lifetime ends).

Save `data` with `XP.saveLocalLoggedUserData()`. `XP.checkPermission()` reads the permissions from there.

Failed logins return `success: false` with a message such as `Password or email is incorrect.` or `Valid email required.`.

<aside>
⚠️ The login does not check the account status by default, because `auth::$SKIP_ACCOUNT_ACTIVATION_CHECK` is `true`. Users who have not activated their account log in normally. Disabled users also get `Successfully logged in.`, but their session ends on the next request, so the SPA sends them back to the login page without an error message.

</aside>

## Two-factor login

When the user's `2fa` column in `xp_users_user` is `1`, the login creates no session. It returns `data` as `{"2fa": "1", "token": "..."}` and stores a numeric code in the PHP session. The token expires after 30 minutes.

To finish the login, send the token and the code to `api/auth/validate2fa`. The response has the same shape as a password login. The code lives in the PHP session, so both requests must come from the same browser.

`api/auth/resendtwofa` with the token generates a new code and emails it to the user.

<aside>
⚠️ The login response says `Please check email for Two Factor Code.`, but the login does not send that email. Only `resendtwofa` sends a code. The built-in two-factor page (`/login/two-factor`) has a resend button. If you build your own client, call `resendtwofa` as soon as the login returns `2fa` set to `"1"`.

</aside>

---

# How to log a user out

Send `POST api/auth/logout`, then clear local storage:

```jsx
await fetch(XP.getApiUrl() + "/auth/logout", {
    method: "POST",
    credentials: "include",
});
XP.deleteLocalLoggedUserData();
Router.replace({ name: "login" });
```

The server deletes the user's remember-me tokens, unsets the session variables and destroys the PHP session.

<aside>
⚠️ `logout` is not a public endpoint. It needs the `auth/logout` grant. The two roles created at install have it. A role you add on the Roles page, or one provisioned from a manifest `<roles>` block, starts with only `dashboard/view`. If such a role lacks `auth/logout`, the logout request gets a 401 and the server session stays alive until it expires. Grant `auth/logout` to every role.

</aside>

---

# How to reset a forgotten password

1. Send the user's `email` to `api/auth/forgotpassword`. If a user has that email, the server emails them a link to `/login/create-password?token=...`.
2. The link opens the built-in Create Password page. It sends `token` and the new `password` to `api/auth/setpassword`.

Set-password tokens expire after 30 minutes. The new password must contain a lower-case letter, an upper-case letter, a number and a special character. Otherwise the response lists the missing criteria.

`setpassword` takes two optional fields:

- **`activate`**: set it for a first-time password. The account is activated as the password is saved.
- **`login`**: send `"1"` to log the user in straight away. The response is then the same as a password login.

An admin can trigger the same email for another user with `api/auth/resetpassword` and the user's `id`. This needs the `auth/resetpassword` grant. If the user is not activated yet and `activate` is set, the user gets the welcome email with a set-password link instead.

---

# How to keep users logged in with remember-me

Send `rememberMe` as `"true"` with the login. The server then:

1. Deletes any remember-me token the user already has.
2. Stores a new token in `auth_rememberme_tokens`. Only a hash of its secret part is kept.
3. Sets a `remember_me` cookie (`secure`, `httponly`, path `/`) that expires after 15 days.

When the PHP session has expired, `validate_session` checks the cookie. If the token is valid, it rebuilds the session and returns the full user object as `data.session`. The SPA router saves it, so the user stays logged in.

<aside>
💡 Each user has at most one remember-me token. Logging in with remember-me on a second browser invalidates the first one.

</aside>

---

# How the SPA checks the session

The SPA router calls `api/auth/validate_session` before every navigation to a route with `meta.requiresAuth: true`. It sends the route's `meta.permissions` and the `permissions_version` it holds in local storage. The router only makes this call when local storage holds a logged-in user. Otherwise it goes straight to the login page.

`validate_session` first lets `auth::syncSession()` bring the session up to date with the database. It then answers with `data`:

- **`logged_in`**: `true` when the session is valid.
- **`has_permission`**: `true` when the session holds `permission[action]` for `permission[name]`.
- **`permissions_version`**: the session's current stamp.
- **`permissions`** and **`permission_scopes`**: only when the client's `permissions_version` is missing or differs. The router writes them to local storage, so `XP.checkPermission()` follows role changes without a new login.
- **`session`**: only when the session was restored from the remember-me cookie.

The router sends the user to the login page when `logged_in` is `false`, and to the dashboard when the route's permission is missing.

<aside>
💡 Give every route with `requiresAuth: true` a `meta.permissions` object. Without it, `has_permission` is `false` and the router sends the user to the dashboard.

</aside>

`validate_session` never rotates the session id. The id changes only at login.

---

# How sessions work

After login, the session holds:

| Key | Content |
| --- | --- |
| `USER_ID`, `NAME`, `EMAIL`, `COMPANY_ID` | The logged-in user. |
| `ROLE` | The user's main role id: the first of their roles in priority order. |
| `ROLE_IDS` | All the user's role ids, comma-separated. |
| `PERMISSIONS` | The permission JSON, `{"permissions": {"<app>": ["<action>"]}}`. |
| `PERMISSIONS_VERSION` | The stamp the permissions were built from. |
| `PERMISSION_SCOPES` | Where scoped grants reach. |

Read these through `SessionManager` (or `authSession`, which extends it) rather than `$_SESSION`:

```php
$userId = SessionManager::getUserID();
$roleIds = SessionManager::sessionRoleIds();

if (SessionManager::is_superAdmin()) {
    // the user holds the system_admin role
}
```

`is_superAdmin()` and `is_admin()` both mean "holds the `system_admin` role". Since users can hold several roles, they test all the user's roles, not only `ROLE`. `is_supervisor()` and `is_staff()` are deprecated and always return `false`.

## Session lifetime and cookie flags

The session lifetime is `session_expire_seconds` in the `<system>` section of `api/config.<environment>.xml`. The default is `43200` (12 hours). See [Configuration Files](./Configuration%20Files.md) for which file applies.

On every request, `Framework::init()` uses that value for `session.gc_maxlifetime` and the session cookie lifetime. The session cookie is `secure` and `httponly`. No `SameSite` attribute is set, so the browser's default applies.

- The cookie expires `session_expire_seconds` after login. Activity does not extend it.
- The server can also delete the session data after `session_expire_seconds` without requests.
- The cookie is `secure`, so the site must run over HTTPS.

The admin panel uses the same PHP session cookie. Its login stores its own keys (`ADMIN_USER_ID`, `ADMIN_PERMISSIONS` and others) next to the user's.

---

# How to protect a controller

Implement `authenticate()` in your controller and call `auth::appUserPermission()` with the current action, the controller name and the list of public actions:

```php
class myappController extends Controller
{
    public function authenticate(): bool
    {
        $action = $this->getRequest()->getAction();
        $controller = $this->getRequest()->getController();

        // Actions anyone can call, logged in or not
        $publicEndpoints = array('get_public_info');

        return auth::appUserPermission($action, $controller, $publicEndpoints);
    }

    // Render() and the action handlers ...
}
```

For each request, `appUserPermission()`:

1. Returns `true` if the action is in `$publicEndpoints`. No session is needed.
2. Calls `auth::syncSession()`. This rebuilds the session's permissions if an admin changed the user's roles or grants. It ends the session and returns `false` if the user was disabled or removed.
3. Returns `true` if the session's permissions hold the action under the controller name, for example `myapp/get_data` for `api/myapp/get_data`.
4. Also returns `true` if the browser has an admin-panel session whose permission set holds the action under the controller name.

So the controller name in the URL must match the `<user_permissions name>` in your app manifest. See [Roles And Permissions](./Roles%20And%20Permissions.md).

<aside>
⚠️ Always pass an array as `$publicEndpoints`, even an empty one. The parameter defaults to `null`, and passing `null` makes `in_array()` throw a `TypeError`, so the request fails with an error.

</aside>

<aside>
💡 Don't rely on the base `Controller::authenticate()`. It only checks that a session exists, through `SessionManager::validateSession()`, and it requires a non-empty `COMPANY_ID`. It refuses users without a company and checks no permissions.

</aside>

---

# Methods

### auth::appUserPermission

Description:

The **`appUserPermission`** method decides whether the current request may run an action. Call it from your controller's `authenticate()` method.

Syntax:

```php
$allowed = auth::appUserPermission($action, $controller, $publicEndpoints);
```

**Parameters:**

- **`$action`**: The action from the URL, from `$this->getRequest()->getAction()`.
- **`$controller`**: The controller from the URL, from `$this->getRequest()->getController()`.
- **`$publicEndpoints`**: An array of actions that need no login. Pass `array()` when there are none.

**Return Value:**

- **`Boolean`**: `true` if the action is public, or the user session or admin-panel session holds it. `false` otherwise, or when the user has been disabled or removed.

---

### auth::checkPermissions

Description:

The **`checkPermissions`** method checks one action against the user session's permissions. Use it inside an action for an extra check, for example before returning a field only some users may see.

Syntax:

```php
if (auth::checkPermissions('export', 'myapp')) {
    // ...
}
```

**Parameters:**

- **`$permission`**: The action name.
- **`$app_name`**: The `<user_permissions name>` the action belongs to.

**Return Value:**

- **`Boolean`**: `true` if the session's permissions hold the action.

<aside>
💡 `checkPermissions` reads only the user session. Unlike `appUserPermission`, it does not sync the session first or accept admin-panel grants. Within a request that already passed `appUserPermission`, the session is already in sync.

</aside>

---

### auth::syncSession

Description:

The **`syncSession`** method brings the logged-in user's session up to date with the database. It runs at most one query per request; later calls return the first result. `appUserPermission`, `authSession::validateSession` and `auth::scopesFor` call it for you.

It compares the user's current roles and permission stamp with the session's. When they differ, it rebuilds `PERMISSIONS`, `PERMISSION_SCOPES`, `ROLE`, `ROLE_IDS` and `PERMISSIONS_VERSION`. When the user is disabled or removed, it ends the session. Sessions without a `USER_ID` (anonymous, admin panel only, CLI) are left alone.

Syntax:

```php
if (!auth::syncSession()) {
    // the user was disabled or removed; the session is gone
}
```

**Parameters:**

- None.

**Return Value:**

- **`Boolean`**: `false` if the session was ended. `true` otherwise.

---

### authSession::validateSession

Description:

The **`validateSession`** method checks that a user is logged in. It calls `auth::syncSession()` first, so the answer reflects the database as of this request.

Syntax:

```php
$loggedIn = authSession::validateSession();
```

**Parameters:**

- None.

**Return Value:**

- **`Boolean`**: `true` if the session has a user id, name, email, role and permissions.

---

### SessionManager::is_superAdmin

Description:

The **`is_superAdmin`** method checks whether the logged-in user holds the `system_admin` role among any of their roles. **`is_admin`** is the same check.

Syntax:

```php
if (SessionManager::is_superAdmin()) {
    // ...
}
```

**Parameters:**

- None.

**Return Value:**

- **`Boolean`**: `true` if `system_admin` is one of the session user's roles.

---

### SessionManager::sessionRoleIds

Description:

The **`sessionRoleIds`** method returns the ids of every role the logged-in user holds.

Syntax:

```php
$roleIds = SessionManager::sessionRoleIds();
```

**Parameters:**

- None.

**Return Value:**

- **`Array`**: Role ids as integers, from `ROLE_IDS`. Before the session's first sync it holds only `ROLE`.

---

### Session getters

These `SessionManager` methods read one session value and return `null` when it is not set:

| Method | Returns |
| --- | --- |
| `getUserID()` | `USER_ID` |
| `getUserName()` | `NAME` (first and last name) |
| `getEmail()` | `EMAIL` |
| `getCompanyID()` | `COMPANY_ID` |
| `getUserRole()` | `ROLE`, the user's main role id |

`SessionManager::createSessionVar($key, $value)` stores your own value in the session. It returns `false` and stores nothing when the key or the value is empty, so it can't store `0` or `""`. `SessionManager::getSessionVar($key)` reads it back and returns `false` when it is not set.

---
