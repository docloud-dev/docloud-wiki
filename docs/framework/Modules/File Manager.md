---
title: File Manager
sidebar_label: File Manager
---

# File Manager

Owner: Nuwan Danushka

# Introduction

`FileManager` is the framework module for files: it takes uploads from a request, makes image thumbnails, builds paths and public URLs, and copies and deletes files. All of its methods are static, so you call them as `FileManager::methodName()`.

Files are stored in one of two places, chosen by `system_storage_type` in `api/config.<environment>.xml`:

- **`LOCAL`** (the default): files go into the `storage/` folder of the site root, next to `api/`. The web server serves them directly, so a file saved as `storage/myapp/photos/a.jpg` loads from `https://<your host>/storage/myapp/photos/a.jpg`.
- **`S3`**: files go into an S3 bucket, or any service with an S3-compatible API.

The module reads the setting the first time a request uses `FileManager`. You don't need to initialise it. Most upload, thumbnail, URL and delete methods follow the setting. Some methods only ever work on the local disk and some only on S3. The table at the end of "How to switch to S3 storage" lists which are which.

The image methods need the PHP `gd` and `exif` extensions.

## Paths used on this page

The methods mix three kinds of path. Keep them apart:

| Kind | Example | Used by |
| --- | --- | --- |
| Root-relative path | `/storage/myapp/photos/` | Upload and thumbnail methods, `buildUrl`, `deleteImage`, `deleteAllFiles`. It starts with `/` and is relative to the site root. For a folder, end it with `/`. |
| Absolute file path | `/var/www/html/storage/myapp/photos/a.jpg` | `createImageThumbnail` (local mode), `delete_file` (local mode), `copyFile`, `removeDirectory`. |
| S3 object key | `storage/myapp/photos/a.jpg` | `objectExist`, `objectDelete`, `putObject`. No leading `/` and no bucket name. |

`create_directory()` turns a folder name into a root-relative path, and `build_path()` turns a root-relative path into an absolute file path in local mode.

<aside>
⚠️ The local root is the web server's document root (`$_SERVER['DOCUMENT_ROOT']`). In `shell.php` and heartbeat runs it is empty, so local file methods point at the wrong place there. Do file work in HTTP requests. See [Architecture](../Architecture.md) for the CLI differences.

</aside>

---

# How to upload a file from a controller

Read the uploaded files with `$this->getRequest()->getFiles()`. It returns PHP's `$_FILES` array, keyed by the form field name. Pass one entry to `filesuploadv2()` with the allowed extensions, the size limit in bytes and the target folder.

```php
private function upload_document()
{
    $res = new Response();
    $files = $this->getRequest()->getFiles();

    if (empty($files['document'])) {
        echo $res->create(200, 'No file was sent.', false);
        return;
    }

    // Creates storage/myapp/documents/ if needed and returns "/storage/myapp/documents/"
    $dir = FileManager::create_directory('myapp/documents/');

    $result = FileManager::filesuploadv2(
        $files['document'],
        array('pdf', 'docx', 'xlsx'),
        5000000, // 5 MB
        $dir
    );

    if ($result === false || !$result['status']) {
        echo $res->create(200, $result['message'] ?? 'Upload failed.', false);
        return;
    }

    $res->setData($result['info']);
    echo $res->create(200, 'Document uploaded.', true);
}
```

Call the action from a `POST` handler. On success, `$result` looks like this in local mode:

```php
array(
    'status' => true,
    'message' => 'File uploaded successfully',
    'info' => array(
        'name' => '66f1c2a9e4b1d',             // file name without extension
        'extension' => 'pdf',
        'path' => '/var/www/html/storage/myapp/documents/66f1c2a9e4b1d.pdf',
        'url' => '/storage/myapp/documents/66f1c2a9e4b1d.pdf',
    ),
)
```

The file is saved under a new name, `uniqid()` plus the extension, unless you pass your own name as the fifth argument. If the name comes from the user, clean it first with `sanitize_file_name()`.

On the frontend, send the file in `FormData` with `XP.readyFormData()` (see `readyFormData` in [Frontend Runtime (XP)](../Frontend%20Runtime%20%28XP%29.md)):

