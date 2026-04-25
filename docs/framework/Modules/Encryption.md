# Encryption

Owner: Nuwan Danushka

# Introduction

The Encryption Module offers secure data encryption and decryption through functions like getEncryptedData and getDecryptedData. Additionally, it facilitates token creation. With a focus on simplicity and security, it seamlessly integrates into applications, ensuring data security without compromising ease of use.

---

<aside>
💡 The encryption method used for securing data and other settings for encryption can typically be found within the security settings of the admin panel.

</aside>

# How To Encrypt

This guide outlines the process of encrypting data using the **`Encryption`** module in Do Framework.

1. **Define Data to Encrypt**
    
    ```php
    $data_to_encode = "Hello World";
    ```
    
    - Set the variable **`$data_to_encode`** to the data you want to encrypt. Replace **`"Hello World"`** with the actual data you intend to encrypt.
    
2. **Initialize Encryption Object**
    
    ```php
    $encryption_object = new Encryption();
    ```
    
    - Create a new instance of the **`Encryption`** class. This class is assumed to handle encryption operations.
    
3. **Set Data for Encryption**
    
    ```php
    $encryption_object->setString($data_to_encode);
    ```
    
    - Call the **`setString()`** method on the **`$encryption_object`** instance, passing the data to be encrypted (**`$data_to_encode`**) as an argument.
    
4. **Retrieve Encrypted Data**
    
    ```php
    $encrypted_string = $encryption_object->getEncryptedData();
    ```
    
    - Call the **`getEncryptedData()`** method on the **`$encryption_object`** instance. This method is expected to perform encryption on the previously set string and return the encrypted data. The encrypted data is stored in the variable **`$encrypted_string`**.

```php
// Step 1: Define Data to Encrypt
$data_to_encode = "Hello World";

// Step 2: Initialize Encryption Object
$encryption_object = new Encryption();

// Step 3: Set Data for Encryption
$encryption_object->setString($data_to_encode);

// Step 4: Retrieve Encrypted Data
$encrypted_string = $encryption_object->getEncryptedData();

```

This code snippet demonstrates how to encrypt data using the Encryption module provided by the Do framework. 
Each step is accompanied by a comment to explain its purpose in the encryption process. 

---

# How To Decrypt

This guide outlines the process of decrypting data using the **`Encryption`** module in Do Framework.

1. **Define Data to Decrypt**
    
    ```php
    $data_to_decrypt = "YEwsEjrTMu7m3bliq0aqTg==";
    ```
    
    - Set the variable **`$data_to_decrypt`** to the encrypted data you want to decrypt.
    
2. **Initialize Decryption Object**
    
    ```php
    $decryption_object = new Encryption();
    ```
    
    - Create a new instance of the **`Encryption`** class. This class is assumed to handle decryption operations.
    
3. **Set Data for Decryption**
    
    ```php
    $encryption_object->setString($data_to_encode);
    ```
    
    - Call the **`setString()`** method on the **`$decryption_object`** instance, passing the data to be decrypted (**`$data_to_decrypt`**) as an argument.
    
4. **Retrieve Decrypted Data**
    
    ```php
    $decrypted_data = $decryption_object->getDecryptedData();
    ```
    
    - Call the **`getDecryptedData()`** method on the **`$decryption_object`** instance. This method is expected to perform decryption on the previously set encrypted string and return the decrypted data. The decrypted data is stored in the variable **`$decrypted_data`**.

```php
// Step 1: Define Data to Decrypt
$data_to_decrypt = "YEwsEjrTMu7m3bliq0aqTg=="; // Encrypted data to be decrypted

// Step 2: Initialize Decryption Object
$decryption_object = new Encryption(); // Initialize Decryption object

// Step 3: Set Data for Decryption
$decryption_object->setString($data_to_decrypt); // Set data for decryption

// Step 4: Retrieve Decrypted Data
$decrypted_data = $decryption_object->getDecryptedData(); // Retrieve decrypted data

```

This code snippet demonstrates how to decrypt data using the Encryption module provided by the Do framework. 
Each step is accompanied by a comment to explain its purpose in the decryption process. 

---

# How to Build a Token

This guide outlines the process of building a token using the **`Encryption`** module in Do Framework.

<aside>
💡 if additional data is added to the token, its size will increase.

</aside>

1. **Define Token Data**
    
    ```php
    // Define the data to be included in the token
    $token_data = array(
        "user_id" => $user_id, // User ID
        "email" => $email, // Email
        "expire" => $expire_int // Expiry time
    );
    ```
    
    - Define an associative array **`$token_data`** containing the information you want to include in the token. This may include user ID, email, and expiration time, among other relevant data.

1. **Build the Token**
    
    ```php
    // Build the token using the Encryption class method
    $token = Encryption::buildToken($token_data);
    ```
    
    - Call the **`buildToken()`** method from the **`Encryption`** class, passing the token data array as an argument. This method will generate the token based on the provided data.

```php
// Define the token data
$token_data = array(
    "user_id" => $user_id,
    "email" => $email,
    "expire" => $expire_int
);

// Build the token
$token = Encryption::buildToken($token_data);
```

 

This code snippet demonstrates how to build a token using the Encryption module provided by the Do framework. 
Each step is accompanied by a comment to explain its purpose in the token build process. 

---

# How to Decode a Token

This guide outlines the process of decoding a token using the **`Encryption`** module in Do Framework.

1. **Decode the Token**
    
    ```php
    // Decode the token using the Encryption class method
    $decoded_data = Encryption::decodeToken($token);
    ```
    
    - Call the **`decodeToken()`** method from the **`Encryption`** class, passing the token string as an argument. This method will decode the token and return the decoded data.
2. **Access Decoded Data**
    
    ```php
    // Access decoded data
    $user_id = isset($decoded_data['user_id']) ? $decoded_data['user_id'] : null;
    $email = isset($decoded_data['email']) ? $decoded_data['email'] : null;
    $expire = isset($decoded_data['expire']) ? $decoded_data['expire'] : null;
    ```
    
    - Access the decoded data using keys corresponding to the data you encoded into the token. In this example, **`$decoded_data['user_id']`**, **`$decoded_data['email']`**, and **`$decoded_data['expire']`** correspond to the user ID, email, and expiration time respectively.

This code snippet demonstrates how to build a token using the Encryption module provided by the Do framework. 
Each step is accompanied by a comment to explain its purpose in the token build process.