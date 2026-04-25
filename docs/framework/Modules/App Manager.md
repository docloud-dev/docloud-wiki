# App Manager

Owner: Nuwan Danushka

# Introduction

The AppManager module simplifies application and database management through two main classes: AppManager and AppManagerDatabaseFunctions. AppManager handles tasks like starting and stopping apps, managing user permissions, and retrieving app details. On the other hand, AppManagerDatabaseFunctions facilitates smooth communication with the database, offering functions to create, update, and retrieve data. Together, these classes provide an organized and user-friendly solution for effective application management, promoting reusability and scalability while maintaining a clear distinction between application logic and database interactions.

---

# AppManager Class

---

## Functions For Database Operations

This documentation provides a detailed overview of essential functions within the framework, specifically designed to streamline database operations. Let's delve into the functionality of each crucial function:

---

### createTable

Description:

The **`createTable`** function is designed to create tables dynamically by specifying the table name, an array of columns, and optionally, the primary key column.

The **`$ColumnAndDataType`** array should adhere to the following format:

```php
$ColumnAndDataType = array(
    "id" => "int(20) NOT NULL AUTO_INCREMENT",
    "name" => "varchar(255)",
    // Add more columns as needed
);
```

Syntax:

```php
AppManager::createTable(string $tableName, array $ColumnAndDataType, string $primaryKey = null)
```

**Parameters**:

- **`$tableName`**: The name of the table to be created.
- **`$ColumnAndDataType`**: An array specifying the columns and their data types.
- **`$primaryKey`** (optional): The column name is designated as the primary key.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function offers a flexible and efficient means to dynamically create tables, making it an indispensable tool for database schema management within your applications.

---

### insertIntoMetaTable

Description:

The **`insertIntoMetaTable`** function is designed to insert data into metatables. Users need to specify the meta table name, a unique column name, the unique value for that column, and the data to be inserted.

The **`$dataToInsert`** array should follow this format:

```php
$dataToInsert = array(
											"contact_name" => 'Thilina',
											"contact_occupation" => 'CEO',
											 // Add more data as needed
									);
```

Syntax:

```php
AppManager::insertIntoMetaTable(string $tableName, string $uniqueColumn, string $uniqueValue, array $dataToInsert)
```

**Parameters**:

- **`$tableName`**: The name of the meta table where data will be inserted.
- **`$uniqueColumn`**: The unique column name in the meta table.
- **`$uniqueValue`**: The unique value corresponding to the specified unique column.
- **`$dataToInsert`**: An array containing the data to be inserted into the meta table.

**Returns:** returns true if success and false if not success

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a streamlined approach to insert metadata, making it a valuable asset for managing metadata associated with various tables in your application.

---

### getRecordsFromMetaTable

Description:

The **`getRecordsFromMetaTable`** function is engineered to retrieve data from meta tables. Users must specify the meta table name, a unique column name, and the unique value for that column.

Syntax:

```php
AppManager::getRecordsFromMetaTable(string $tableName, string $uniqueColumn, string $uniqueValue)
```

**Parameters**:

- **`$tableName`**: The name of the metatable where data will be retrieved.
- **`$uniqueColumn`**: The unique column name in the meta table.
- **`$uniqueValue`**: The unique value corresponding to the specified unique column.

**Returns:**

- **`Array`** of data if the retrieve is successful.
- **`false`** if the operation is not successful.

This function provides a streamlined approach to retrieving metadata, making it a valuable asset for managing metadata associated with various tables in your application.

---

### updateMetaTable

Description:

The **`updateMetaTable`** function is engineered to update data in metatables. It updates existing records if the specified value exists and inserts a new record if it does not.

Syntax:

```php
AppManager::updateMetaTable(string $tableName, string $uniqueColumn, string $uniqueValue, string $meta_key_column, string $updating_value)
```

**Parameters**:

- **`$tableName`**: The name of the metatable where data will be retrieved.
- **`$uniqueColumn`**: The unique column name in the meta table.
- **`$uniqueValue`**: The unique value corresponding to the specified unique column.
- **`$meta_key_column`**: The meta key is to be updated in the meta table.
- **`$updating_value`**: The new value to be set in the specified meta key column.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a streamlined approach to update metadata, seamlessly managing metadata associated with various tables in your application.

---

### deleteMetaTableRecords

Description:

