---
title: Notification
sidebar_label: Notification
---

# Notification

Owner: Nuwan Danushka

# Introduction

Do Framework sends notifications to users in two layers:

- The **`Notification` class** (`api/core/AppModules/Notification/`) stores, reads and updates notifications. It takes a `NotificationModel`.
- The **`xp_notification` system app** wraps that class with helper methods. It also provides the HTTP endpoints, the notification bar in the frontend and the per-role notification settings in the admin panel.

Each app declares the notifications it can send in its XML manifest. Before a notification is stored, the framework checks the recipient's preferences for that notification.

A notification can name three channels: `push`, `email` and `sms`. Only `push` is delivered today. Push here means in-app: the notification is stored in the `notification_system` table and shown in the user's notification bar.

<aside>
⚠️ Email and SMS are not implemented. The email and SMS branches in `Notification::pushNotification` are empty, so enabling those channels sends nothing. Send email yourself with the Email module.

</aside>

Notification status is `1` for unread and `0` for read. The constants are `xp_notification::$NOTIFICATION_STATUS_UNREAD` and `xp_notification::$NOTIFICATION_STATUS_READ`.

The framework creates the notification tables when it initializes the database, through `Notification::initializeNotification()`. Apps don't need to create them.

---

# How to declare notifications

Add a `<user_notifications>` block to your app's XML manifest (for example `api/apps/myapp/myapp.xml`).

```xml
<user_notifications>
    <category name="orders" display_name="Orders">
        <notification name="order_shipped" display_name="Order shipped" description="Sent when an order ships" default_enabled="true">
            <email active="false"/>
            <push active="true"/>
            <sms active="false"/>
        </notification>
    </category>
</user_notifications>
```

- `<category>` groups notifications in the admin panel. It needs a `name` and a `display_name`.
- `<notification>` needs a `name`, which you pass as `$notification_name` when you send it, and a `display_name`. The optional `description` is shown in the admin panel.
- `default_enabled="true"` turns the notification on for every role by default. With any other value, it stays off until an admin turns it on for a role.
- `<email>`, `<push>` and `<sms>` set each channel's default with `active="true"` or `active="false"`.

---

# How preferences resolve

Preferences are stored at two levels: one set per role and one set per user. Only the user's set is checked when a notification is sent.

1. **Manifest defaults.** When an app is installed or updated as a package from the admin panel, each notification with `default_enabled="true"` is added to every role's preferences. Each channel is enabled according to its `active` attribute. Choices an admin already made for a role are kept. Reinitializing an app does not add its notifications.
2. **Role settings (admin panel).** The admin panel's notification settings page lists every app's notifications for each role. When an admin saves the page, the role preferences are stored and copied to every user in each role.
3. **User preferences.** Each user has one preferences record, copied from their role's preferences when the user is created or updated, and again whenever role preferences are saved. There is no endpoint for users to change their own preferences.

When you send a notification, the framework looks up the recipient's record. If the record has no entry for the app and notification name, nothing is stored and the call still reports success. If the entry exists, each enabled channel is delivered.

<aside>
⚠️ Roles created after the framework was set up have no stored role preferences. Saving them in the admin panel updates the role's existing users, but the role settings themselves are not saved. Users added to that role later get no preferences, so they receive no notifications.

</aside>

---

# How to send a notification to a user

1. Grant your app access to the notification app. `AppManager::CreateAppInstance('xp_notification')` returns `false` unless the `<app_permissions>` block in `api/apps/xp_notification/xp_notification.xml` lists your app:

    ```xml
    <permission app_name="myapp" />
    ```

    A framework update replaces `<app_permissions>` with the packaged copy, so this edit is lost on the next update. The direct `Notification` call shown below needs no manifest change.

2. Build the click action as JSON. The notification bar supports one action, `go_to_path`, which opens a frontend route. The column holds 255 characters.

    ```php
    $action = json_encode(array('action' => 'go_to_path', 'value' => '/orders'));
    ```

3. Send it:

    ```php
    $notificationApp = AppManager::CreateAppInstance('xp_notification');

    $result = $notificationApp->pushNotificationForUser(
        $user_id,
        'myapp',
        1,
        'order_shipped',
        'Order shipped',
        'fa-truck',
        'Order 1042 is on its way.',
        xp_notification::$NOTIFICATION_STATUS_UNREAD,
        $action
    );

    if (!$result['success']) {
        // $result['message'] says what went wrong
    }
    ```

