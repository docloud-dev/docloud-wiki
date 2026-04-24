# Notification

Owner: Nuwan Danushka

# Notification App

## Introduction

The "Notification App" is a default system within the Do Framework designed to efficiently manage notifications. This app enables users to send customized notifications to individuals or groups through various applications. The flexibility of customization allows for tailoring notifications according to specific needs, whether it's delivering important updates, alerts, or personalized messages. The "Notification App" provides a seamless solution for keeping users informed, with a user-friendly interface and adaptability that makes it a valuable tool for enhancing communication within the Do Framework environment.

User notification preferences are stored in the database. By default, notifications are defined in the app's XML configuration with the `default` property set to `true`, applying to all users initially.

Notification preferences can be customized in several ways:

1. **Admin Panel:** Admins can adjust notification settings globally.
2. **Role-Based Settings:** Specific notification preferences can be set for each user role in adminpanel.
3. **User Settings:** Individual users can personalize their notification preferences in the app settings, with their choices recorded separately in the database.

---

## Usage

### Push Notification for a User

This is how you can send a push notification to a user through an app. Let's break it down step by step:

1. **Define Action:**
    
    ```php
    $action = array('action' => 'go_to_path', 'value' => '/user');
    $action = json_encode($action);
    ```
    
    Here, an action is defined as an associative array with two key-value pairs: 'action' and 'value'. You can define any action and its value depending on the developer's requirements. In this example, we are instructing the system to change the route when the user clicks the notification. This action is then converted to a JSON string using **`json_encode`** to pass it as a parameter.
    
2. **Create Notification App Instance:**
    
    ```php
    $notificationApp = AppManager::CreateAppInstance('xp_notification');
    ```
    
    An instance of the **`xp_notification`** app is created using the **`AppManager::CreateAppInstance`** method.
    
3. **Push Notification for User:**
    
    ```php
    $notificationApp->pushNotificationForUser($user_id, $app_name, $type, $title, $notification_icon, $notification_message, $status, $action);
    ```
    
    Finally, a push notification is sent to a specific user. The parameters are as follows:
    
    - **`$user_id`**: User ID of the recipient.
    - **`$app_name`**: Name of the app sending the notification.
    - **`$type`**: Notification type (any integer number as needed).
    - **`$title`**: Title of the notification.
    - **`$notification_icon`**: Icon for the notification.
    - **`$notification_message`**: Message to be included in the notification.
    - **`$status`**: 1 for unread, 0 for read.
    - **`$action`**: The previously defined action in JSON format.
    

In summary, this code is a simplified representation of how to send a push notification to a user through the **`xp_notification`** app, including details such as user ID, app name, notification type, notification status, title, icon, message, and an associated action to be performed when the user interacts with the notification (in this case, navigating to the '/user' path).

---

## Functions

### pushNotificationForUser

### Description:

The **`pushNotificationForUser`** function is designed to send notifications to specific users.

Syntax:

```php
pushNotificationForUser($user_id, $app_name, $type, $title, $icon, $description, $status, $action)
```

**Parameters**:

- **`$user_id`**: The identifier of the target user.
- **`$app_name`**: The name of the application triggering the notification.
- **`$type`**: The type of notification.
- **`$title`**: The title of the notification.
- **`$icon`**: The icon associated with the notification.
- **`$description`**: The detailed description accompanying the notification.
- **`$status`**: The status of the notification.
- **`$action`**: The action to be taken upon interacting with the notification.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function streamlines the process of notifying specific users, offering a straightforward and organized approach to managing notifications within an application.

### pushNotificationForUsersRoles

Description:

The **`pushNotificationForUsersRoles`** function is created to send notifications to users belonging to a specific role.

Syntax:

```php
NotificationForUsersRoles($role_id, $app_name, $type, $title, $icon, $description, $status, $action)
```

**Parameters**:

