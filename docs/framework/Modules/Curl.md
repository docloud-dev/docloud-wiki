---
title: Curl
sidebar_label: Curl
---

# Curl

Owner: Nuwan Danushka

# Introduction

The `Curl` module wraps PHP's cURL functions for calling HTTP APIs. It sends GET, POST, PUT and DELETE requests, sets headers and authentication, and decodes JSON responses for you.

The module is loaded automatically. Create an instance with `new Curl()` from any controller or class.

A new instance starts with these defaults:

- Returns the response body instead of printing it.
- Follows redirects, up to 10.
- Times out after 30 seconds.
- Uses HTTP/1.1 and accepts any response encoding the server supports.

Change any of them with `setOption()`.

---

# How to send a GET request

```php
$curl = new Curl('https://example.com/api/items');
$items = $curl->get();
$curl->close();

if ($items === false) {
    // cURL failed, or the response wasn't JSON. Both are logged.
}
```

`get()`, `post()`, `put()` and `delete()` decode the response as JSON by default and return an array. They return `false` if the request fails or the body isn't valid JSON, including an empty body. Pass `false` as the `$expectJson` argument to get the raw body as a string instead.

<aside>
⚠️ An HTTP error status is not a failure. A 404 or 500 with a JSON body is decoded and returned like a 200. Check the status code with `get_info(CURLINFO_HTTP_CODE)` before you trust the result.

</aside>

---

# How to send a POST request

```php
$curl = new Curl('https://example.com/api/items');
$curl->setAuth('bearer', $api_token);

$result = $curl->post(['name' => 'Desk lamp', 'price' => 25], 'json');
$status = $curl->get_info(CURLINFO_HTTP_CODE);
$curl->close();
```

The second argument sets how the body is encoded:

| `$type` | Body | Headers added |
| --- | --- | --- |
| `form` (default) | The array is passed to cURL as is, so it's sent as `multipart/form-data`. | None |
| `json` | `json_encode($data)` | `Content-Type: application/json`, `Accept: application/json` |
| `urlencoded` | `http_build_query($data)` | `Content-Type: application/x-www-form-urlencoded` |

Any other value throws an `InvalidArgumentException` ("Unsupported format").

---

# How to set headers and authentication

Headers are full header lines, not key/value pairs:

```php
$curl = new Curl('https://example.com/api/items');
$curl->setHeaders(['Accept-Language: en', 'X-Request-Id: 42']);
$curl->setAuth('apikey', $api_key);
$items = $curl->get();
```

`setAuth()` supports four types:

| `$type` | `$credentials` | Effect |
| --- | --- | --- |
| `basic` | `'username:password'` | Sets `CURLOPT_USERPWD`. |
| `bearer` | The token | Adds `Authorization: Bearer <token>`. |
| `apikey` | The key | Adds `X-API-Key: <key>`. |
| `custom` | A header line, or an array of header lines | Adds them as given. |

<aside>
⚠️ For `bearer`, `apikey` and `custom`, `setAuth()` stores the header in both the header list and the auth list, so the request carries it twice. Most servers accept that. Calling `setAuth()` again on the same instance keeps the old header as well, so use a new `Curl` instance when the credentials change.

</aside>

---

# Curl Class Methods

### __construct

Description:

The **`__construct`** method starts a cURL session and applies the defaults listed in the introduction.

Syntax:

```php
$curl = new Curl($url = null);
```

**Parameters:**

- **`$url`** (optional): The request URL. You can set it later with `setURL()`.

---

### setURL

Description:

The **`setURL`** method sets the URL for the next request.

Syntax:

```php
$curl->setURL($url);
```

**Parameters:**

- **`$url`**: The request URL.

---

### setOption

Description:

The **`setOption`** method sets any cURL option on the session.

Syntax:

```php
$curl->setOption(CURLOPT_TIMEOUT, 60);
```

**Parameters:**

- **`$option`**: A `CURLOPT_*` constant.
- **`$value`**: The value for the option.

