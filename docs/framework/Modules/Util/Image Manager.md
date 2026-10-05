---
title: Image Manager
sidebar_label: Image Manager
---

# Image Manager

# Introduction

`ImageManager` is a small Util class for images held in memory as **base64 text**, for example a picture drawn on a canvas, taken with the camera in the browser, or sent in a JSON body. It can tell you an image's type and width, and resize it. It does not read or save files.

Get an instance with `Util::ImageManager()`:

```php
$images = Util::ImageManager();
$type = $images->imageInfo($base64); // "png"
```

All methods take the raw base64 data, **without** the `data:image/png;base64,` prefix that a browser data URL starts with. Remove the prefix first. With it, the data does not decode to an image and the methods return `false`.

The methods use the PHP `gd` extension.

## Image Manager or File Manager?

[File Manager](../File%20Manager.md) also handles images. The two don't overlap much:

| | Image Manager | File Manager |
| --- | --- | --- |
| Input | Base64 text in memory | An uploaded file, or a file on disk or in S3 |
| Resizing | `reSize()`: to one width, height follows | `createImageThumbnail()`: several sizes at once, each fitted inside a width and height |
| Output format | Always JPEG | Same format as the original |
| Saves files | No | Yes, locally or in S3 |

Use File Manager for images uploaded from a form: `imageUploadv2()` then `createImageThumbnail()`. Use Image Manager only when the image reaches your controller as base64 text and you want to check or shrink it before you save it.

---

# How to check and shrink a base64 image before saving it

A signature pad or camera component usually gives you a data URL. Strip the prefix, check the type, shrink the image if it's too wide, then save it with File Manager's `base64ImagetoImageFile()`.

```php
private function save_photo()
{
    $res = new Response();
    $data = $this->getRequest()->getData();

    // "data:image/png;base64,iVBORw0KGgo..."
    $dataUrl = $data['photo'] ?? '';
    $comma = strpos($dataUrl, ',');
    $base64 = $comma === false ? $dataUrl : substr($dataUrl, $comma + 1);

    $images = Util::ImageManager();

    $type = $images->imageInfo($base64);
    if (!in_array($type, array('jpeg', 'png', 'webp'), true)) {
        echo $res->create(200, 'Send a JPEG, PNG or WebP image.', false);
        return;
    }

    if ($images->checkImageSize($base64) > 1200) {
        $base64 = $images->reSize(1200, $base64);
        $type = 'jpeg'; // reSize() always returns a JPEG
    }

    if ($base64 === false) {
        echo $res->create(200, 'Could not read the image.', false);
        return;
    }

    $dir = FileManager::create_directory('myapp/photos/'); // "/storage/myapp/photos/"
    $name = uniqid() . '.' . ($type === 'jpeg' ? 'jpg' : $type);

    $saved = FileManager::base64ImagetoImageFile(
        'data:image/' . $type . ';base64,' . $base64,
        RDIR . $dir,
        $name
    );

    if (!$saved) {
        echo $res->create(200, 'Could not save the image.', false);
        return;
    }

    $res->setData(array('url' => FileManager::buildUrl($dir . $name)));
    echo $res->create(200, 'Photo saved.', true);
}
```

`base64ImagetoImageFile()` writes to the local disk only. With S3 storage, write `base64_decode($base64)` to a temporary file and upload it with `FileManager::putObject()`. See [File Manager](../File%20Manager.md).

<aside>
⚠️ `reSize()` always produces a JPEG. Transparent parts of a PNG, WebP or GIF turn black, and an animated GIF keeps only its first frame. Resize only images that can lose transparency, such as photos.

</aside>

---

# How to make a fixed-width copy

`reSize()` scales an image to the width you give and works out the height from the aspect ratio. It also enlarges images narrower than that width, so check the width first if you only want to shrink:

```php
$images = Util::ImageManager();

$width = $images->checkImageSize($base64);
$preview = ($width !== false && $width > 300)
    ? $images->reSize(300, $base64)
    : $base64;
```

---

# Image Manager methods

### imageInfo

Description:

The **`imageInfo`** method returns the type of a base64 image, taken from its content rather than from any name or prefix.

Syntax:

```php
$images = Util::ImageManager();
$type = $images->imageInfo($base64);
```

**Parameters:**

- **`$imageString`**: Raw base64 image data, without a `data:` prefix.

**Return Value:**

- **`String`**: The part of the MIME type after `/`, in lowercase: `jpeg`, `png`, `gif`, `webp` and so on. It is not the full MIME type.
- **`false`**: If the string is empty or is not an image.

---

### checkImageSize

Description:

The **`checkImageSize`** method returns the width of a base64 image in pixels. Despite its name, it does not check against a limit and it does not return the height.

Syntax:

```php
$images = Util::ImageManager();
$width = $images->checkImageSize($base64);
```

**Parameters:**

- **`$imageString`**: Raw base64 image data, without a `data:` prefix.

**Return Value:**

- **`Integer`**: The width in pixels.
- **`false`**: If the string is empty or is not an image.

---

### reSize

Description:

The **`reSize`** method scales a base64 image to the given width, keeps the aspect ratio, and returns the result as a base64 JPEG at quality 100. It enlarges images narrower than `$width`.

Syntax:

```php
$images = Util::ImageManager();
$resized = $images->reSize(500, $base64);
```

**Parameters:**

- **`$width`**: The new width in pixels. Must be a number greater than 0.
- **`$imageString`**: Raw base64 image data, without a `data:` prefix.

**Return Value:**

- **`String`**: The resized image as raw base64 JPEG data, without a `data:` prefix.
- **`false`**: If `$width` is not a positive number, the string is empty, or it is not an image. Invalid image data also logs a PHP warning.

---

### setImageString / getImageString

Description:

The **`setImageString`** and **`getImageString`** methods store and read a base64 string on the instance. The other methods don't use the stored value, so you must still pass the string to them.

Syntax:

```php
$images = Util::ImageManager();
$images->setImageString($base64);
$width = $images->checkImageSize($images->getImageString());
```

**Parameters:**

- **`$imageString`** (`setImageString` only): The string to store.

**Return Value:**

- **`String`**: `getImageString` returns the stored string, or `null` if none was set. `setImageString` returns nothing.

---
