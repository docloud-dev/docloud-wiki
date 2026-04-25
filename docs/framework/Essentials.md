# Essentials

Owner: Nuwan Danushka

---

# Introduction

Essentials, the cornerstone of Do Framework, brings together a suite of indispensable tools designed to elevate your development experience. This comprehensive package comprises key functionalities essential for crafting robust and feature-rich applications. Let's delve into its core components.

---

## Notification

Keep your users informed and engaged with seamless notification capabilities. Whether it's alerts, updates, or reminders, the Notification module empowers you to deliver timely messages to your audience, enhancing user experience and interaction.

---

## Email

Streamline communication and outreach with the Email module. From transactional emails to marketing campaigns, this feature-rich component provides the tools you need to effortlessly send and manage email communications, ensuring reliable delivery and engagement.

---

## Authentication

Safeguard your application and user data with the Authentication module. With robust authentication mechanisms in place, you can ensure secure access to your application, protect sensitive information, and foster trust among your user base.

---

## Logging

Gain valuable insights into your application's behavior and performance with the Logging module. By capturing and analyzing logs, you can identify issues, track user actions, and optimize your application for peak efficiency, facilitating proactive maintenance and improvement.

---

## Localization

Reach a global audience and tailor your application to diverse languages and regions with the Localization module. From translating content to adapting formats and conventions, this versatile tool empowers you to create a truly inclusive and accessible user experience.

---

## Moving DoFramework to another development environment

To move the **DoFramework** from one server to another or create a backup, follow these simplified steps:

### 1. **Copy the Framework Files**

- **What to do**: Make a copy of the entire working framework, including these important folders:
  - **API**
  - **App**
  - **Assets**
  - **Storage**
  - All other essential files are in the public directory.
- **How**: You can zip the entire framework directory.

### 2. **Export the Database**

- **What to do**: Export the database using a tool like **PHPMyAdmin** or **Direct Admin Databases**.
- **How**:
  - In **PHPMyAdmin** or your database manager, go to your database.
  - Choose the **Export** option and download the SQL file.

### 3. **Update Configuration Files**

- **File to update**: `configs.development.xml`.
- **What to change**:
  - **Database settings**: Update the database connection details under the `<databases>` section, like database name, user, and password.
  - **System settings**: Update the `system_sitepath` (the path where the system is installed on the new server).
  - **System email**: Update the email address used for system notifications in the `system` section.

### 4. **Change Email Settings (If Necessary)**

- **What to do**: If you need to change how the system sends emails, update the **SMTP settings**.
- **Where**: In the `<smtp>` section of the `<email>` in `configs.development.xml` file.
  - You might need to change the SMTP server, port, username, or password, depending on your email provider.

### 5. **Change System Token (If Necessary)**

- **What to do**: If you need to change how the DoCloud identifies the application, update the **System Token**.
- **Where**: In the `<system_token>` section of the `<do_cloud>` in `config.xml` file.
  - Update the system token tag `<system_token> token here </system_token>`

### Final Steps:

- **Upload the zipped framework** to the new server.
- **Import the SQL file** to the new database.
- **Update the configuration file** with new server settings.

That's it! Your DoFramework should now be set up on the new server.

---