To skip the app permission, build a `NotificationModel` and call the `Notification` class directly. It does the same preference check:

```php
$notification = new NotificationModel(array(
    'user_id' => $user_id,
    'app_name' => 'myapp',
    'type' => 1,
    'notification_name' => 'order_shipped',
    'title' => 'Order shipped',
    'icon' => 'fa-truck',
    'description' => 'Order 1042 is on its way.',
    'status' => 1,
    'action' => $action,
));

$result = Notification::pushNotification($notification);
```

<aside>
💡 The title may contain only English letters, digits, spaces and these characters: `. , ; : ! ? @ # $ % ^ & * ( ) _ + - / < =`. An apostrophe, a quote or an accented letter fails with "Following fields are invalid: title". The description has no such limit. `type` must be a positive whole number.

</aside>

---

# How to send a notification to a role or a list of users

To notify every user whose role is `$role_id`, use `pushNotificationForUsersRoles`. It takes the same arguments as `pushNotificationForUser`, with the role ID first.

```php
$result = $notificationApp->pushNotificationForUsersRoles($role_id, 'myapp', 1, 'order_shipped', 'Order shipped', 'fa-truck', 'Order 1042 is on its way.', 1, $action);
```

To notify a list of users, use `Notification::pushNotificationBatch`. Each user's preferences are checked, and only users with push enabled for the notification receive it.

```php
$result = Notification::pushNotificationBatch($notification, array(4, 7, 12));
```

---

# Endpoints

All endpoints are under `/api/xp_notification/`. Except for `init_app`, they need a logged-in user whose role has the matching `xp_notification` permission (for example `list`), or an admin panel session with that permission.

| Method | Endpoint | What it does |
| --- | --- | --- |
| GET | `list` | Lists the current user's notifications, grouped as `Today`, `Yesterday`, `Last 7 days`, a month, or a year and month. |
| GET | `list_new` | Lists the current user's unread notifications, grouped the same way. |
| POST | `add` | Adds a notification. Send the `NotificationModel` fields (`user_id`, `app_name`, `type`, `notification_name`, `title`, `description`, `icon`, `action`). Status is always set to unread. |
| POST | `remove` | Deletes the notification with the given `id`. |
| POST | `update` | Updates the notification with the given `id`. Send the fields to change. |
| POST | `mark_read` | Toggles the notification with the given `id` between read and unread. |
| POST | `mark_read_all` | Marks all of the current user's notifications as read. |
| POST | `clear_all` | Deletes the current user's **read** notifications. Unread ones are kept. |
| GET | `get_notification_types_from_apps` | Admin panel. Lists the notifications declared by every app, with each channel's `active` default. |
| GET | `get_notifications_for_user_roles` | Admin panel. Returns the stored preferences of each role, keyed by role name. |
| POST | `save_user_role_notifications` | Admin panel. Saves role preferences from `notification_settings`, a JSON string keyed by role name, then app, notification and channel. Also copies them to the users in each role. |
| POST | `init_app` | Public. Creates the notification app's own tables from its manifest if they don't exist. |

<aside>
⚠️ `add`, `remove`, `update` and `mark_read` don't check that the notification belongs to the caller. Any user with those permissions can send to any user ID, or change or delete any notification by its `id`. The default roles get all of them at setup. Remove them from roles that don't need them.

</aside>

---

# Methods

## xp_notification app

Get the instance with `AppManager::CreateAppInstance('xp_notification')`. Both methods are instance methods.

### pushNotificationForUser

Description:

The **`pushNotificationForUser`** method sends a notification to one user, if that user's preferences allow it.

Syntax:

```php
$result = $notificationApp->pushNotificationForUser($user_id, $app_name, $type, $notification_name, $title, $icon, $description, $status, $action);
```

**Parameters:**

- **`$user_id`**: The recipient's user ID. Required.
- **`$app_name`**: The sending app's name. Required.
- **`$type`**: A positive whole number your app uses to tell kinds of notification apart. Required.
- **`$notification_name`**: The `name` of a `<notification>` in the app's `<user_notifications>` block. Required.
- **`$title`**: The title. Required. See the character limits above.
- **`$icon`**: A Font Awesome icon class, such as `fa-truck`.
- **`$description`**: The message. Required.
- **`$status`**: `1` for unread, `0` for read. Pass `1` for a new notification.
- **`$action`**: The click action as a JSON string.

