---
title: Exchanger API
sidebar_label: Exchanger API
---

# Exchanger API

Owner: Nuwan Danushka

# Introduction

The Exchanger API module stores OAuth2 tokens for external APIs and includes a client for QuickBooks Online. It has these classes:

- `ExchangerApi`: the module class. Factory methods for the classes below, table setup and a connection check.
- `ExchangerApiToken`: a token record (user, token name, access and refresh tokens, expiry dates).
- `ExchangerApiDAO`: reads and writes token records in the `exchanger_api_oauth2_tokens` table.
- `ExchangerApiSessions`: keeps token data in the PHP session.
- `quickbooksAPI`: a QuickBooks Online client, returned by `ExchangerApi::quickbooks()`.

`ExchangerApi` is loaded automatically. The other classes load with it, so get them through the `ExchangerApi` factory methods.

<aside>
⚠️ In v0.0.42 the module can't be loaded. The QuickBooks client file includes the logging module a second time, so the first reference to `ExchangerApi` in a request stops PHP with the fatal error "Cannot declare class Loging". The rest of this page describes the module as written.

</aside>

---

# How to create the token table

Tokens are stored in the `exchanger_api_oauth2_tokens` table. Create it once, for example when your app is set up:

```php
(new ExchangerApi())->initializeExchangerAPI();
```

It runs `CREATE TABLE IF NOT EXISTS`, so calling it again is safe. The table has these columns: `id`, `user_id`, `token_name`, `access_token`, `refresh_token`, `custom_field`, `access_token_expires_at`, `refresh_token_expires_at` and `created_date`.

<aside>
⚠️ `ExchangerApiDAO::updateToken()` also writes a `last_updated_date` column, which the table doesn't have. Every update fails and returns `false` (the error is logged). Add the column yourself if you need updates to work: `ALTER TABLE exchanger_api_oauth2_tokens ADD last_updated_date DATETIME NULL`.

</aside>

---

# How to store an API token

Fill in a token record, then add it or update the existing record with the same name:

```php
$exchangerApiToken = ExchangerApi::ExchangerApiToken();
$exchangerApiToken->setUserId($user_id);
$exchangerApiToken->setTokenName("MyService");
$exchangerApiToken->setAccessToken($access_token);
$exchangerApiToken->setRefreshToken($refresh_token);
$exchangerApiToken->setCustomField($account_id);
$exchangerApiToken->setAccessTokenExpiresAt('2026-10-05 12:00:00');
$exchangerApiToken->setRefreshTokenExpiresAt('2027-01-05 12:00:00');

$exchangerApiDAO = ExchangerApi::ExchangerApiDAO();

if ($exchangerApiDAO->checkTokenExistsByName($exchangerApiToken) == 0) {
    $exchangerApiDAO->addToken($exchangerApiToken);
} else {
    $exchangerApiDAO->updateToken($exchangerApiToken, true);
}
```

`custom_field` is a free text column for anything else the API needs, such as an account or company id.

<aside>
⚠️ Set every field before you call `addToken()` or `updateToken()`. The getters have strict return types, so reading a field you haven't set throws a `TypeError`, which the DAO doesn't catch.

</aside>

---

# How to keep tokens in the session

`ExchangerApi::Sessions()` stores token data in `$_SESSION`. Keys are prefixed with `exchanger_api_`, so the name `MY_SERVICE_TOKEN` is stored as `$_SESSION['exchanger_api_MY_SERVICE_TOKEN']`.

```php
// Store
ExchangerApi::Sessions()->setAccessToken('MY_SERVICE_TOKEN', $accessTokenArray);

// Read (null if not set)
$accessTokenArray = ExchangerApi::Sessions()->getAccessToken('MY_SERVICE_TOKEN');

// Remove
ExchangerApi::Sessions()->unsetAccessToken('MY_SERVICE_TOKEN');
```

---

# How to check whether an API is connected

