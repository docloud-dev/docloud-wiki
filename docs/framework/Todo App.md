# Todo App

Owner: Nuwan Danushka

# Introduction

Welcome to the step-by-step guide to familiarizing you with the Do Framework.

The to-do application serves as a simple showcase for the Do Framework, explaining implementation and usage.

# Before building a to-do app let us familiarize ourselves with the framework a bit

## 1. First things first Let’s Download The DoFramework and Setup.

1. Ensure your development environment meets all the required prerequisites. Typically, a team member will provide you with an environment that already includes these prerequisites. To learn more about the prerequisites,
2. Afterward, download the framework zip file from the DO Cloud. Please refer to the DoCloud guide by
3. Next, place the downloaded zip file in the "public_html" directory and extract its contents.

<aside>
🌟

**Congratulations! You have downloaded the Do Framework and are ready to install it. Let’s proceed to the next step.**

</aside>

## 2. Let’s install the framework in the development environment.

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

<aside>
🌟

**Congratulations you have now installed Do Framework. Now Let’s go to the next step.**

</aside>

## 3. Let’s set up a development environment.

1. Navigate to the file manager or directory where you have installed the framework in the server.
2. you will see a file structure as below

   ```html
   public_html ├── api/ ├── apps/ ├── assets/ ├── .gitignore ├── .httacess ├──
   gateway.php ├── index.php ├── manifest.json ├── server.php ├── sw_reg.js ├──
   xp.js └── xp-config.js
   ```

3. Create a zip file including all files in the directory after installing the framework and download it.
4. Extract it to your work directory.
5. Open with your editor and map the work directory with the server. via FTP

<aside>
🌟

**Congratulations you have a copy of Do Framework and We are ready for the next step.**

</aside>

## 4. Let’s take a look at the file structure of the framework

```html
● Importand files for next steps are colored green ● Framework -- Framework
Directory ├── api/ -- API Directory │ ├── admin/ -- Framework Admin Panel
Directory │ │ ├── apps/ -- Admin panel apps │ │ │ ├── helloworld/ -- admin panel
app for helloworld │ │ │ ├── logs/ -- admin panel app for logs │ │ │ ├──
system_admin_appp/ -- admin panel app │ │ │ ├── xp_notification/ -- admin panel
app for notification │ │ │ └── xp_system/ -- framework app that has component
kits,styles and other helpers │ │ │ │ │ ├── assets/ -- Assets needed for the
admin panel such as fonts,icons, images and libs │ │ ├── .htaccess -- Admin
panel .htaccess file │ │ ├── gateway.php -- Responsible for localization │ │ ├──
server.php -- Responsible for frontend bundling and other frontend functions │ │
├── index.php -- Index file where the admin panel app renders │ │ ├── README.md
-- Admin panel README file │ │ ├── xp.js -- Frontend framework functions file │
│ └── xp-config.js -- Admin panel frontend config file │ │ │ ├── apps/ --
Backend~endpoints for apps │ │ ├── auth/ -- Authentication backend files │ │ ├──
helloworld/ -- Hello World sample app backend files │ │ ├── system_admin_app/ --
System admin panel app backend files │ │ ├── xp_email/ -- Email app for sending
emails │ │ ├── xp_notification/ -- Notification app backend files │ │ ├──
xp_system/ -- Framework app responsible for global search, etc. │ │ └──
xp_users/ -- User app backend files │ │ │ ├── classes/ -- Framework classes │ │
└── appConstants.class.php -- Constants used by the framework │ │ │ ├── core/ --
Framework core files │ │ │ ├── db/ -- Local SQLite database │ ├── includes/ --
Included files for SQLite database initilization and for mail assets. │ ├──
logs/ -- Logs saved here (text files if logging is set to text mode) │ ├── sdks/
-- SDKs used in the application │ │ └──PHPMailer -- SMTP Email libarary included
with the framework. │ │ │ ├── .htaccess -- API .htaccess file │ ├── CHANGELOG.md
-- Framework changelog │ ├── Config.php -- Deprecated config file (kept for
backward compatibility) │ ├── config.production.xml -- Environmental
configuration files (contains most system settings) │ ├── config.staging.xml --
Environmental configuration files (contains most system settings) │ ├──
config.development.xml -- Environmental configuration files (contains most
system settings) │ ├── config.xml -- Main Backend configuration file (contains
most framework settings) │ ├── heartbeat.php -- Scheduler for the framework │
├── index.php -- Initial file of the API │ ├── README.md -- API README file │
└── shell.php -- PHP file for supporting shell commands │ ├── apps/ -- Frontend
files │ ├── auth/ -- frontend app for auth │ ├── helloworld/ -- frontend app for
helloworld │ ├── xp_email/ -- frontend app for email │ ├── xp_notification/ --
frontend app for notification │ ├── xp_system/ -- frontend framework app that
has component kits,styles and other helpers │ └── xp_users/ -- frontend user
app. │ ├── assets/ -- Libraries, fonts, images, icons ├── .gitignore --
Gitignore file ├── .htaccess -- Main .htaccess file for routing ├── gateway.php
-- Responsible for localization ├── index.php -- Index file where the app
renders ├── manifest.json -- Manifest file for PWA ├── server.php -- Responsible
for frontend bundling and other frontend functions ├── sw_reg.js -- Service
worker registration file ├── xp.js -- Frontend framework functions file └──
xp-config.js -- Main app frontend framework config file
```

<aside>
🌟

**Congratulations you have observed the structure of Do Framework. Now Let’s go to the next step.**

</aside>

## 5. Import Files: Backend config file and Frontend config file. - (not written)

To get an idea about configuration files. click here.

<aside>
🌟

Congratulations! You now have a rough idea of the Do Framework. Now, let’s take a look at the app's structure.

</aside>

## 6. App structures - Frontend / Backend

```php
Framework
├── api/   -- API Directory
│   ├── admin/ -- Framework Admin Panel Directory
│   │  └─ apps/ -- Admin panel apps
│   │	  └─ helloworld/ -- admin panel app for helloworld
│		│			 ├── assets/
│		│			 *│*   ├── scripts.js
│		│			 │   └── styles.css
│		│			 ├── components/
│		│			 │   └── helloworld-settings.js
│		│			 ├── app-config.json
│		│			 ├── index.php
│		│			 ├── readme.txt
│		│			 ├── route.js
│		│			 └── services.js
│		│
│		└─ apps/ -- Backend~endpoints Directory for apps
│      └─ helloworld/ -- Hello World sample app backend files
│					├── helloworld.xml
│					├── helloworld.class.php
│					├── helloworldController.class.php
│					├── helloworldDAO.class.php
│					└── helloworldModel.class.php
│
├── apps/  -- Frontend APP Directory
│   ├── helloworld/ --  Helloworld Front-end App
│		│			├── assets/
│		│			│   ├── images/
│		│			*│*   ├── scripts.js
│		│			│   └── styles.css
│		│			├── components/
│		│			│   ├── widgets/
│		│			│   └── helloworld.js
│		│			├── app-config.json
│		│			├── index.php
│		│			├── readme.txt
│		│			├── route.js
│		│			└── services.js
```

**Front-end app structure.**

<aside>
💡

The admin panel app is the same as to frontend app. Most of the files and the behavior are the same.

</aside>

```
Framework
├── api/   -- API Directory
├── apps/  -- Frontend APP Directory
│   ├── helloworld/ --  Helloworld Front-end App
│		│			├── assets/
│		│			│   ├── images/
│		│			*│*   ├── scripts.js
│		│			│   └── styles.css
│		│			├── components/
│		│			│   ├── widgets/
│		│			│   └── helloworld.js
│		│			├── app-config.json
│		│			├── index.php
│		│			├── readme.txt
│		│			├── route.js
│		│			└── services.js
```

| No                                                                                        | Folder, File & Description |
| ----------------------------------------------------------------------------------------- | -------------------------- |
| 1                                                                                         | **assets**                 |
| This directory is reserved for app assets, including images, fonts, scripts, styles, etc. |
| 2                                                                                         | **components**             |

This directory is designated for app components, where you can organize your app components such as pages, widgets, or other elements.

