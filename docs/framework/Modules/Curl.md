# Curl

Owner: Nuwan Danushka

# Introduction

The cURL module in DoFramework serves as a versatile tool for interacting with web services by facilitating straightforward communication with servers using different protocols. With cURL, you can effortlessly make HTTP requests to specified URLs, customize requests with options like headers and timeouts, and handle responses effectively. Whether you need to perform GET or POST requests, cURL provides a simple and powerful interface. The library also offers functions such as **`curl_getinfo()`** for retrieving details about the request and **`curl_close()`** to tidy up and release resources. In essence, cURL streamlines the process of connecting to web services, making it a valuable asset for developers working on various web applications.

---

# How to send a curl request

This guide outlines the process of sending a get request using the **`Curl`** module in Do Framework.

1. **Initialize cURL**
First, we need to initialize cURL in PHP. This can be done by creating a new instance of the `Curl` class.
    
    ```php
    $curl = new Curl();
    
    ```
    
2. **Set the URL**
Set the URL to which the cURL request will be sent.
    
    ```php
    $curl_url = "<https://example.com/api>"; // Replace this with the actual URL
    
    ```
    
3.  Set URL in cURL Instance
    
    Assign the URL to the cURL instance using the **`setURL()`** method.
    
    ```php
    $curl->setURL($curl_url);
    
    ```
    
4. **Send GET Request**
Now, we'll send a GET request to the specified URL and store the response data.
    
    ```php
    $response_data = $curl->get();
    
    ```
    
5. **Close cURL**
After the request is made, it's good practice to close the cURL connection.
    
    ```php
    $curl->close();
    
    ```
    

**Complete Example:**
Putting it all together, here's the complete code:

```php
// Step 1: Initialize cURL
$curl = new Curl();

// Step 2: Set the URL
$curl_url = "<https://example.com/api>"; // Replace this with the actual URL

// Step 3: Set URL in cURL Instance
$curl->setURL($curl_url);

// Step 4: Send GET Request
$response_data = $curl->get();

// Step 5: Close cURL
$curl->close();

```

This code will send a GET request to the specified URL and store the response data. Make sure to replace `"<https://example.com/api>"` with the actual URL you want to send the request to.

---

<aside>
💡 **Please refer to the methods for usage examples in other contexts.**

</aside>

# Curl Class Methods

## __construct

Description:

The **`__construct`** is the class constructor for the **`Curl`** class. This function initializes the cURL instance and sets the default necessary options to the object.

Syntax:

```php
$curl_manager = new Curl($url = null);
```

**Parameters**:

- **`$url`: The URL for the cURL request.**

This function provides a convenient way to create a new instance of the **`Curl`** class and set the initial URL for cURL requests.

---

## setURL

Description:

The **`setURL`** method is used to set the URL for the cURL request in the **`Curl`** class.

Syntax:

```php
$curl_manager->setURL($url);
```

**Parameters**:

- **`$url`: The URL for the cURL request.**

This method provides a convenient way to update the URL for cURL requests in an existing **`Curl`** instance.

---

## setOption

Description:

The **`setOption`** method is used to set a cURL option for the **`Curl`** class.

Syntax:

```php
$curl_manager->setOption($option, $value);
```

**Parameters**:

- **`$option`: The name of the cURL option.**
- **`$value`: The value to set for the cURL option.**

<aside>
💡  For a list of cURL options and their values, refer to [PHP manual - curl_setopt](https://www.php.net/manual/en/function.curl-setopt.php)

</aside>

This method provides a convenient way to set cURL options for a specific cURL request in an existing **`Curl`** instance.

---

## get

Description:

The **`get`** method is used to perform a GET request using the **`Curl`** class.

Syntax:

```php
$response = $curl_manager->get();
```

**Returns:**

- An array containing the response.
- **`false`** if the operation is not successful.

**Usage Example** 

```php
	$curl = new Curl();
  $curl->setURL($curl_url);
  $response_data = $curl->get();
  $curl->close();
```

This method provides a convenient way to perform GET requests using an existing **`Curl`** instance. The response is returned as an array, and **`false`** is returned in case of an unsuccessful operation.

---

## post

Description:

The **`post`** method is used to perform a POST request using the **`Curl`** class.

The **`$postData`** array should adhere to the following format:

```php
$postData= array(
    "id" => "1",
    "name" => "John",
    // Add more columns as needed
);
```

Syntax:

```php
$response = $curl_manager->post($postData);
```

**Parameters**:

- **`$postData`**: An array containing the POST data.

**Returns:**

- An array containing the response.
- **`false`** if the operation is not successful.

**Usage Example** 

```php
	$postData= array(
    "id" => "1",
    "name" => "John"
);

	$curl = new Curl();
  $curl->setURL($curl_url);
  $response = $curl_manager->post($postData);
  $curl->close();
```

This method provides a convenient way to perform POST requests using an existing **`Curl`** instance. The response is returned as an array, and **`false`** is returned in case of an unsuccessful operation.

---

## exec

Description:

The **`exec`** method is used to execute the cURL request in the **`Curl`** class.

Syntax:

```php
$curl_manager->exec();
```

**Returns:**

- A string containing the response.
- **`false`** if the operation is not successful.

This method provides a convenient way to execute the cURL request.

---

## close

Description:

The `close` method is used to close the cURL connection.

Syntax:

```php
$curl_manager->close();
```

This method provides a convenient way to close the cURL connection.

---

## get_info

Description:

The **`get_info`** method is used to retrieve information about the cURL request in the **`Curl`** class.

Syntax:

```php
$curl_manager->get_info($option);
```

**Parameters**:

- **`$option`**: The option for cURL info options.

<aside>
💡 For a list of cURL get info options and their values, refer to [cURL get info](https://www.php.net/manual/en/function.curl-getinfo.php).

</aside>

**Usage Example** 

```php
  $curl = new Curl();
  $curl->setURL($curl_url);
  $info = $curl_manager->get_info($option);
  $curl->close();
```

This method provides a convenient way to retrieve information about the cURL request.

---