<aside>
💡 For the list of options, see [curl_setopt in the PHP manual](https://www.php.net/manual/en/function.curl-setopt.php).

</aside>

---

### setHeaders

Description:

The **`setHeaders`** method sets request headers. Headers stay set for every later request on the same instance.

Syntax:

```php
$curl->setHeaders(['Accept: application/json'], $merge = true);
```

**Parameters:**

- **`$headers`**: An array of header lines, such as `'Accept: application/json'`.
- **`$merge`** (optional, default `true`): `true` adds the headers to the ones already set. `false` replaces them.

---

### setAuth

Description:

The **`setAuth`** method sets the credentials for the request. The types are listed under "How to set headers and authentication" above. An unknown type changes nothing.

Syntax:

```php
$curl->setAuth('basic', 'username:password');
$curl->setAuth('bearer', $token);
$curl->setAuth('apikey', $key);
$curl->setAuth('custom', ['X-Client-Id: 123', 'X-Client-Secret: abc']);
```

**Parameters:**

- **`$type`**: `basic`, `bearer`, `apikey` or `custom`.
- **`$credentials`**: A string, or for `custom` a string or an array of header lines.

---

### get

Description:

The **`get`** method sends a GET request.

Syntax:

```php
$response = $curl->get($expectJson = true);
```

**Parameters:**

- **`$expectJson`** (optional, default `true`): Decode the body as JSON.

**Return Value:**

- **`Array`**: The decoded body, when `$expectJson` is `true`.
- **`String`**: The raw body, when `$expectJson` is `false`.
- **`false`**: The request failed, or `$expectJson` is `true` and the body isn't valid JSON. The error is logged.

---

### post

Description:

The **`post`** method sends a POST request with `$data` encoded as `$type`.

Syntax:

```php
$response = $curl->post(array $data, string $type = 'form', $expectJson = true);
```

**Parameters:**

- **`$data`**: The fields to send.
- **`$type`** (optional): `form` (default), `json` or `urlencoded`. See the table under "How to send a POST request".
- **`$expectJson`** (optional, default `true`): Decode the body as JSON.

**Return Value:**

- The same as `get()`.

---

### put

Description:

The **`put`** method sends a PUT request with `$data` encoded as `$format`.

Syntax:

```php
$response = $curl->put(['name' => 'Desk lamp'], 'json');
```

**Parameters:**

- **`$data`**: An array of fields to send.
- **`$format`**: `form`, `json` or `urlencoded`, as for `post()`.
- **`$expectJson`** (optional, default `true`): Decode the body as JSON.

**Return Value:**

- The same as `get()`.

<aside>
⚠️ Always pass the format. The second parameter defaults to `false`, which is not a valid format, so `put($data)` throws an `InvalidArgumentException` ("Unsupported format").

</aside>

---

### delete

Description:

The **`delete`** method sends a DELETE request.

Syntax:

```php
$response = $curl->delete($expectJson = true);
```

**Parameters:**

- **`$expectJson`** (optional, default `true`): Decode the body as JSON.

**Return Value:**

- The same as `get()`.

---

### exec

Description:

The **`exec`** method runs the session as it is configured, with no JSON decoding. It doesn't set the request method, so use it after `setOption()` calls of your own.

Syntax:

```php
$body = $curl->exec();
```

**Return Value:**

- **`String`**: The raw body.
- **`false`**: The request failed.

---

### get_info

Description:

The **`get_info`** method returns information about the last request, such as the HTTP status code.

Syntax:

```php
$curl = new Curl('https://example.com/api/items');
$items = $curl->get();
$status = $curl->get_info(CURLINFO_HTTP_CODE);
$all = $curl->get_info();
$curl->close();
```

**Parameters:**

- **`$option`** (optional): A `CURLINFO_*` constant. Leave it out to get every value.

**Return Value:**

- The value for `$option`, or an array of all values.

<aside>
💡 For the list of options, see [curl_getinfo in the PHP manual](https://www.php.net/manual/en/function.curl-getinfo.php).

</aside>

---

### get_error

Description:

The **`get_error`** method returns the cURL error message from the last request.

Syntax:

```php
$error = $curl->get_error();
```

**Return Value:**

- **`String`**: The error message.
- **`null`**: There was no error.

---

### close

Description:

The **`close`** method closes the cURL session. Don't use the instance after this.

Syntax:

```php
$curl->close();
```

---