```jsx
const api_url = XP.getApiUrl();

export const myapp_services = {

    uploadDocument: async function (file) {
        const response = await fetch(api_url + '/myapp/upload_document', {
            method: 'POST',
            body: XP.readyFormData({ document: file }),
            credentials: 'include',
        });
        return await response.json();
    },
};
```

For an input with `multiple`, the field arrives as one entry holding lists. Turn it into separate files with `FileManager::flatten_file_data($files, 'documents')` and upload each one.

<aside>
⚠️ `getFiles()` only works in `POST` requests. In a `GET` request the files were never set, and calling it throws an `Error`.

</aside>

<aside>
⚠️ `filesuploadv2()` checks only the file name's extension, not the content. Local files are served straight from `storage/`, so never allow executable extensions such as `php`, `phtml` or `phar`. Keep the extension list short and lowercase.

</aside>

---

# How to upload an image and create thumbnails

Use `imageUploadv2()` for images. It works like `filesuploadv2()` but also checks that the file really is a JPEG, PNG, GIF or WebP image. Then pass the saved file to `createImageThumbnail()` with the sizes you want.

```php
private function upload_photo()
{
    $res = new Response();
    $files = $this->getRequest()->getFiles();

    if (empty($files['photo'])) {
        echo $res->create(200, 'No image was sent.', false);
        return;
    }

    $dir = FileManager::create_directory('myapp/photos/'); // "/storage/myapp/photos/"

    $upload = FileManager::imageUploadv2(
        $files['photo'],
        array('jpg', 'jpeg', 'png', 'webp'),
        5000000,
        $dir
    );

    if ($upload === false || !$upload['status']) {
        echo $res->create(200, $upload['message'] ?? 'Upload failed.', false);
        return;
    }

    $sizes = array(
        array('name' => 'thumbnail', 'width' => 150, 'height' => 150),
        array('name' => 'medium', 'width' => 500, 'height' => 500),
    );

    // Pass info['path']: an absolute file path in local mode, the object key in S3 mode
    $thumbs = FileManager::createImageThumbnail($upload['info']['path'], $dir, $sizes);

    if ($thumbs === false) {
        echo $res->create(200, 'Could not create thumbnails.', false);
        return;
    }

    // Save json_encode($thumbs['sizes']) with your record, then send URLs to the browser
    $urls = array_map(fn($path) => FileManager::buildUrl($path), $thumbs['sizes']);

    $res->setData($urls);
    echo $res->create(200, 'Photo uploaded.', true);
}
```

For a 1600×1200 JPEG, `$thumbs` is:

```php
array(
    'status' => true,
    'aspect_ratio' => 1.3333333333333,
    'sizes' => array(
        'thumbnail' => '/storage/myapp/photos/66f1c2a9e4b1d-150x112.jpg',
        'medium' => '/storage/myapp/photos/66f1c2a9e4b1d-500x375.jpg',
        'full' => '/storage/myapp/photos/66f1c2a9e4b1d.jpg',
    ),
)
```

- Each size fits inside its box and keeps the aspect ratio, so a 150×150 box gives 150×112 here. Pass `true` as the fourth argument to stretch to the exact box instead.
- Thumbnail files are named `<original>-<width>x<height>.<ext>` and saved in the folder you pass as the second argument.
- `full` is that folder plus the original file name. It points at the original only when you save thumbnails in the folder you uploaded to, as above.

<aside>
⚠️ A size is only made when the original is **wider** than it. Otherwise the entry for that size is the path you passed in. In local mode that's the absolute file path on the server, not a URL. If your originals can be small, check each entry before you send it to the browser.

</aside>

To replace an image later, delete the original and all its thumbnails in one call. They all contain the original's name:

```php
FileManager::deleteImage('/storage/myapp/photos/', '66f1c2a9e4b1d');
```

`deleteImage()` only works in local mode. In S3 mode, delete each entry of `sizes` with `delete_file()`.

---

# How to build a public URL

Store root-relative paths (`/storage/...`) in your tables, and turn them into URLs when you send them to the browser. Then the same rows keep working if you move from local storage to S3.

```php
$url = FileManager::buildUrl('/storage/myapp/photos/66f1c2a9e4b1d.jpg');
// LOCAL: "/storage/myapp/photos/66f1c2a9e4b1d.jpg"
// S3:    "https://<s3_access_domain>/<s3_bucket>/storage/myapp/photos/66f1c2a9e4b1d.jpg"
```