- **`$role_id`**: The identifier of the target role.
- **`$app_name`**: The name of the application triggering the notification.
- **`$type`**: The type of notification.
- **`$title`**: The title of the notification.
- **`$icon`**: The icon associated with the notification.
- **`$description`**: The detailed description accompanying the notification.
- **`$status`**: The status of the notification.
- **`$action`**: The action to be taken upon interacting with the notification.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function facilitates the process of notifying users based on their assigned roles, providing a clear and organized way to manage notifications within an application.

---

## **Endpoints**

### **GET**

- **list**
    - List all notifications belonging to a user.
- **list_new**
    - List new notifications belonging to a user.

### **POST**

- **add**
    - Add a new notification.
- **remove**
    - Remove a notification.
- **update**
    - Update a notification.
- **mark_read**
    - Mark a notification as read.
- **clear_all**
    - Delete all notifications belonging to a user.
- **mark_read_all**
    - Mark all notifications as read.

These endpoints provide a comprehensive set of functionalities for managing notifications within the system. Developers can use these endpoints to retrieve lists of notifications, add new ones, remove or update existing notifications, mark them as read, and perform bulk actions such as clearing all notifications or marking all as read. The clear naming convention makes it easy to understand the purpose and functionality of each endpoint in the context of the Notification App.

---

# Notification Module

## Introduction

The "Notification Module" in the Do Framework efficiently manages personalized notifications, allowing users to stay informed. With customization options for various needs, it delivers updates, alerts, and personalized messages seamlessly. The user-friendly interface enhances communication within the Do Framework environment.

---

## Functions

---

### pushNotification

### Description:

The **`pushNotification`** function is designed for sending notifications efficiently.

Syntax:

```php
pushNotification(NotificationModel $notification)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`user_id`**
    - **`app_name`**
    - **`title`**
    - **`type`**
    - **`description`**
    
    (All properties are required)
    

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function streamlines the process of pushing notifications, allowing for seamless integration within your applications.

---

### pushNotificationBatch

### Description:

The **`pushNotificationBatch`** function is designed to send notifications in batches.

The **`$user_ids`** array should adhere to the following format:

```php
$user_ids = array(1,2,3,4,5);
```

Syntax:

```php
pushNotificationBatch(NotificationModel $notification, array $user_ids)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`user_id`**
    - **`app_name`**
    - **`title`**
    - **`type`**
    - **`description`**
    
    (All properties are required)
    
- **`$user_ids`**: The user id list.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function streamlines the process of notifying specific users, offering a straightforward and organized approach to managing notifications within an application.

---

### markAsReadNotification

### Description:

The **`markAsReadNotification`** function is designed to mark as read.

Syntax:

```php
markAsReadNotification(NotificationModel $notification)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`user_id`**
    
    (All properties are required)
    

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function streamlines the process of marking notifications as read, providing a convenient method for managing notification status within your application.

---

### markAllAsReadNotification

### Description:

The **`markAllAsReadNotification`** function is designed to mark all notifications of a user as read.

Syntax:

```php
markAllAsReadNotification(NotificationModel $notification)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`user_id`**
    
    (All properties are required)
    

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function streamlines the process of marking all notifications of a user as read, providing a convenient method for managing notification statuses within your application.

---

### removeNotification

### Description:

The **`removeNotification`** This function provides a convenient way to remove specific notifications for a user, aiding in the efficient management of notification data within your application.

Syntax:

```php
removeNotification(NotificationModel $notification)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`user_id`**
    
    (All properties are required)
    

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a convenient way to remove specific notifications for a user, aiding in the efficient management of notification data within your application.

---

### removeNotificationByUser

### Description:

The **`removeNotificationByUser`** function is designed to send notifications to specific users.

Syntax:

```php
removeNotificationByUser(NotificationModel $notification)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`user_id`**
    
    (All properties are required)
    

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function streamlines the process of notifying specific users, offering a straightforward and organized approach to managing notifications within an application.

---

### removeAllNotifications

