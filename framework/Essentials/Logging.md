# Logging

Owner: Nuwan Danushka

# Log Types

1. **LOG_WARN** (Warning): 

- Indicates a potential issue or concern that might need attention but does not necessarily halt the program's execution.

2. **LOG_ERROR**: 

- Indicates a significant problem that occurred during the execution of the program, which may affect its functionality.

3. **LOG_NOTICES** (Notice): 

- Provides general information about the program's operation, often used for informational purposes.

4. **LOG_EXCEPTION**: 

- Marks an unexpected event or error that caused the program to deviate from its normal flow of execution.

5. **LOG_CRITICAL**: 

- This signifies a severe error or problem that requires immediate attention as it may lead to system failure.

---

# How To Log Errors

Logging errors is typically achieved by utilizing the try-catch method to capture exceptions. Within our framework, we employ a custom logging method to handle exceptions.

```php
Loging::log($e->getMessage(), 'class name ', LOG_WARN)
```

The parameters for this method include:

- **`text`**: The error message or description.
- **`class name`**: The name of the class where the error occurred.
- **`log type`**: The type of log entry
    - Types
        - `LOG_ERROR`
        - `LOG_WARN`
        - `LOG_NOTICES`
        - `LOG_EXCEPTION`
        - `LOG_CRITICAL`

Here's an example of how this logging method is used within a try-catch block:

```php
try {
    // Code block where errors might occur
} catch (Exception $e) {
    System::errorlog(Loging::log($e->getMessage(), 'class name ', LOG_WARN));
    return;
}
```

In this example, when an exception is caught, the error message along with the class name is logged using the **`Loging::log()`** method, and the log entry is marked as a warning. Finally, the error log is handled by the **`System::errorlog()`** method.

---

# How To Enable Mail Errors

Here are steps to enable email notifications for errors:

1. **Access the Admin Panel**: 
    - Log in to your system's admin panel.
2. **Navigate to Settings**: 
    - Look for the "Settings" section within the admin panel.
3. **Find Logs Settings**: 
    - Once you're in the settings, locate the logs. It is labeled as "Logs".
4. **Select Mail Error Option**: 
    - Within the logs settings, there should be a selection for mailing errors. Find it and select it.
5. **Choose "Yes"**:
    - When you find the mail error option, there will be a dropdown. Choose the option “Yes”
6. **Select Error Types**: 
    - Checkbox option to choose which types of errors you want to receive emails for. Select the error types you're interested in.
7. **Update Settings**: 
    - After choosing your preferences, Click the button update to apply the changes.
    

Now, whenever an error occurs within the framework, you'll receive an email notification with the details of the error.

---

# **How To View Logs**

To access and view logs, follow these steps:

1. **Log in to Admin Panel**: 
    - Access the admin panel using your credentials.
2. **Navigate to Logs**: 
    - Look for a section or tab labeled "Logs" within the admin panel interface.
3. **View Error Logs**: 
    - Once in the logs section, you'll typically find error logs listed along with details such as class name, message, type, date, and time.

By following these steps, you can easily locate and review error logs, allowing you to diagnose issues and monitor system behavior effectively.

---

# Access Log

An access log is a system mechanism that records user actions within a Do framework. It stores data such as device information, IP addresses, messages, and actions performed by users. This log helps track user activity for troubleshooting, security analysis, and auditing purposes.

## How To Log Access Log

To log access activities, you can utilize the provided function as follows:

```php
System::acesslog(Loging::AccessLog('Create Task', 'Create', 'Task Create Successfully'));
```

### **Parameters:**

- **`$action`**: Pass the specific action that triggered the logging, for example, 'create user'.
- **`$actionType`**: Specify the type of action performed, like 'create', 'delete', or 'update'.
- **`$message`**: Include a descriptive message indicating the outcome of the action, for instance, 'User Created Successfully'.

This logging mechanism allows you to efficiently track user interactions and outcomes within the framework.