```php
$status = ExchangerApi::checkAPIConnection('MyService');

if ($status && $status['status']) {
    // Connected
}
```

It looks up the stored record by token name and returns an array with `status` (Boolean) and `message`:

| `status` | `message` | When |
| --- | --- | --- |
| `false` | "App not connected" | No record with that name. |
| `false` | "App authentication expired" | Fewer than 7 days are left on the refresh token, or the record has no expiry dates. |
| `true` | "App is connected" | 7 or more days are left on the refresh token. |
| `false` | "Couldn't found the app" | The token name is empty. |

It returns `null` if an exception is thrown. Dates are compared in the `system_api_timezone` time zone.

<aside>
⚠️ The check uses the number of days between now and the expiry date, without its sign. A refresh token that expired 7 or more days ago is reported as "App is connected".

</aside>

---

# How to connect to QuickBooks Online

`ExchangerApi::quickbooks()` returns a client for the QuickBooks Online accounting API. It stores one QuickBooks connection for the whole system, under the token name `QuickBooks` and the session key `QB_ACCESS_TOKEN`.

## Install the QuickBooks SDK

The client uses Intuit's QuickBooks V3 PHP SDK, which the framework doesn't ship. Only PHPMailer is included in `api/sdks/`. Install the SDK as a framework SDK:

1. Create `api/sdks/quickbooks/` and install the SDK there with Composer:

   ```bash
   cd api/sdks/quickbooks
   composer require quickbooks/v3-php-sdk
   ```

2. Add `api/sdks/quickbooks/autoloader.php`:

   ```php
   <?php
   require __DIR__ . '/vendor/autoload.php';
   ```

3. List the SDK and its settings under `<sdks>` in `api/config.<environment>.xml`. The name must be `quickbooks`, in lower case:

   ```xml
   <sdks>
     <sdk name="PHPMailer"/>
     <sdk name="quickbooks">
       <quickbooks_client_id>your-client-id</quickbooks_client_id>
       <quickbooks_client_secret>your-client-secret</quickbooks_client_secret>
       <quickbooks_oauth_redirect_uri>https://example.com/api/myapp/quickbooks-callback</quickbooks_oauth_redirect_uri>
       <quickbooks_base_url>Development</quickbooks_base_url>
     </sdk>
   </sdks>
   ```

   `quickbooks_base_url` is passed to the SDK as its `baseUrl`: `Development` for the sandbox, `Production` for live companies.

Every SDK in `<sdks>` is loaded on each request, and the boot health check fails if its `autoloader.php` is missing. See [Configuration Files](../Essentials/Configuration%20Files.md).

## Connect, query and disconnect

```php
$qb = ExchangerApi::quickbooks();

// 1. Send the user to Intuit to approve the connection.
$auth_url = $qb->getAuthURL();

// 2. In the handler for your redirect URI, exchange the code for tokens.
//    They are saved to the session and to exchanger_api_oauth2_tokens.
$qb->exchangeAuthorizationCodeForToken($_GET['code'], $_GET['realmId'], $user_id);

// 3. Before each query, load the stored token and refresh it if needed.
if ($qb->generateAccessToken($user_id)) {
    $query = $qb->createQuery();   // the SDK's QueryMessage: fill it in as the SDK documents
    $result = $qb->executeQuery();
}

// 4. Disconnect: revokes the token at Intuit and deletes the stored record.
$qb->revokeAccessToken();
```

`generateAccessToken()` reads the token from the session, or from the database if the session has none. If fewer than 7 days are left on the refresh token, or fewer than 10 minutes on the access token, it requests new tokens.

---

# Exchanger API Methods

## ExchangerApi class

### quickbooks

Description:

The **`quickbooks`** static method returns a new QuickBooks Online client, configured from the `quickbooks` SDK settings.

Syntax:

```php
$qb = ExchangerApi::quickbooks();
```

**Return Value:**

- **`quickbooksAPI`**: The client.

---

### initializeExchangerAPI

