---
title: IP Manager
sidebar_label: IP Manager
---

# IP Manager

Owner: Nuwan Danushka

# Introduction

`IpManager` reads the client's and the server's IP addresses from the server environment (`$_SERVER`). Both methods are static:

```php
$client_ip = Util::IpManager()::get_client_ip();
```

---

## IP Manager Methods

### get_client_ip

Description:

The **`get_client_ip`** method returns the client's IP address. It checks these `$_SERVER` entries in order and returns the first one that is set: `HTTP_CLIENT_IP`, `HTTP_X_FORWARDED_FOR`, `HTTP_X_FORWARDED`, `HTTP_FORWARDED_FOR`, `HTTP_FORWARDED`, `REMOTE_ADDR`.

Syntax:

```php
Util::IpManager()::get_client_ip();
```

**Return Value:**

- **`String`**: The value of the first entry found, returned as is.
- **`null`**: None of the entries is set, for example in a shell or heartbeat run.

<aside>
⚠️ Every entry except `REMOTE_ADDR` comes from a request header, and any client can send those headers with any value. Don't use this method for security decisions such as allow lists, rate limits or login checks. The value is also not cleaned: behind a proxy chain, `X-Forwarded-For` can hold several comma-separated addresses.

</aside>

---

### get_server_ip

Description:

The **`get_server_ip`** method returns the server's IP address from `$_SERVER['SERVER_ADDR']`.

Syntax:

```php
Util::IpManager()::get_server_ip();
```

**Return Value:**

- **`String`**: The server's IP address.
- **`null`**: `SERVER_ADDR` is not set or is empty, for example in a shell run.

---