The **`deleteMetaTableRecords`** function is engineered to delete records from meta tables, providing an efficient and streamlined approach to data removal based on a unique key.

Syntax:

```php
AppManager::deleteMetaTableRecords(string $tableName, string $uniqueColumn, string $uniqueValue)
```

**Parameters**:

- **`$tableName`**: The name of the metatable where data will be retrieved.
- **`$uniqueColumn`**: The unique column name in the meta table.
- **`$uniqueValue`**: The unique value corresponding to the specified unique column.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides an efficient and streamlined approach to deleting metadata, making it an invaluable asset for managing metadata associated with various tables in your application.

---

### deleteMetaTableValue

Description:

The **`deleteMetaTableValue`** function is engineered to delete a specific record from meta tables, providing an efficient and streamlined approach to data removal based on a unique key and meta key.

Syntax:

```php
AppManager::deleteMetaTableValue(string $tableName, string $uniqueColumn, string $uniqueValue, string $meta_key_column)
```

**Parameters**:

- **`$tableName`**: The name of the metatable where data will be retrieved.
- **`$uniqueColumn`**: The unique column name in the meta table.
- **`$uniqueValue`**: The unique value corresponding to the specified unique column.
- **`meta_key_column`**: The meta key associated with the record to be deleted.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to deleting metadata, making it an invaluable asset for managing metadata associated with various tables in your application.

---

### insertInToTable

Description:

The **`insertInToTable`** function is engineered to insert values into a specified table. Users need to pass the table name and data as an associative array.

The **`$data`** array should follow this format:

- The array key should be the column name
- The array value should be the value you want to insert

```php
$data = array(
    "name" => 'John',
    "age" => '20',
    // Add more data as needed
);
```

Syntax:

```php
AppManager::insertInToTable(string $tableName, array $data)
```

**Parameters**:

- **`$tableName`**: The name of the table where data will be inserted.
- **`$data`**: An associative array containing the data to be inserted into the table.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to insert data into tables, making it an invaluable asset for managing various tables in your application.

---

### insertMultiple

Description:

The **`insertMultiple`** function is engineered to insert multiple values into a specified table. Users need to pass the table name and data as an associative array. The array keys should correspond to the column names, and the array values should contain arrays of data to be inserted.

The **`$dataArray`** array should follow this format:

- The **`column`** key’s value should be an array of column names.
- The **`dataArray`** key’s value should be an array of data to insert.

```php
$dataArray = array(
				'column' => array("first_name", "last_name"),
				'data' => array(
										array("first_name" => "Kaylee", "last_name" => "Frye"),
									  array("first_name" => "Jayne", "last_name" => "Cobb"),
										array("first_name" => "Jayne", "last_name" => "Cobb")
									)
					);
```

Syntax:

```php
AppManager::insertMultiple(string $tableName, array $dataArray)
```

**Parameters**:

- **`$tableName`**: The name of the table where data will be inserted.
- **`$dataArray`**: An associative array containing the data to be inserted into the table. It should have a 'column' key with an array of column names and a 'data' key with an array of arrays containing the data.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to batch data insertion into tables, making it an invaluable asset for managing various tables in your application.

---

### updateTable

Description:

The **`updateTable`** function is engineered to update specific record values in a table. Users need to pass the table name, data, and criteria for updating records.

The **`$data`** array should follow this format:

- The array key should be the column name
- The array value should be the value you want to update

```php
$data = array(
    "name" => 'John',
    "age" => '20',
    // Add more data as needed
);
```

Syntax:

```php
AppManager::updateTable(string $tableName, array $data, string $where_column_name, string $where_value)
```

**Parameters**:

- **`$tableName`**: The name of the metatable where data will be retrieved.
- **`$uniqueColumn`**: The unique column name in the meta table.
- **`$where_column_name`**:  The column name for the WHERE clause.
- **`$where_value`**: The value to be matched in the WHERE clause.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to update table records, making it an invaluable asset for managing tables in your application.

---

### addPrimaryKeyToTable

Description:

The **`addPrimaryKeyToTable`** function is engineered to add a primary key to a specified table.

Syntax:

```php
AppManager::addPrimaryKeyToTable(string $table, string $primarykeycolumn)
```

**Parameters**:

- **`$tableName`**: The name of the table where the primary key will be added.
- **`$primarykeycolumn`**: The name of the primary key column to be added to the table.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to adding the primary key to the table. making it an invaluable asset for managing metadata associated with various tables in your application.

