# Util

Owner: Nuwan Danushka

# Introduction

The Util module in the DoFramework delivers a versatile toolkit comprising essential utility classes tailored to streamline common programming challenges. From handling date and time functionalities to managing IP addresses and performing data validations, this module offers a comprehensive array of tools to simplify development tasks. With classes such as CommonFunctions, DateTime, IPManager, TimeZone, and Validations, developers gain access to reusable components that enhance code efficiency and maintainability. By incorporating the Util Classes module into their projects, developers can accelerate development workflows, promote code reusability, and ensure robustness across various application scenarios.

---

# How to Access The Util Module’s Classes

To access the classes within the Util module, you can utilize either Type 1 or Type 2.

Type 1 includes static methods, while Type 2 does not.

---

## Type 1: Access Static Methods in Util Class

```php
// Access Util class for static methods
$timestamp = Util::DateAndTimeManager()::get_timestamp();
```

In this step:

- **`DateAndTimeManager()`** is a static method inside the **`Util`** class, returning a class that manages date and time.
- Then, we call the **`get_timestamp()`** method on the returned class to retrieve the timestamp.

---

## **Type2: Access Non-Static Methods in Util Class**

```php
// Access Util class for non-static methods
$common_functions_obj = Util::CommonFunction(); // Returns an instance of the CommonFunction class
$country_list = $common_functions_obj->countryList(); // Call the countryList() function
```

In this step:

- **`CommonFunction()`** is a method inside the **`Util`** class, returning an instance of the **`CommonFunction`** class.
- We store this instance in **`$common_functions_obj`**.
- Then, we call the **`countryList()`** method on the **`$common_functions_obj`** instance to retrieve the list of countries.

---