In local mode the path is returned unchanged. The browser loads it from the same host. For a full URL, for example in an email, put the site address in front:

```php
$site = rtrim(system_config::get('system', 'system_site_path'), '/');
$absolute = $site . FileManager::buildUrl($relative);
```

The thumbnail `sizes` are already root-relative in both modes. For an upload result, take the root-relative path like this:

```php
$relative = FileManager::getStorageType() === 'S3'
    ? '/' . $upload['info']['path']  // the object key
    : $upload['info']['url'];        // already "/storage/..."
```

To delete a stored file in either mode, turn the root-relative path into the form `delete_file()` expects with `build_path()`:

```php
FileManager::delete_file(FileManager::build_path($relative));
```

---

# How to switch to S3 storage

S3 mode uses the AWS SDK for PHP (version 3). The framework does not ship it, so add it as an SDK first. Without it, the first request that uses `FileManager` in S3 mode fails with a "Class not found" error.

1. Install the SDK into a folder under `api/sdks/` and give it an `autoloader.php`:

   ```bash
   cd api/sdks
   mkdir AwsSdk && cd AwsSdk
   composer require aws/aws-sdk-php
   printf "<?php\n\nrequire __DIR__ . '/vendor/autoload.php';\n" > autoloader.php
   ```

2. List it in the `<sdks>` section of `api/config.<environment>.xml`, next to PHPMailer:

   ```xml
   <sdks>
     <sdk name="PHPMailer"/>
     <sdk name="AwsSdk"/>
   </sdks>
   ```

   The boot health check stops every request with "SDK Not Found" if a listed SDK has no `autoloader.php`. See [Configuration Files](../Essentials/Configuration%20Files.md).

3. Set the storage type and the bucket. In the admin panel, open **Settings → Storage**, choose **S3** and fill in the fields. Or edit the same keys in `api/config.<environment>.xml`:

   ```xml
   <system>
     <!-- ... -->
     <system_storage_type>S3</system_storage_type>
   </system>
   <storage>
     <aws>
       <s3_bucket>myapp-files</s3_bucket>
       <s3_access_key>AKIA...</s3_access_key>
       <s3_access_secret>...</s3_access_secret>
       <s3_access_domain>https://s3.ap-southeast-1.amazonaws.com</s3_access_domain>
       <s3_region>ap-southeast-1</s3_region>
     </aws>
   </storage>
   ```

| Key | Meaning |
| --- | --- |
| `system_storage_type` | `LOCAL` or `S3`. Any value other than `S3` means local. |
| `s3_bucket` | Bucket name. |
| `s3_access_key`, `s3_access_secret` | Credentials of a user that can read, write and delete objects in the bucket. |
| `s3_access_domain` | The S3 endpoint URL, with no trailing slash. The client uses it with path-style addressing, and `buildUrl()` builds URLs from it. Set it for AWS too. For another provider, such as DigitalOcean Spaces or MinIO, use that provider's endpoint. |
| `s3_region` | The bucket's region. |

Things to know about S3 mode:

- Uploads are written with the `public-read` ACL, so anyone with the URL can read them. The bucket must accept ACLs. New AWS buckets have ACLs turned off by default, and then every upload fails.
- Object keys are the root-relative path without the leading `/`, for example `storage/myapp/photos/a.jpg`.
- The S3 client is created with SSL certificate verification turned off.
- `create_directory()` still makes a local folder, but you only need its return value as the key prefix.

Which methods follow the storage type:

| Works with | Methods |
| --- | --- |
| Both, following `system_storage_type` | `filesuploadv2`, `imageUploadv2`, `createImageThumbnail`, `buildUrl`, `build_path`, `delete_file`, `fileExist`, `deleteFile`, `deleteAllObject` |
| S3 only | `putObject`, `objectExist`, `objectDelete`, `createS3bucket` |
| Local disk only | `create_directory`, `deleteImage`, `deleteAllFiles`, `copyFile`, `base64ImagetoImageFile`, `removeDirectory`, `uploadFileUsingGlobleFile` |
| Local only in practice | `imageResize`, `imageUpload`, `fileUpload` (their S3 branches fail, see each method) |

---

# File Manager methods

## Uploads

