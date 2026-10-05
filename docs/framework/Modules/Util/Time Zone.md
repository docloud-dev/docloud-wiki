---
title: Time Zone
sidebar_label: Time Zone
---

# Time Zone

Owner: Nuwan Danushka

# Introduction

The `Timezone` class gives you lists of time zones for drop-downs and a lookup of the client's time zone from their IP address. Get an object through the Util accessor:

```php
$time_zone_object = Util::Timezone();
```

To convert dates between zones, use [Date And Time Manager](Date%20And%20Time%20Manager.md).

---

## Time Zone Methods

### getTimezone

Description:

The **`getTimezone`** method looks up the current time and time zone for the client's IP address. It reads the IP with `IpManager::get_client_ip()` and sends it to the public timeapi.io service (`https://timeapi.io/api/Time/current/ip`).

Syntax:

```php
$time_zone_object = Util::Timezone();
$result = $time_zone_object->getTimezone();

if ($result !== null) {
    $zone = $result['timeZone'];   // e.g. "Asia/Colombo"
}
```

**Return Value:**

- **`Array`**: The decoded JSON response from timeapi.io. It includes keys such as `timeZone`, `dateTime`, `date`, `time`, `dayOfWeek` and `dstActive`.
- **`null`**: The client IP could not be read, the request failed, or the response was not valid JSON.

<aside>
💡 This makes an outbound HTTP request on every call, so the server needs internet access and the call adds latency. On a local machine the client IP is `127.0.0.1` or `::1`, which the service cannot place, so expect `null`. The IP comes from headers a client can set; see [IP Manager](IP%20Manager.md).

</aside>

---

### createTimezoneList

Description:

The **`createTimezoneList`** static method returns every time zone ID that PHP knows from `DateTimeZone::listAbbreviations()`, without duplicates, sorted alphabetically.

Syntax:

```php
$zones = Timezone::createTimezoneList();
// ['Africa/Abidjan', 'Africa/Accra', 'Africa/Addis_Ababa', ...]
```

**Return Value:**

- **`Array`**: A list of time zone ID strings, indexed from 0. It is never `false`.

---

### timezoneList

Description:

The **`timezoneList`** method returns a fixed list of 424 time zones with display labels, ordered by UTC offset from GMT -11:00 to GMT +14:00. Use it to fill a time zone picker.

Syntax:

```php
$time_zone_object = Util::Timezone();
$result = $time_zone_object->timezoneList();
// [
//   ['name' => 'Pacific/Pago_Pago', 'value' => '(GMT -11:00) Pago Pago'],
//   ...
//   ['name' => 'Asia/Colombo', 'value' => '(GMT +05:30) Colombo'],
//   ...
// ]
```

**Return Value:**

- **`Array`**: One row per time zone, each with two keys:
  - **`name`**: The time zone ID, such as `Asia/Colombo`. Store this value.
  - **`value`**: The display label, such as `(GMT +05:30) Colombo`.

The offsets in the labels are fixed text. They show standard time and don't change during daylight saving time. The method's code still has a `false` branch for an empty list, but the list is hard-coded, so it always returns rows.

---