**Return Value:**

- **`Array`**: `success` (boolean) and `message` (string). On failure, `message` lists the empty or invalid fields.
- **`false`**: If an exception is thrown.

---

### pushNotificationForUsersRoles

Description:

The **`pushNotificationForUsersRoles`** method sends a notification to every user whose role is `$role_id`. Users whose preferences don't allow it are skipped.

Syntax:

```php
$result = $notificationApp->pushNotificationForUsersRoles($role_id, $app_name, $type, $notification_name, $title, $icon, $description, $status, $action);
```

**Parameters:**

- **`$role_id`**: The role ID. Required.
- The other parameters are the same as for `pushNotificationForUser`.

**Return Value:**

- **`Array`**: `success` and `message`, when the role has users.
- **`true`**: When the role has no users.
- **`false`**: When `$role_id` is empty or an error occurs.

---

## Notification class

All methods are static except `initializeNotification`. They take a `NotificationModel` (see below) and, unless noted, return an array with `success` (boolean) and `message` (string).

### pushNotification

Description:

The **`pushNotification`** method stores a notification for one user after checking the user's preferences.

Syntax:

```php
$result = Notification::pushNotification($notification);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `user_id`, `app_name`, `type`, `notification_name`, `title` and `description` set. Also set `status`, because the column doesn't accept an empty value.

**Return Value:**

- **`Array`**: `success` and `message`. `success` is also `true` when the user's preferences block the notification and nothing is stored.

---

### pushNotificationBatch

Description:

The **`pushNotificationBatch`** method stores the same notification for several users. It keeps only the users with push enabled for the notification, then inserts in batches of `notification_batch_size` (a setting in the config's `notification` section, 100 by default).

Syntax:

```php
$result = Notification::pushNotificationBatch($notification, $user_ids);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `app_name`, `type`, `notification_name`, `title`, `description` and `status` set. `user_id` is not needed.
- **`$user_ids`**: An array of user IDs, such as `array(1, 2, 3)`.

**Return Value:**

- **`Array`**: `success` and `message`.

---

### markNotification

Description:

The **`markNotification`** method toggles a notification's status: unread becomes read, and read becomes unread.

Syntax:

```php
$result = Notification::markNotification($notification);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `id` set.

**Return Value:**

- **`Array`**: `success` and `message`. `message` is "Notification not exist" if the ID is not found.

---

### markAllAsReadNotification

Description:

The **`markAllAsReadNotification`** method marks all of a user's notifications as read.

Syntax:

```php
$result = Notification::markAllAsReadNotification($notification);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `user_id` set.

**Return Value:**

- **`Array`**: `success` and `message`.

---

### removeNotification

Description:

The **`removeNotification`** method deletes one notification.

Syntax:

```php
$result = Notification::removeNotification($notification);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `id` set.

**Return Value:**

- **`Array`**: `success` and `message`.

---

### removeNotificationByUser

Description:

The **`removeNotificationByUser`** method deletes all of a user's notifications.

Syntax:

```php
$result = Notification::removeNotificationByUser($notification);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `user_id` set.

**Return Value:**

- **`Array`**: `success` and `message`.

---

### removeAllNotifications

Description:

The **`removeAllNotifications`** method empties the notification table. It deletes every user's notifications.

Syntax:

```php
$result = Notification::removeAllNotifications();
```

**Return Value:**

- **`Array`**: `success` and `message`.

---

### getAllNotifications

Description:

The **`getAllNotifications`** method returns the notifications of all users.

Syntax:

```php
$result = Notification::getAllNotifications($page, $records_per_page);
```

**Parameters:**

- **`$page`** (optional): The number of rows to skip. See the note below.
- **`$records_per_page`** (optional): The maximum number of rows to return.

**Return Value:**

- **`Array`**: `success`, `message` and, when rows are found, `list`.

<aside>
💡 In `getAllNotifications`, `getNotificationsByUser` and `getNotificationsByCompany`, `$page` is used as the row offset, not as a page number. To get page 3 of 20 rows, pass `40` and `20`. Pagination applies only when both values are set.

</aside>

---

### getNotificationsByUser