---

### deleteFromTable

Description:

The `deleteFromTable` function is engineered to delete records from the specified table based on a provided condition.

Syntax:

```php
AppManager::deleteFromTable(string $tableName, string $where_column_name, string $where_value)
```

**Parameters**:

- **`$tableName`**: The name of the table.
- **`$where_column_name`**: The column name for the WHERE clause.
- **`$where_value`**: The value to be matched in the WHERE clause.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to deleting records from the table. making it an invaluable asset for managing tables in your application.

---

### deleteFromTableMultipleWhere

Description:

The **`deleteFromTableMultipleWhere`** function is engineered to delete records from the specified table based on multiple conditions.

The **`$data`** array should follow this format:

- The array key should be the column name
- The array value should be the matching value you want to delete

```php
$where_columns_n_values = array(
    "type" => 'animals',
    "category" => 'cats',
    // Add more data as needed
);
```

Syntax:

```php
AppManager::deleteFromTableMultipleWhere(string $tableName, array $where_columns_n_values)
```

**Parameters**:

- **`$tableName`**: The name of the table.
- **`$where_columns_n_values:`** An associative array containing column names as keys and corresponding values as values, representing the conditions for deletion.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to deleting records from a table based on multiple conditions, making it an invaluable asset for managing tables in your application.

---

### dropTable

Description:

The **`dropTable`** function is engineered to drop the specified table from the database.

Syntax:

```php
AppManager::dropTable(string $tableName)
```

**Parameters**:

- **`$tableName`**: The name of the table will be dropped.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to drop a table, making it an invaluable asset for managing tables in your application.

---

### emptyTable

Description:

The **`emptyTable`** function is engineered to remove all data from the specified table, effectively emptying its contents.

Syntax:

```php
AppManager::emptyTable(string $tableName)
```

**Parameters**:

- **`$tableName`**: The name of the table from which all data will be removed.

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to empty the data from a table, making it an invaluable asset for managing tables in your application.

---

### getRecordsFromTable

Description:

The **`getRecordsFromTable`** function is engineered to retrieve values from the specified table. Users can specify conditions for retrieval, select specific columns, and opt for distinct values.

Syntax:

```php
AppManager::getRecordsFromTable(string $tableName, string $where_column_name = null, string $where_value = null, array $columns = null, bool $distinct = false)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.
- **`$whereColumnName`**: The column name for the WHERE clause (optional).
- **`$whereValue`**: The value to be matched in the WHERE clause (optional).
- **`$columns`**: An array of column names to retrieve (optional).
- **`$distinct`**: Flag to indicate if distinct values should be retrieved (default is **`false`**).

**Returns:**

- An `array` of data if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to retrieving data from a table, making it an invaluable asset for managing tables in your application.

---

### getRecordsLimited

Description:

The **`getRecordsLimited`** function is engineered to retrieve values from the specified table with pagination support. Users can specify conditions for retrieval, select specific columns, and opt for distinct values.

Syntax:

```php
AppManager::getRecordsLimited(string $tableName, int $page, int $recordsPerPage, string $whereValue = null, string $whereColumnName = null, array $columns = null, $orderBy = null, $latestRecord = true)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.
- **`$page`**: The current page number for paginated retrieval.
- **`$recordsPerPage`**: The number of records to be retrieved per page.
- **`$whereColumnName`**: The column name for the WHERE clause (optional).
- **`$whereValue`**: The value to be matched in the WHERE clause (optional).
- **`$columns`**: An array of column names to retrieve (optional).
- **`$orderBy`**: The column by which the result should be ordered (optional).
- **`$latestRecord`**: Flag to indicate if the latest record should be retrieved first (default is **`true`**).

**Returns:**

- An `array` of data if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to paginated retrieval of data from a table, making it an invaluable asset for managing tables in your application.

---

### getRecordFromTable

Description:

The **`getRecordFromTable`** function is engineered to retrieve values from the specified table. Users can specify conditions for retrieval, select specific columns, and opt for distinct values.

Syntax:

```php
AppManager::getRecordFromTable(string $tableName, string $where_column_name = null, string $where_value = null, array $columns = null, bool $distinct = false)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.
- **`$whereColumnName`**: The column name for the WHERE clause (optional).
- **`$whereValue`**: The value to be matched in the WHERE clause (optional).
- **`$columns`**: An array of column names to retrieve (optional).
- **`$distinct`**: Flag to indicate if distinct values should be retrieved (default is **`false`**).

**Returns:**

- An `array` of data if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to retrieving a single record from a table, making it an invaluable asset for managing tables in your application.

---

### selectLikeFromTable

Description:

The **`selectLikeFromTable`** function is engineered to search for a specified pattern in a column of a table. Users can specify conditions for retrieval, select specific columns, and opt for distinct values.

Syntax:

```php
AppManager::selectLikeFromTable(string $tableName, string $where, string $like, array $columns = null, $distinct = false)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.
- **`$where`**: The column name for the WHERE clause.
- **`$like`**: The pattern to search for in the specified column.
- **`$columns`**: An array of column names to retrieve (optional).
- **`$distinct`**: Flag to indicate if distinct values should be retrieved (default is **`false`**).

**Returns:**

- An `array` of data if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to retrieve records based on a specified pattern in a column, making it an invaluable asset for managing tables in your application.

---

### customSelectQuery

Description:

The **`customSelectQuery`** function is engineered to execute custom SELECT queries on a specified table. It offers flexibility by allowing users to define custom SELECT, WHERE, and JOIN clauses. Additionally, users can choose to retrieve a single result or multiple results based on the query.

Syntax:

```php
AppManager::customSelectQuery(string $tableName, string $select, string $where = null, string $join = null, bool $getSingle = false)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.
- **`$select`**: Custom SELECT string.
- **`$where`**: Custom WHERE string (optional).
- **`$join`**: Custom JOIN string (optional).
- **`$getSingle`**: Pass **`true`** to retrieve a single result (default is **`false`**).

**Returns:**

- An `array` of data if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to executing custom SELECT queries, making it an invaluable asset for managing tables in your application.

---

### customSelectQuerySingle

Description:

The **`customSelectQuerySingle`** function is engineered to execute custom SELECT queries on a specified table, allowing users to define custom SELECT, WHERE, and JOIN clauses. This function is optimized for retrieving a single result based on the query.

Syntax:

```php
AppManager::customSelectQuerySingle(string $tableName, string $select, string $where = null, string $join = null)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.
- **`$select`**: Custom SELECT string.
- **`$where`**: Custom WHERE string (optional).
- **`$join`**: Custom JOIN string (optional).

**Returns:**

- An `array` of data if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to executing custom SELECT queries and retrieving a single result, making it an invaluable asset for managing tables in your application.

---

### getRecordCount

Description:

The **`getRecordCount`** function is engineered to efficiently retrieve the record count of a specified table.

Syntax:

```php
AppManager::getRecordCount(string $tableName)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.

**Returns:**

- An `array` value represents the record count if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to retrieving the record count of a table, making it an invaluable asset for managing tables in your application.

---

### checkRecordExistById

Description:

The **`checkRecordExistById`** function is engineered to efficiently verify the existence of a record in a specified table based on its ID.

Syntax:

```php
AppManager::checkRecordExistById(string $tableName, int $id)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.
- **`$id`**: The ID of the record to be checked for existence.

**Returns:**

- An integer value (1) represents the record that exists.
- **`false`** if the record does not exist or if the operation is not successful.

This function provides a precise and streamlined approach to verifying the existence of a record in a table based on its ID, making it an invaluable asset for managing tables in your application.

---

### checkRecordExistByIdnKey

Description:

The **`checkRecordExistByIdnKey`** function stands as an advanced tool in our framework, providing an efficient solution for verifying the existence of a record in a specified table based on both its ID and a custom key column. This comprehensive guide dissects the purpose, syntax, and optimal usage of this essential function.

Syntax:

```php
AppManager::checkRecordExistByIdnKey(string $tableName, int $id, $keyColumn, $keyValue)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.
- **`$id`**: The ID of the record to be checked for existence.
- **`$keyColumn`**: The custom key column to be checked.
- **`$keyValue`**: The value of the custom key column to be checked.

**Returns:**

- An integer value (1) represents the record that exists.
- **`false`** if the record does not exist or if the operation is not successful.

This function provides a precise and streamlined approach to verifying the existence of a record in a table based on its ID and a custom key column, making it an invaluable asset for managing tables in your application.

---

### getNextAutoIncrementID

Description:

The **`getNextAutoIncrementID`** function is engineered to efficiently retrieve the next auto-increment ID of a specified table.

Syntax:

```php
AppManager::getNextAutoIncrementID($table_name)
```

**Parameters**:

- **`$tableName`**: The name of the table from which data will be retrieved.

**Returns:**

- An `array` containing the value representing the next auto-increment ID if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to retrieving the next auto-increment ID of a table, making it an invaluable asset for managing tables in your application.

---

---

## Functions For App Operations

This documentation outlines key functions within our framework, tailored to optimize various app operations. Each function is meticulously crafted to enhance efficiency and streamline essential tasks. Explore the detailed descriptions and usage syntax below.

---

### getRegistered_apps

Description:

The `getRegistered_apps` function retrieves registered apps from the system configuration file.

Syntax:

```php
AppManager::getRegistered_apps()
```

**Returns:**

- An array containing registered system apps.
- **`false`** if the operation is not successful.

<aside>
💡 Apps are automatically registered to configuration when the app instance is created.

</aside>

This function provides a precise and streamlined approach to retrieving registered apps in the configuration, making it an invaluable asset for managing apps in your application.

---

### register

Description:

The **`register`** function is used to register an app in the system configuration.

Syntax:

```php
AppManager::register($app_name, $active)
```

**Parameters**:

- **`$app_name`:** The name of the app to be registered.

**Returns:**

- void

This function provides a precise and streamlined approach to save and register the app on the configuration, making it an invaluable asset for managing apps in your application.

---

### CreateAppInstance

Description:

The **`CreateAppInstance`** function is employed to instantiate an app.

Syntax:

```php
AppManager::CreateAppInstance(string $AppName)
```

**Parameters**:

- **`$app_name`:** The name of the app to be create instence.

**Returns:**

- An app object upon successful operation.
- **`false`** if the operation is not successful.

This function offers a straightforward and efficient way to create an instance of an app.

---

### checkIfAppExist

Description:

The `checkIfAppExist` function is utilized to verify if an app exists in the system.

Syntax:

```php
AppManager::checkIfAppExist(string $appName)
```

**Parameters**:

- **`$app_name`:** The name of the app to check for existence.

**Returns:**

- **`true`** if the app exists.
- **`false`** if the app does not exist.

This function provides a straightforward and efficient way to check whether an app exists in the system.

---

### getAppPermission

Description:

The **`getAppPermission`** function is created to retrieve an app's permissions for internal app communications.

Syntax:

```php
AppManager::getAppPermission(string $app_name)
```

**Parameters**:

- **`$app_name`:** The name of the app

**Returns:**

- An array of app names allowed for communication with other apps.
- **`false`** if the app does not exist.

This function offers a straightforward and efficient way to retrieve app permissions for internal communications,

---

### createTablesfromxml

Description:

The **`createTablesfromxml`** function generates tables for the specified app if they do not already exist. The table definitions are taken from the app's **`config.xml`** file.

<aside>
💡 This function creates tables for the app calling the function.

</aside>

Syntax:

```php
AppManager::createTablesfromxml()
```

**Returns:**

- void

This function provides a straightforward and efficient way to generate tables for an app based on its **`config.xml`** file.

---

### generateTableFromXml

Description:

The `generateTableFromXml` function generates tables for the specified app if they do not already exist. The table definitions are taken from the app's **`config.xml`** file.

Syntax:

```php
AppManager::generateTableFromXml($app_name)
```

**Parameters**:

- **`$app_name`:** The name of the app to be created tables from the XML.

**Returns:**

- void

This function provides a straightforward and efficient way to generate tables for an app based on its **`config.xml`** file.

---

### getAppsInfo

Description:

The **`getAppsInfo`** function reads the XML configurations of apps in the system and provides the info section of the XML config.

Syntax:

```php
AppManager::getAppsInfo()
```

**Returns:**

- An array containing app information in the system.
- An empty array if the operation to retrieve app information is unsuccessful.

This function offers a straightforward and efficient way to retrieve information about apps in the system.

---

### extract_xml_section_from_all_app_configs

Description:

The **`extract_xml_section_from_all_app_configs`** function extracts the specified XML section from the configuration of each application.

Syntax:

```php
AppManager::extract_xml_section_from_all_app_configs($section)
```

**Parameters**:

- **`$section`:**  The section to extract from each app's configuration.

**Returns:**

- An array containing the specified XML section from each app's configuration.
- An empty array if retrieval is unsuccessful.

This function provides a straightforward and efficient way to extract a specific XML section from the configuration of all applications.

---

### getAppsUserPermissions

Description:

The **`getAppsUserPermissions`** function retrieves the defined user permissions of all apps in the system.

Syntax:

```php
AppManager::getAppsUserPermissions()
```

**Returns:**

- An array of user permissions of apps.
- An empty array if retrieval is unsuccessful..

his function offers a straightforward and efficient way to retrieve user permissions of apps.

---

### getAppUserPermission

Description:

The **`getAppUserPermission`** function retrieves an app’s defined user permissions.

Syntax:

```php
AppManager::getAppsUserPermissions(string $app_name)
```

**Parameters**:

- **`$app_name`:** The name of the app

**Returns:**

- An array of user permissions of an app.
- An empty array if retrieval is unsuccessful.

This function offers a straightforward and efficient way to retrieve user permissions of an app

---

### getTableNames

Description:

The **`getTableNames`** function is designed to retrieve table names from the specified app’s XML config.

Syntax:

```php
AppManager::getTableNames($app_name = null)
```

**Parameters**:

- **`$app_name` (optional):** The name of the app. If not specified, it will get the calling app.

**Returns:**

- An array of table names
- An empty array if retrieval is unsuccessful.

This function offers a straightforward and efficient way to retrieve table names.

---

### runCommonFuntionInApps

Description:

The **`runCommonFuntionInApps`** function is designed to invoke a method declared within the 'app' class. It iterates through all instances of the 'app' class and executes the specified function with the given parameters.

Syntax:

```php
AppManager::runCommonFuntionInApps($function_name, $params)
```

**Parameters**:

- **`$function_name`: The name of the function to be called within the 'app' class.**
- $params: An array containing any parameters needed for the function.

**Returns:**

- An array containing the results of executing the specified function in each app class.
- An empty array if retrieval is unsuccessful.

This function offers a straightforward and efficient way to invoke methods within the 'app' class for internal communication.,

---

### getAppRun

Description:

The **`getAppRun`** function is created to retrieve configuration tasks for an app from its XML configuration file. It retrieves configuration tasks, such as scripts and SQL queries, for a specified app from its XML configuration file (**`app_name.xml`**). The tasks are located within the 'run' element of the XML.

Syntax:

```php
AppManager::getAppRun($app_name = null)
```

**Parameters**:

- **`$app_name`:** The name of the app for which configuration tasks are to be retrieved. If not provided, it is dynamically determined from the calling app.

**Returns:**

- Returns a SimpleXMLElement representing the 'run' element from the app's XML configuration file.
- **`false`** If the file or 'run' element is not found, returns false.

This function offers a straightforward and efficient way to retrieve configuration tasks from the XML file of a specified app.

---

### runConfig

Description:

The **`runConfig`** function is designed to execute configuration tasks for an app, including scripts and SQL queries. This function executes configuration tasks for an app, obtained from the 'AppRun' configuration. Tasks can include running scripts or executing SQL queries, depending on the configuration.

Syntax:

```php
AppManager::runConfig($app_name = null)
```

**Parameters**:

- **`$app_name`:** The name of the app for which configuration tasks are to be retrieved. If not provided, it is dynamically determined from the calling app.

**Returns:**

- Returns an array indicating the success of each configuration task.
- **`false`** If no tasks are executed, returns false.

This function provides a straightforward and efficient way to execute configuration tasks for an app based on the 'AppRun' configuration.

---

### initialize_app

Description:

The **`initialize_app`** function is designed to initialize an app by creating/updating its database tables, adding columns, and managing permissions. This function performs the following tasks:

- Determines the app name, either from the provided parameter or dynamically from the calling app.
- Uses **`AppManager::DBFunctions()`** to manage database-related functions.
- Retrieves tables from XML configuration and checks/creates each table in the database.
- Adds new columns to existing tables if necessary.
- Manages user permissions for both app users and the admin panel.
- Executes app-specific scripts using **`AppManager::runConfig()`**.

Syntax:

```php
AppManager::initialize_app($app_name = null)
```

**Parameters**:

- **`$app_name`:** The name of the app to initialize. If not provided, it is dynamically determined from the calling app.

**Returns:**

- Returns an array with information about the initialization process.
- **`false`** if an error occurs.

This function provides a comprehensive and efficient way to initialize an app, ensuring that database tables, columns, and permissions are set up correctly.

---

# AppManagerDatabaseFunctions Class

---

## Functions For Database Operations

### check_table_exist

Description:

The **`check_table_exist`** function is used to check if the specified table exists in the database.

Syntax:

```php
AppManager::check_table_exist($table_name)
```

**Parameters**:

- **`$table_name`:** The name of the table

**Returns:**

- **`true`** if the table exists.
- **`false`** if the table does not exist.

This function provides a straightforward and efficient way to check the existence of a table in the database.

---

### create_table

Description:

The **`create_table`** function is used to create a table in the database.

The **`$table`** array should follow this format:

```php
$table = array(
    'name' => 'your_table_name',
    'column' => array(
        array(
            'name' => 'column1',
            'type' => 'datatype1',
            'size' => 'size1',
            'default' => 'default_value1',
            'attributes' => 'additional_attributes1',
            'null' => 'true_or_false', // 'true' for NULL, 'false' for NOT NULL
            'autoincrement' => 'true_or_false', // 'true' for AUTO_INCREMENT, 'false' for no autoincrement
            'primarykey' => 'true_or_false', // 'true' if this column is part of the primary key, 'false' otherwise
        ),
        // Additional columns can be added similarly
        array(
            'name' => 'column2',
            // ... (other column properties)
        ),
    ),
);
```

Syntax:

```php
AppManager::create_table($table,$prefix)
```

**Parameters**:

- **`$table`:** The data of the table to be created.
- **`$prefix`:** The table prefix.

**Returns:**

- **`true`** if the table is successfully created.
- **`false`** if the table creation fails.

This function provides a straightforward and efficient way to create a table in the database.

---

### get_columns

Description:

The **`get_columns`** function is used to retrieve the columns of a specified table.

Syntax:

```php
AppManager::get_columns($table_name)
```

**Parameters**:

- **`$table_name`:** The name of the table

**Returns:**

- An array of columns
- **`false`** if the table does not exist.

This function offers a precise and efficient way to retrieve the columns of a table.

---

### get_column_info

Description:

The **`get_column_info`** function is used to retrieve information about a specific column in a table.

Syntax:

```php
AppManager::get_column_info($table_name, $column_name)
```

**Parameters**:

- **`$table_name`**: The name of the table to get column info.
- **`$column_name`**: The column name to get info.

**Returns:**

- An array containing information about the specified column.
- **`false`** if the table or column does not exist.

This function offers a precise and efficient way to retrieve information about a specific column in a table.

---

### update_column

Description:

The **`update_column`** function is used to update the properties of a column in a table.

Syntax:

```php
AppManager::update_column($table_name, $column_name, $type, $size = null, $default = null, $attributes = null, $nullable = false, $new_column_name = null)
```

**Parameters**:

- **`$table_name`**: The name of the table in which the column exists.
- **`$column_name`**: The name of the column to be updated.
- **`$type`**: The new data type for the column.
- **`$size`**: The new size for the column (optional).
- **`$default`**: The new default value for the column (optional).
- **`$attributes`**: The new attributes for the column (optional).
- **`$nullable`**: Boolean indicating whether the column should be nullable (default is **`false`**).
- **`$new_column_name`**: The new name for the column (optional).

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to updating the properties of a column in a table, making it an invaluable asset for managing database schema changes in your application.

---

### add_column

Description:

The **`add_column`** function is used to add a new column to a table in the database.

Syntax:

```php
AppManager::add_column($table_name, $column_name, $type, $size = null, $default = null, $attributes = null, $nullable = false)
```

**Parameters**:

- **`$table_name`**: The name of the table to which the new column will be added.
- **`$column_name`**: The name of the new column.
- **`$type`**: The data type of the new column.
- **`$size`**: The size of the new column (optional).
- **`$default`**: The default value for the new column (optional).
- **`$attributes`**: The attributes for the new column (optional).
- **`$nullable`**: Boolean indicating whether the new column should be nullable (default is **`false`**).

**Returns:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This function provides a precise and streamlined approach to adding a new column to a table, making it an invaluable asset for managing database schema changes in your application.

---

### compareAndUpdateColumn

---