### Description:

The **`removeAllNotifications`** function is designed to remove all notifications.

Syntax:

```php
removeAllNotifications()
```

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a convenient and efficient way to remove all notifications, aiding in the comprehensive management of notification data within your application.

---

### getAllNotifications

### Description:

The **`getAllNotifications`** function is designed to retrieve all notifications.

Syntax:

```php
getAllNotifications($page = null, $records_per_page = null)
```

**Parameters**:

- **`$page`** (optional): The page number for paginated results.
- **`$records_per_page`** (optional): The number of records per page for paginated results.

**Returns:**

- An array of notifications if the operation is successful.
- **`false`** if the operation is not successful.

This function facilitates the retrieval of all notifications, providing options for pagination to handle large sets of data in a convenient manner within your application.

---

### getNotificationsByUser

### Description:

The **`getNotificationsByUser`** function is designed to retrieve notifications belonging to a specific user.

Syntax:

```php
pushNotificationForUsergetNotificationsByUser(NotificationModel $notification, $page = null, $records_per_page = null)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`user_id`**
    
    (All properties are required)
    
- **`$page`** (optional): The page number for paginated results.
- **`$records_per_page`** (optional): The number of records per page for paginated results.

**Returns:**

- An array of notifications if the operation is successful.
- **`false`** if the operation is not successful.

This function facilitates the retrieval of notifications for a specific user, providing options for pagination to handle large sets of data in a convenient manner within your application.

---

### getNotificationsByCompany

### Description:

The **`getNotificationsByCompany`** function is designed to retrieve notifications by company ID.

Syntax:

```php
getNotificationsByCompany(NotificationModel $notification, $page = null, $records_per_page = null)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`company_id`**
    
    (All properties are required)
    
- **`$page`** (optional): The page number for paginated results.
- **`$records_per_page`** (optional): The number of records per page for paginated results.

**Returns:**

- An array of notifications if the operation is successful.
- **`false`** if the operation is not successful.

This function facilitates the retrieval of notifications by company ID, providing options for pagination to handle large sets of data in a convenient manner within your application.

---

### checkNotificationExist

### Description:

The **`checkNotificationExist`** function is designed to check if a notification exists.

Syntax:

```php
checkNotificationExist(NotificationModel $notification)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`id`**
    
    (All properties are required)
    

**Returns:**

- **`1`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a convenient way to check the existence of a notification, returning a specific value to indicate success or failure within your application.

---

### updateNotification

### Description:

The **`updateNotification`** function is designed to update a notification.

Syntax:

```php
updateNotification(NotificationModel $notification)
```

**Parameters**:

- **`id`**: The identifier of the notification.
- **`$app_name`** (optional): The name of the application triggering the notification.
- **`$type`** (optional): The type of notification.
- **`$title`** (optional): The title of the notification.
- **`$icon`** (optional): The icon associated with the notification.
- **`$description`** (optional): The detailed description accompanying the notification.
- **`$status`** (optional): The status of the notification.
- **`$action`** (optional): The action to be taken upon interacting with the notification.

**Returns:**

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a flexible way to update various properties of a notification, allowing for efficient management and customization within your application.

---

### getNotificationsByID

### Description:

The **`getNotificationsByID`** function is designed to retrieve notifications by their unique identifier.

Syntax:

```php
getNotificationsByID(NotificationModel $notification)
```

**Parameters**:

- **`$notification`**: An instance of the **`NotificationModel`** class containing the necessary information for the notification.
    - **`id`**
    
    (All properties are required)
    

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function streamlines the process of retrieving notifications based on their unique identifier, providing a straightforward method for accessing specific notifications within your application.

---

### initializeNotification

### Description:

The **`initializeNotification`** function is designed to create a table for storing notifications.

Syntax:

```php
initializeNotification()
```

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function streamlines the process of initializing a notification table, providing a convenient way to set up the necessary database structure for managing notifications within your application.

---