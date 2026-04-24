# File Manager

Owner: Nuwan Danushka

# Introduction

The FileManager module in the DoFramework simplifies file operations within applications, providing intuitive functions for tasks like creation and deletion. With a focus on efficiency and ease of use, it offers developers a streamlined solution for effective file management.

---

# File Manager Class Methods

## remove_http

Description:

The **`remove_http`** method is utilized to remove the "http://" or "https://" prefix from a URL if present.

Syntax:

```php
FileManager::remove_http($url);
```

**Parameters**:

- **`$url`**: The URL from which to remove the prefix.

**Return Value:**

- Returns **`string`**: The URL without the "http://" or "https://" prefix.
- Returns **`false`** when the operation fails.

This method provides a means to remove URL prefixes such as "http://" or "https://".

---

## imageUploadv2

Description:

The **`imageUploadv2`** method is utilized for uploading images to the server.

Syntax:

```php
FileManager::imageUploadv2($image, Array $allowedFileTypes, int $allowedFileSize, string $path, string $uniqueName = null)
```

**Parameters**:

- **`$image`**: Pass the file from the request.
    - **`$request->getfile['filename']`**
    
- **`$allowedFileTypes`**: An array specifying allowed file types.
    - **`array('jpg')`**
    - 
- **`$allowedFileSize`**: Size limit of the file in bytes.
    - 5000000  for 5MB.
    
- **`$path`**: Folder path to which the image will be uploaded
    - **`'users/profileimages/'`**.
    
- **`$uniqueName`** (optional): Unique name for the uploaded file. else it will generate a unique ID

**Return Value:**

- Returns **`string`**: Path of the image.
- Returns **`false`** when the operation fails.

This method offers a convenient means to upload images.

---

## imageResize / imageResize_global

Description:

The **`imageResize`** method is utilized for resizing images.

<aside>
💡 jpeg, jpg, png, gif, and webp are allowed

</aside>

The **`$widthAndHeight`** array should adhere to the following format:

```php
$widthAndHeight = array(
    "width" => "150",
    "height" => "150",
);
```

Syntax:

```php
FileManager::imageResize(string $imagePath, string $savePath, string $fileName, array $widthAndHeight)
```

**Parameters**:

- **`$imagePath`**: Pass the file path of the image.
- **`$fileName`**: File name that should be renamed or the desired file name.
- **`$savePath`**: Folder path to save the resized image, e.g., **`'users/image/thumbnails'`**.
- **`$widthAndHeight`**: An array specifying the width and height.

**Return Value:**

- Returns **`string`**: Path of the resized image.
- Returns **`false`** when the operation fails.

This method is used to resize images.

---

## createImageThumbnail

Description:

The **`createImageThumbnail`** method is utilized for resizing images.

<aside>
💡 jpeg, jpg, png, gif, and webp are allowed

</aside>

The **`$image_sizes_ary`** array should adhere to the following format:

```php
$widthAndHeight = array(
					array('name' => 'thumbnail', 'width' => '150', 'height' => '150'),
					array('name' => 'medium', 'width' => '500', 'height' => '500'),
					array('name' => 'large', 'width' => '1024', 'height' => '1024')
					);
```

Syntax:

```php
FileManager::createImageThumbnail(string $imagePath, string $savePath, array $image_sizes_ary)
```

**Parameters**:

- **`$imagePath`**: Pass the file path of the image.
- **`$savePath`**: Folder path to save the resized image, e.g., **`'users/image/thumbnails'`**.
- **`$**image_sizes_ary`: An array specifying the width and height of thumbnails.

**Return Value:**

- Returns **`array`**:  array of the resized image paths and sizes.
- Returns **`false`** when the operation fails.

This method is used to create thumbnails.

---

## deleteImage

Description:

The **`deleteImage`** method is used to delete images or thumbnails.

Syntax:

```php
FileManager::deleteImage($path, $fileName)
```

**Parameters**:

- **`$path`**: Pass the file path of the image.
- **`$fileName`**: Pass the Image name.

**Return Value:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This method allows for the deletion of images or thumbnails.

---

## deleteAllFiles

Description:

The **`deleteAllFiles`** method is used to delete files in a given path.

<aside>
💡  Directories will not be deleted.

</aside>

Syntax:

```php
FileManager::deleteAllFiles($path);
```

**Parameters**:

- **`$path`**: Pass the file path of files.

**Return Value:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

This method is designed to delete files within a specified path, excluding directories.

---

## filesuploadv2

Description:

The **`filesuploadv2`** method is utilized to upload a file to the specified path with optional unique filename and checks against allowed file types and size.

Syntax:

```php
FileManager::filesuploadv2($file, array $allowedFileTypes, int $allowedFileSize, string $path, string $uniqueName = null);
```

**Parameters**:

- **`$file`**: The file to be uploaded.
- **`$allowedFileTypes`**: An array specifying allowed file types.
- **`$allowedFileSize`**: The maximum allowed file size in bytes.
- **`$path`**: The folder path to which the file will be uploaded.
- **`$uniqueName`** (optional): Unique name for the uploaded file.

**Return Value:**

- An **`array`** containing name, extension, path, and URL if the operation is successful.
- **`array`** containing the error message ****if the operation is not successful.
- **`false`** if there are exceptions.

This method provides functionality to upload files while ensuring they meet specified criteria.

---

## base64ImagetoImageFile

Description:

The **`base64ImagetoImageFile`** method is utilized to convert a base64 encoded image string to an image file and save it to the specified path.

Syntax:

```php
FileManager:: base64ImagetoImageFile($base64String, $path, $uniqueName = null);
```

**Parameters**:

- **`$base64String`**: The base64 encoded image string to be converted.
- **`$path`**: The folder path where the image file will be saved.
- **`$uniqueName`** (optional): Unique name for the saved image file.

**Return Value:**

- Returns **`true`** if the operation is successful.
- Returns **`false`** if the operation is not successful.

This method provides functionality to convert a base64 encoded image string to an image file and save it to the specified path.

---

## removeDirectory

Description:

The **`removeDirectory`** method is used to delete files and directories in a path.

Syntax:

```php
FileManager::removeDirectory($directory);
```

**Parameters**:

- **`$directory`**: Pass the path of the directory.

**Return Value:**

- **`true`** if the operation is successful.
- **`false`** if the operation is not successful.

---