### filesuploadv2

Description:

The **`filesuploadv2`** method checks an uploaded file's extension, upload error and size, then saves it under a new name in the given folder, locally or in S3.

Syntax:

```php
$result = FileManager::filesuploadv2($files['document'], array('pdf'), 5000000, '/storage/myapp/documents/');
```

**Parameters:**

- **`$file`**: One file entry from `getFiles()`, with `name`, `tmp_name`, `size` and `error`.
- **`$allowedFileTypes`**: Allowed extensions, in lowercase. The file's extension is lowercased before the check.
- **`$allowedFileSize`**: Size limit in bytes. The file must be smaller than this.
- **`$path`**: Root-relative folder, starting and ending with `/`. Missing folders are created.
- **`$uniqueName`** (optional): File name without extension. Defaults to `uniqid()`. An existing file with the same name is overwritten.

**Return Value:**

- **`Array`**: On success, `status` is `true` and `info` holds `name`, `extension`, `path` and `url`. In local mode `path` is the absolute file path and `url` the root-relative path. In S3 mode `path` is the object key and `url` the full object URL.
- **`Array`**: On a failed check, `status` is `false` and `message` is one of "Invalid file type", "Error uploading file" or "File is too big".
- **`false`**: When an exception is thrown, for example by S3.

<aside>
⚠️ In local mode, `status` is `true` even if moving the file into place failed, for example because the folder isn't writable. If that can happen on your server, check the file exists with `is_file($result['info']['path'])`.

</aside>

---

### imageUploadv2

Description:

The **`imageUploadv2`** method works like `filesuploadv2`, and also checks with `exif_imagetype()` that the file is a JPEG, PNG, GIF or WebP image.

Syntax:

```php
$result = FileManager::imageUploadv2($files['photo'], array('jpg', 'jpeg', 'png'), 5000000, '/storage/myapp/photos/');
```

**Parameters:**

- **`$image`**: One file entry from `getFiles()`.
- **`$allowedFileTypes`**: Allowed extensions, in lowercase.
- **`$allowedFileSize`**: Size limit in bytes.
- **`$path`**: Root-relative folder, starting and ending with `/`.
- **`$uniqueName`** (optional): File name without extension. Defaults to `uniqid()`.

**Return Value:**

- **`Array`**: The same shape as `filesuploadv2`. The extra failure message is "Corrupted image file or image format not supported".
- **`false`**: When an exception is thrown.

The same caveat about a failed move in local mode applies.

---

### flatten_file_data

Description:

The **`flatten_file_data`** method turns a multi-file field (`<input type="file" multiple>`, sent as `name[]`) into a list of single-file entries you can pass to the upload methods.

Syntax:

```php
$documents = FileManager::flatten_file_data($this->getRequest()->getFiles(), 'documents');
foreach ($documents as $document) {
    FileManager::filesuploadv2($document, array('pdf'), 5000000, $dir);
}
```

**Parameters:**

- **`$data`**: The whole array from `getFiles()`.
- **`$field_name`**: The field name.

**Return Value:**

- **`Array`**: A list of entries with `name`, `full_path`, `type`, `tmp_name`, `error` and `size`.

---

### base64ImagetoImageFile

Description:

The **`base64ImagetoImageFile`** method decodes an image data URL, such as `data:image/png;base64,iVBOR...`, and writes it to a file. Local disk only.

Syntax:

```php
$dir = FileManager::create_directory('myapp/signatures/');
$ok = FileManager::base64ImagetoImageFile($dataUrl, RDIR . $dir, 'signature-42.png');
```

**Parameters:**

- **`$base64String`**: A data URL. It must start with `data:image/`.
- **`$path`**: Absolute path of an existing folder, ending with `/`.
- **`$uniqueName`** (optional): The full file name, including the extension. Only letters, digits, `_`, `.` and `-` are allowed.

**Return Value:**

- **`Boolean`**: `true` if the file was written, `false` otherwise. The file name is not returned.

<aside>
⚠️ Always pass `$uniqueName`. Without it the file is named `uniqid()` + "FileManager" + the image type, with no dot, for example `66f1c2a9e4b1dFileManagerpng`.

</aside>

---

### imageUpload

Description:

**Deprecated.** The **`imageUpload`** method writes a base64 JPEG to `$path . $fileName` and checks the result is an image. Use `imageUploadv2` for uploads, or `base64ImagetoImageFile` for base64 data.

Syntax:

```php
$saved = FileManager::imageUpload($path, $fileName, $imageString);
```

**Parameters:**

- **`$path`**: Folder path. Locally it's used as given, so it's relative to the working directory unless absolute.
- **`$fileName`**: File name with extension.
- **`$imageString`**: Base64 data. Only a `data:image/jpg;base64,` prefix is stripped.

**Return Value:**

- **`String`**: The saved path.
- **`false`**: If writing failed or the result is not an image. `null` on an exception.

Its S3 branch writes through an `s3://` stream wrapper that the module never registers, so it fails in S3 mode.

---

### fileUpload

Description:

**Deprecated.** The **`fileUpload`** method writes base64 data of any type to `$path . $fileName`. Use `filesuploadv2` instead.

Syntax:

```php
$saved = FileManager::fileUpload($path, $fileName, $base64String, 'data:application/pdf;base64');
```

**Parameters:**

- **`$path`**: Folder path, used as given.
- **`$fileName`**: File name with extension.
- **`$base64String`**: The base64 data, optionally with a data-URL prefix.
- **`$replaceData`**: The prefix to strip, without the trailing comma.
- **`$fileType`** (optional): Not used.

**Return Value:**

- **`String`**: The saved path.
- **`false`**: If writing failed.

Like `imageUpload`, it fails in S3 mode.

---

### uploadFileUsingGlobleFile

Description:

The **`uploadFileUsingGlobleFile`** method moves the file sent in the form field named `image` (read from `$_FILES['image']`) into a folder. It's an old helper. Prefer `filesuploadv2`.

Syntax:

```php
$saved = FileManager::uploadFileUsingGlobleFile('avatar-42', RDIR . '/storage/myapp/avatars');
```

**Parameters:**

- **`$fileName`**: New file name **without** extension. The original extension is kept.
- **`$uploadDir`**: Absolute folder path, without a trailing `/`.

**Return Value:**

- **`String`**: The saved path.
- **`false`**: If the move failed.

---

## Images

### createImageThumbnail

Description:

The **`createImageThumbnail`** method makes resized copies of an image, one for each entry in `$image_sizes_ary`, and saves them locally or in S3. JPEG, PNG, GIF and WebP are supported.

Syntax:

```php
$sizes = array(
    array('name' => 'thumbnail', 'width' => 150, 'height' => 150),
    array('name' => 'medium', 'width' => 500, 'height' => 500),
    array('name' => 'large', 'width' => 1024, 'height' => 1024),
);
$result = FileManager::createImageThumbnail($upload['info']['path'], '/storage/myapp/photos/', $sizes);
```

**Parameters:**

- **`$imagePath`**: The source image. In local mode, its absolute file path. In S3 mode, its object key. `info['path']` from an upload is the right value in both modes.
- **`$savePath`**: Root-relative folder for the thumbnails, starting and ending with `/`.
- **`$image_sizes_ary`**: A list of sizes, each with `name`, `width` and `height`.
- **`$ignore_aspect_ratio`** (optional): `false` (default) fits each size inside its box and keeps the aspect ratio. `true` stretches to the exact width and height.

**Return Value:**

- **`Array`**: `status` (`true`), `aspect_ratio` (width divided by height) and `sizes`, which maps each size name, plus `full`, to a root-relative path. A size is only created when the original is wider than it. Otherwise its entry is `$imagePath`.
- **`false`**: If the source is missing, is not a supported image, or a file could not be written.

---

### imageResize

Description:

The **`imageResize`** method saves one resized copy of an image, fitted inside the given width and height with the aspect ratio kept. JPEG, PNG, GIF and WebP are supported. For several sizes, use `createImageThumbnail`.

Syntax:

```php
// For a 1600×1200 original
$path = FileManager::imageResize(
    RDIR . '/storage/myapp/photos/66f1c2a9e4b1d.jpg',
    '/storage/myapp/photos/resized/',
    'unused',
    array('width' => 800, 'height' => 800)
);
// "/storage/myapp/photos/resized/66f1c2a9e4b1d-800x600.jpg"
```

**Parameters:**