Description:

The **`getNotificationsByUser`** method returns a user's notifications. Each row also has the `first_name` and `image` of the user who created it.

Syntax:

```php
$result = Notification::getNotificationsByUser($notification, $page, $records_per_page);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `user_id` set.
- **`$page`**, **`$records_per_page`** (optional): As for `getAllNotifications`.

**Return Value:**

- **`Array`**: `success`, `message` and, when rows are found, `list`.

---

### getNotificationsByCompany

Description:

The **`getNotificationsByCompany`** method returns the notifications stored with a company ID.

Syntax:

```php
$result = Notification::getNotificationsByCompany($notification, $page, $records_per_page);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `company_id` set.
- **`$page`**, **`$records_per_page`** (optional): As for `getAllNotifications`.

**Return Value:**

- **`Array`**: `success`, `message` and, when rows are found, `list`.

---

### getNotificationsByID

Description:

The **`getNotificationsByID`** method returns one notification.

Syntax:

```php
$result = Notification::getNotificationsByID($notification);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `id` set.

**Return Value:**

- **`Array`**: `success`, `message` and, when found, `list` holding the notification row.

---

### updateNotification

Description:

The **`updateNotification`** method changes the fields you set on the model. Fields left empty are not changed.

Syntax:

```php
$result = Notification::updateNotification($notification);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `id` set, plus any of `type`, `app_name`, `title`, `icon`, `description`, `action` and `status`.

**Return Value:**

- **`Array`**: `success` and `message`.

<aside>
💡 A status of `0` counts as empty, so `updateNotification` can't mark a notification as read. Use `markNotification` instead.

</aside>

---

### checkNotificationExist

Description:

The **`checkNotificationExist`** method is meant to check whether a notification ID exists.

Syntax:

```php
$result = Notification::checkNotificationExist($notification);
```

**Parameters:**

- **`$notification`**: A `NotificationModel` with `id` set.

**Return Value:**

- **`Array`**: Its `success` and `message` are always empty.

<aside>
⚠️ This method doesn't work: it reads an array from a value that is a row count. Use `getNotificationsByID` and check `success`.

</aside>

---

### initializeNotification

Description:

The **`initializeNotification`** method creates the `notification_system` and `notification_system_user_preferences` tables if they don't exist. The framework calls it when it initializes the database. It is an instance method.

Syntax:

```php
$notification = new Notification();
$notification->initializeNotification();
```

**Return Value:**

- None.

---

### update_user_preference

Description:

The **`update_user_preference`** method replaces a user's whole preferences record. The record is overwritten again when the user is updated or when an admin saves role settings.

Syntax:

```php
$list = json_encode(array('notifications' => array(
    'myapp' => array('order_shipped' => array('push' => array('enabled' => true))),
)));

$result = Notification::update_user_preference($user_id, $list, $updating_user_id);
```

**Parameters:**

- **`$user_id`**: The user whose preferences to replace.
- **`$notification_string`**: The preferences as a JSON string, keyed by app, notification name and channel.
- **`$updating_user_id`**: The user ID recorded as the editor.

**Return Value:**

- **`Boolean`**: `true` on success, `false` on failure.

---

## NotificationModel

Pass an array to the constructor, or use the setters. `xp_notificationModel` extends `NotificationModel` and adds `role`.

| Array key | Setter | Notes |
| --- | --- | --- |
| `id` | `setId` | Notification ID. Digits only. |
| `user_id` | `setUser_id` | Recipient. Digits only. |
| `company_id` | `setCompany_id` | Optional. Digits only. |
| `app_name` | `setApp_name` | Sending app. |
| `type` | `setType` | Positive whole number. |
| `notification_name` | `setNotificationName` | Name from `<user_notifications>`. Used for the preference check, not stored. |
| `title` | `setTitle` | See the character limits above. |
| `icon` | `setIcon` | Font Awesome class. |
| `description` | `setDescription` | The message. |
| `action` | `setAction` | JSON string, up to 255 characters. |
| `status` | `setStatus` | `1` unread, `0` read. |
| `created_date` | `setCreated_date` | Set by the framework when stored. |
| `created_by` | `setCreatedBy` | The logged-in user is stored when the notification is created. |
| `role` | `setRole` | `xp_notificationModel` only. Used by `pushNotificationForUsersRoles`. |

---
