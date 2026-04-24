# Exchanger API

Owner: Nuwan Danushka

# Introduction

Introducing the Exchanger API module: Your gateway to seamless integration with external APIs. Designed to streamline communication with external services, Exchanger API serves as a centralized hub for managing API tokens, assessing their status, and efficiently handling access and refresh tokens. With the ability to craft custom wrapper functions, leveraging the Exchanger API class enhances security measures, ensuring a robust and reliable connection between your application and external APIs. Say goodbye to cumbersome integration processes and hello to a simplified, secure approach with Exchanger API.

---

# **Managing API Tokens with Exchanger API in PHP**

1. **Obtain Exchanger API Token Instance**
First, we need to obtain an instance of the Exchanger API token.
    
    ```php
    $exchangerApiToken = ExchangerApi::ExchangerApiToken();
    
    ```
    
2. **Set Token Information**
Set the necessary information for the token, such as user ID, token name, access token, refresh token, and expiry details.
    
    ```php
    $exchangerApiToken->setUserId($user_id);
    $exchangerApiToken->setTokenName("QuickBooks");
    $exchangerApiToken->setRefreshToken($accessToken->getRefreshToken());
    $exchangerApiToken->setAccessToken($accessToken->getAccessToken());
    $exchangerApiToken->setCustomField($accessToken->getRealmID());
    $exchangerApiToken->setAccessTokenExpiresAt($accessToken->getAccessTokenExpiresAt());
    $exchangerApiToken->setRefreshTokenExpiresAt($accessToken->getRefreshTokenExpiresAt());
    
    ```
    
3. **Check Token Existence**
Check if the token already exists in the database.
    
    ```php
    if ($exchangerApiDAO->checkTokenExistsByName($exchangerApiToken) == 0) {
    
    ```
    
4. **Add or Update Token**
If the token doesn't exist, add it to the database. Otherwise, update the existing token.
    
    ```php
        $exchangerApiDAO->addToken($exchangerApiToken);
    } else {
        $exchangerApiDAO->updateToken($exchangerApiToken, true);
    }
    
    ```
    

**Complete Example:**
Combining all the steps, here's the complete code:

```php
$exchangerApiToken = ExchangerApi::ExchangerApiToken();
$exchangerApiToken->setUserId($user_id);
$exchangerApiToken->setTokenName("QuickBooks");
$exchangerApiToken->setRefreshToken($accessToken->getRefreshToken());
$exchangerApiToken->setAccessToken($accessToken->getAccessToken());
$exchangerApiToken->setCustomField($accessToken->getRealmID());
$exchangerApiToken->setAccessTokenExpiresAt($accessToken->getAccessTokenExpiresAt());
$exchangerApiToken->setRefreshTokenExpiresAt($accessToken->getRefreshTokenExpiresAt());

if ($exchangerApiDAO->checkTokenExistsByName($exchangerApiToken) == 0) {
    $exchangerApiDAO->addToken($exchangerApiToken);
} else {
    $exchangerApiDAO->updateToken($exchangerApiToken, true);
}

```

This code snippet manages API tokens using Exchanger API in PHP, adding them to the database if they don't exist and updating them if they do. Make sure to replace `$user_id`, `$accessToken`, and other variables with actual values as per your application's context.

---

# **Managing Sessions with Exchanger API**

1. **Retrieve Access Token**
To retrieve the access token from the session, you would typically use the `getAccessToken()` method provided by Exchanger API. This method retrieves the access token associated with a specific key from the session.
    
    ```php
    $accessTokenArray = ExchangerApi::Sessions()->getAccessToken('API_NAME_OF_ACCESS_TOKEN');
    
    ```
    
2. **Set Access Token**
Once you have the access token array, you can set it in the session using the `setAccessToken()` method. This method stores the access token array in the session under the specified key.
    
    ```php
    ExchangerApi::Sessions()->setAccessToken('API_NAME_OF_ACCESS_TOKEN', $accessTokenArray);
    
    ```
    
3. **Unset Access Token**
If you need to remove the access token from the session, you can use the `unsetAccessToken()` method. This method removes the access token associated with the specified key from the session.
    
    ```php
    ExchangerApi::Sessions()->unsetAccessToken('API_NAME_OF_ACCESS_TOKEN');
    
    ```
    

**Complete Example:**
Here's how you would perform these steps in sequence:

```php
// Step 1: Retrieve Access Token
$accessTokenArray = ExchangerApi::Sessions()->getAccessToken('API_NAME_OF_ACCESS_TOKEN');

// Step 2: Set Access Token
ExchangerApi::Sessions()->setAccessToken('API_NAME_OF_ACCESS_TOKEN', $accessTokenArray);

// Step 3: Unset Access Token
ExchangerApi::Sessions()->unsetAccessToken('API_NAME_OF_ACCESS_TOKEN');

```

<aside>
💡 Make sure to replace `'API_NAME_OFP_ACCESS_TOKEN'` with the appropriate key you're using for your access token session management.

</aside>

---

# Exchanger API Methods

### checkAPIConnection

Description:

The **`checkAPIConnection`** function serves the purpose of verifying the status of a provided API token.

Syntax:

```php
 ExchangerApi::checkAPIConnection(string $token_name);
```

**Parameters**:

- **`$token_namee`**: The name of the API Token to be checked.

**Returns:**

- An array containing the status of the token and a message.

This function enables you to efficiently assess the validity and status of an API token, aiding in seamless integration and management of API connections within your application.