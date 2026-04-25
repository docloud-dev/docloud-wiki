# Date And Time Manager

Owner: Nuwan Danushka

# Introduction

Introducing Date and Time Manager: Your Go-To Solution for Streamlined Date and Time Handling in the Do Framework. With essential functions like time convert, createDate, and convertTimeZone, this class simplifies tasks such as formatting, creating, and adjusting dates and times. Whether you need to generate date ranges or convert time zones, Date and Time Manager ensures efficient and accurate temporal data management, empowering developers to enhance their applications effortlessly.

---

## Date And Time Manager Methods

### timeConvert

Description:

The **`timeConvert`** method is utilized to convert a string representation of time to a DateTime object.

Syntax:

```php
Util::DateAndTimeManager()::timeConvert(string $timeString);
```

**Parameters:**

- **`$dateString`**: The string representation of the date to be converted.

**Return Value:**

- `DateTime`:  Returns a DateTime object representing the converted time.

This method converts a string representation of time into a DateTime object. The DateTime object can then be used for various date and time operations.

---

### dateConvert

Description:

The **`dateConvert`** method is utilized to convert string representation of the date to a DateTime object.

Syntax:

```php
Util::DateAndTimeManager()::dateConvert(string $dateString);
```

**Parameters:**

- **`$dateString`**: The string representation of the date to be converted.

**Return Value:**

- `DateTime`:  Returns a DateTime object representing the converted time.

This method converts a string representation of a date into a DateTime object. The DateTime object can then be used for various date and time operations.

---

### createDate

Description:

The **`createDate`** method is utilized to convert a string representation of a date to a DateTime object.

Syntax:

```php
Util::DateAndTimeManager()::dateConvert(string $dateString);
```

**Parameters:**

- **`$dateString`**: The string representation of the date to be converted.

**Return Value:**

- `DateTime`:  Returns a DateTime object representing the converted string.

---

### getDateRange

Description:

The **`getDateRange`** method is utilized to get all dates of a week for a given date.

Syntax:

```php
Util::DateAndTimeManager()::getDateRange(string $date);
```

**Parameters:**

- **`$date`**: The date string.

**Return Value:**

- `DateTime`:  Returns a DateTime object representing the converted string.

This method retrieves all dates of a week for a given date. It returns a DateTime object representing the provided date.

---

### forwardBackwardDateRange

Description:

The **`forwardBackwardDateRange`** method is utilized to generate an array of dates in a forward or backward direction from a given date.

Syntax:

```php
Util::DateAndTimeManager()::forwardBackwardDateRange(string $date = null, bool $forward = true, int $how_long = 7);
```

**Parameters:**

- **`$date`**: The starting date. If not provided, the current date is used.
- **`$forward`**: A boolean indicating whether to generate dates forward (true) or backward (false). The default is true.
- **`$how_long`**: The number of days to generate. The default is 7.

**Return Value:**

- An array containing the range of dates day by day in the specified direction.

This method generates an array of dates day by day in a forward or backward direction from the provided date. If **`$forward`** is set to true, it generates dates forward from the starting date. If **`$forward`** is set to false, it generates dates backward from the starting date. The number of days generated is determined by the **`$how_long`** parameter.

---

### convertTimeZone

Description:

The **`convertTimeZone`** method is utilized to convert a given date and time from one timezone to another.

Syntax:

```php
Util::DateAndTimeManager()::convertTimeZone(string $dateTime, string $timezone);
```

**Parameters:**

- **`$dateTime`**: The date and time string to be converted.
- **`$timezone`**: The target timezone to convert the date and time to.

**Return Value:**

- The date and time string converted to the specified timezone.

This method converts a given date and time from one timezone to another, returning the converted date and time string.

---

### dateTimeDiff

Description:

The **`dateTimeDiff`** method is utilized to calculate the difference between two date and time values.

Syntax:

```php
Util::DateAndTimeManager()::dateTimeDiff(string $dateHigh, string $dateLow, string $outputUnit = 's');
```

**Parameters:**

- **`$dateHigh`**: The higher or later date and time string.
- **`$dateLow`**: The lower or earlier date and time string.
- **`$outputUnit`**: (Optional) The unit in which the difference should be expressed. The default is 's' (seconds).

**Return Value:**

- The difference between the two date and time values, is expressed in the specified output unit.

This method calculates the difference between two date and time values and returns the result in the specified output unit (e.g., seconds, minutes, hours).

---

### createInterval

Description:

The **`createInterval`** method is utilized to create an interval between two given dates.

Syntax:

```php
Util::DateAndTimeManager()::createInterval($s_date, $e_date);
```

**Parameters:**

- **`$s_date`**: The start date.
- **`$e_date`**: The end date.

**Return Value:**

- Returns an interval object representing the duration between the start and end dates.

This method creates an interval object representing the duration between the provided start and end dates.

---