---
title: Feedback And Overlays
sidebar_label: Feedback And Overlays
---

# Feedback And Overlays

# Introduction

These components tell the user what is happening: a dialog over the page, a loader while a request runs, a progress bar, and the notice that reports the result. They don't call the server. Your app makes the request, keeps the state (open, saving, the server's message) in the page's `data()` and passes it in.

| Component | Use it for |
| --- | --- |
| `DcPopup` | A dialog over the page: confirmations, short forms, details |
| `DcLoaderBar` | A thin bar at the top of a card while a record saves in the background |
| `DcProgressBar` | How far a task has got, as steps (`3/5`) or a percentage |
| `DcAjaxLoader` | The animated dots inside a button while its request runs |
| `DcAjaxNotice` | The message in the bottom-right corner after a save or delete |

`DcAjaxLoader` and `DcAjaxNotice` are the framework's `Ajax_Loader` and `Ajax_Notice` helpers from `components/helpers.js`, exported under kit names. See [Confirming a delete](#confirming-a-delete) for all of them working together.

Every example imports from the kit's registry. The path below is from a component in `apps/myapp/components/`:

```jsx
import { DcPopup } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Register each imported component in the `components` option before you use its tag. See [Vue DC UI KIT](./Vue%20DC%20UI%20KIT.md) for the setup.

---

## DcPopup

A centred dialog over a blurred overlay, with a × in the corner. Open it through a `ref` with `show()`, or from its `trigger` slot. The body goes in the `content` slot.

```jsx
import { DcPopup, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcPopup, DcButton },
    template: `
    <dc-button @click="$refs.delivery.show()">Delivery Details</dc-button>

    <dc-popup ref="delivery" title="Delivery Details" class="dcui-w-500 min-w-360">
        <template #content>
            <p>Orders leave the warehouse at 9 am, Monday to Friday.</p>
            <div class="dcui-flex-item dcui-justify-flex-end dcui-m-t-15">
                <dc-button class="dcui-button-no-fill" @click="$refs.delivery.hide()">Close</dc-button>
            </div>
        </template>
    </dc-popup>
    `,
};
```

The `trigger` slot renders your opener in place and passes it `onToggle`, so you don't need a `ref`:

```jsx
template: `
<dc-popup title="Style Details" class="dcui-w-500 min-w-360">
    <template #trigger="{ onToggle }">
        <dc-button @click="onToggle">Show Details</dc-button>
    </template>
    <template #content>
        <p>Summer linen dress, sizes S to XL.</p>
    </template>
</dc-popup>
`,
```

How it behaves:

- **Content.** There is no default slot. Anything outside `#content` (or `#title`, or `#trigger`) isn't shown. Put the buttons last in `#content`.
- **Title.** The `title` prop shows as the heading. When `title` is empty, the `title` slot is shown in its place, for a heading with markup.
- **Width.** The framework styles the box at 650px wide at least, and 95% of the screen at most. A width class alone can't make it narrower, so for a short message add `min-w-360` as well: `class="dcui-w-500 min-w-360"`. That also keeps it on the screen on a phone. `class` goes on the box, not the overlay. Other attributes, such as `id`, aren't applied anywhere.
- **Rendering.** The overlay and its content are only rendered while the popup is open. Components inside it mount each time it opens and are removed when it closes, so keep form values in the page's `data()`. A `ref` to something inside the popup is only set after `show()` and the next render (`await this.$nextTick()`).
- **Closing.** The × calls `close()`. Escape doesn't close the popup, and the × can't be reached with the Tab key, so always put a Cancel or Close button in the content.
- **`before-close`.** If you listen for it, the × (and `close()`) emits it with a `resolve` function and waits. Call `resolve()` to let the popup close. Don't call it to keep the popup open. `hide()` and `toggle()` skip this step.
- **`closed`.** Emitted when the popup goes from open to closed through `hide()`, `close()` or the ×. Closing it with `toggle()` (including the trigger slot's `onToggle`) doesn't emit it.

Show one popup at a time. Don't open a popup from inside another.

### Confirming a delete

The kit's rule: confirm every delete in a `DcPopup` that names the item and says what will happen. This screen lists orders and deletes one after the user confirms it:

- The title is the action (Delete Order). The message names the order and says what happens, never a bare "Are you sure?".
- The confirm button repeats the verb (Delete). The other button says Cancel.
- While the request runs, the Delete button shows a [DcAjaxLoader](#dcajaxloader) and the popup can't be closed.
- On success the popup closes, the order leaves the list and a [DcAjaxNotice](#dcajaxnotice) shows the server's message.
- On failure the popup stays open and shows the error above the buttons.

`myapp_services` stands for your app's `services.js` (see [Frontend Runtime (XP)](../Frontend%20Runtime%20(XP).md)).

```jsx
import { DcPopup, DcButton, DcAjaxLoader, DcAjaxNotice } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcPopup, DcButton, DcAjaxLoader, DcAjaxNotice },
    data() {
        return {
            orders: [
                { id: 1042, number: "ORD-1042", customer: "Sam Perera" },
                { id: 1043, number: "ORD-1043", customer: "Alex Silva" },
            ],
            order_to_delete: null,
            deleting: false,
            delete_error: "",
            notice: { show: false, type: "", text: "" },
        };
    },
    methods: {
        confirm_delete(order) {
            this.order_to_delete = order;
            this.$refs.confirm_delete.show();
        },
        // The × and Cancel call close(), which waits for resolve(). Keep the popup open while the delete runs.
        before_close(resolve) {
            if (!this.deleting) resolve();
        },
        async delete_order() {
            if (this.deleting) return;
            this.deleting = true;
            this.delete_error = "";
            try {
                const form = new FormData();
                form.append("id", this.order_to_delete.id);
                const res = await myapp_services.delete_order(form);
                if (res.response.success) {
                    this.orders = this.orders.filter((order) => order.id !== this.order_to_delete.id);
                    this.$refs.confirm_delete.hide();
                    this.notice = { show: true, type: "success", text: res.response.statusMsg };
                } else {
                    this.delete_error = res.response.statusMsg;
                }
            } catch (e) {
                this.delete_error = "Couldn't delete the order. Try again.";
            } finally {
                this.deleting = false;
            }
        },
    },
    template: `
    <div v-for="order in orders" :key="order.id" class="dcui-flex-item dcui-justify-space-between dcui-align-center dcui-m-b-10">
        <span>{{ order.number }}, {{ order.customer }}</span>
        <dc-button class="dcui-button-no-fill" @click="confirm_delete(order)">Delete</dc-button>
    </div>

    <dc-popup ref="confirm_delete" title="Delete Order" class="dcui-w-500 min-w-360"
        @before-close="before_close" @closed="delete_error = ''">
        <template #content>
            <p>Delete order {{ order_to_delete.number }} for {{ order_to_delete.customer }}? The order and its items are removed for everyone. This can't be undone.</p>
            <p v-if="delete_error" class="dcui-text-danger">{{ delete_error }}</p>
            <div class="dcui-flex-item dcui-justify-flex-end dcui-m-t-15">
                <dc-button class="dcui-button-no-fill dcui-m-r-10" @click="$refs.confirm_delete.close()">Cancel</dc-button>
                <dc-button :class="{ 'doing-ajax': deleting }" @click="delete_order">
                    Delete <dc-ajax-loader theme="dc" v-if="deleting" />
                </dc-button>
            </div>
        </template>
    </dc-popup>

    <Transition name="fade-up">
        <dc-ajax-notice v-if="notice.show" theme="dc" :type="notice.type" :text="notice.text"
            @dismiss_notice="notice.show = false" />
    </Transition>
    `,
};
```

Only call `hide()` once you know the delete worked. An error inside a popup belongs in the popup, in red above the buttons, not in a notice.

<aside>
⚠️ Leave `dismiss_on_overlay_click` off. Its click handler sits on the overlay, and clicks inside the popup bubble up to it, so with it on, a click anywhere in the popup closes it: on a field, on text, even on the Delete button (whose own click still runs). With a `before-close` listener, each of those clicks emits `before-close`.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | String | none | The heading. When empty, the `title` slot is shown instead. |
| `class` | String | none | Classes for the popup box, such as `dcui-w-500 min-w-360`. |
| `dismiss_on_overlay_click` | Boolean | `false` | Closes the popup, through `close()`, on a click on the overlay. See the warning above. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `before-close` | `resolve`, a function | The × was clicked or `close()` was called. Only emitted when you listen for it. The popup closes when you call `resolve()`. |
| `closed` | none | The popup went from open to closed through `hide()`, `close()` or the ×. |

**Slots**

| Name | Scope | Description |
| --- | --- | --- |
| `content` | none | The body, with the buttons last. |
| `title` | none | A custom heading, shown when the `title` prop is empty. |
| `trigger` | `onToggle` | Your own opener, rendered where the popup is placed. Call `onToggle` to open or close the popup. |

**Methods**

| Name | Description |
| --- | --- |
| `show()` | Opens the popup. |
| `hide()` | Closes the popup without `before-close`, and emits `closed`. |
| `close()` | What the × does: emits `before-close` and waits for `resolve()` when you listen for it, then calls `hide()`. |
| `toggle()` | Opens or closes the popup. Skips `before-close` and doesn't emit `closed`. |

---

## DcLoaderBar

A thin blue bar across the top of a card that shows a record is saving in the background, for example while a detail page saves a change automatically. For a save the user starts with a button, use a [DcAjaxLoader](#dcajaxloader) in the button instead.

```jsx
import { DcLoaderBar, DcCard } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcLoaderBar, DcCard },
    props: ["order"],
    data() {
        return { saving: false };
    },
    methods: {
        // Call this whenever one of the order's fields changes.
        async save() {
            this.saving = true;
            try {
                const form = new FormData();
                form.append("id", this.order.id);
                form.append("note", this.order.note);
                await myapp_services.save_order(form);
            } finally {
                this.saving = false;
            }
        },
    },
    template: `
    <dc-card>
        <dc-loader-bar :loading="saving" />
        <h3>Order {{ order.number }}</h3>
        <p>{{ order.note }}</p>
    </dc-card>
    `,
};
```

When `loading` turns true, the bar starts from nothing and grows by 10% every half second, up to 90%. When `loading` turns false, it fills to 100%, then disappears after about a second, ready for the next save.

The bar is positioned at the top of its nearest positioned ancestor, full width, over the content. A `DcCard` is positioned, so put the bar first inside the card.

<aside>
⚠️ The bar only reacts when `loading` changes. If it mounts with `loading` already true, it stays empty until `loading` turns false, then flashes to 100%. Render it before the save starts, rather than under the same `v-if` as the work.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `loading` | Boolean | `false` | Set it to true when the work starts and false when it ends. |
| `line_size` | String | `"5"` | The bar's height in pixels, such as `line_size="3"`. Read once, when the component is created. |

**Events**

None.

**Methods**

| Name | Description |
| --- | --- |
| `startLoading()` | Starts the bar from nothing, as `loading` turning true does. |
| `completeProgress()` | Fills the bar and hides it, as `loading` turning false does. |

---

## DcProgressBar

Shows how far a task has got: a bar with a label beside it, either as steps done out of a total (`3/5`) or as a percentage (`40%`). It only displays the value you pass.

```jsx
import { DcProgressBar } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcProgressBar },
    data() {
        return { tasks_done: 3, tasks_total: 5, upload_percent: 40 };
    },
    template: `
    <dc-progress-bar :model-value="tasks_done" :steps="tasks_total" />
    <dc-progress-bar type="percentage" :model-value="upload_percent" :steps="0" />
    `,
};
```

With `steps` set, the bar's width is `modelValue` out of `steps`, and the bar is complete when they're equal. With `steps` at `0`, `modelValue` is the percentage, and the bar is complete at 100. `type` only changes the label. The component never changes the value, so `:model-value` is enough; `v-model` works too.

The track and the label get the class `completed` when the bar is full, and `no-progress` when `modelValue` is `0` and `in_progress` isn't set.

<aside>
⚠️ In framework 0.0.44 no stylesheet defines `dc-container`, `dc-progress` or `dc-progress-text`, the classes the bar is drawn with. Only the label (`3/5` or `40%`) shows: the track and the fill have no height or colour, and `completed` and `no-progress` change nothing. Also, `steps` defaults to the string `"0"`, which counts as set. For a percentage bar, pass `:steps="0"`, or the width is worked out by dividing by zero and the bar never counts as complete.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Number | `"0"` | The progress: steps done, or a percentage when `steps` is `0`. |
| `steps` | Number | `"0"` | The total number of steps. Pass `0` for a percentage bar. |
| `type` | String | `"steps"` | The label. `steps` shows `3/5`. Any other value, such as `percentage`, shows `40%`. |
| `in_progress` | String | `null` | Any value other than `null` or `0` marks a task that has started but has no progress yet, so a `0` isn't shown as "no progress". |

**Events**

None.

---

## DcAjaxLoader

Four animated dots that cover a button while its request runs. It's the framework's `Ajax_Loader` helper. Put it inside a `DcButton` with `v-if`, and add the class `doing-ajax` to the button for as long as the request runs.

```jsx
import { DcButton, DcAjaxLoader } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcButton, DcAjaxLoader },
    props: ["order"],
    data() {
        return { saving: false };
    },
    methods: {
        async save() {
            if (this.saving) return;
            this.saving = true;
            try {
                const form = new FormData();
                form.append("id", this.order.id);
                form.append("status", this.order.status);
                await myapp_services.save_order(form);
            } finally {
                this.saving = false;
            }
        },
    },
    template: `
    <dc-button :class="{ 'doing-ajax': saving }" @click="save">
        Save Changes <dc-ajax-loader theme="dc" v-if="saving" />
    </dc-button>
    `,
};
```

How it works:

- **`theme="dc"`** gives the kit's look: white dots on the kit's secondary colour. Without it you get the framework's older loader, which never shows inside a `DcButton`. Always pass `theme="dc"`.
- **`doing-ajax`** on an ancestor is what makes it visible. It fills the nearest positioned ancestor; a `DcButton` is positioned, so it covers the button and hides the label.
- **A second click.** A `DcButton` with `doing-ajax` ignores clicks. Pressing Enter in a form still submits it, so guard the handler as `save()` does above.
- **Icon buttons.** Don't put it on an icon-only or transparent button: it fills the whole button with blue. Use the `loading` prop of [DcIconButton](./Buttons%20And%20Links.md) there instead.

Write the tag as `dc-ajax-loader` after importing `DcAjaxLoader`. The helper is also registered globally as `Ajax_Loader`, so `<Ajax_Loader theme="dc" />` works without an import, but only with that exact name: `<ajax-loader>` renders nothing.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `theme` | String | none | `dc` for the kit's look. Any other value, or none, gives the older loader. |

**Events**

None.

The admin-panel registry doesn't export `DcAjaxLoader`. In the admin panel, the same component is registered globally as `Ajax_Loader`.

---

## DcAjaxNotice

The message that reports a result: a white box fixed to the bottom-right corner, with a coloured edge for success, error or warning, a × and a five-second countdown ring. It's the framework's `Ajax_Notice` helper. After a create, update or delete, show it with the server's `statusMsg`.

```jsx
import { DcAjaxNotice, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcAjaxNotice, DcButton },
    props: ["order"],
    data() {
        return { notice: { show: false, type: "", text: "", id: 0 } };
    },
    methods: {
        show_notice(type, text) {
            // A new id gives each message a fresh notice and its own five seconds.
            this.notice = { show: true, type, text, id: this.notice.id + 1 };
        },
        async archive() {
            try {
                const form = new FormData();
                form.append("id", this.order.id);
                const res = await myapp_services.archive_order(form);
                this.show_notice(res.response.success ? "success" : "error", res.response.statusMsg);
            } catch (e) {
                this.show_notice("error", "Couldn't archive the order. Try again.");
            }
        },
    },
    template: `
    <dc-button @click="archive">Archive Order</dc-button>

    <Transition name="fade-up">
        <dc-ajax-notice v-if="notice.show" :key="notice.id" theme="dc" :type="notice.type" :text="notice.text"
            @dismiss_notice="notice.show = false" />
    </Transition>
    `,
};
```

How it behaves:

- **Hiding.** The notice never hides itself. Five seconds after it appears, or when the × is clicked, it emits `dismiss_notice`. Set your flag to false, and show it with `v-if`.
- **A new message.** The five seconds start when the notice is created. If you change `text` while a notice is showing, the old timer still runs and closes the new message early. Give it a `:key` that changes with each message, as above.
- **Placement.** It's fixed to the bottom-right corner whatever its place in the template, so put it once at the end of the screen. `fade-up` is a transition defined in the framework's stylesheet.
- **`type`.** `success`, `error` and `warning` colour the left edge green, red and orange. Any other value leaves it grey.

The framework's own screens keep the notice as `{ show, type, text }` and bind the whole object, which works the same way:

```jsx
template: `
<dc-ajax-notice theme="dc" v-bind="ui.notice" v-if="ui.notice.show" @dismiss_notice="(n) => ui.notice.show = !n" />
`,
```

Write the tag as `dc-ajax-notice` after importing `DcAjaxNotice`. The helper is also registered globally as `Ajax_Notice`, so `<Ajax_Notice>` works without an import, but `<ajax-notice>` renders nothing.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | String | none | `success`, `error` or `warning`. |
| `text` | String | none | The message, shown as plain text. |
| `theme` | String | none | `dc` for the kit's look. Any other value, or none, gives the older notice without the countdown ring. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `dismiss_notice` | `true` | Five seconds have passed since the notice appeared, or the × was clicked. Hide the notice. |

The admin-panel registry doesn't export `DcAjaxNotice`. In the admin panel, the same component is registered globally as `Ajax_Notice`.

---

## Choosing the feedback

- **A button starts a save or delete:** add `doing-ajax` and a [DcAjaxLoader](#dcajaxloader) to the button. When the server answers, show a [DcAjaxNotice](#dcajaxnotice) with its `statusMsg`, and update the screen so the change is visible.
- **A record saves in the background:** put a [DcLoaderBar](#dcloaderbar) at the top of its card.
- **A delete, remove, reject or cancel:** confirm it in a [DcPopup](#confirming-a-delete) first. Never act on one click, and never use `window.confirm()`.
- **An error inside a popup:** show it in red above the popup's buttons and keep the popup open. A notice is for results on the page itself.
- **A request the server refuses:** handle `success: false` as well as a failed request, and turn the loader off in both cases (a `finally` block does this).