Description:

The **`initializeExchangerAPI`** method creates the `exchanger_api_oauth2_tokens` table if it doesn't exist. It's an instance method.

Syntax:

```php
(new ExchangerApi())->initializeExchangerAPI();
```

---

### ExchangerApiDAO

Description:

The **`ExchangerApiDAO`** static method returns a new `ExchangerApiDAO`.

Syntax:

```php
$exchangerApiDAO = ExchangerApi::ExchangerApiDAO();
```

---

### ExchangerApiToken

Description:

The **`ExchangerApiToken`** static method returns a new, empty `ExchangerApiToken`. To build one from a database row instead, use `new ExchangerApiToken($row)`: the constructor reads the keys `id`, `user_id`, `token_name`, `access_token`, `refresh_token`, `custom_field`, `access_token_expires_at`, `refresh_token_expires_at` and `last_updated_date`.

Syntax:

```php
$token = ExchangerApi::ExchangerApiToken();
```

The token has a getter and a setter for each field: `setId`, `setUserId`, `setTokenName`, `setAccessToken`, `setRefreshToken`, `setCustomField`, `setAccessTokenExpiresAt`, `setRefreshTokenExpiresAt` and `setLastupdatedDate`, with matching `get…` methods.

---

### Sessions

Description:

The **`Sessions`** static method returns a new `ExchangerApiSessions`. See "How to keep tokens in the session" above.

Syntax:

```php
$sessions = ExchangerApi::Sessions();
```

---

### checkAPIConnection

Description:

The **`checkAPIConnection`** static method reports whether a stored token is still usable. See "How to check whether an API is connected" above.

Syntax:

```php
$status = ExchangerApi::checkAPIConnection(string $token_name);
```

**Parameters:**

- **`$token_name`**: The token name the record was stored under.

**Return Value:**

- **`Array`**: `status` (Boolean) and `message`.
- **`null`**: An exception was thrown. It is logged.

---

## ExchangerApiDAO class

Every method opens its own database connection. Errors are logged, and the method returns `false`.

### createTable

Description:

The **`createTable`** method creates `exchanger_api_oauth2_tokens` if it doesn't exist. `initializeExchangerAPI()` calls it.

Syntax:

```php
$ok = $exchangerApiDAO->createTable();
```

**Return Value:**

- **`Boolean`**: `true` on success.

---

### addToken

Description:

The **`addToken`** method inserts a token record. `created_date` is set to the current time in the `system_api_timezone` time zone.

Syntax:

```php
$ok = $exchangerApiDAO->addToken(ExchangerApiToken $token);
```

**Return Value:**

- **`Boolean`**: `true` on success.

---

### updateToken

Description:

The **`updateToken`** method updates the record with the token's id, or with its token name when `$byName` is `true`. Only fields with a value are written. See the warning under "How to create the token table": it fails on a table created by `initializeExchangerAPI()`.

Syntax:

```php
$ok = $exchangerApiDAO->updateToken(ExchangerApiToken $token, $byName = false);
```

**Return Value:**

- **`Boolean`**: `true` on success.

---

### removeTokenByID, removeTokenByTokenName, removeTokenByUserID

Description:

These methods delete the records that match the token's id, token name or user id.

Syntax:

```php
$ok = $exchangerApiDAO->removeTokenByID($token);
$ok = $exchangerApiDAO->removeTokenByTokenName($token);
$ok = $exchangerApiDAO->removeTokenByUserID($token);
```

**Return Value:**

- **`Boolean`**: `true` if the statement ran.

---

### getTokenByTokenName, getTokenByID

Description:

These methods return the first record that matches the token's name or id.

Syntax:

```php
$token = ExchangerApi::ExchangerApiToken();
$token->setTokenName('MyService');
$row = $exchangerApiDAO->getTokenByTokenName($token);
```

**Return Value:**

- **`Array`**: The row.
- **`null`**: No match.
- **`false`**: An error.