- **`$imagePath`**: Absolute file path of the source image.
- **`$savePath`**: Root-relative folder for the copy.
- **`$fileName`**: Not used. The copy is always named `<original>-<width>x<height>.<ext>`.
- **`$widthAndHeight`**: An array with `width` and `height`.

**Return Value:**

- **`String`**: Root-relative path of the resized copy.
- **`false`**: If the source is missing or not a supported image.

<aside>
⚠️ Use `imageResize` in local mode only. In S3 mode it reads the image size from a local path that doesn't exist, and the request ends with a division-by-zero error. Use `createImageThumbnail` with one size instead.

</aside>

---

## Paths and URLs

### create_directory

Description:

The **`create_directory`** method creates a folder under the site's `storage/` folder, if it doesn't exist yet, and returns its root-relative path. Use the result as the `$path` of the upload methods.

Syntax:

```php
$dir = FileManager::create_directory('myapp/photos/'); // "/storage/myapp/photos/"
```

**Parameters:**

- **`$file_path`**: Folder path inside `storage/`. End it with `/` so the result can be used as an upload folder.

**Return Value:**

- **`String`**: `/storage/` followed by `$file_path`. It is returned even if the folder could not be created.

---

### build_path

Description:

The **`build_path`** method turns a root-relative path into the form the delete and exist methods need: an absolute file path in local mode, or the unchanged path in S3 mode.

Syntax:

```php
$target = FileManager::build_path('/storage/myapp/photos/a.jpg');
FileManager::delete_file($target);
```

**Parameters:**

- **`$path`**: A root-relative path.

**Return Value:**

- **`String`**: The document root plus `/` plus `$path` in local mode. `$path` unchanged in S3 mode.

---

### buildUrl

Description:

The **`buildUrl`** method turns a root-relative path into the URL the browser should load.

Syntax:

```php
$url = FileManager::buildUrl('/storage/myapp/photos/a.jpg');
```

**Parameters:**

- **`$relativePath`**: A root-relative path, starting with `/`.

**Return Value:**

- **`String`**: In local mode, `$relativePath` unchanged. In S3 mode, `s3_access_domain` + `/` + `s3_bucket` + `$relativePath`. If `s3_access_domain` is empty, the result is not a usable URL.

---

### remove_http

Description:

The **`remove_http`** method removes the scheme from a URL that starts with `http:` or `https:`, which leaves a protocol-relative URL.

Syntax:

```php
$url = FileManager::remove_http('https://cdn.example.com/a.jpg'); // "//cdn.example.com/a.jpg"
```

**Parameters:**

- **`$url`**: The URL.

**Return Value:**

- **`String`**: The URL without its scheme. The `//` stays. A URL that doesn't start with `http:` or `https:` is returned unchanged. The method never returns `false`.

Every occurrence of the matched scheme is removed, including any inside a query string.

---

## File names

### sanitize_file_name

Description:

The **`sanitize_file_name`** method makes a file name safe to store: spaces and every character other than letters, digits, `_`, `-` and `.` become `_`.

Syntax:

```php
$name = FileManager::sanitize_file_name('My Report (final).pdf'); // "My_Report__final_.pdf"
```

**Parameters:**

- **`$file_name`**: The file name.

**Return Value:**

- **`String`**: The cleaned name.

---

### add_timestamp_to_file_name

Description:

The **`add_timestamp_to_file_name`** method adds `_t` and the current date, time and microseconds (for example `20261005_103000_123456`) to a file name, so repeated uploads of the same name don't collide.

Syntax:

```php
$name = FileManager::add_timestamp_to_file_name('avatar');     // "avatar_t20261005_103000_123456"
$name = FileManager::add_timestamp_to_file_name('login_logo'); // "login_t20261005_103000_123456_logo"
```

**Parameters:**

- **`$file_name`**: The name **without** extension. Dots are turned into `_`.

**Return Value:**

- **`String`**: The new name. If the name contains `_`, the timestamp goes before the last `_` part, as in the second example.

---

### get_file_name_from_file

Description:

The **`get_file_name_from_file`** method returns a file's name without folder or extension, in lowercase.

Syntax:

```php
$name = FileManager::get_file_name_from_file('/storage/myapp/Photo.JPG'); // "photo"
```

**Parameters:**

- **`$file_name`**: A file name or path.

