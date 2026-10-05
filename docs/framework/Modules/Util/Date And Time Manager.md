---
title: Date And Time Manager
sidebar_label: Date And Time Manager
---

# Date And Time Manager

Owner: Nuwan Danushka

# Introduction

`DateAndTimeManager` is the Util class for parsing dates, building lists of dates, measuring the gap between two dates and converting between time zones. Every method is static. Reach the class through the Util accessor:

```php
$today = Util::DateAndTimeManager()::get_system_datetime('Y-m-d');
```

Most methods take and return dates as `Y-m-d` strings (`2026-10-05`) and date-times as `Y-m-d H:i:s` strings (`2026-10-05 14:30:00`).

## Time zones in the framework

Since 0.0.23 the framework keeps PHP and MySQL on the same clock:

- `api/Config.php` calls `date_default_timezone_set('Asia/Colombo')`. Every entry point (HTTP, shell and heartbeat) loads that file, so `date()`, `strtotime()` and `new DateTime()` work in `Asia/Colombo` unless you pass another zone.
- When the database class opens a connection, it sets the MySQL session `time_zone` to PHP's current offset (`+05:30`). `CURRENT_TIMESTAMP` and `NOW()` then match the values PHP produces.

A separate setting, `system_api_timezone` in `api/config.<environment>.xml`, holds the zone that `get_system_datetime` converts to. See [Configuration Files](../../Essentials/Configuration%20Files.md).

---

# How to get the current date and time

```php
$dtm = Util::DateAndTimeManager();

$now   = $dtm::get_system_datetime();          // "2026-10-05 14:30:00", in system_api_timezone
$today = $dtm::get_system_datetime('Y-m-d');   // "2026-10-05"
$unix  = $dtm::get_timestamp();                // 1791190800

// Five minutes from now, expressed in UTC
$expires = $dtm::add_time('5 minutes', 'UTC');
```

---

# How to build a list of dates

Use the method that matches the shape you need. All of them return arrays of `Y-m-d` strings.

```php
$dtm = Util::DateAndTimeManager();

// Every date from start to end, inclusive, plus a rough size label
$range = $dtm::createInterval('2026-01-01', '2026-01-09');
// ['type' => 'weeks', 'date_range' => ['2026-01-01', ..., '2026-01-09']]

// The Monday-to-Sunday week that contains a date
$week = $dtm::getDateRange('2026-10-07');
// ['2026-10-05', '2026-10-06', ..., '2026-10-11']

// The last 7 days, counting back from today
$lastWeek = $dtm::forwardBackwardDateRange(null, false, 7);

// A start date plus 4 repeats of an interval: 5 dates in all
$schedule = $dtm::createDate('2026-01-05', '1 week', 4);
// ['2026-01-05', '2026-01-12', '2026-01-19', '2026-01-26', '2026-02-02']
```

---

# How to compare two dates

```php
$dtm = Util::DateAndTimeManager();

// Whole days between two dates (always positive)
$days = $dtm::dateDiff('2026-01-01', '2026-01-10');          // "9"

// Signed difference: later date first
$minutes = $dtm::dateTimeDiff('2026-01-01 10:00:00', '2026-01-01 09:15:00', 'm');  // 45

// Check a user-supplied date before using it
if (!$dtm::validate_date($input)) {
    // not a real Y-m-d date
}
```

---

# How to convert between time zones

`convertTimeZone` treats its input as **UTC** and returns the time in the target zone, with the offset attached:

```php
$local = Util::DateAndTimeManager()::convertTimeZone('2026-01-01 10:00:00', 'Asia/Colombo');
// "2026-01-01 15:30:00+05:30"
```

If your stored value is not UTC, convert it with PHP's `DateTime` directly instead.

---

# Methods

### timeConvert

Description:

The **`timeConvert`** method parses a date or time string with `strtotime()` and returns a `DateTime` object.

Syntax:

```php
$dt = Util::DateAndTimeManager()::timeConvert('2026-01-01 10:00:00');
```

**Parameters:**

- **`$timeString`**: Any string `strtotime()` understands, such as `2026-01-01 10:00:00`, `tomorrow` or `+2 hours`.

**Return Value:**

- **`DateTime`**: The parsed time.
- **`null`**: The string is empty or cannot be parsed. An unparseable string is also written to the error log as a warning.

<aside>
💡 The returned object is in UTC, not in the PHP default zone. The input is read in `Asia/Colombo`, so `timeConvert('2026-01-01 10:00:00')->format('H:i')` gives `04:30`. Call `setTimezone()` on the result before formatting it for display.

