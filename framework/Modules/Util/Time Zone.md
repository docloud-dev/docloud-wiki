# Time Zone

Owner: Nuwan Danushka

# Introduction

Introducing the TimeZone Class : Simplifying Timezone Management in the Do Framework. This module offers streamlined handling of timezone-related data, ensuring accurate temporal representation in your applications.

---

## Time Zone Methods

### getTimezone

Description:

The **`getTimezone`** method is utilized to fetch geolocation data based on the client's IP address.

Syntax:

```php
$time_zone_object = Util::Timezone();
$result = $time_zone_object->getTimezone();
```

**Return Value:**

- **`Array`**: Geolocation data for the client's IP address, or **`null`** on failure.

This method retrieves geolocation data based on the client's IP address. It returns an array containing the geolocation information if successful, or **`null`** if it fails to retrieve the data.

---

### createTimezoneList

Description:

The **`createTimezoneList`** method is utilized to generate a list of timezones with their display names.

Syntax:

```php
$time_zone_object = Util::Timezone();
$result = $time_zone_object->createTimezoneList();
```

**Return Value:**

- **`Array`**: An array containing timezone names and display names, or false if empty.

This method generates a list of timezones with their corresponding display names. It returns an array containing timezone names and display names if successful, or **`false`** if the list is empty.

---

### timezoneList

Description:

The **`timezoneList`** method is utilized to generate a list of timezones with their display names.

Syntax:

```php
$time_zone_object = Util::Timezone();
$result = $time_zone_object->timezoneList();
```

**Return Value:**

- **`Array`**: An array containing timezone names and display names, or false if empty.

This method generates a list of timezones with their corresponding display names. It returns an array containing timezone names and display names if successful, or **`false`** if the list is empty.

---