**Return Value:**

- **`String`**: The lowercase base name.

---

### get_file_type

Description:

The **`get_file_type`** method returns the main part of a MIME type, for example to tell images from documents.

Syntax:

```php
$kind = FileManager::get_file_type($files['upload']['type']); // "image" for "image/png"
```

**Parameters:**

- **`$type`**: A MIME type.

**Return Value:**

- **`String`**: The part before `/`.

---

## Checking, copying and deleting

### delete_file

Description:

The **`delete_file`** method deletes one file, locally or from S3. Pass it the result of `build_path()`.

Syntax:

```php
$deleted = FileManager::delete_file(FileManager::build_path('/storage/myapp/photos/a.jpg'));
```

**Parameters:**

- **`$file_path`**: In local mode, an absolute file path. In S3 mode, the object key. A leading `/` is removed.

**Return Value:**

- **`Boolean`**: `true` if the file was deleted, or if a local file did not exist. `false` if deletion failed.

---

### deleteImage

Description:

The **`deleteImage`** method deletes every file in a folder whose name contains `$fileName`. Use it to delete an image together with its thumbnails. Local disk only.

Syntax:

```php
$deleted = FileManager::deleteImage('/storage/myapp/photos/', '66f1c2a9e4b1d');
```

**Parameters:**

- **`$path`**: Root-relative folder, ending with `/`.
- **`$fileName`**: Text to match anywhere in the file name. A short value matches unrelated files too.

**Return Value:**

- **`Boolean`**: `true` if every matching file was deleted (also when nothing matched), `false` otherwise.

---

### deleteAllFiles

Description:

The **`deleteAllFiles`** method deletes every file in a folder. Sub-folders and their contents are kept. Local disk only.

Syntax:

```php
$deleted = FileManager::deleteAllFiles('/storage/myapp/tmp/');
```

**Parameters:**

- **`$path`**: Root-relative folder. End it with `/`: the method matches `$path*`, so without the `/` it also deletes files in the parent folder whose names start with the folder name.

**Return Value:**

- **`Boolean`**: `true` if every file was deleted, `false` otherwise.

---

### removeDirectory

Description:

The **`removeDirectory`** method deletes a folder with all its files and sub-folders. Local disk only.

Syntax:

```php
$removed = FileManager::removeDirectory(RDIR . '/storage/myapp/tmp');
```

**Parameters:**

- **`$directory`**: Absolute folder path.

**Return Value:**

- **`Boolean`**: `true` if the folder was removed. `false` if it doesn't exist or something could not be deleted.

---

### copyFile

Description:

The **`copyFile`** method copies a file with PHP's `copy()`. Local disk only.

Syntax:

```php
$copied = FileManager::copyFile(RDIR . '/storage/myapp/a.pdf', RDIR . '/storage/myapp/archive/a.pdf');
```

**Parameters:**

- **`$source`**: Absolute path of the file to copy.
- **`$destination`**: Absolute path of the new file. Its folder must exist.

**Return Value:**

- **`Boolean`**: `true` on success, `false` otherwise.

---

### fileExist

Description:

The **`fileExist`** method checks whether a file exists, locally or in S3.

Syntax:

```php
$exists = FileManager::fileExist(FileManager::build_path('/storage/myapp/photos/a.jpg'));
```

**Parameters:**

- **`$path`**: In local mode, an absolute file path. A relative path is resolved against the `api/` folder, not the site root. In S3 mode, a path-style object URL that contains the bucket name as one segment, such as the result of `buildUrl()`. For an object key, use `objectExist` instead.

**Return Value:**

- **`Boolean`**: `true` if the file exists.

---

### deleteFile

Description:

The **`deleteFile`** method is the older form of `delete_file`. Prefer `delete_file`.

Syntax:

```php
$deleted = FileManager::deleteFile($path);
```

**Parameters:**

- **`$path`**: In local mode, an absolute file path. In S3 mode, a path-style object URL that contains the bucket name as one segment.

**Return Value:**

- **`Boolean`**: `true` if the file is gone, `false` otherwise.

---

### deleteAllObject

Description:

The **`deleteAllObject`** method deletes everything under a prefix. In S3 mode it deletes every object whose key starts with `$path`. In local mode it deletes the files (not folders) in the folder `$path`.

