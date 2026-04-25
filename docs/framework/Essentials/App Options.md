# App Options

Owner: Nuwan Danushka

<aside>
💡 Note that we can insert any number of options into the option table and access them in the backend. However, only the allowed options can be retrieved from the frontend framework. This makes it clear that while you can manage options freely in the backend, the frontend framework is restricted to certain options.

</aside>

# Backend

## How To Insert An Options

Inserting the options is typically achieved by calling the static method in the app_option class called insert_option. Within our framework, we employ an inset option feature to insert/update options.

```php
app_options::insert_option(app_name,option_name,option_value);
```

The parameters for this method include:

- **`app_name`**: The app_name.
- **`option name`**: The name of the option.
- **`option value`**: The value of the option.

Here’s an example of how this insert option method is used.

```php
app_options::insert_option('la_vivente_pms','process_task_name',la_vivente_pms::$DEFAULT_PROCESS_NAME);
```

In this example, the option is inserted or updated in the option table specific to the app. The app name should be specified to determine which app's option table will store the data. The second parameter is the option name, and the last parameter is the value. After calling the method, it will either update the existing value or insert a new one.

## How To Get All Options

Getting the options in the framework is typically achieved by calling the static method in the app_option class called get_app_options. Within our framework, we employ a get option list categorized by app name.

```php
app_options::get_app_options();
```

Here’s an example of how the output will look like.

```php
Array
(
    [la_vivente_pms] => Array
        (
            [process_task_name] => Style
            [process_task_prefix] => LV
            [process_name] => Production
            [process_task_name_plural] => Styles
            [enable_editable_process_name_create] => false
            [enable_editable_process_name_edit] => false
            [enable_show_process_name_create] => false
            [enable_show_process_name_edit] => true
        )

)
```

## How To Get A Specific Application and/or a Specific Option

Getting the options in the framework is typically achieved by calling the static method in the app_option class called get_option.

```php
app_options::get_option($app_name = null, $option_name = null);
```

The parameters for this method include:

- **`app_name`**: The app_name.
- **`option name`**: The name of the option.

Here are examples of how the output will look like.

<aside>
💡 If there are no options for given names it will return an empty array

</aside>

```php
---------------------------------------------------------
											Example 1
---------------------------------------------------------

* function - app_options::get_option('la_vivente_pms');
* Output -
Array
(
    [process_task_name] => Style
    [process_task_prefix] => LV
    [process_name] => Production
    [process_task_name_plural] => Styles
    [enable_editable_process_name_create] => false
    [enable_editable_process_name_edit] => false
    [enable_show_process_name_create] => false
    [enable_show_process_name_edit] => true
)

---------------------------------------------------------
											Example 2
---------------------------------------------------------

* function - app_options::get_option('la_vivente_pms','process_task_name');
* Output - Style

```

In the first example, we demonstrate how to retrieve all options that belong to the app. If options are available for the app, it will return an array with those options. In the second example, we specify the app name and option name. If a matching option is found, it will return a string value.

## How to Initialize App Options When Installing or Updating the App

We can add a run script to our app that executes when installing or reinitializing the app from the admin panel. Within this script, we can call the `init_app_options` function, which adds options to the table specified in the configuration. Options under the `allowed_options` tag will be populated with empty values.

```php
app_options::init_app_options($app_name);
```

The parameters for this method include:

- **`app_name`**: The app_name.

# Frontend

## How to Access & Get Options

To access and retrieve options in the app, you can use the `get_option` method from the `app_options` object.

```php
app_options::get_option(app_name = null, option_name = null);
```

The parameters for this method include:

- **`app_name`**: The name of the app.
- **`option_name`**: The name of the option.

Example 1: Retrieving All Options for an App

```jsx
const app_option_lv_pms = XP.app_options.get_option('la_vivente_pms');
```

In this example, `get_option` retrieves all options for the app `la_vivente_pms`, and stores them in the `app_option_lv_pms` variable as an object:

```jsx
{
    "process_task_name": "Style",
    "process_task_prefix": "LV",
    "process_name": "Production",
    "process_task_name_plural": "Styles",
    "enable_editable_process_name_create": "false",
    "enable_editable_process_name_edit": "false",
    "enable_show_process_name_create": "false",
    "enable_show_process_name_edit": "true"
}
```

Example 2: Retrieving a Specific Option

```jsx
const app_option_lv_pms = XP.app_options.get_option('la_vivente_pms','process_name');
```

In this example, `get_option` retrieves the value of the `process_name` option for the `la_vivente_pms` app, and stores it in the `app_option_lv_pms` variable as a string:

```jsx
Production
```

<aside>
💡 If the specified app or option doesn't have any data, the method will return `undefined`.

</aside>