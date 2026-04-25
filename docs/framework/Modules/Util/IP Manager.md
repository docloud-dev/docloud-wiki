# IP Manager

Owner: Nuwan Danushka

# Introduction

Introducing IP Manager: Simplifying IP Address Management within the Do Framework. This module streamlines the retrieval of client and server IP addresses from server environment variables, enhancing security and optimizing network performance seamlessly.

---

## IP Manager Methods

### get_client_ip

Description:

The **`get_client_ip`** method is utilized to retrieve the client's IP address from server environment variables.

Syntax:

```php
Util::IpManager()::get_client_ip();
```

**Return Value:**

- **`String`**: The client's IP address, or **`null`** if it cannot be determined.

This method retrieves the client's IP address from server environment variables. If the IP address cannot be determined, it returns **`null`**.

---

### get_server_ip

Description:

The **`get_server_ip`** method is utilized to get the server's IP address.

Syntax:

```php
Util::IpManager()::get_server_ip();
```

**Return Value:**

- **`String`**: The server's IP address, or null if it cannot be determined.

This method retrieves the server's IP address from server environment variables. If the IP address cannot be determined, it returns **`null`**.

---