Syntax:

```php
$deleted = FileManager::deleteAllObject('storage/myapp/tmp/');
```

**Parameters:**

- **`$path`**: In S3 mode, a key prefix. In local mode, an absolute folder path without a trailing `/`.

**Return Value:**

- **`Boolean`**: In S3 mode, `true` if every object was deleted, `false` if there was nothing to delete or an error occurred. In local mode it returns nothing (`null`).

---

## S3

### Initialize

Description:

The **`Initialize`** method reads `system_storage_type` and, in S3 mode, the `storage` settings, and creates the S3 client. The module calls it when it loads, so you don't need to.

Syntax:

```php
FileManager::Initialize();
```

**Parameters:**

- None.

**Return Value:**

- None.

---

### putObject

Description:

The **`putObject`** method uploads a local file to the bucket with the `public-read` ACL. S3 mode only.

Syntax:

```php
$url = FileManager::putObject('storage/myapp/exports/report.csv', '/tmp/report.csv');
```

**Parameters:**

- **`$path`**: The object key.
- **`$sourceFile`**: Absolute path of the local file.

**Return Value:**

- **`String`**: The object URL.
- **`false`**: In local mode, or on an error. On an error the exception message is also printed into the response, which breaks a JSON response.

---

### objectExist

Description:

The **`objectExist`** method checks whether an object key exists in the bucket. S3 mode only.

Syntax:

```php
$exists = FileManager::objectExist('storage/myapp/photos/a.jpg');
```

**Parameters:**

- **`$pathFromBucketWithOutBucket`**: The object key, without the bucket name.

**Return Value:**

- **`Boolean`**: `true` if the object exists. `null` in local mode.

---

### objectDelete

Description:

The **`objectDelete`** method deletes one object from the bucket. S3 mode only.

Syntax:

```php
$deleted = FileManager::objectDelete('storage/myapp/photos/a.jpg');
```

**Parameters:**

- **`$pathFromBucketWithOutBucket`**: The object key, without the bucket name.

**Return Value:**

- **`Boolean`**: `true` if the object no longer exists. `null` in local mode.

---

### createS3bucket

Description:

The **`createS3bucket`** method creates a bucket with the configured credentials. S3 mode only.

Syntax:

```php
$created = FileManager::createS3bucket('myapp-files');
```

**Parameters:**

- **`$bucketName`**: The new bucket's name.

**Return Value:**

- **`Boolean`**: `true` if S3 answered with status 200, `false` otherwise.

---

### Storage settings accessors

Description:

Getters and setters for the values `Initialize` loads. Setting a value changes it for the rest of the request only.

Syntax:

```php
$type = FileManager::getStorageType();     // "LOCAL" or "S3"
$bucket = FileManager::getS3Bucket();
$domain = FileManager::getS3AccessDomain();
$client = FileManager::getS3client();      // Aws\S3\S3Client, or null in local mode
```

**Parameters:**

- `setStorageType($storage_type)`, `setS3Bucket($s3_bucket)`, `setS3AccessDomain($s3_access_domain)`, `setS3AccessKey($s3_access_key)` and `setS3AccessSecret($s3_access_secret)` take the new value.

**Return Value:**

- The getters return the stored value. `getS3AccessKey()` and `getS3AccessSecret()` return `null` unless you set them yourself, because `Initialize` passes the credentials straight to the client.

---

### putFileToBucket / putFileToLocal

Description:

The **`putFileToBucket`** and **`putFileToLocal`** methods do the storing for `filesuploadv2` and `imageUploadv2`, without any checks. Call the upload methods instead.

Syntax:

```php
$result = FileManager::putFileToLocal($path, $fileNameNew, $fileTmpName, $uniqueid, array(), $extension);
```

**Parameters:**

- **`$path`**, **`$fileNameNew`**, **`$fileTmpName`**, **`$uniqueid`**, **`$result`**, **`$fileActualExt`**: The folder, new file name, temporary upload path, name without extension, result array to fill, and extension.

**Return Value:**

- **`Array`**: `$result` with the `info` entry added.

---

<aside>
💡 If the `docloudSaasClient` app is installed and activated, the upload and thumbnail methods put `/space_storage/<space>` in front of the folder you pass, so each space's files stay apart.

</aside>
