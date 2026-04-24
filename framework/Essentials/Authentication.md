# Authentication

Owner: Nuwan Danushka

# Introduction

In the Do Framework, permissions persist within the session post-login, while the frontend framework utilizes local storage to retain user permissions. Initially, permissions are stored in the users' table, and there exist permission templates for each role. When a user creates a role, the permissions are defined by the role and subsequently updated in the user's permissions.

# How authentication works on the endpoint

When a user sends a request to the API endpoint, the **`Auth::appUserPermission`** function is triggered to authenticate the request. Let's break down the process:

**Understanding the Endpoint Structure:**

- The endpoint URL, such as **`https://www.example.com/api/users/add`**, is comprised of:
    - **`www.example.com`**: Location of the application.
    - **`users`**: Controller responsible for handling user-related operations.
    - **`add`**: Specific action within the **`users`** controller, indicating the addition of a new user.
    

**Checking Public Endpoints:**

- The first check is performed against the list of public endpoints.
- If the requested action is found in the **`public_endpoints_Ary`**, authentication is granted.
    
    ```php
    $public_endpoints_Ary = array('login');
    Auth::appUserPermission($get_action, $get_controller, $public_endpoints_Ary);
    ```
    

**Session-based Permission Check:**

- If the requested action is not a public endpoint, the system consults the user's session permissions.
- These permissions are stored in JSON format in the **`permission`** field of the user table.
    
    This is what the permission JSON looks like:
    
    ```php
    {
       "permissions":{
          "user":[
             "add",
             "remove",
             "list",
             // Other actions
          ],
          // Other app's permissions
       }
    }
    ```
    

**Authentication Process:**

- If the requested action is found in the user's permission list, authentication is granted.

**User Permission Management:**

- Each user has a set of permissions stored in the **`permission`** field of the user table.
- Permissions are structured in JSON format, and categorized by user roles.

<aside>
💡 The default permissions for each role are stored in the database tables. Upon user creation, these permissions are automatically copied to the user's profile based on their assigned role.

</aside>

This authentication process ensures that only authorized users can access specific endpoints within the API, maintaining the security and integrity of the application.

---

# How to access permissions in the frontend.

Let's explore how we can utilize permissions in the front end:

<aside>
💡 User permissions are stored in the local storage along with other user information.

</aside>

**Checking User Permissions:**

- Permissions can be checked by invoking the following function:

```php
const permissions = { name: app_name, action: action};
XP.checkPermission(permissions); // Returns true or false
```

**Wrapping the Framework Function in Vue Method:**

- For enhanced convenience, we can encapsulate the framework function within a Vue method as follows:
    
    ```php
    
    methods: {
       hasPermission(app_name, action) {
          return XP.checkPermission({ name: app_name, action: action });
       },
       // Other Vue methods
    }
    ```
    

**Usage of `v-if` Directive:**

- We can utilize the **`v-if`** directive to conditionally display elements based on user permissions.
- For instance, in the following example, the "Edit user" button will only be visible to users who have permission to edit users:
    
    ```php
    <a v-if="hasPermission('user','edit_users')" class="action-btns" @click="editUser(item)">
    	<span class="info-tip action-btns" data-tip="Edit user">
    			<i class="fas fa-user-edit"></i>
    	</span>
    </a>
    ```
    

By incorporating these methods, we ensure that user interface elements are displayed or hidden based on the user's permissions, enhancing the application's security and user experience.

---

# How to add permissions to the app.

Permissions can be categorized into two types: those applicable to the application itself and those specific to the admin panel.

## User App Permissions

1. **Navigate to the Backend App Folder:**
    - Open the backend app folder of your application.
2. **Edit the App Configuration File:**
    - Locate and open the **`"yourappname.xml"`** file.
3. **Add a New User Permission:**
    - Within the **`<user_permissions>`** section, add a new permission record.
    - Define the permission name and a display name.
    - Optionally, set **`auto_update="true"`** if this is a default permission for the app, ensuring users are granted necessary permissions automatically.
        
        ```xml
        <user_permissions name="yourappname">
            <category name="basic_permissions">
                <permission display_name="Explain what it does" name="permission_name" auto_update="true"/>	
            </category>
        </user_permissions>
        ```
        

---

## Admin Panel Permissions

1. **Navigate to the Backend App Folder:**
    - Open the backend app folder of your application.
2. **Edit the App Configuration File:**
    - Locate and open the **`"yourappname.xml"`** file.
3. **Add a New Admin Panel Permission:**
    - Within the **`<admin_panel_permissions>`** section, add a new permission record.
    - Define the permission name and a display name.
    - Optionally, set **`auto_update="true"`** if this is a default permission for the system admin app, ensuring users are granted necessary permissions automatically.
        
        ```xml
        <admin_panel_permissions name="yourappname">
            <category name="basic_permissions">
                <permission display_name="Explain what it does" name="permission_name" auto_update="true"/>	
            </category>
        </admin_panel_permissions>
        ```
        

---

# **How to Enable Defined Permissions in the App**

1. **Navigate to the Admin Panel:**
    - Access the admin panel of your application.
2. **Go to "Roles & Permissions":**
    - Locate and access the "Roles & Permissions" section within the admin panel.
3. **Find the Relevant App Name or Section:**
    - Look for the app name or section specified in the **`app.xml`** configuration file.
4. **Locate the Defined Permission:**
    - Within the specified section, find the permission you declared earlier.
5. **Assign Permissions to User Roles:**
    - Add a tick/checkmark for the user roles that should have access to the permission.
6. **Save Permissions:**
    - Press the "Save Permissions" button to update the permissions.
    

By following these steps, you will effectively enable the permissions defined in your application. Ensure that the roles granted permission align with the roles assigned to users who require access. Once saved, users with the granted roles will have permission to perform the specified actions.

---

# **How to Enable Defined Permissions in the  Admin Panel**

1. **Navigate to the Admin Panel:**
    - Access the admin panel of your application.
2. **Go to "Settings":**
    - Locate and access the "Settings" section within the admin panel.
3. **Find the “Permission” Sub-settings:**
    - Look for the permission.
4. **Locate the Defined Permission:**
    - Within the specified section, find the permission you declared earlier.
5. **Assign Permissions to Admin Panel:**
    - Add a tick/checkmark to grant access to the permission.
6. **Save Permissions:**
    - Press the "Update" button to save the permissions.
    

By following these steps, you will effectively enable the permissions defined in your application. Ensure that the admin panel requires access to the granted permissions. Once saved, the admin user will have permission to perform the specified actions.

---