---
title: Media
sidebar_label: Media
---

# Media

# Introduction

These components handle images: choosing them on the user's device, and showing the ones your app has already saved. None of them uploads anything. The two uploaders hand your page the chosen files as browser `File` objects. Your page puts them in `FormData` and posts them to its own controller, which saves them with [File Manager](../Modules/File%20Manager.md). The framework has no upload endpoint for these components.

| Component | Use it for |
| --- | --- |
| `DcImageUploader` | A drop area for choosing several images, with previews, sent later with a form |
| `DcImageUploaderMini` | A small "Add media" tile, for images you upload as soon as they're chosen |
| `DcMediaViewer` | Thumbnails of saved images that open full screen, with remove and featured buttons |

The framework's [Image Manager](../Modules/Util/Image%20Manager.md) isn't part of this. It works on images held as base64 text, while the uploaders give you files, which your controller saves with File Manager's `imageUploadv2()`. [Image Manager or File Manager?](../Modules/Util/Image%20Manager.md#image-manager-or-file-manager) explains when to use each.

Every example imports from the kit's registry. The path below is from a component in `apps/myapp/components/`:

```jsx
import { DcImageUploader } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Register each imported component in the `components` option before you use its tag. See [Vue DC UI KIT](./Vue%20DC%20UI%20KIT.md) for the setup.

---

## DcImageUploader

A drop area for choosing images. The user drags files onto it or clicks it to browse. Each file then shows as a card with a preview and a remove button, and an **Add media** card lets the user add more. The chosen files reach your page through `v-model`, as an array of `File` objects.

```jsx
import { DcImageUploader } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcImageUploader },
    data() {
        return { photos: [] };
    },
    template: `
    <dc-image-uploader id="myapp-photos" v-model="photos" :file_limit="5" />
    <p class="dcui-text-light">{{ photos.length }} of 5 photos chosen.</p>
    `,
};
```

How it behaves:

- **`v-model` only goes out.** The uploader sends its list each time it changes, but never reads the value you pass in. You can't preload files, and setting your variable to `[]` doesn't empty the uploader. To empty it, call `clear_attachments()` through a `ref` and set your variable to `[]` as well. To show images that are already saved, use [DcMediaViewer](#dcmediaviewer).
- **Duplicates and the limit.** A file with the same name, size and last-modified time as one already in the list is skipped. With `file_limit`, files past the limit are skipped without a message, and the Add media card goes away once the limit is reached. Tell users the limit next to the uploader.
- **Previews.** Each card shows the image and a short form of its name (the first three letters and the extension). The full name shows on hover. Previews are drawn as images, so other file types get a broken preview.
- **Selecting a card.** Clicking a card selects it and emits `selected` with the file and its index. Clicking it again unselects it and emits `selected` with `null, null`. Use it to let the user pick one of the new files, such as a cover photo. The selected card gets the class `selected`, which the framework's stylesheets don't style, so add a rule for it to your app's stylesheet.
- **Removing a card** emits `update:modelValue` with the shorter list. If the removed card came before the selected one, `selected` fires with `null` and the selected card's new index. If it was the selected card, `selected` fires with `null, null`. In every case the second argument is the selected card's index, so keep that.
- **`id`.** Give each uploader on a screen its own `id`. Its label opens the file input with that id, so two uploaders that both use the default `fileInput` open the same input. The same goes for [DcImageUploaderMini](#dcimageuploadermini).

<aside>
⚠️ `accept` only filters the browse dialog. Files dragged onto the uploader are added whatever their type, so a dropped PDF gets a broken preview and is in your array. Check each file's `type` before you send them, and let your controller reject anything else (`imageUploadv2()` does).

</aside>

### Sending the files to your backend

This screen adds photos to a listing. The user chooses up to 10 images, may click one to make it the cover, and presses **Upload photos**. The page sends every file in one `FormData` under the field name `photos[]`. `myapp_services` stands for your app's `services.js` (see [Frontend Runtime (XP)](../Frontend%20Runtime%20%28XP%29.md)).

```jsx
import { DcImageUploader, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcImageUploader, DcButton },
    props: ["listing_id"],
    data() {
        return { photos: [], cover_index: null, saving: false, error: "" };
    },
    methods: {
        on_selected(file, index) {
            // index is the selected card's position, or null when none is selected.
            this.cover_index = index;
        },
        async upload() {
            if (this.photos.some((file) => !file.type.startsWith("image/"))) {
                this.error = "Only images can be uploaded. Remove the other files.";
                return;
            }
            this.saving = true;
            this.error = "";
            try {
                const form = new FormData();
                form.append("listing_id", this.listing_id);
                this.photos.forEach((file) => form.append("photos[]", file));
                if (this.cover_index !== null) {
                    form.append("cover_index", this.cover_index);
                }
                const res = await myapp_services.add_listing_photos(form);
                if (res.response.success) {
                    // Empty the uploader, and your own copy of its list.
                    this.$refs.uploader.clear_attachments();
                    this.photos = [];
                    this.cover_index = null;
                }
                if (!res.response.success || res.data.failed.length) {
                    this.error = res.response.statusMsg;
                }
            } catch (e) {
                this.error = "Couldn't upload the photos. Try again.";
            } finally {
                this.saving = false;
            }
        },
    },
    template: `
    <dc-image-uploader ref="uploader" id="myapp-listing-photos" v-model="photos"
        :file_limit="10" @selected="on_selected" />
    <p class="dcui-text-light dcui-m-t-10">Up to 10 JPEG, PNG or GIF images. Click a photo to make it the cover.</p>
    <p v-if="error" class="dcui-text-danger">{{ error }}</p>
    <dc-button :disabled="!photos.length || saving" @click="upload">Upload photos</dc-button>
    `,
};
```

In `services.js`, post the `FormData` as it is. Don't use `XP.readyFormData()` here: it sends each value as one field, and turns an array of files into text.

```jsx
const api_url = XP.getApiUrl();

