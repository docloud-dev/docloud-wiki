# Get Started

Owner: Thilina Deepal

# Development Environment Requirements

## **Supported PHP Versions.**

- PHP : 7.2 or Above

### **Required PHP Extensions:**

**Core Extensions:**

- bcmath
- ctype
- date
- filter
- hash
- iconv
- json
- libxml
- mbstring
- session

**Data Handling Extensions:**

- curl
- exif
- fileinfo
- gettext

**Graphics and Multimedia Extensions:**

- gd

**Internationalization Extensions:**

- intl

**Database Extensions:**

- mysqli
- PDO
- pdo_mysql
- pdo_sqlite

**Security Extensions:**

- openssl

**Web and Networking Extensions:**

- Phar
- redis
- session

## **Supported server software.**

- Apache 2.4
- OpenLitespeed 1.7.x + or LSWS 6.0 + (Not Officially tested on Other webservers )

## **Dependencies.**

- MySQL
  - Server type: MariaDB

## SSL Certificate.

- Security (SSL) : TLS 1.0 or above (not tested)

## .htacess Support

---

# **Set up a Development Environment.**

1. Make sure you meet all the required prerequisites. Afterward, download the framework zip file from the DO Cloud by
2. Next, place the downloaded zip file in the "public_html" directory and extract its contents.
3. Proceed to the next section titled for step-by-step instructions on installing the DoFramework.

---

# Let’s Install Do Framework

1. Go to your domain's /api/admin/ page.
2. Click on "Get Started" on the welcome screen.
3. Check system requirements on the self-check screen.
4. If everything checks out, proceed to "Begin Installation."
5. Choose "Get Started with Docloud" on the next screen.
6. Sign in to your Docloud account.
7. Enter the token if you already have one; if not, create an app with a name and description.
8. Choose either basic or advanced mode.
9. Fill in the required information in the steps form.
   1. If signed in with Docloud, the first step will be skipped in the form.
   2. for more information about the steps and what it means
10. Navigate through the steps and click "Finish Setup" at the end.
11. After that, you'll see a congratulations screen. Click "Login to System Admin" to access the admin panel.

---

# Get started framework installation steps explained

## **Step 1: API Configuration**

In the initial API configuration step, provide essential details for your application. Specify the app name, admin information, email settings, and default time zone. The app URL is automatically generated, and the system email is configured based on your domain. Maintain accuracy in these settings to ensure smooth functionality throughout your application.

<aside>
💡 If you click "Get Started with Docloud" on the Ready for Action! screen, this step will fill in by itself.

</aside>

| Name              | Description                                                                    |
| ----------------- | ------------------------------------------------------------------------------ |
| App Name          | Enter your app's name.                                                         |
| Name of The admin | Provide your name.                                                             |
| Admin Email       | Use your email for admin purposes.                                             |
| App URL           | The app URL is automatically generated from your domain, no need to change it. |
| System Email      | A system email will be created using your domain.                              |
| Time Zone         | Set the timezone to Sri Lanka by default.                                      |
| Charset           | The default charset is UTF-8 for the system.                                   |

## **Step 2:** Apps Support **(Advance Mode Only)**

This configuration step is available in the advanced settings and the application's support settings. Choose the API structure, set the app folder depth, specify the app directory, and configure email and storage preferences based on your advanced requirements.

| Name          | Description                 |
| ------------- | --------------------------- |
| API Structure | Choose between two options: |

Apps: Recommended for modern app structure.
Basic: Suitable for an old-school controller class structure. |
| App Folder Depth | Set the depth of the app folders for the class autoloader. It's recommended to keep it at level 1 to avoid performance issues. |
| App Directory | The default app directory is 'apps' for now. |
| Email Provider | Select either LOCAL or AWS:
LOCAL: Uses the server's email configuration to send emails.
AWS: Utilizes AWS configuration for email sending. |
| Storage Type | Choose between Local or AWS:
Local: Uses server storage, and files are stored in the root directory.
AWS: Utilizes AWS S3 bucket for data storage. |

## **Step 3:** Database Settings

In this step, configure crucial database settings, including the SQL database host, database name, username, and password. These details are essential for establishing a robust connection and effective data management within your application.

| Name              | Description                                   |
| ----------------- | --------------------------------------------- |
| SQL Database Host | The default SQL database host is 'localhost.’ |
| Database Name     | Provide the name of your database.            |
| Database Username | Enter the username for your database.         |
| Database password | Set a password for your database.             |

## **Step 4:** Error Logs Settings

In this step, tailor your error logs settings, specifying the log directory, file name, log level, and choose whether to save logs to the database. Additionally, enable email notifications for specific log types, providing an effective mechanism for error monitoring and resolution.

| Name           | Description                                                                                                          |
| -------------- | -------------------------------------------------------------------------------------------------------------------- |
| Logs Directory | Specify the location for storing the log file. If 'save logs to database' is enabled, this setting might be ignored. |
| Log File Name  | Set the name for the log file.                                                                                       |
| Log Level      | Choose between:                                                                                                      |

0: No JSON output.
1: Include JSON. |
| Save logs to Database | If set to true, logs will be saved to the local SQLite database. |
| Email Errors | Enable to receive emails when errors occur. |
| Which Emails you want to receive via email? | Choose from CRITICAL, DEBUG, EMERGENCY, WARNING, ERROR (types of logs). Select multiple log types to receive email notifications for. |

## **Step 5:** Security Settings **(Advance Mode Only)**

In this advanced security configuration step, customize encryption settings, establish a secret encryption key, choose a password encryption algorithm, and set an API key for heightened security measures within your application. These settings contribute to the robust protection of sensitive data and system resources.

| Name                          | Description                                                           |
| ----------------------------- | --------------------------------------------------------------------- |
| Encryption Method             | Specify the encryption method for tokens and other security measures. |
| Encryption Key                | Set a secret encryption key for the chosen method.                    |
| Password Encryption Algorithm | Choose the encryption method for securing passwords.                  |
| API Key                       | Provide an API key for enhanced security measures.                    |

## **Congratulations! Final Setup Complete**

Upon successful completion of the configuration process, users will encounter a congratulatory screen displaying vital information for their reference:

| Name                | Description                                         |
| ------------------- | --------------------------------------------------- |
| Web Application URL | Enter your application's URL.                       |
| API Path            | Specify the system's API path.                      |
| System Admin URL    | Provide the URL for your application's admin panel. |
| System Admin Email  | Enter the admin email saved in the system.          |