</aside>

---

### dateConvert

Description:

The **`dateConvert`** method turns a `Y-m-d` string into a `DateTime` object.

Syntax:

```php
$dt = Util::DateAndTimeManager()::dateConvert('2026-01-31');
```

**Parameters:**

- **`$dateString`**: A date in `Y-m-d` format. Other formats, such as `31/01/2026`, are rejected.

**Return Value:**

- **`DateTime`**: The date. Its time part is the current time, not midnight.
- **`null`**: The string is empty or not in `Y-m-d` format.

An out-of-range day rolls over instead of failing: `2026-02-30` becomes 2 March. Use `validate_date` first if you need a strict check.

---

### createDate

Description:

The **`createDate`** method builds a list of dates from a start date by adding the same interval again and again.

Syntax:

```php
$dates = Util::DateAndTimeManager()::createDate('2026-01-05', '1 week', 4);
```

**Parameters:**

- **`$startDate`**: The first date, in `Y-m-d` format.
- **`$interval`**: A relative interval such as `1 day`, `2 weeks` or `1 month`.
- **`$repetitions`**: How many times to add the interval.

**Return Value:**

- **`Array`**: `$repetitions + 1` dates as `Y-m-d` strings. The first entry is `$startDate` exactly as you passed it.

Month intervals follow PHP's overflow rules: from `2026-01-31`, adding `1 month` gives `2026-03-03`, and later dates continue from there. An invalid start date causes a fatal error.

---

### getDateRange

Description:

The **`getDateRange`** method returns the seven dates of the week that contains a given date. Weeks run Monday to Sunday.

Syntax:

```php
$week = Util::DateAndTimeManager()::getDateRange('2026-10-07');
```

**Parameters:**

- **`$date`**: Any date `strtotime()` understands.

**Return Value:**

- **`Array`**: Seven `Y-m-d` strings, Monday first, Sunday last.

---

### forwardBackwardDateRange

Description:

The **`forwardBackwardDateRange`** method returns consecutive dates, one per day, going forward or backward from a start date.

Syntax:

```php
$dates = Util::DateAndTimeManager()::forwardBackwardDateRange('2026-01-03', false, 3);
// ['2026-01-03', '2026-01-02', '2026-01-01']
```

**Parameters:**

- **`$date`**: The start date. `null` means today. Default: `null`.
- **`$forward`**: `true` to count forward, `false` to count backward. Default: `true`.
- **`$how_long`**: How many dates to return, including the start date. Default: `7`.

**Return Value:**

- **`Array`**: `Y-m-d` strings in the order they were generated.

---

### convertTimeZone

Description:

The **`convertTimeZone`** method converts a UTC date-time to another time zone.

Syntax:

```php
$local = Util::DateAndTimeManager()::convertTimeZone('2026-01-01 10:00:00', 'America/New_York');
// "2026-01-01 05:00:00-05:00"
```

**Parameters:**

- **`$dateTime`**: A UTC date-time in exactly `Y-m-d H:i:s` format.
- **`$timezone`**: A PHP time zone name, such as `Asia/Colombo`.

**Return Value:**

- **`String`**: The converted time in `Y-m-d H:i:sP` format, for example `2026-01-01 15:30:00+05:30`.
- **`null`**: The time zone is empty or unknown, or `$dateTime` is not in `Y-m-d H:i:s` format.

---

### dateTimeDiff

Description:

The **`dateTimeDiff`** method returns `$dateHigh` minus `$dateLow` in seconds, minutes or hours.

Syntax:

```php
$hours = Util::DateAndTimeManager()::dateTimeDiff('2026-01-02 12:00:00', '2026-01-01 09:00:00', 'h');
// 27
```

**Parameters:**

- **`$dateHigh`**: The later date-time.
- **`$dateLow`**: The earlier date-time.
- **`$outputUnit`**: `s` (seconds), `m` (minutes) or `h` (hours). Default: `s`.

**Return Value:**

- **`Integer`**: Seconds, when the unit is `s`.
- **`Float`**: Minutes or hours, rounded to 2 decimal places.
- **`null`**: The unit is anything other than `s`, `m` or `h`.

The result is negative when `$dateHigh` is earlier than `$dateLow`. Invalid date strings are not detected and produce a meaningless number, so validate the inputs first.

---

### createInterval

Description:

The **`createInterval`** method lists every date between two dates and labels the size of the gap.

Syntax:

```php
$result = Util::DateAndTimeManager()::createInterval('2026-01-01', '2026-03-15');
```

**Parameters:**