export const myapp_services = {

    add_listing_photos: async function (form) {
        const response = await fetch(api_url + '/myapp/add_listing_photos', {
            method: 'POST',
            body: form,
            credentials: 'include',
        });
        return await response.json();
    },
};
```

The controller receives `photos[]` as one entry holding lists. [`flatten_file_data()`](../Modules/File%20Manager.md#flatten_file_data) splits it into single files, and [`imageUploadv2()`](../Modules/File%20Manager.md#imageuploadv2) checks and saves each one:

```php
private function add_listing_photos()
{
    $res = new Response();
    $data = $this->getRequest()->getData();
    $files = $this->getRequest()->getFiles();

    if (empty($files['photos'])) {
        echo $res->create(200, 'No photos were sent.', false);
        return;
    }

    $dir = FileManager::create_directory('myapp/listings/'); // "/storage/myapp/listings/"
    $saved = 0;
    $failed = array();

    foreach (FileManager::flatten_file_data($files, 'photos') as $photo) {
        // Clean the user's file name before you store or show it.
        $name = FileManager::sanitize_file_name($photo['name']);

        $upload = FileManager::imageUploadv2($photo, array('jpg', 'jpeg', 'png', 'gif'), 5000000, $dir);

        if ($upload === false || !$upload['status']) {
            $failed[] = $name;
            continue;
        }

        $relative = FileManager::getStorageType() === 'S3'
            ? '/' . $upload['info']['path']  // the object key
            : $upload['info']['url'];        // already "/storage/..."

        // Store $relative and $name with $data['listing_id'] in your own table.
        // $data['cover_index'], when sent, is the position of the cover in photos[].
        $saved++;
    }

    $res->setData(array('saved' => $saved, 'failed' => $failed));

    if ($failed) {
        echo $res->create(200, 'These photos could not be saved: ' . implode(', ', $failed), $saved > 0);
        return;
    }

    echo $res->create(200, 'Photos saved.', true);
}
```

To make smaller copies for thumbnails, pass each saved file to `createImageThumbnail()`. See [File Manager](../Modules/File%20Manager.md).

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Array | none | Bind it with `v-model` to receive the chosen files. The uploader doesn't read it. |
| `accept` | String | `"image/png, image/gif, image/jpeg"` | The file types the browse dialog offers. Dropped files aren't checked. |
| `file_limit` | Number | `0` | The most files the list can hold. `0` means no limit. |
| `id` | String | `"fileInput"` | The id of the file input. Give each uploader on a screen its own. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | Array of `File` | Files were added or removed. Handled by `v-model`. |
| `selected` | `file`, `index` | A card was selected or unselected, or removing a card moved the selection. `file` is `null` unless a card was just selected. `index` is the selected card's index, or `null`. |

**Methods**

| Name | Description |
| --- | --- |
| `clear_attachments()` | Empties the list and the selection. It doesn't emit `update:modelValue`, so set your `v-model` variable to `[]` yourself. |

The admin panel's copy has no `id` prop. Its file input's id is always `fileInput`, so use one uploader per screen there.

---

## DcImageUploaderMini

A small **Add media** tile. Clicking it opens the browse dialog, and files can also be dropped on it. It suits uploading straight away: the user picks images, your page uploads them, and the saved images appear in a [DcMediaViewer](#dcmediaviewer). With `hidePreview` it shows only the tile. Without it, chosen files also show as cards beside the tile, as in [DcImageUploader](#dcimageuploader).

This tile uploads the files as soon as they're chosen. It listens to `update:modelValue` directly, because the files are needed once, not kept:

```jsx
import { DcImageUploaderMini } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcImageUploaderMini },
    props: ["listing_id"],
    emits: ["uploaded"],
    data() {
        return { uploads: 0, error: "" };
    },
    methods: {
        async upload(files) {
            // Take the files and empty the tile, so the next pick holds only new files.
            const picked = Array.from(files);
            this.$refs.picker.clear_attachments();
            if (!picked.length) return;

            this.uploads++;
            this.error = "";
            try {
                const form = new FormData();
                form.append("listing_id", this.listing_id);
                picked.forEach((file) => form.append("photos[]", file));
                const res = await myapp_services.add_listing_photos(form);
                if (!res.response.success || res.data.failed.length) {
                    this.error = res.response.statusMsg;
                }
                this.$emit("uploaded");
            } catch (e) {
                this.error = "Couldn't upload the photos. Try again.";
            } finally {
                this.uploads--;
            }
        },
    },
    template: `
    <dc-image-uploader-mini ref="picker" id="myapp-add-photos" placeholder="Add photos"
        :hide-preview="true" :loading="uploads > 0" @update:modelValue="upload" />
    <p v-if="error" class="dcui-text-danger">{{ error }}</p>
    `,
};
```

`add_listing_photos` is the service and controller shown under [DcImageUploader](#dcimageuploader). The parent reloads its photo list on `uploaded`.

How it differs from `DcImageUploader`:

- It has no `file_limit`.
- `loading` shows a spinner on the tile. `disable` greys out the tile's label and disables its file input.
- `capture` asks a phone's browser to open the camera instead of the file browser. `icon` changes the tile's Font Awesome icon.
- Removing a card doesn't emit `update:modelValue`. The array you received is the tile's own array, so the file is gone from it as well, but a watcher on your variable only notices with `deep: true`.

Everything else works as in `DcImageUploader`: `v-model` only goes out, duplicates are skipped, `accept` only filters the browse dialog, each tile on a screen needs its own `id`, and clicking a card emits `selected`.

<aside>
⚠️ `disable` doesn't stop drops. Files dropped on a disabled tile are still added, and `update:modelValue` fires. If the user may not add images at all, leave the tile out with `v-if` instead of disabling it.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Array | none | Bind it with `v-model` to receive the chosen files. The tile doesn't read it. |
| `accept` | String | `"image/png, image/gif, image/jpeg"` | The file types the browse dialog offers. Dropped files aren't checked. |
| `hidePreview` | Boolean | `false` | Shows only the tile, without a card per chosen file. |
| `loading` | Boolean | `false` | Shows a spinner on the tile. |
| `disable` | Boolean | `false` | Greys out the tile's label and disables the browse dialog. Drops still work. |
| `placeholder` | String | `"Add media"` | The tile's label. |
| `id` | String | `"fileInput"` | The id of the file input. Give each tile on a screen its own. |
| `capture` | Boolean | `false` | Asks a phone's browser to open the camera. |
| `icon` | String | `"fa-solid fa-upload"` | Font Awesome classes for the tile's icon. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | Array of `File` | Files were added. Handled by `v-model`. Not emitted when a card is removed. |
| `selected` | `file`, `index` | As in `DcImageUploader`. Only possible while cards are shown. |

**Methods**

| Name | Description |
| --- | --- |
| `clear_attachments()` | Empties the list and the selection. It doesn't emit `update:modelValue`. |

The admin panel's copy has no `capture` or `icon` props, and dropping files on it adds nothing (it fails with a script error). Users have to click the tile to browse.

---

## DcMediaViewer

A grid of thumbnails for images your app has already saved. Clicking a thumbnail opens the image full screen in Fancybox, which the framework loads on every page. The full-screen viewer has zoom, rotate, flip and full-screen buttons, and arrows to the other images in the same group. Optional buttons let the user remove an image or mark one as featured. The viewer only raises events: your app saves the change and updates `attachments`.

```jsx
import { DcMediaViewer } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcMediaViewer },
    data() {
        return {
            photos: [
                { id: 1, path: "/storage/myapp/listings/66f1c2a9e4b1d.jpg", thumbnails: "/storage/myapp/listings/66f1c2a9e4b1d-300x225.jpg", original_file_name: "front.jpg" },
                { id: 2, path: "/storage/myapp/listings/66f1c2b04f2a7.jpg", thumbnails: "/storage/myapp/listings/66f1c2b04f2a7-300x225.jpg", original_file_name: "garden.jpg" },
            ],
        };
    },
    template: `
    <dc-media-viewer :attachments="photos" group="listing-photos" />
    `,
};
```

Each image is an object with these fields:

- `path`: the full-size image's URL, opened full screen.
- `thumbnails`: the image shown on the tile. A URL string is simplest. It can also be an object, or JSON text of one, shaped `{ "300x450": { "image_path": "<url>" } }`. Without `thumbnails` the tile has no picture, so send the `path` again when you have no smaller copy.
- `original_file_name`: the label under the tile, the image's alternative text, and the caption in the full-screen viewer.
- Anything else, such as `id`, is ignored by the viewer. It comes back to you in the `selected` and `removeItem` events.

<aside>
⚠️ A `thumbnails` object with a `thumbnail` key, which is how File Manager's `createImageThumbnail()` names its sizes, shows no picture: the viewer then reads a top-level `image_path` instead. Send the thumbnail's URL as a string.

</aside>

How it behaves:

- **Opening an image.** Only the picture opens the full-screen viewer, not the label under it. Tiles with the same `group` open as one set, so give each viewer on a screen its own `group`. `viewer_class` adds a class to the full-screen viewer, for example to give it a higher `z-index` than a popup it opens from.
- **Featured image.** With `show_featured_icons`, hovering a tile shows a star at its top left, except on the featured tile. Clicking the star emits `selected` with the image and its index, and the viewer marks that tile straight away. The featured tile shows its star only while hovered. Save the choice, then set `selected_image_index` to the new index.
- **Removing.** With `show_remove_icons`, hovering a tile shows a remove button at its top right. Clicking it emits `removeItem` with the image. The tile stays until you take the image out of `attachments`. Indexes after it move down by one, so update `selected_image_index` too.
- **Loading and empty.** `loading` shows a loader over the viewer. When `attachments` is an empty array and `loading` is false, the viewer shows "No attachments found." with a picture. Always pass an array: with the default, an empty object, the message doesn't show.
- **`disable`** hides the star and remove buttons. The images still open.

<aside>
⚠️ The viewer only follows `selected_image_index` when its value changes. If saving a new featured image fails and you leave `selected_image_index` as it was, the mark stays on the tile the user clicked. To move it back, set `selected_image_index` to `-1`, wait for `this.$nextTick()`, then set it back to the old index.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `attachments` | Array | `{}` | The images, in order. It's declared as an Object, but pass an array. |
| `selected_image_index` | Number | `null` | The index of the featured image. |
| `show_featured_icons` | Boolean | `false` | Shows a star on hover for marking an image as featured. |
| `show_remove_icons` | Boolean | `false` | Shows a remove button on hover. |
| `loading` | Boolean | `false` | Shows a loader and hides the empty message. |
| `disable` | Boolean | `false` | Hides the star and remove buttons. |
| `group` | String | `"attachments"` | The full-screen viewer's set. Tiles with the same group open together. |
| `viewer_class` | String | `""` | A class added to the full-screen viewer. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `selected` | `attachment`, `index` | The star on a tile was clicked. Save it as the featured image. |
| `removeItem` | `attachment` | The remove button on a tile was clicked. Delete the image, then take it out of `attachments`. |

The admin panel's copy has no `group` or `viewer_class` props, so all the viewers on a screen open as one set. Its `thumbnails` must be JSON text: an object or a plain URL breaks the viewer. A `selected_image_index` of `0` isn't marked until the value changes, and the empty message only appears after `attachments` changes.

---

## A photo gallery for a record

A record's photos usually sit in one block: a DcMediaViewer showing what's saved, with a DcImageUploaderMini beside it to add more. The tile uploads at once, and the page reloads the list afterwards, so the viewer always shows what the server holds.

```jsx
import { DcMediaViewer, DcImageUploaderMini } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcMediaViewer, DcImageUploaderMini },
    props: ["listing_id", "can_edit"],
    data() {
        return { photos: [], cover_index: null, loading: false, uploads: 0, error: "" };
    },
    methods: {
        async load_photos() {
            this.loading = true;
            try {
                // Returns { photos: [{ id, path, thumbnails, original_file_name }], cover_id }
                const res = await myapp_services.list_listing_photos({ listing_id: this.listing_id });
                if (res.response.success) {
                    this.photos = res.data.photos;
                    const index = this.photos.findIndex((photo) => photo.id === res.data.cover_id);
                    this.cover_index = index === -1 ? null : index;
                }
            } finally {
                this.loading = false;
            }
        },
        async upload(files) {
            const picked = Array.from(files);
            this.$refs.picker.clear_attachments();
            if (!picked.length) return;

            this.uploads++;
            this.error = "";
            try {
                const form = new FormData();
                form.append("listing_id", this.listing_id);
                picked.forEach((file) => form.append("photos[]", file));
                const res = await myapp_services.add_listing_photos(form);
                if (!res.response.success || res.data.failed.length) {
                    this.error = res.response.statusMsg;
                }
                await this.load_photos();
            } catch (e) {
                this.error = "Couldn't upload the photos. Try again.";
            } finally {
                this.uploads--;
            }
        },
        async set_cover(photo, index) {
            const form = new FormData();
            form.append("photo_id", photo.id);
            const res = await myapp_services.set_listing_cover(form);
            if (res.response.success) {
                this.cover_index = index;
                return;
            }
            // Move the viewer's mark back to the old cover.
            this.error = res.response.statusMsg;
            const old_index = this.cover_index;
            this.cover_index = -1;
            await this.$nextTick();
            this.cover_index = old_index;
        },
        async remove_photo(photo) {
            const form = new FormData();
            form.append("photo_id", photo.id);
            const res = await myapp_services.remove_listing_photo(form);
            if (res.response.success) {
                // Reloading also corrects the cover's index.
                await this.load_photos();
            } else {
                this.error = res.response.statusMsg;
            }
        },
    },
    mounted() {
        this.load_photos();
    },
    template: `
    <div class="dcui-flex-item dcui-align-center">
        <dc-media-viewer :attachments="photos" :selected_image_index="cover_index"
            :loading="loading" group="listing-photos"
            :show_featured_icons="can_edit" :show_remove_icons="can_edit"
            @selected="set_cover" @removeItem="remove_photo" />
        <dc-image-uploader-mini v-if="can_edit" ref="picker" id="myapp-listing-add-photo"
            placeholder="Add photos" :hide-preview="true" :loading="uploads > 0"
            @update:modelValue="upload" />
    </div>
    <p v-if="error" class="dcui-text-danger">{{ error }}</p>
    `,
};
```

- The page keeps the photos and the cover's index. The viewer and the tile hold nothing your page needs later.
- The cover is stored by photo id on the server and turned into an index after each load, because indexes change whenever a photo is added or removed.
- Users who can't edit get no tile and no buttons. The tile is left out with `v-if` rather than disabled, because a disabled tile still takes dropped files.