💡 Keep the JavaScript components in the component directory for better cache management. If the system is cached, having the components in the correct directory ensures that they will be properly updated when changes are cleared from the admin panel. 💡
|
| 3 | **widgets**
The "widgets" directory is intended for app widgets, specifically those used in dashboards and other panels. |
| 4 | **app-config.json**
This file, "app-config.json," serves as the app configuration file. It stores app information and other configurations. For further details on app configurations, refer to [t](https://chat.openai.com/c/34a846e5-4d72-48a3-a5d1-b34ccb06a5fe#)his link. |
| 5 | **index.php**
This file addresses security concerns within the application and avoid directory listing. |
| 6 | **readme.txt**
"readme.txt" serves as the readme file for your app, providing essential information and guidance. |
| 7 | **route.js**
"route.js" is responsible for handling Vue routes. Place your page routes in this file for effective route management. |
| 8 | **services.js**
"services.js" contains functions for handling various requests such as GET, POST, and others within your app. Place your services in this file to manage requests effectively. |

**Back-end / API structure.**

```
Framework
├── api/   -- API Directory
│		└─ apps/ -- Backend~endpoints Directory for apps
│      └─ helloworld/ -- Hello World sample app backend files
│					├── helloworld.xml
│					├── helloworld.class.php
│					├── helloworldController.class.php
│					├── helloworldDAO.class.php
│					└── helloworldModel.class.php
├── apps/
```

| No                                                                                                                                                                                                                                                                                                                                                                      | Folder, File & Description         |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| 1                                                                                                                                                                                                                                                                                                                                                                       | **helloworld.xml**                 |
| This file, "helloworld.xml," functions as the backend app configuration file. It contains essential configurations for the app. For more detailed information, please refer to this The naming convention, "helloworld XML," is used for this configuration file. If you are creating your configuration, please use the app name that you have used for the directory. |
| 2                                                                                                                                                                                                                                                                                                                                                                       | **helloworld.class.php**           |
| This file serves as the app class, where functions are written to be accessed by other apps. The purpose is to facilitate interaction with other apps by providing accessible functions. In this file, you can define functions that are intended to be utilized by other parts of the application.                                                                     |
| 3                                                                                                                                                                                                                                                                                                                                                                       | **helloworldController.class.php** |
| This file contains the API endpoints and is responsible for handling requests made to the app's endpoint. It serves as a controller for managing interactions with the app's API, processing incoming requests and providing appropriate responses.                                                                                                                     |
| 4                                                                                                                                                                                                                                                                                                                                                                       | **helloworldDAO.class.php**        |
| This file is a sample DAO (Data Access Object) class. It contains database functions needed for the app, handling interactions with the database. The DAO class typically encapsulates the database access code, providing a clean interface for the app to interact with the database.                                                                                 |
| 5                                                                                                                                                                                                                                                                                                                                                                       | **helloworldModel.class.php**      |
| This file is a sample model class. It contains properties and functions that are necessary for a model in the application. Model classes often represent data structures or business logic within the app, encapsulating the functionality related to data manipulation and processing.                                                                                 |

# Let's build a to-do app as our first Docloud app

## 1. Let's copy the sample app to create a new app.

1. Let's get a copy of the hello world frontend, backend, and admin panel directories and rename it to the **todo*.***
2. Rename files that classes that have ‘helloworld’.
3. For better clarity refer to the structure below.

```html
● New files are colored green ● Framework ├── api/ -- API Directory │ ├── admin/
-- Framework Admin Panel Directory │ │ └─ apps/ -- Admin panel apps │ │ ├──
todo/ -- Todo App admin panel- renamed "helloworld" *rename files and class │ │
│ ├── assets/ │ │ │ *│*   ├── scripts.js │ │ │ │   └── styles.css │ │ │ ├──
components/ │ │ │ │   └── todo-settings.js -- Rename only the file name │ │ │
├── app-config.json │ │ │ ├── index.php │ │ │ ├── readme.txt │ │ │ ├── route.js
│ │ │ └── services.js │ │ │ │ │ └─ helloworld/ -- admin panel app for helloworld
│ │ │ └─ apps/ -- Backend~endpoints Directory for apps │ ├── todo/ -- Todo App
backed-end - renamed "helloworld" *rename files and class │ │ ├── todo.xml --
Rename only the file name │ │ ├── todo.class.php -- Rename the file name and
class name inside │ │ ├── todoController.class.php -- Rename the file name and
class name inside │ │ ├── todoDAO.class.php -- Rename the file name and class
name inside │ │ └── todoModel.class.php -- Rename the file name and class name
inside removed properties inside. │ | │ └─ helloworld/ -- Hello World sample app
backend files | ├── apps/ -- Frontend APP Directory │ ├── helloworld/ --
Helloworld Front-end App │ │ │ ├── todo/ -- Todo App Front-end - renamed
"helloworld" │ │ ├── assets/ │ │ │   ├── images/ │ │ *│*   ├── scripts.js │ │
│   └── styles.css │ │ ├── components/ │ │ │   ├── widgets/ │ │ │   └── todo.js
-- Rename the file name │ │ ├── app-config.json │ │ ├── index.php │ │ ├──
readme.txt │ │ ├── route.js │ │ └── services.js
```

###

<aside>
🌟

**Congratulations! We have successfully copied the sample app to create a new app**. **Let’s go for the next step.**

</aside>

## 2. Let’s configure the configuration files.

### Let’s edit the backend configuration

1. Let’s open the configuration file ”todo.xml” on the backend.

   ```html
   Framework ├── api/ -- API Directory │ └─ apps/ -- Backend~endpoints Directory
   for apps │ └─ todo/ -- Todo app backend files │ ├── todo.xml -- backend
   configuration file. │ ├── todo.class.php │ ├── todoController.class.php │ ├──
   todoDAO.class.php │ └── todoModel.class.php ├── apps/
   ```

2. Let’s make changes to the configuration accordingly.

   <aside>
   💡

   remove comments on the actual configuration file.

   </aside>

   ```html
   <?xml version="1.0" encoding="UTF-8"?>
   <app>
     <app_register active="true" />
     <info>
       <app_name>todo</app_name> //let's give it a name.
       <app_author>DoCloud</app_author> //author of the app.
       <display_name>My Todo</display_name> //the name how it should displayed
       on the app store. <app_version>1.0.1</app_version> //the app version.
       <api_version>0.0.16</api_version> //the framework version that it
       supports. <app_icon>fa-regular fa-circle-check</app_icon> //the icon app
       icon - you can use font awesome 6 icon.
       <app_image src="/assets/images/app_icons/app-icon.png" /> //path to your
       app icon -- refer below (a) for details.
       <app_type>application</app_type> //application type - system or
       application. <status>active</status> //status make this active.
       <release_date>2024-12-17</release_date> //release date of the app.
       <description>
         //description of the application. This is my first DoCloud app
       </description>
       <changelog>
         //here you can write about the changes made in the app compared to the
         previous version. fixed errors.
       </changelog>
     </info>
     <app_permissions>
       //here we specify what apps allowed to access this app.
       <permission app_name="xp_users" />
     </app_permissions>
     <user_permissions name="todo">
       //here we specify the user permissions of the app.
       <category name="basic_permissions">
         //you can categorized like this. //lets define the permissions that we
         will use later on.
         <permission
           display_name="View todo list"
           name="view_todo_list"
           auto_update="true"
         />
         <permission
           display_name="View todo single"
           name="view_todo_single"
           auto_update="true"
         />
         <permission
           display_name="View todo add"
           name="view_todo_add"
           auto_update="true"
         />
         <permission
           display_name="View todo update"
           name="view_todo_update"
           auto_update="true"
         />
         <permission
           display_name="Add a todo"
           name="add_todo"
           auto_update="true"
         />
         <permission
           display_name="Get todos"
           name="get_todo"
           auto_update="true"
         />
         <permission
           display_name="Update todo"
           name="update_todo"
           auto_update="true"
         />
         <permission
           display_name="Delete todo"
           name="delete_todo"
           auto_update="true"
         />
       </category>
     </user_permissions>
     <user_notifications
       >//here we define app notifications.
       <category name="todo" display_name="Todo"
         >//you can categorized like this. //here we will create a notification
         what we will use later on.
         <notification
           name="add_todo"
           display_name="add todo notification"
           description="this will trigger a notification on every created todo"
           default_enabled="true"
         >
           <email active="false" /> //set it to true if you want your app to
           send notifications by default.
           <push active="false" />
           <sms active="false" />
         </notification>
       </category>
     </user_notifications>
     <admin_panel_permissions
       >//here we define admin panel permissions.
       <category name="basic_permissions">
         //you can categorized like this. //lets define the permissions that we
         will use later on.
         <permission
           display_name="view setting page"
           name="view_todo_settings"
           auto_update="true"
         />
         <permission
           display_name="change priority"
           name="change_priority"
           auto_update="true"
         />
       </category>
     </admin_panel_permissions>
     <createTables
       >//define your tables here. lets create a table to save todos
       <table name="todo">
         <column
           name="id"
           type="bigint"
           size="20"
           default=""
           attributes="UNSIGNED"
           null="false"
           autoincrement="true"
           primarykey="true"
         />
         <column
           name="title"
           type="text"
           size=""
           default=""
           attributes=""
           null="true"
         />
         <column
           name="description"
           type="text"
           size=""
           default=""
           attributes=""
           null="true"
         />
         <column
           name="status"
           type="varchar"
           size="255"
           default=""
           attributes=""
           null="true"
         />
         <column
           name="priority"
           type="varchar"
           size="255"
           default=""
           attributes=""
           null="true"
         />
         <column
           name="created_date"
           type="datetime"
           size=""
           default=""
           attributes=""
           null="false"
         />
         <column
           name="created_by"
           type="bigint"
           size="20"
           default=""
           attributes="UNSIGNED"
           null="true"
         />
         <column
           name="updated_date"
           type="datetime"
           size=""
           default=""
           attributes=""
           null="true"
         />
         <column
           name="updated_by"
           type="bigint"
           size="20"
           default=""
           attributes="UNSIGNED"
           null="true"
         />
       </table>
     </createTables>
     <prerequisites
       >//prerequisite apps here -- refer below (b) for details.
     </prerequisites>
     <uninstallConfiguration>
       //app install scrtipt -- refer below (c) for details.
     </uninstallConfiguration>
   </app>
   ```

   ### (a) Guidelines for Placing Your App Icon

   Follow these steps to ensure proper placement and usage of your app icon:
   1. **Icon Size**:

      Use an image with dimensions **128x128 pixels** for the best results.

   2. **File Format**:

      Save your app icon as a **PNG file** (preferred over JPG for better quality).

   3. **File Location**:

      Place your app icon in the `assets` directory of your frontend application.

      Example path: `/assets/images/app_icons/app-icon.png`.

   4. **Implementation in Code**:

      Use the following HTML snippet to link to your app icon:

      ```html
      <app_image src="/assets/images/app_icons/app-icon.png" />
      ```

   This ensures your app icon is displayed correctly and meets system requirements.

   ### (b) Guidelines for defining prerequisite apps can be found below.

   ### (c) Guidelines for app uninstall configuration can be found below.

### Let’s edit the frontend configuration

1. Let’s open the configuration file “app-config.json” on the front end.

   ```html
   Framework ├── api/ -- API Directory ├── apps/ -- Frontend APP Directory │ ├──
   todo/ -- Todo Front-end App │ │ ├── assets/ │ │ │   ├── images/ │ │ *│*   ├──
   scripts.js │ │ │   └── styles.css │ │ ├── components/ │ │ │   ├── widgets/ │
   │ │   └── todo.js │ │ ├── app-config.json │ │ ├── index.php │ │ ├──
   readme.txt │ │ ├── route.js │ │ └── services.js
   ```

2. Let’s make changes to the configuration accordingly.

   ```json
   {
     "version": "1.0.1", //the app version.
     "release_date": "2024-12-17", //release date of the app.
     "app_name": "todo", //here we define app name.
     "app_type": "custom", //let's specifies the type of the app. accepted values: 'system' for core system apps or 'custom' for user-defined custom apps.
     "status": "active", //defines the current status of the app.
     "description": "", //description of the app

     "resources": {
       //here we define our scripts and styles
       "scripts": [{ "url": "assets/scripts.js" }, { "url": "route.js" }],

       "styles": [{ "url": "assets/styles.css" }]
     },
     //define here menu items to inject framework side bar and mega bar
     "menus": [
       {
         "label": "Todo", //we will add todo as menu item label.
         "svg_icon": "", //if we have a custom svg icon we can include here. we recommend to use and svg icon.
         "icon": "fa-regular fa-circle-check", //font Awesome class name for the menu item icon, as a fallback if an SVG is not provided.
         "path_name": "todo", //here we define the route name for this menu item (not a direct link).
         "description": "Say Hello to Do Framework.", //brief information or context for the menu item.
         "position": {
           "sidebar": true,
           "sidebar_priority": 100,
           "megabar": true,
           "megabar_priority": 100
         }, //here we can control the visibility and order of the menu item in various UI areas like 'sidebar' and 'megabar'.
         "permission": {
           //defines the required permission settings for this menu item, specifying 'name' (app name) and 'action' (allowed operation).
           "name": "todo",
           "action": "view_todo_list"
         },
         "sub_paths": [
           //here we can declare our sub route name/paths
           "todo_single",
           "todo_add"
         ]
       }
     ],

     "_comments": {
       "app_type": "Type of the app. Accepted values: system | custom",
       "status": "Status of this app. Accepted values: active | disabled",
       "menus": {
         "intro": "How the app navigation labels should be displayed",
         "icon": "Font Awesome class names for the menu icons",
         "path_name": "Route path name. (not the link)"
       }
     },

     //here we choose what property available to public
     "_public": [
       "version",
       "release_date",
       "app_name",
       "status",
       "description",
       "menus"
     ]
   }
   ```

<aside>
🌟

**Congratulations! We have successfully configured the to-do app configurations. Let’s proceed to the next step.**

</aside>

## 3. Let’s add the routes.

### Let’s edit the route file.

1. Let’s open the route file ”route.js” on the front end.

   ```html
   Framework ├── api/ -- API Directory ├── apps/ -- Frontend APP Directory │ ├──
   todo/ -- Todo Front-end App │ │ ├── assets/ │ │ │   ├── images/ │ │ *│*   ├──
   scripts.js │ │ │   └── styles.css │ │ ├── components/ │ │ │   ├── widgets/ │
   │ │   └── todo.js │ │ ├── app-config.json │ │ ├── index.php │ │ ├──
   readme.txt │ │ ├── route.js │ │ └── services.js
   ```

2. Let’s make changes to the routes accordingly.
   1. Let's Add the /todo route first.
   2. Add route for to-do single page, add page, update page.

   ```json

   /*
   Routes of the apps
    */

   const Ext_Todo = () => XP.import('/apps/todo/components/todo.js');
   const Ext_Todo_Single = () => XP.import('/apps/todo/components/todo_single.js');
   const Ext_Todo_Add = () => XP.import('/apps/todo/components/todo_add.js');
   const Ext_Todo_Update = () => XP.import('/apps/todo/components/todo_update.js');

   Router.addRoute( {
       path: '/todos',
       name: 'todo',
       component: Ext_Todo,
       meta: {
           title: 'Todo List',
           requiresAuth: true,
           permissions: {
               name: "todo", //here we added pemissions that we have added before
               action: "view_todo_list",
           },
       } ,
   });

   //route for todo single
   Router.addRoute( {
       path: '/todo/view/:id',
       name: 'todo_single',
       component: Ext_Todo_Single ,
       meta: {
           title: 'Todo',
           requiresAuth: true,
           permissions: {
               name: "todo",
               action: "view_todo_single",
           },
       } ,
   });

   //route for add todo
   Router.addRoute( {
       path: '/todo/add',
       name: 'todo_add',
       component: Ext_Todo_Add ,
       meta: {
           title: 'Add Todo',
           requiresAuth: true,
           permissions: {
               name: "todo",
               action: "view_todo_add",
           },
       } ,
   });

   //route for update todo
   Router.addRoute( {
       path: '/todo/update/:id',
       name: 'todo_update',
       component: Ext_Todo_Update ,
       meta: {
           title: 'Update Todo',
           requiresAuth: true,
           permissions: {
               name: "todo",
               action: "view_todo_update",
           },
       } ,
   });

   Router.replace( Router.currentRoute.value.fullPath );
   ```

### Let’s create files for the routes.

1. In the component directory, we will create an addition two files. for todo, single and todo add.

   ```html
   Framework ├── api/ -- API Directory ├── apps/ -- Frontend APP Directory │ ├──
   todo/ -- Todo Front-end App │ │ ├── assets/ │ │ │   ├── images/ │ │ *│*   ├──
   scripts.js │ │ │   └── styles.css │ │ ├── components/ │ │ │   ├── widgets/ │
   │ │  ├── todo_single.js -- we have added todo single file. │ │ │  ├──
   todo_add.js -- we have added todo single file. │ │ │  ├── todo_update.js --
   we have added todo add file. │ │ │   └── todo.js -- we will modify this file.
   │ │ ├── app-config.json │ │ ├── index.php │ │ ├── readme.txt │ │ ├── route.js
   │ │ └── services.js
   ```

2. let's create page `todo_single.js`, `todo_add.js`, `todo_update.js` and modify `todo.js` in this format below.

   ```json
   //todo_single.js | todo_add.js | todo_update.js | todo.js
   import DC_Sidebar from "../../xp_system/components/navigation/dc_sidebar.js?v=1.0.0";
   export default {
       components: {
           DC_Sidebar,
       },
       data() {
           return {
           };
       },
       template: `
   <DC_Sidebar />
   <div class="dc-app-container">
           <div>
                <div class="dc-big-heading">
                   <h1 class="dc-bh-heading">Todo Page</h1>
               </div>
           </div>
           <!-- Html here or the components -->
   </div>
   `,
       methods: {},
       watch: {},
       computed: {},
       mounted() {},
       created() {}
   };

   ```

<aside>
🌟

**Congratulations! We have successfully added pages. Let’s proceed to the next step.**

</aside>

## 4. Let’s enable app user permissions for the users.

1. Let's navigate to the framework’s admin panel ( your domain /api/admin/ ).
2. Login to the admin panel using DoCloud.
3. Go to "Roles & Permissions".
4. Look for the "todo" section.
5. Under the "todo" section, locate the declared permissions.
6. Add a tick/checkmark for the user roles that should have access to the permissions.
7. Press the "Save Permissions" button.

<aside>
🌟

**Congratulations! We have successfully enabled user permissions. Let’s proceed to the next step.**

</aside>

## 4. Let’s initialize the app.

1. Let's navigate to the framework’s admin panel ( your domain /api/admin/ ).
2. Login to the admin panel using DoCloud.
3. Go to "Apps".
4. Look for the "My todo" in the installed section.
5. Hover the card and click the gear icon ⚙ to open the manage app,
6. Press the "Reinitialize" button.

<aside>
🌟

**Congratulations! We have successfully initialized the app. Let’s proceed to the next step.**

</aside>

## 5. Let’s create the endpoints of the todo app.

1. Navigate to the **`api/app`** directory.
2. Find the "todo" app.
3. Open the controller class file, which is likely named **`todoController`**.

<aside>
💡 If you're creating the endpoint for testing purposes, it should be removed from `$publicEndpointsAry` after testing. However, if you intend to make the endpoint public, you can keep it as it is.

</aside>

<aside>
💡 adding the endpoint to the `$publicEndpointsAry`, it will be accessible to unauthorized users, making it available to anyone.

</aside>

### Let’s create get todo endpoint

1. Inside the controller class, under the `GetHandler` function, add a new case for handling the `get_todo` endpoint.

   ```php
   // todoController.php

   private function GetHandler() {
      switch ($this->getRequest()->getAction()) {
           // ... other cases
           case 'get_todo':
               $this->get_todo();
               break;
           default:
               $this->notsupported();
               break;
       }
   }
   ```

2. Let’s create the `get_todo` endpoint function

   ```php
       private function get_todo()
       {
   			  //Create an instance of the Response class. And it will be used to manage the response to be sent back.
           $res = new Response();

           //The try block contains the main logic of the function.
           try {

               //returns an array. This function will be used to get data with the request.
               //works for both GET & POST type requests.
               $data = $this->getRequest()->getData();

               $todo_id = $data['id'] ?? null;;

               //gets data from the database.
               $todo_list = todoDAO::get_todo_records($todo_id);

               if (empty($todo_id)) {
                   $response_message = "No Todo items.";
                   $total_count = "0";

                   if (!empty($todo_list)) {
                       $response_message = "Todo items.";
                       $total_count = count($todo_list);
                   }

                   $response_data = array(
                       "list" => $todo_list,
                       "total_count" => $total_count,
                   );

               } else {
                   $response_message = "Todo not found";
                   if (!empty($todo_list)) {
                       $response_message = "Todo id: $todo_id.";
                   }
                   $response_data = array();
                   if(!empty($todo_list)){
                       $response_data = $todo_list;
                   }
               }

               //This sets the data to the response object.
               //This data will be used to send with the response back to the client.
               $res->setData($response_data);

               //This line outputs the response created by the create method of the $res object.
               //It takes three parameters:
               //HTTP status, a message associated with the response, indicates success or unsuccessful

               echo $res->create(200, $response_message, true);
               return;

               //If any exception occurs during the execution of the try block,
               //it will be caught by the catch block.
           } catch (Exception $ex) {
               //in case of an exception, we can log the exception using System::errorlog
               //creating a log entry with the provided exception, location, and log level.
               System::errorlog(Loging::log($ex->getMessage(), 'todoController:get_todo', LOG_WARN));
               echo $res->create(500, 'Something went wrong.', false);
               return;
           }
       }
   ```

3. Let’s create the dao function get_todo_records()

   ```php
      /**
        * Get data from todo table
        * @return array|false
        */
      public static function get_todo_records($todo_id = null)
       {
           $database = new Database();

           try {

               $query = !empty($todo_id) ? "SELECT * FROM todo_todo WHERE id = :id;" : "SELECT * FROM todo_todo;";

               $database->query($query);

               if (!empty($todo_id)) {
                   $database->bind(':id', $todo_id);
               }

               $result_data = !empty($todo_id) ? $database->single() : $database->resultset();

               if (!empty($result_data)) {
                   return $result_data;
               } else {
                   return false;
               }

           } catch (Exception $exc) {
               System::errorlog(Loging::log($exc->getMessage(), 'todoDAO:get_todo', LOG_CRITICAL));
               return false;
           }
       }
   ```

4. Let’s test and examine the response. Our endpoint can use a tool like [**Postman**](https://www.postman.com/). but first, we need to call the auth/login with the email and password and log in.

5. Then we can test `get_todo` endpoint from the tool.
6. After completing these steps, you've successfully set up the get todo endpoint. Now, let's explore how we can create the add todo endpoint.

### Let’s create add todo endpoint

1. First, let's create a new class in todo model class in the todo app directory.

   ```php
   <?php

   class TodoModel {

       private $id;
       private $title;
       private $description;
       private $status;
       private $priority;
       private $created_date;
       private $created_by;
       private $updated_date;
       private $updated_by;

       public function __construct($data = null) {

          if (!empty($data)) {
               if (is_array($data)) {
                   foreach ($data as $key => $value) {
                       $this->$key = $value;
                   }
               }
           }
       }

        /**
        * @return mixed
        */
       public function getId()
       {
           return $this->id;
       }

       /**
        * @param mixed $id
        */
       public function setId($id): void
       {
           $this->id = $id;
       }


       //other get and setter functions

       }
   ```

2. Let's write a validation function to validate data.

   ```php
   <?php

   class TodoModel {

   	//other function and properties
    public function validate_data($type = 'add')
       {
           $errors = [];
           $datePattern = '/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/';
           $validStatuses = ['completed', 'active'];
           $validPriorities = ['low', 'normal', 'high'];

           // General validations based on type
           if (in_array($type, ['update', 'delete']) && empty($this->id)) {
               $errors[] = "Id is required.";
           }

           if ($type === 'add' && empty($this->title)) {
               $errors[] = "Title is required.";
           }

           if (in_array($type, ['add', 'default']) && (empty($this->created_date) || !preg_match($datePattern, $this->created_date))) {
               $errors[] = empty($this->created_date)
                   ? "Created date is required."
                   : "Created date must be in 'YYYY-MM-DD HH:MM:SS' format.";
           }

           if (in_array($type, ['add', 'default']) && empty($this->created_by)) {
               $errors[] = "Created by is required.";
           }

           if ($type === 'update' && (empty($this->updated_date) || !preg_match($datePattern, $this->updated_date))) {
               $errors[] = empty($this->updated_date)
                   ? "Updated date is required."
                   : "Updated date must be in 'YYYY-MM-DD HH:MM:SS' format.";
           }

           if ($type === 'update' && empty($this->updated_by)) {
               $errors[] = "Updated by is required.";
           }

           // Validate status and priority only for 'add', 'update', or 'default' operations
           if ($type !== 'delete') {
               if (empty($this->status) || !in_array($this->status, $validStatuses)) {
                   $errors[] = empty($this->status)
                       ? "Status is required."
                       : "Status must be 'completed' or 'active'.";
               }

               if (empty($this->priority) || !in_array($this->priority, $validPriorities)) {
                   $errors[] = empty($this->priority)
                       ? "Priority is required."
                       : "Priority must be 'low', 'normal', or 'high'.";
               }
           }

           // Return errors or success
           return empty($errors) ? true : implode(" ", $errors);
       }
    }
   ```

3. Let’s create the add todo function in the Dao class

   ```php
   <?php

   class todoDAO {

      public static function add_todo(TodoModel $todo) {

            $database = new Database();
           $database->beginTransaction();

           try {
               // Prepare the SQL query
               $insert_sql = "INSERT INTO todo_todo (title,description, status, priority, created_date, created_by, updated_date, updated_by)
                       VALUES (:title, :description, :status, :priority, :created_date, :created_by, :updated_date, :updated_by)";

               $database->query($insert_sql);

               // Bind values from the TodoModel object
               $database->bind(':title', $todo->getTitle());
               $database->bind(':description', $todo->getDescription());
               $database->bind(':status', $todo->getStatus());
               $database->bind(':priority', $todo->getPriority());
               $database->bind(':created_date', $todo->getCreatedDate());
               $database->bind(':created_by', $todo->getCreatedBy());
               $database->bind(':updated_date', $todo->getUpdatedDate());
               $database->bind(':updated_by', $todo->getUpdatedBy());

               $database->execute();
               $id = $database->lastInsertId();

               $result = $database->endTransaction();

               if (!$result) {
                   $database->cancelTransaction();
                   return false;
               }else{
                   return $id;
               }

           } catch (Exception $exc) {
               $database->cancelTransaction();
               System::errorlog(Loging::log($exc->getMessage(), 'todoDAO:add_todo', LOG_CRITICAL));
               return false;
           }
       }
    }
   ```

4. Lets create the controller function in the controller class, under the `post` handler function, add a new case for handling the `add_todo` endpoint.

   ```php
   // todoController.php

   public function PostHandler() {
      switch ($this->getRequest()->getAction()) {
           // ... other cases
           case 'add_todo':
               $this->add_todo();
               break;
           default:
               $this->notsupported();
               break;
       }
   }
   ```

5. Let’s create the `add_todo` endpoint function in todoController

   ```php
       private function add_todo()
       {
           $res = new Response();

           try {

               $data = $this->getRequest()->getData();

               $todo_obj = new todoModel($data);

               //get login user's id
               $logged_in_user = authSession::getUserID();
               $todo_obj->setCreatedBy($logged_in_user);

               // Get the current date and time
               $current_data_time = Util::DateAndTimeManager()::get_system_datetime();

               $todo_obj->setCreatedDate($current_data_time);

               //validate the data :- checking empty and validating data
               $validation_response = $todo_obj->validate_data();

               if($validation_response !== true && !empty($validation_response) && is_string($validation_response)){
                   echo $res->create(200, $validation_response, false);
                   return;
               }

               //add to the todo obj
               $last_inserted_id = todoDAO::add_todo($todo_obj);

               if(empty($last_inserted_id)){
                   echo $res->create(200, "Todo create unsuccessful.", false);
                   return;
               }

               $response_data = array(
                   "todo_id"=>$last_inserted_id,
               );

               $res->setData($response_data);
               echo $res->create(200, "Todo successfully created.", true);
               return;

           } catch (Exception $ex) {
               System::errorlog(Loging::log($ex->getMessage(), 'todoController:add_todo', LOG_WARN));
               echo $res->create(500, 'Something went wrong.', false);
               return;
           }
       }
   ```

6. Let’s test and examine the response.
7. Then we can test `add_todo` endpoint from the tool.
8. After completing these steps, you've successfully created the add todo endpoint. Now, let's explore how we can create the update todo endpoint.

### Let’s create the todo update endpoint

1. Let’s create the update todo function in the dao class first. and `check_id` function

   ```php

    public static function update_todo(TodoModel $todo) {

           $database = new Database();
           $database->beginTransaction();

           try {
               // Prepare the SQL query for update
               $update_sql = "UPDATE todo_todo
                          SET title = :title,
                              description = :description,
                              status = :status,
                              priority = :priority,
                              updated_date = :updated_date,
                              updated_by = :updated_by
                          WHERE id = :id";

               $database->query($update_sql);

               // Bind values from the TodoModel object
               $database->bind(':title', $todo->getTitle());
               $database->bind(':description', $todo->getDescription());
               $database->bind(':status', $todo->getStatus());
               $database->bind(':priority', $todo->getPriority());
               $database->bind(':updated_date', $todo->getUpdatedDate());
               $database->bind(':updated_by', $todo->getUpdatedBy());
               $database->bind(':id', $todo->getId());

               // Execute the query
               $database->execute();

               $result = $database->endTransaction();

               if (!$result) {
                   $database->cancelTransaction();
                   return false;
               } else {
                   return true; // Update successful
               }
           } catch (PDOException $e) {
               $database->cancelTransaction();
               System::errorlog(Loging::log($e->getMessage(), 'todoDAO:update_todo', LOG_CRITICAL));
               return false;
           }
       }

    public static function check_id(TodoModel $todo) {

          $database = new Database();

           try {
               // Prepare the SQL query to check if the id exists
               $check_sql = "SELECT COUNT(*) as count FROM todo_todo WHERE id = :id";

               $database->query($check_sql);

               // Bind the id value
               $database->bind(':id', $todo->getId());

               // Execute the query and fetch the result
               $result = $database->single();

               $count = $result['count'] ?? 0;

               // Return true if the id exists, false otherwise
               return $count > 0;

           } catch (PDOException $e) {
               System::errorlog(Loging::log($e->getMessage(), 'todoDAO:check_id', LOG_CRITICAL));
               return false;
           }

       }

   ```

2. Lets create the controller function in the controller class, under the `post` handler function, add a new case for handling the `update_todo` endpoint.

   ```php
   // todoController.php

   public function post($request) {
      switch ($this->getRequest()->getAction()) {
           // ... other cases
           case 'update_todo':
               $this->update_todo();
               break;
           default:
               $this->notsupported();
               break;
       }
   }
   ```

3. Let’s create the `update_todo` endpoint function in todoController

   ```php
   private function update_todo(){

           $res = new Response();

           try {

               $data = $this->getRequest()->getData();

               $todo_obj = new todoModel($data);

               //get login user's id
               $logged_in_user = authSession::getUserID();
               $todo_obj->setUpdatedBy($logged_in_user);

               // Get the current date and time
               $current_data_time = Util::DateAndTimeManager()::get_system_datetime();

               $todo_obj->setUpdatedDate($current_data_time);

               //validate the data :- checking empty and validating data
               $validation_response = $todo_obj->validate_data('update');

               if($validation_response !== true && !empty($validation_response) && is_string($validation_response)){
                   echo $res->create(200, $validation_response, false);
                   return;
               }

               $check_exist = todoDAO::check_id($todo_obj);

               if(empty($check_exist)){
                   echo $res->create(200, "Id does not exist.", false);
                   return;
               }

               //update the todo obj
               $update_result = todoDAO::update_todo($todo_obj);

               if(empty($update_result)){
                   echo $res->create(200, "Todo update unsuccessful.", false);
                   return;
               }

               echo $res->create(200, "Todo successfully updated.", true);
               return;

           } catch (Exception $ex) {
               System::errorlog(Loging::log($ex->getMessage(), 'todoController:updated_todo', LOG_WARN));
               echo $res->create(500, 'Something went wrong.', false);
               return;
           }
       }
   ```

4. After completing these steps, you've successfully created the add todo endpoint. Now, let's explore how we can create the delete todo endpoint.

### Let’s create delete todo endpoint

1. Let’s create the delete todo function in dao class first.

   ```php
   public static function delete_todo(TodoModel $todo) {

           $database = new Database();
           $database->beginTransaction();

           try {
               // Prepare the SQL query for deletion
               $delete_sql = "DELETE FROM todo_todo WHERE id = :id";

               $database->query($delete_sql);

               // Bind the id value
               $database->bind(':id', $todo->getId());

               // Execute the query
               $database->execute();

               $result = $database->endTransaction();

               if (!$result) {
                   $database->cancelTransaction();
                   return false;
               } else {
                   return true; // Deletion successful
               }
           } catch (PDOException $e) {
               $database->cancelTransaction();
               System::errorlog(Loging::log($e->getMessage(), 'todoDAO:delete_todo', LOG_CRITICAL));
               return false;
           }
   }

   ```

2. Lets create the controller function in the controller class, under the `post` handler function, add a new case for handling the `delete_todo` endpoint.

   ```php
   // todoController.php

   public function post($request) {
      switch ($this->getRequest()->getAction()) {
           // ... other cases
           case 'delete_todo':
               $this->delete_todo();
               break;
           default:
               $this->notsupported();
               break;
       }
   }
   ```

3. Let’s create the `delete_todo` endpoint function in todoController

   ```php
       private function delete_todo()
       {
   			 $res = new Response();

           try {

               $data = $this->getRequest()->getData();

               $todo_obj = new todoModel($data);

               //validate the data :- checking empty and validating data
               $validation_response = $todo_obj->validate_data('delete');

               if($validation_response !== true && !empty($validation_response) && is_string($validation_response)){
                   echo $res->create(200, $validation_response, false);
                   return;
               }

               $check_exist = todoDAO::check_id($todo_obj);

               if(empty($check_exist)){
                   echo $res->create(200, "Id does not exist.", false);
                   return;
               }

               //update the todo obj
               $result = todoDAO::delete_todo($todo_obj);

               if(empty($result)){
                   echo $res->create(200, "Todo delete unsuccessful.", false);
                   return;
               }

               echo $res->create(200, "Todo successfully deleted.", true);
               return;

           } catch (Exception $ex) {
               System::errorlog(Loging::log($ex->getMessage(), 'todoController:delete_todo', LOG_WARN));
               echo $res->create(500, 'Something went wrong.', false);
               return;
           }
       }
   ```

4. After completing these steps, you've successfully created the delete todo endpoint.

<aside>
🌟

**Congratulations! We have successfully created endpoints for your application. Let’s proceed to the next step.**

</aside>

## 6. Let’s add our todo endpoints to services.js

1. We create functions in the service file to call endpoints. Here, we have used the Javascript fetch API to call the endpoints.
2. Let’s open the service file. Location below.

   ```php
   Framework
   ├── api/   -- API Directory
   ├── apps/  -- Frontend APP Directory
   │   ├── todo/ --  Todo Front-end App
   │		│			├── assets/
   │		│			│   ├── images/
   │		│			*│*   ├── scripts.js
   │		│			│   └── styles.css
   │		│			├── components/
   │		│			│   ├── widgets/
   │		│			│		├── todo_update.js
   │		│			│ 	├── todo_single.js
   │		│			│ 	├── todo_add.js
   │		│			│   └── todo.js
   │		│			├── app-config.json
   │		│			├── index.php
   │		│			├── readme.txt
   │		│			├── route.js
   │		│			└── services.js  -- open this file.
   ```

3. Here we should create functions for `get_todos`, `add_todo`,`update_todo`, and `delete_todo` refer below to get an idea.

   ```php

   /*
      Endpoints of the todo app
    */

   const api_url = XP.getApiUrl();

   export const todo_services = {

       /*
        *Get todo endpoint
        */
        get_todos: async function (data) {

           let response = await fetch(api_url + '/todo/get_todo?'+ new URLSearchParams(data),  {
               method: 'GET',
               credentials: "include"
           });
           return await response.json();

       },

        /*
        *Add todo endpoint
        */
        add_todo: async function (data) {

   		    let response = await fetch(api_url + "/todo/add_todo", {
               method: "POST",
               body: data,
               credentials: "include",
           });
           return await response.json();
       },

        /*
        *Update todo endpoint
        */
        update_todo: async function (data) {

   		    let response = await fetch(api_url + "/todo/update_todo", {
               method: "POST",
               body: data,
               credentials: "include",
           });
           return await response.json();
       },

        /*
        *Delete todo endpoint
        */
        delete_todo: async function (data) {

   		    let response = await fetch(api_url + "/todo/delete_todo", {
               method: "POST",
               body: data,
               credentials: "include",
           });
           return await response.json();
       },

   }

   ```

   <aside>
   🌟

   **Congratulations! We have successfully created endpoint functions on the services file. Let’s proceed to the next step.**

   </aside>

## 7. Let’s create the todo list view

1. Let’s open the todo.js to develop the frontend

   ```php
   Framework
   ├── api/   -- API Directory
   ├── apps/  -- Frontend APP Directory
   │   ├── todo/ --  Todo Front-end App
   │		│			├── assets/
   │		│			│   ├── images/
   │		│			*│*   ├── scripts.js
   │		│			│   └── styles.css
   │		│			├── components/
   │		│			│   ├── widgets/
   │		│			│		│── todo_update.js
   │		│			│ 	├── todo_single.js
   │		│			│ 	├── todo_add.js
   │		│			│   └── todo.js  -- open this file.
   │		│			├── app-config.json
   │		│			├── index.php
   │		│			├── readme.txt
   │		│			├── route.jsa
   │		│			└── services.js
   ```

2. Let’s edit the todo.js. We will add a table to view the todos and a button to add a todo, which will go to the todo_add page. and popup to edit todos., for a delete popup and mark todo as completed or active.
   1. Import components and other scripts.
   2. Register components.
   3. Define variables.
   4. Create HTML using components
   5. Write methods

   ```jsx
   import DC_Sidebar from "../../xp_system/components/navigation/dc_sidebar.js?v=1.0.0"; //let's import sidebar
   import { Data_Loader } from "/apps/xp_system/components/helpers.js?v=1.0.0"; //let's import data loader to show loading
   import DcTable from "../../xp_system/components/dc_ui_kit_componenets/DcTable.js"; //and Dc kit components that we will use
   import DcCard from "../../xp_system/components/dc_ui_kit_componenets/DcCard.js";
   import DcIconButton from "../../xp_system/components/dc_ui_kit_componenets/DcIconButton.js";
   import DcButton from "../../xp_system/components/dc_ui_kit_componenets/DcButton.js";
   import DcPopup from "../../xp_system/components/dc_ui_kit_componenets/DcPopup.js";
   import { todo_services } from "../services.js"; //we add services for calling endpoint functions.
   import { XP_Util } from "../../xp_system/util.js"; //we add util for calling util functions.

   export default {
     components: {
       //here we register the components
       DC_Sidebar,
       Data_Loader,
       DcTable,
       DcCard,
       DcButton,
       DcIconButton,
       DcPopup,
     },
     data() {
       //here we define data variables
       return {
         todo_list: [],
         selected_todo: null,
         headers: [
           {
             label: "Title",
             key: "title",
           },
           {
             label: "Status",
             key: "status",
           },
           {
             label: "Priority",
             key: "priority",
           },
           {
             label: "Created Date",
             key: "created_date",
           },
           {
             label: "Actions",
             key: "actions",
           },
         ],
         ui: {
           doing_ajax_delete: false,
           data_loading: true,
           notice: {
             show: false,
             type: "",
             text: "",
           },
         },
       };
     },
     template: `
   <!-- SideBar-->
   <DC_Sidebar />
   	 <div class="dc-app-container">
   	 
   <!-- Title -->
           <div class="dcui-flex-item dcui-justify-space-between">
                <div class="dc-big-heading">
                   <h1 class="dc-bh-heading">My Todo List</h1>
               </div>
               <div>
   	             <dc-button v-if="hasPermission('todo','add_todo')" class="dcui-button-no-fill" @click="add_todo">
   		             <span class="dcui-b-icon">
   			             <i class="fa-regular fa-plus"></i>
   			           </span>
   			           Add Todo
   		           </dc-button>
               </div>
           </div>
           
   <!-- Table -->
           <dc-card class="dcui-m-t-25">
   	         <div class="relative m-t-15">
   	            <dc-table :headers="headers" :items="todo_list">
   	                <template  v-slot:table-data="{ item }">
   	                    <td>
   	                        <div>
   	                        <!-- link to todo single -->
   	                            <router-link class="todo-link" :to="{ name: 'todo_single', params: { id: item.id }}">{{item.title}}</router-link>
   	                        </div>
   	                    </td>
   	                        <!-- capitalize status and priority  -->
   	                    <td><div>{{capitalize(item.status)}}</div></td>
   	                    <td><div>{{capitalize(item.priority)}}</div></td>
   	                    <td><div>{{item.created_date}}</div></td>
   	                    <td>
   	                        <!-- action buttons  -->
   	                    <div class="dcui-flex-item">
                              <div v-if="hasPermission('todo','update_todo')">
                                <Tooltip placement="top-center" mode="hover">
                                  <template v-slot:outlet> 
                                      <div>
                                         <dc-icon-button @click="action('edit',item)" icon="fa-solid fa-pen-to-square"></dc-icon-button>
                                      </div>
                                  </template>
                                  <template v-slot:tooltip>
                                    Edit Todo
                                  </template>
                                </Tooltip>
                               </div>
                               <div v-if="hasPermission('todo','delete_todo')">
                                   <Tooltip placement="top-center" mode="hover">
                                   <template v-slot:outlet> 
                                       <div>
                                           <dc-icon-button @click="action('delete',item)" icon="fa-solid fa-trash"></dc-icon-button>
                                       </div> 
                                  </template>
                                 <template v-slot:tooltip>
                                        Delete Todo
                                 </template>
                                   </Tooltip>
                               </div>
                               <div v-if="hasPermission('todo','update_todo')">
                                   <Tooltip placement="top-center" mode="hover">
                                   <template v-slot:outlet> 
                                       <div>
                                           <dc-icon-button 
                                               @click="mark_todo(item)" 
                                               :icon="item.status === 'active' ? 'fa-regular fa-square' : 'fa-solid fa-square-check'">
                                           </dc-icon-button>
                                       </div> 
                                  </template>
                                 <template v-slot:tooltip>
                                 {{item.status === 'active' ? 'Mark as complete': 'Mark as active'}}
                                 </template>
                                   </Tooltip>
                               </div>
                           </div>
   	                    </td>
   	                </template>
   	                <template v-if="no_todos" v-slot:custom-table-row>
                          <td class="text-center" colspan="5">No todos</td>
   	                </template>
   	            </dc-table>
               <Data_Loader transparent="true" v-if="ui.data_loading" />
              </div>
           </dc-card>
    </div>
   <!-- popups-->
      <!-- delete confirmation popup  -->
   <dc-popup ref="delete_todo_popup" title="Delete Todo" class="w-600">
      <template v-slot:content>
          <div>
             <p class="lv-typo-bold-600-f-16">Are you sure you want to delete this todo?</p>
          </div>
          <form @submit.prevent="delete_todo">
              <div class="dcui-flex-item justify-end">
                  <div class="m-r-10">
                      <dc-button type="submit" class="dcui-button-no-fill" :class="{ 'doing-ajax': ui.doing_ajax_delete }"> Delete <Ajax_Loader theme="dc" v-if="ui.doing_ajax_delete " /> </dc-button>
                   </div>
                         <div>
                             <dc-button @click="close_delete_popup">Discard</dc-button>
                         </div>
                     </div>
                  </form>
      </template>
   </dc-popup>
   
   <!-- notices-->
   
   <Transition name="fade-up"> 
       <Ajax_Notice theme="dc" v-bind="ui.notice" v-if="ui.notice.show" @dismiss_notice="(n) => ui.notice.show = ! n" />
   </Transition>
   `,
     methods: {
       //we create this function to capitalize words
       capitalize(word) {
         if (word) {
           return XP_Util.firstLetterToUpperCase(word);
         }
         return "";
       },
       //this function to direct to add todo page.
       add_todo() {
         //$router is vue object
         this.$router.push({ name: "todo_add" });
       },
       //action function
       action(action, item, index) {
         this.selected_todo = item;

         switch (action) {
           case "delete":
             this.open_delete_popup();
             break;
           case "edit":
             this.go_to_edit_page();
             break;
         }
       },
       //this function to direct to add todo update.
       go_to_edit_page() {
         if (this.selected_todo !== null) {
           const todo_id = this.selected_todo.id;
           this.$router.push({ name: "todo_update", params: { id: todo_id } });
         }
       },
       //this function to open delete popup.
       open_delete_popup() {
         //here we refer the dom element like this
         //so we can access the methods inside.
         let popup = this.$refs.delete_todo_popup;
         if (popup) {
           popup.show();
         }
       },
       //this function to close delete popup.
       close_delete_popup() {
         let popup = this.$refs.delete_todo_popup;
         if (popup) {
           popup.hide();
         }
       },
       //this function is get new data and rest the selected todo and list.
       refresh() {
         this.todo_list = [];
         this.selected_todo = null;
         this.get_todo_list();
       },
       //delete todo function to handle delete functionality
       async delete_todo() {
         if (this.selected_todo !== null) {
           this.ui.doing_ajax_delete = true;

           const todo_id = this.selected_todo.id;

           let form_data = {
             id: todo_id,
           };

           try {
             const res = await todo_services.delete_todo(
               XP.readyFormData(form_data),
             );

             this.ui.doing_ajax_delete = false;

             this.ui.notice = {
               show: true,
               type: res.response.success ? "success" : "error",
               text: res.response.statusMsg,
             };

             this.close_delete_popup();
             this.refresh();
           } catch (error) {
             let notice = {
               show: true,
               type: "error",
               text: error,
             };
           }
         }
       },
       //delete todo function to handle mark functionality.
       //here we use same update endpoint to mark this as completed or active.
       async mark_todo(item) {
         const current_status = item.status;

         const new_status =
           current_status === "active" ? "completed" : "active";

         let form_data = {
           ...item,
           status: new_status,
         };

         try {
           const res = await todo_services.update_todo(
             XP.readyFormData(form_data),
           );

           this.ui.notice = {
             show: true,
             type: res.response.success ? "success" : "error",
             text: res.response.statusMsg,
           };

           if (res.response.success) {
             this.refresh();
           }
         } catch (error) {
           this.ui.notice = {
             show: true,
             type: "error",
             text: error,
           };
         }
       },
       //this method will check for permissions
       hasPermission(name_parm, action_parm) {
         return XP.checkPermission({ name: name_parm, action: action_parm });
       },
       //this method to get todo data from endpoint
       async get_todo_list() {
         this.ui.data_loading = true;

         const data = {};

         try {
           const res = await todo_services.get_todos(data);

           this.ui.data_loading = false;

           if (res.response.success) {
             this.todo_list = res?.data?.list || [];
           }
         } catch (error) {
           this.ui.data_loading = false;
           console.error(error);
         }
       },
     },

     watch: {},
     computed: {
       //If theres no todo it will return true.
       no_todos() {
         if (this.ui.data_loading === false && this.todo_list.length === 0) {
           return true;
         } else {
           return false;
         }
       },
     },
     mounted() {
       //here we can declare functions after VDOM rendered.
     },
     created() {
       //method calling when page is created on VDOM.
       this.get_todo_list();
     },
   };
   ```

3. Let’s add some style to the style.css

   ```php
   Framework
   ├── api/   -- API Directory
   ├── apps/  -- Frontend APP Directory
   │   ├── todo/ --  Todo Front-end App
   │		│			├── assets/
   │		│			│   ├── images/
   │		│			*│*   ├── scripts.js
   │		│			│   └── styles.css -- open this file.
   │		│			├── components/
   │		│			│   ├── widgets/
   │		│			│		├── todo_update.js
   │		│			│ 	├── todo_single.js
   │		│			│ 	├── todo_add.js
   │		│			│   └── todo.js
   │		│			├── app-config.json
   │		│			├── index.php
   │		│			├── readme.txt
   │		│			├── route.jsa
   │		│			└── services.js
   ```

   1. here you can write your app style. or you can add another style file to the app config
   2. let's add these styles to the file

      ```css
      /* Styles Here */

      .todo-link {
        text-decoration: underline;
        color: var(--dcui-secondary-color);
      }
      .todo-link:hover {
        text-decoration: underline;
      }
      ```

<aside>
🌟

Congratulations! We've successfully implemented the to-do list view and completed the delete functionality, including creating links to the relevant pages. Let's move on to the next step!

</aside>

## 8. Let’s create the todo single view

1. Let’s open the todo_single.js to develop the frontend

   ```php
   Framework
   ├── api/   -- API Directory
   ├── apps/  -- Frontend APP Directory
   │   ├── todo/ --  Todo Front-end App
   │		│			├── assets/
   │		│			│   ├── images/
   │		│			*│*   ├── scripts.js
   │		│			│   └── styles.css
   │		│			├── components/
   │		│			│   ├── widgets/
   │		│			│		├── todo_update.js
   │		│			│ 	├── todo_single.js -- open this file.
   │		│			│ 	├── todo_add.js
   │		│			│   └── todo.js
   │		│			├── app-config.json
   │		│			├── index.php
   │		│			├── readme.txt
   │		│			├── route.jsa
   │		│			└── services.js
   ```

2. Let’s edit the todo_single.js.

   ```jsx
   //import the components and service file
   import DC_Sidebar from "../../xp_system/components/navigation/dc_sidebar.js?v=1.0.0";
   import { todo_services } from "../services.js";
   import DcIconButton from "../../xp_system/components/dc_ui_kit_componenets/DcIconButton.js";
   import DcTable from "../../xp_system/components/dc_ui_kit_componenets/DcTable.js";
   import DcCard from "../../xp_system/components/dc_ui_kit_componenets/DcCard.js";
   export default {
     //register the ui components here
     components: {
       DC_Sidebar,
       DcIconButton,
       DcTable,
       DcCard,
     },
     data() {
       return {
         //table headers and other variables here
         todo_data: [],
         todo_id: null,
       };
     },
     template: `
   <DC_Sidebar />
   <div class="dc-app-container">
           <div class="dcui-flex-item">
               <div>
                   <dc-icon-button @click="go_to_list" icon="fa-solid fa-chevron-left"></dc-icon-button>
               </div>
               <!--Title of the todo displayed here-->
                <div class="dc-big-heading">
                   <h1 class="dc-bh-heading" v-text="todo_title"></h1>
               </div>
           </div>
           <div>
           <!-- Here we created a card and table to show data -->
               <dc-card class="dcui-m-t-25">
                   <div class="dcui-row">
                      <div class="dcui-col-md-1">Title</div>
                      <div v-if="todo_data.title" class="dcui-col-md-3">: {{ todo_data.title }}</div>
                   </div>
                   <div class="dcui-row">
                   <div class="dcui-col-md-1">Description</div>
                      <div v-if="todo_data.description" class="dcui-col-md-3">: {{ todo_data.description }}</div>
                   </div>
                   <div class="dcui-row">
                   <div class="dcui-col-md-1">Status</div>
                      <div v-if="todo_data.status" class="dcui-col-md-3">: {{ todo_data.status }}</div>
                   </div>
                   <div class="dcui-row">
                   <div class="dcui-col-md-1">Priority</div>
                      <div v-if="todo_data.priority" class="dcui-col-md-3">: {{ todo_data.priority }}</div>
                   </div>
                   <div class="dcui-row">
                   <div class="dcui-col-md-1">Created Date</div>
                      <div v-if="todo_data.created_date" class="dcui-col-md-3">: {{ todo_data.created_date }}</div>
                   </div>
                   <div class="dcui-row">
                   <div class="dcui-col-md-1">Updated Date</div>
                      <div v-if="todo_data.updated_date" class="dcui-col-md-3">: {{ todo_data.updated_date }}</div>
                   </div>
             </dc-card>
           </div>
   </div>
   `,
     methods: {
       //Direct to main page 'todo'
       go_to_list() {
         this.$router.push({ name: "todo" });
       },
       //This method is to get data from calling get todos endpoint
       async get_todo_data(todo_id) {
         try {
           const param_data = {
             id: todo_id,
           };

           const res = await todo_services.get_todos(param_data);

           if (res.response.success) {
             this.todo_data = res?.data || [];
           }
         } catch (error) {
           console.error(error);
         }
       },
     },
     watch: {},
     computed: {
       //default title will be todo. if the title available in the todo data it will show the title
       todo_title() {
         if (Array.isArray(this.todo_data) && this.todo_data.length > 0) {
           return this.todo_data[0]?.title || "Todo";
         }
         return "Todo";
       },
     },
     mounted() {},
     created() {
       // first we get the id from the passed params if available else return to todo list.
       // get data from the endpoint if id is available
       let todo_id = (this.todo_id = this.$route.params.id || "");
       if (todo_id) {
         this.get_todo_data(todo_id);
       } else {
         this.$router.push({ name: "todo" });
       }
     },
   };
   ```

   <aside>
   🌟

   Congratulations! We've successfully implemented the to-do single view and completed it.

   </aside>

## 9. Let’s create the add-todo view

1. **First, let’s create a reusable form component for adding and updating.**
   1. Let's create a dir called shared and inside that we will make our `todo_form.js`.

      ```jsx
      Framework
      ├── api/   -- API Directory
      ├── apps/  -- Frontend APP Directory
      │   ├── todo/ --  Todo Front-end App
      │		│			├── assets/
      │		│			│   ├── images/
      │		│			*│*   ├── scripts.js
      │		│			│   └── styles.css
      │		│			├── components/
      │		│			│   ├── widgets/
      │		│			│   ├── shared/
      │		│			│ 	│ 	└── todo_form.js  -- create this file.
      │		│			│		├── todo_update.js
      │		│			│ 	├── todo_single.js
      │		│			│ 	├── todo_add.js
      │		│			│   └── todo.js  -- open this file.
      │		│			├── app-config.json
      │		│			├── index.php
      │		│			├── readme.txt
      │		│			├── route.jsa
      │		│			└── services.js
      ```

   2. Here we will import components and script first.
   3. We will define props to get data to the component such as `modelValue` prop, `validate_config` prop, etc.
   4. Next, register the components and declare data variables.
   5. Create HTML using components.
   6. Write methods.

      ```jsx
      //import components,services and validator.
      import DcInputField from "../../../xp_system/components/dc_ui_kit_componenets/DcInputField.js";
      import DcTextField from "../../../xp_system/components/dc_ui_kit_componenets/DcTextField.js";
      import DcDropdown from "../../../xp_system/components/dc_ui_kit_componenets/DcDropdown.js";
      import { validateField } from "../../../xp_system/validator.js";
      import { XP_Util } from "../../../xp_system/util.js";

      export default {
        //props to get data into the component
        props: {
          modelValue: Object,
          validation_config: Object,
          form_errors: {
            type: Object,
            default: {},
          },
          form_type: {
            type: String,
            default: "add",
          },
        },
        //register here the components
        components: {
          DcInputField,
          DcTextField,
          DcDropdown,
        },
        data() {
          //data variables
          return {
            inputs: {
              title: this.modelValue.title || "",
              description: this.modelValue.description || "",
              status: this.modelValue.status || "",
              priority: this.modelValue.priority || "",
            },
            status_options: [
              { label: "Active", value: "active" },
              { label: "Completed", value: "completed" },
            ],
            priority_options: [
              { label: "Low", value: "low" },
              { label: "Normal", value: "normal" },
              { label: "High", value: "high" },
            ],
            errors: {},
          };
        },
        template: `
      <!-- row and columns used to structure the form -->
        <div class="dcui-row"> 
            <div class="dcui-col-sm-6 dcui-col-lg-4">
               <div class="flex-grow-1">
               <!-- title input field form -->
                  <dc-input-field 
                      id="todo-fld-style-id"
                      v-model="inputs.title"
                      placeholder="Title"
                      required>
                  </dc-input-field>
                    <!-- display the error here if there is -->
                  <span class="dcui-text-danger" v-if="errors.todo_title"> {{ errors.todo_title }}</span>
              </div>
            </div>
        </div>
        <div class="dcui-row"> 
           <div class="dcui-col-sm-3 dcui-col-lg-2">
             <!-- dropdown for status -->
              <dc-dropdown 
                  labelKey="label" 
                  valueKey="value" 
                  @blur="validate('status')"
                  @change="validate('status')"
                  v-model="inputs.status" 
                  :color_selected="true">
                      <template v-slot:label="{selected_value}">
                          <div v-if="selected_value" >{{capitalize(selected_value)}}</div>
                          <div v-else>Status</div>
                      </template>
                      <template  v-slot:content="slotProps">
                          <li  v-for="(item,index) in status_options" :key="index" @click="slotProps.select(item,index)" :class="{'selected':slotProps.selected_index === index}">
                              <a>
                                  <div class="flex-item dcui-justify-space-between dcui-align-center">
                                      <div class="dcui-flex-item align-center">
                                         <div>{{item.label}}</div>
                                      </div>
                                      <div class="dcui-select-dropdown-close" v-if="slotProps.selected_index === index">
                                          <i class="fa-regular fa-xmark"></i>
                                      </div>
                                  </div>
                              </a>
                          </li>
                      </template>
              </dc-dropdown>
              <span class="dcui-text-danger" v-if="errors.status"> {{ errors.status }}</span>
          </div>
          <div class="dcui-col-sm-3 dcui-col-lg-2">
              <dc-dropdown 
                  labelKey="label" 
                  valueKey="value" 
                  @blur="validate('priority')"
                  @change="validate('priority')"
                  v-model="inputs.priority" 
                  :color_selected="true">
                      <template v-slot:label="{selected_value}">
                          <div v-if="selected_value" >{{capitalize(selected_value)}}</div>
                          <div v-else>Priority</div>
                      </template>
                      <template  v-slot:content="slotProps">
                          <li  v-for="(item,index) in priority_options" :key="index" @click="slotProps.select(item,index)" :class="{'selected':slotProps.selected_index === index}">
                              <a>
                                  <div class="flex-item dcui-justify-space-between dcui-align-center">
                                      <div class="dcui-flex-item align-center">
                                         <div>{{item.label}}</div>
                                      </div>
                                      <div class="dcui-select-dropdown-close" v-if="slotProps.selected_index === index">
                                          <i class="fa-regular fa-xmark"></i>
                                      </div>
                                  </div>
                              </a>
                          </li>
                      </template>
              </dc-dropdown>
              <span class="dcui-text-danger" v-if="errors.priority"> {{ errors.priority }}</span>
          </div>
       </div>
       <div class="dcui-row"> 
         <div class="dcui-col-sm-6 dcui-col-lg-4">
          <!-- text area for description -->
            <dc-text-field 
                  id="todo-fld-style-description" 
                  v-model="inputs.description"
                  placeholder="Description" 
                  :resize="false" 
                  >
            </dc-text-field>
             <span class="dcui-text-danger" v-if="errors.description"> {{ errors.description }}</span>
         </div>
       </div>                          
      `,
        watch: {
          //watching for modelValue changes and assign it to inputs
          modelValue: {
            handler(newValue) {
              this.inputs = newValue;
            },
            deep: true,
          },
          //watching for form_errors changes and assign it to errors
          form_errors: {
            handler(newValue) {
              this.errors = newValue;
            },
          },
          //watching for inputs changes and push data to modelValue
          inputs: {
            handler(newValue) {
              this.$emit("update:modelValue", newValue);
            },
            deep: true,
          },
        },
        computed: {},
        methods: {
          //function for capitalize
          capitalize(word) {
            if (word) {
              return XP_Util.firstLetterToUpperCase(word);
            }
            return "";
          },
          //validate the form fields and check for the config
          validate(field) {
            this.errors[field] = validateField(
              field,
              this.inputs[field],
              this.inputs,
              this.validation_config,
            );
          },
          //clear the form
          clear_form_data() {
            this.inputs = {
              title: "",
              description: "",
              status: "",
              priority: "",
            };
          },
        },
        mounted() {},
        created() {},
      };
      ```

2. Now we have created the form component. Let’s open the todo_add.js to develop.

   ```php
   Framework
   ├── api/   -- API Directory
   ├── apps/  -- Frontend APP Directory
   │   ├── todo/ --  Todo Front-end App
   │		│			├── assets/
   │		│			│   ├── images/
   │		│			*│*   ├── scripts.js
   │		│			│   └── styles.css
   │		│			├── components/
   │		│			│   ├── widgets/
   │		│			│   ├── shared/
   │		│			│ 	│ 	└── todo_form.js
   │		│			│		├── todo_update.js
   │		│			│ 	├── todo_single.js
   │		│			│ 	├── todo_add.js -- open this file.
   │		│			│   └── todo.js
   │		│			├── app-config.json
   │		│			├── index.php
   │		│			├── readme.txt
   │		│			├── route.jsa
   │		│			└── services.js
   ```

3. Let’s edit the todo_add.js

   ```php
   //import components and services
   import DC_Sidebar from "../../xp_system/components/navigation/dc_sidebar.js?v=1.0.0";
   import {validateForm, validationRules} from "../../xp_system/validator.js";
   import todo_form from "./shared/todo_form.js";
   import {todo_services} from "../services.js";
   import DcButton from "../../xp_system/components/dc_ui_kit_componenets/DcButton.js";
   import DcIconButton from "../../xp_system/components/dc_ui_kit_componenets/DcIconButton.js";

   export default {
       //register the ui components and todo_form
       components: {
           DC_Sidebar,
           todo_form,
           DcButton,
           DcIconButton,
       },
       data() {
           return {
               //inputs data property to store form data
               inputs: {
                   title: "",
                   description: "",
                   status: "",
                   priority: "",
               },
               //validate config to set rules for properties
               validation_config: {
                   title: {
                       rules: [validationRules.required],
                   },

                   description: {
                       rules: [validationRules.optional],
                   },

                   status: {
                       rules: [validationRules.required],
                   },

                   priority: {
                       rules: [validationRules.required],
                   },

               },
               //to store errors
               form_errors: {},
               ui: {
                   doing_ajax:false,
                   notice: {
                       show: false,
                       type: "",
                       text: "",
                   },
               },
           };
       },
       template: `
   <DC_Sidebar />
   <div class="dc-app-container">
       <div class="dcui-flex-item">
           <div>
           <!-- back button go to todo list -->
             <dc-icon-button @click="go_to_list" icon="fa-solid fa-chevron-left"></dc-icon-button>
           </div>
           <div class="dc-big-heading">
              <h1 class="dc-bh-heading">Create Todo</h1>
           </div>
       </div>
       <div class="m-t-10">
       <!--form implementation and submit  -->
           <form @submit.prevent="add_todo">
           <!-- Html here or the components -->
               <div>
               <!--todo form component -->
                   <todo_form form_type="add" ref="todo_add_form" :validation_config="validation_config" :form_errors="form_errors" v-model="inputs"></todo_form>
               </div>
               <div>
                   <dc-button type="submit" :class="{ 'doing-ajax': ui.doing_ajax }"> Create <Ajax_Loader theme="dc" v-if="ui.doing_ajax" /> </dc-button>
               </div>
           </form>
       </div>
   </div>
   <Transition name="fade-up">
       <Ajax_Notice theme="dc" v-bind="ui.notice" v-if="ui.notice.show" @dismiss_notice="(n) => ui.notice.show = ! n" />
   </Transition>
   `,
       methods: {
           //function to go to do list
           go_to_list(){
               this.$router.push({ name: 'todo' });
           },
           //function adds to do
           async add_todo(type = null) {
               //function validates the input data according to the config and return true or false
               const {errors, isValid} = validateForm(this.inputs, this.validation_config);

               //assign errors to the variable
               this.form_errors = errors;

               if (isValid) {

                   //send data to add todo endpoint
                   this.ui.doing_ajax = true;

                   let form_data = this.inputs;

                   try {

                       const res = await todo_services.add_todo(XP.readyFormData(form_data));

                       this.ui.doing_ajax = false;

                       this.ui.notice = {
                           show: true,
                           type: res.response.success ? "success" : "error",
                           text: res.response.statusMsg,
                       };

                       if (res.response.success) {
                           this.go_to_list();
                       }

                   } catch (error) {
                       this.ui.notice = {
                           show: true,
                           type: "error",
                           text: error,
                       };
                   }
               }
           },
       },
       watch: {},
       computed: {},
       mounted() {
       },
       created() {
       }
   };
   ```

<aside>
🌟

Congratulations! We've successfully implemented the add-to-do view. Let's move on to the next step!

</aside>

## 10. Let’s create the update todo view

1. Let’s open the todo_single.js to develop the frontend

   ```php
   Framework
   ├── api/   -- API Directory
   ├── apps/  -- Frontend APP Directory
   │   ├── todo/ --  Todo Front-end App
   │		│			├── assets/
   │		│			│   ├── images/
   │		│			*│*   ├── scripts.js
   │		│			│   └── styles.css
   │		│			├── components/
   │		│			│   ├── widgets/
   │		│			│		├── todo_update.js -- open this file.
   │		│			│ 	├── todo_single.js
   │		│			│ 	├── todo_add.js
   │		│			│   └── todo.js
   │		│			├── app-config.json
   │		│			├── index.php
   │		│			├── readme.txt
   │		│			├── route.jsa
   │		│			└── services.js
   ```

2. Let’s edit the todo_update.js.

   ```jsx
   //import components and services
   import DC_Sidebar from "../../xp_system/components/navigation/dc_sidebar.js?v=1.0.0";
   import { validateForm, validationRules } from "../../xp_system/validator.js";
   import todo_form from "./shared/todo_form.js";
   import { todo_services } from "../services.js";
   import DcButton from "../../xp_system/components/dc_ui_kit_componenets/DcButton.js";
   import DcIconButton from "../../xp_system/components/dc_ui_kit_componenets/DcIconButton.js";

   export default {
     //register the ui components and todo_form
     components: {
       DC_Sidebar,
       todo_form,
       DcButton,
       DcIconButton,
     },
     data() {
       return {
         //inputs data property to store form data
         inputs: {
           id: "",
           title: "",
           description: "",
           status: "",
           priority: "",
         },
         //validate config to set rules for properties
         validation_config: {
           title: {
             rules: [validationRules.required],
           },

           description: {
             rules: [validationRules.optional],
           },

           status: {
             rules: [validationRules.required],
           },

           priority: {
             rules: [validationRules.required],
           },
         },
         //to store errors
         form_errors: {},
         ui: {
           doing_ajax: false,
           notice: {
             show: false,
             type: "",
             text: "",
           },
         },
       };
     },
     template: `
   <DC_Sidebar />
   <div class="dc-app-container">
        <div class="dcui-flex-item">
           <div>
               <!-- back button go to todo list -->
               <dc-icon-button @click="go_to_list" icon="fa-solid fa-chevron-left"></dc-icon-button>
           </div>
           <div class="dc-big-heading">
             
              <h1 class="dc-bh-heading">Update Todo</h1>
           </div>
       </div>
       <div class="m-t-10">
        <!--form implementation and submit  -->
           <form @submit.prevent="update_todo">
               <div>
                  <!--todo form component -->
                   <todo_form form_type="update" ref="todo_update_form" :validation_config="validation_config" :form_errors="form_errors" v-model="inputs"></todo_form>
               </div>
               <div>
                   <dc-button type="submit" :class="{ 'doing-ajax': ui.doing_ajax }"> Update <Ajax_Loader theme="dc" v-if="ui.doing_ajax" /> </dc-button>
               </div>
           </form>
       </div>
   </div>
   <Transition name="fade-up"> 
       <Ajax_Notice theme="dc" v-bind="ui.notice" v-if="ui.notice.show" @dismiss_notice="(n) => ui.notice.show = ! n" />
   </Transition>
   `,
     methods: {
       //function to go to do list
       go_to_list() {
         this.$router.push({ name: "todo" });
       },
       //function update to do
       async update_todo(type = null) {
         //function validates the input data according to the config and return true or false
         const { errors, isValid } = validateForm(
           this.inputs,
           this.validation_config,
         );

         //assign errors to the variable
         this.form_errors = errors;

         if (isValid) {
           //send data to add todo endpoint
           this.ui.doing_ajax = true;

           let form_data = this.inputs;

           try {
             const res = await todo_services.update_todo(
               XP.readyFormData(form_data),
             );

             this.ui.doing_ajax = false;

             this.ui.notice = {
               show: true,
               type: res.response.success ? "success" : "error",
               text: res.response.statusMsg,
             };

             if (res.response.success) {
               this.go_to_list();
             }
           } catch (error) {
             this.ui.notice = {
               show: true,
               type: "error",
               text: error,
             };
           }
         }
       },
       //assign data to input object
       assign_to_inputs(todo_data) {
         this.inputs.id = todo_data.id;
         this.inputs.title = todo_data.title;
         this.inputs.description = todo_data.description || "";
         this.inputs.status = todo_data.status;
         this.inputs.priority = todo_data.priority;
       },
       //get todo data by calling the get todos endpoint
       async get_todo_data(todo_id) {
         try {
           const param_data = {
             id: todo_id,
           };

           const res = await todo_services.get_todos(param_data);

           if (res.response.success) {
             const todo_data = res?.data || [];
             this.assign_to_inputs(todo_data);
           }

           this.ui.doing_ajax_delete = false;
         } catch (error) {
           console.error(error);
         }
       },
     },
     watch: {},
     computed: {},
     mounted() {},
     created() {
       // first we get the id from the passed params if available else return to todo data.
       // get data from the endpoint if id is available
       let todo_id = (this.todo_id = this.$route.params.id || "");
       if (todo_id) {
         this.get_todo_data(todo_id);
       } else {
         this.$router.push({ name: "todo" });
       }
     },
   };
   ```

<aside>
🌟

Congratulations! We've successfully implemented the update to-do view. Congratulations now you have a working todo app.

</aside>

<aside>
🌟

Congratulations! We've successfully built a to-do app

</aside>
