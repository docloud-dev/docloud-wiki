# Core Classes

Owner: Thilina Deepal

# Controller class

The controller class functions as the endpoint handler, with its name reflecting the associated resource being managed. Within this class, actions or endpoints can be identified using `$this->getRequest()->getAction()`.

To respond to the request, a response object can be created, and its output can be echoed.

The class includes the following abstract functions:

1. **`authenticate` Function:**
    - **Purpose:** Authenticate the user to determine authorization for accessing the associated endpoints within the app.
    - **Return:** Boolean (`true` or `false`).
2. **`render` Function:**
    - **Purpose:** To handle request and render the response.
    

---

# Request class

The `Request` class serves as a pivotal component in handling incoming HTTP requests, catering to various methods such as `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`. This class is meticulously designed to capture crucial information from requests, including data payload, action specifics, and controller details. Acting as a seamless bridge between the application and incoming requests, it streamlines the extraction of essential parameters necessary for processing.

Developers can effortlessly access and leverage key information, such as request data, the action being performed, and the associated controller, thereby enhancing the clarity and manageability of the request-handling process within the application.

**Example:** For a `GET` request like:

`https://www.yoursite.site/api/user/list?page=1&per_page=10`

In this example API endpoint, the request type is `GET`, the controller is `user`, the action is `list`, and the data includes parameters 

like `page` and `per_page`. 

These details can be accessed in the controller class using:

- `$this->getRequest()->getController()` to retrieve the controller name.
- `$this->getRequest()->getAction()` to obtain the action name.
- `$this->getRequest()->getType()` to determine the request type.
- `$this->getRequest()->getData()` to obtain the data with request.
- `$this->getRequest()->getFiles()` to obtain the binary data with request.

---

# Response class

The `Response` class holds a pivotal role in shaping the outgoing HTTP responses from the application. It provides developers with a structured and intuitive way to construct and send responses to clients. This class is designed to handle various HTTP status codes, headers, and content, ensuring a seamless communication process between the application and the requesting client.

### **Steps to Create a Response:**

1. **Instantiate Response Object:**
    - Create a response object using `$res = new Response();`.
        
        `$res = new Response();`
        
2. **Set Data (Optional):**
    - If your response includes data, use `$res->setData($yourDataArray);` to set the data.
        
        `$res->setData($userList);`
        
3. **Generate Response:**
    - Use `$res->create(statusCode, message, success);` to generate the response with the specified parameters.
        
        `echo $res->create(200, "student list", true);`
        

**Example: Putting it all together:**

```php

// Step 1: Instantiate Response Object
$res = new Response();

// Step 2: Set Data (Optional) 
$res->setData($userList);

// Step 3: Generate Response
echo $res->create(200, "student list", true);
```

---

# App class

The **`App`** class serves as the parent class for all other app classes, inheriting several key functions: **`register`**, **`init`**, and **`search`**. Here's a breakdown of each function:

1. **`register` Function:**
    - This registered the app to the system
    - Return `true` to register the app.
2. **`init` Function:**
    - Functions as a constructor, automatically executing during app instance creation.
    - Developers employ this function to set up initial parameters, resources, or configurations.
    - Establishes the app's initial state upon instantiation.
3. **`search` Function:**
    - Designed for global searching within the app; developers implement the search logic.
    - Permits users or other system components to search for information or resources.
    - Returns search results if the app supports searching; otherwise, it returns an empty string.
    

In summary, the **`App`** class provides a standardized structure for app development, ensuring seamless registration for communication, initialization, and support for global search functionality. Developers customize the **`search`** function and add specific functionalities as needed for their apps.