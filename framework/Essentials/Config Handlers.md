# Config Handlers

Owner: Nuwan Danushka

# How to Use Frontend Config Handler

The framework provides a Frontend Config Handler to manage frontend configuration dynamically. This guide explains how to utilize it effectively.

---

### Frontend Framework Config (Reference)

Below is an example of the frontend configuration structure:

```json
{
    "version": "0.0.16",
    "release_date": "0000-00-00",
    "res_version": "0.0.16",
    "last_impact_time": 1714129151,
    "mode": "dev",
    "doc_title": "Do App",
    "service_worker": {
        "enable_service_worker": "false",
        "path": "/sw.js",
        "version":"1.0.0",
        "debug": "true"
    },
    // ... rest of the properties
    "resources": {
        "scripts": [
            {
                "url": "./assets/libs/vuex/4.0.0/vuex.js"
            },
            {
                "url": "./xp.js"
            },
            {
                "url": "./assets/libs/dc-ui-kit/0.0.2/dc-ui-kit.js"
            },
            {
                "url": "./assets/libs/dc-ui-kit/0.0.2/dc-script.js"
            }
            // ... rest of the properties
        ],
        "styles": [
            {
                "url": "./assets/libs/vue-quill/1.1.1/vue-quill.snow.css"
            },
            {
                "url": "./assets/libs/font-awesome/6-pro/css/all.min.css"
            },
            {
                "url": "./assets/libs/dc-ui-kit/0.0.2/dc-ui-kit.css"
            },
            {
                "url": "./assets/libs/dc-ui-kit/0.0.2/dc-style.css"
            }
           // ... rest of the properties
        ]
    },
    "_comments": {
        "version": "XP Framework version",
        "res_version": "Resources version of the system. Use to force-download new resource updates to the browser. Hard cache clearance",
        "mode": "The running environment of the system. Accepted values: dev | staging | live"
    },
    "_public": [
        "version",
        "res_version",
        "release_date",
        "mode",
				// ... rest of the properties
    ]
}

```

---

## 1. **Create a Config Handler Object**

Start by creating a Config Handler object. Depending on your needs, specify the configuration type as either **`admin_config`** or **`app_config`**.

**Example:**

```php
$config_handler = DoFrontend::DoFrontendConfigHandler($config_type);
```

<aside>
💡

The default value for the `DoFrontendConfigHandler` parameter is `app_config`.

</aside>

---

## 2. **Modify Root-Level Properties**

You can add, update, or remove root-level properties in the configuration.

### **Add or Update a Root Property**

Use the `manage_root_config_key` method to add or update a property.

**Example:**

```php
$config_handler = DoFrontend::DoFrontendConfigHandler('app_config');
$config_handler->manage_root_config_key("add", "version", "0.0.17");
```

### **Remove a Root Property**

To remove a property, specify the action as `"remove"`.

**Example:**

```php
$config_handler->manage_root_config_key("remove", "version");
```

---

## 3. **Modify Resources**

You can manage script and style resources in the `resources` section of the configuration.

### **Add a Resource**

Add a new resource to the `scripts` or `styles` array.

**Example:**

```php
$config_handler->manage_resource_in_config('add', 'scripts', './assets/libs/dc-ui-kit/0.0.2/dc-ui-kit.js');
```

### **Remove a Resource**

Remove an existing resource from the `scripts` or `styles` array.

**Example:**

```php
$config_handler->manage_resource_in_config('remove', 'styles', './assets/libs/dc-ui-kit/0.0.2/dc-style.css');
```

---

## 4. **Modify the `_public` Section**

The `_public` section defines properties exposed for public access. You can use the `modify_config_section_array_items` method to add or remove items in this section. This method works with any array-based section within the configuration.

### **Add Items to `_public`**

To add items to the `_public` array, specify `"add"` as the action, the section name (e.g., `_public`), and an array of items to add.

**Example:**

```php
$config_handler->modify_config_section_array_items('add', '_public', [
    "service_worker", "dashboard_page_name", "login_redirection", "external_dashboard"
]);
```

### **Remove Items from `_public`**

To remove items, specify `"remove"` as the action, the section name (e.g., `_public`), and an array of items to remove.

**Example:**

```php
$config_handler->modify_config_section_array_items('remove', '_public', [
    "service_worker", "dashboard_page_name", "login_redirection", "external_dashboard"
]);
```

---

This revised documentation eliminates redundancy and clarifies the usage of methods while retaining the necessary details. Let me know if further refinement is needed!

---

# How to Use Backend Config Handler