- **`$s_date`**: The start date.
- **`$e_date`**: The end date. It must not be earlier than the start date.

**Return Value:**

- **`Array`**: Two keys:
  - **`type`**: `years` if the gap is at least a year, `months` if it is at least a month, `weeks` if it is more than 7 days, otherwise `days`.
  - **`date_range`**: Every date from start to end, inclusive, as `Y-m-d` strings.
- **`false`**: A date is empty, or the start is after the end.

An unparseable date throws an exception.

---

### dateDiff

Description:

The **`dateDiff`** method returns the difference between two dates, ignoring the time of day, formatted with a `DateInterval` format string.

Syntax:

```php
$days = Util::DateAndTimeManager()::dateDiff('2026-01-01', '2026-01-10');            // "9"
$signed = Util::DateAndTimeManager()::dateDiff('2026-01-10', '2026-01-01', '%R%a');  // "-9"
```

**Parameters:**

- **`$s_date`**: The start date.
- **`$e_date`**: The end date.
- **`$unit`**: A `DateInterval::format()` pattern. Default: `%a` (total days, without a sign).

**Return Value:**

- **`String`**: The formatted difference.
- **`false`**: A date is empty.

An unparseable date causes a `TypeError`.

---

### getNextPayDate

Description:

The **`getNextPayDate`** method adds `$frequency × $payNumber` units to a date.

Syntax:

```php
$next = Util::DateAndTimeManager()::getNextPayDate('2026-01-15', 2, 'W', 1);
// "2026-01-29"
```

**Parameters:**

- **`$date`**: The start date, in strict `Y-m-d` format.
- **`$frequency`**: The number of units per payment.
- **`$unit`**: `D` (days), `W` (weeks), `M` (months) or `Y` (years).
- **`$payNumber`**: The number of payments to move forward.
- **`$timezone`**: The time zone for the calculation. Default: `Asia/Colombo`.

**Return Value:**

- **`String`**: The resulting date in `Y-m-d` format.

**Throws:**

- **`InvalidArgumentException`**: The date is not a valid `Y-m-d` date, `$frequency` or `$payNumber` is not numeric, or the unit is not one of `D`, `W`, `M`, `Y`.

<aside>
⚠️ With the `M` unit the result always moves to the **last day** of the resulting month. `getNextPayDate('2026-01-15', 1, 'M', 1)` returns `2026-02-28`, not `2026-02-15`. A start date late in the month can also overflow first: from `2026-01-31` it returns `2026-03-31`. If you need the same day of each month, use `DateTime::modify()` directly.

</aside>

---

### validate_date

Description:

The **`validate_date`** method checks that a string is a real date in strict `Y-m-d` format.

Syntax:

```php
$ok = Util::DateAndTimeManager()::validate_date('2026-02-29');   // false: 2026 is not a leap year
```

**Parameters:**

- **`$dateString`**: The string to check.

**Return Value:**

- **`Boolean`**: `true` if the string is a valid `Y-m-d` date, `false` otherwise. Dates that would roll over, such as `2026-02-30`, return `false`.

---

### get_system_datetime

Description:

The **`get_system_datetime`** method returns the current date and time in the zone set by `system_api_timezone`.

Syntax:

```php
$now = Util::DateAndTimeManager()::get_system_datetime();
$today = Util::DateAndTimeManager()::get_system_datetime('Y-m-d');
```

**Parameters:**

- **`$format`**: A PHP date format. Default: `Y-m-d H:i:s`.

**Return Value:**

- **`String`**: The current time in that format.

**Throws:**

- **`Exception`**: `system_api_timezone` is not a valid time zone name.

---

### get_timestamp

Description:

The **`get_timestamp`** method returns the current Unix timestamp. It is a wrapper around `time()`.

Syntax:

```php
$ts = Util::DateAndTimeManager()::get_timestamp();
```

**Return Value:**

- **`Integer`**: Seconds since 1 January 1970 UTC.

---

### add_time

Description:

The **`add_time`** method adds an interval to the current time and returns the result in the zone you name.

Syntax:

```php
$expires = Util::DateAndTimeManager()::add_time('30 minutes', 'Asia/Colombo');
```

**Parameters:**

- **`$interval_string`**: A relative interval such as `30 minutes`, `2 weeks` or `3600 seconds`.
- **`$time_zone`**: A PHP time zone name. The result is expressed in this zone.

**Return Value:**

- **`String`**: The resulting date-time in `Y-m-d H:i:s` format.

**Throws:**

- **`Exception`**: The time zone name is not valid.

---