---

### checkTokenExistsByName

Description:

The **`checkTokenExistsByName`** method checks whether a record with the token's name exists.

Syntax:

```php
$count = $exchangerApiDAO->checkTokenExistsByName($token);
```

**Return Value:**

- **`Integer`**: `1` if it exists, `0` if not.
- **`false`**: An error.

---

### getTokenExpireDates

Description:

The **`getTokenExpireDates`** static method returns the expiry dates of the record with the token's name.

Syntax:

```php
$dates = ExchangerApiDAO::getTokenExpireDates($token);
```

**Return Value:**

- **`Array`**: `refresh_token_expires_at` and `access_token_expires_at`.
- **`false`**: No match, or an error.

---

## quickbooksAPI class

Methods that call QuickBooks catch exceptions, log them and return `false`.

### getAuthURL

Description:

The **`getAuthURL`** method returns the Intuit URL where the user approves the connection.

Syntax:

```php
$url = $qb->getAuthURL();
```

---

### exchangeAuthorizationCodeForToken

Description:

The **`exchangeAuthorizationCodeForToken`** method exchanges the code from Intuit's redirect for tokens, and saves them to the session and to the `QuickBooks` record.

Syntax:

```php
$ok = $qb->exchangeAuthorizationCodeForToken($code, $realmId, $user_id);
```

**Parameters:**

- **`$code`**: The `code` query parameter from the redirect.
- **`$realmId`**: The `realmId` query parameter, the QuickBooks company id. It's stored in `custom_field`.
- **`$user_id`**: The user who connected.

**Return Value:**

- **`Boolean`**: `true` on success.

---

### generateAccessToken

Description:

The **`generateAccessToken`** method loads the stored token into the client and refreshes it when needed. Call it before every query, batch or report.

Syntax:

```php
$ok = $qb->generateAccessToken($user_id);
```

**Return Value:**

- **`Boolean`**: `false` if there is no stored token or an exception is thrown, otherwise `true`. It also returns `true` when the refresh fails.

---

### validateToken, updateAccessToken, refreshAccessToken

Description:

The steps `generateAccessToken()` uses. `validateToken($accessTokenArray)` returns `true` if 7 or more days are left on the refresh token and 10 or more minutes on the access token. `updateAccessToken($accessTokenArray)` loads a token array into the client. `refreshAccessToken($accessTokenArray, $user_id)` gets new tokens from Intuit and saves them.

The token array has the keys `accessTokenKey`, `accessTokenSecret` (the refresh token), `QBORealmID`, `accessTokenExpireAt` and `refreshTokenExpireAt`.

---

### createQuery, executeQuery

Description:

**`createQuery`** returns a new SDK `QueryMessage` and keeps it in the client. **`executeQuery`** runs that query.

Syntax:

```php
$query = $qb->createQuery();
// set up $query
$result = $qb->executeQuery();
```

**Return Value:**

- The SDK's query result, or `false` on error.

---

### createBatch

Description:

The **`createBatch`** method returns a new SDK `Batch` for sending several operations in one request.

Syntax:

```php
$batch = $qb->createBatch();
```

---

### getContext

Description:

The **`getContext`** method returns the SDK's `ServiceContext`, which the SDK's report service needs.

Syntax:

```php
$context = $qb->getContext();
```

---

### getInvoiceAsPDF

Description:

The **`getInvoiceAsPDF`** method downloads an invoice as a PDF.

Syntax:

```php
$pdf = $qb->getInvoiceAsPDF($invoice_id);
```

**Return Value:**

- The PDF content, or `false` on error.

---

### revokeAccessToken

Description:

The **`revokeAccessToken`** method revokes the access token at Intuit, removes it from the session and deletes the `QuickBooks` record. The record is deleted even if revoking fails.

Syntax:

```php
$qb->revokeAccessToken();
```

**Return Value:**

- **`false`**: An exception was thrown. Otherwise it returns nothing.

---
