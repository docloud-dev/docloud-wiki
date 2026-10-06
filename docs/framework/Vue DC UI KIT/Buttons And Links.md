---
title: Buttons And Links
sidebar_label: Buttons And Links
---

# Buttons And Links

# Introduction

These components are the things a user clicks to act or move: a button, a square icon button, a button with a menu of alternatives, a text link, and the framed icon used in screen headings. They only render the control. Your component handles the click and keeps any state, such as which view is active or whether a save is running, in its own `data()`.

| Component | Use it for |
| --- | --- |
| `DcButton` | The main action on a screen or form, and secondary actions in outline style |
| `DcIconButton` | A square button with only an icon, such as a view switch or a row action |
| `DcSplitButton` | A primary action with a caret menu of alternative actions |
| `DcLink` | A text link, inline or beside a heading |
| `DcBoxIcon` | A framed icon at the start of a screen heading |

Every example imports from the kit's registry. The path below is from a component in `apps/myapp/components/`:

```jsx
import { DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Register each imported component in the `components` option before you use its tag. See [Vue DC UI KIT](./Vue%20DC%20UI%20KIT.md) for the setup.

---

## DcButton

The kit's button: a `<button>` with the class `dcui-button`, filled with the primary colour. Put the label in the default slot.

```jsx
import { DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcButton },
    template: `
    <dc-button @click="create_order">Create Order</dc-button>
    `,
    methods: {
        create_order() {
            // Open your create form.
        },
    },
};
```

The component declares no events, so `@click` and any other listener go straight to the `<button>` element. The handler gets the browser's click event, and doesn't run while the button is disabled. Classes you add land on the `<button>` too:

- `dcui-button-no-fill`: outline style, for a secondary action such as Cancel or Discard.
- `dcui-large`: a slightly taller button with a larger font.
- `dc-button-dark`: grey instead of the primary colour.

`type` defaults to `button`, so a `DcButton` inside a `<form>` doesn't submit it. Set `type="submit"` on the button that should.

### A save button with a busy state

While a save runs, add the class `doing-ajax` and put a [DcAjaxLoader](./Feedback%20And%20Overlays.md#dcajaxloader) with `theme="dc"` inside the button. The loader stays hidden until the button has `doing-ajax`, and then covers the label with animated dots. `myapp_services` stands for your app's `services.js` (see [Frontend Runtime (XP)](../Frontend%20Runtime%20(XP).md)).

```jsx
import { DcButton, DcAjaxLoader } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcButton, DcAjaxLoader },
    props: ["customer"],
    data() {
        return { saving: false };
    },
    methods: {
        async save() {
            if (this.saving) return;
            this.saving = true;
            try {
                const form = new FormData();
                form.append("name", this.customer.name);
                const res = await myapp_services.save_customer(form);
                if (res.response.success) {
                    // Close the form or show the saved record.
                }
            } finally {
                this.saving = false;
            }
        },
        discard() {
            // Close the form without saving.
        },
    },
    template: `
    <form @submit.prevent="save">
        <!-- The form fields go here. -->
        <div class="dcui-flex-item dcui-justify-space-between dcui-m-t-15">
            <dc-button class="dcui-button-no-fill" :disabled="saving" @click="discard">Discard</dc-button>
            <dc-button type="submit" :class="{ 'doing-ajax': saving }">
                Save Details<dc-ajax-loader theme="dc" />
            </dc-button>
        </div>
    </form>
    `,
};
```

`doing-ajax` stops mouse clicks, but a focused button still responds to Enter and Space. Keep the `if (this.saving) return;` guard so a second press doesn't send the form twice.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | String | `"button"` | The button's `type` attribute: `button`, `submit` or `reset`. |
| `disabled` | Boolean | `false` | Disables the button and dims it. |

**Events**

None. Listeners such as `@click` are passed to the `<button>` element.

**Slots**

| Name | Description |
| --- | --- |
| default | The label, and optionally an icon or a `DcAjaxLoader`. |

---

## DcIconButton

A square button that shows only a Font Awesome icon, or a small image. Use it for compact actions, such as switching between a list and a grid or a row's edit action.

```jsx
import { DcIconButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcIconButton },
    data() {
        return { view: "list" };
    },
    template: `
    <div class="dcui-flex-item dcui-flex-gap-5">
        <dc-icon-button class="dcui-ia-switches" icon="fa-solid fa-list" title="List view"
            :classes="view === 'list' ? 'active' : ''" @click="view = 'list'" />
        <dc-icon-button class="dcui-ia-switches" icon="fa-solid fa-grip" title="Grid view"
            :classes="view === 'grid' ? 'active' : ''" @click="view = 'grid'" />
    </div>
    `,
};
```

The component is a wrapper `div` with the class `dcui-icon-actions`, holding the clickable item. Each one is a full-width flex row, so put several in a `dcui-flex-item` container to line them up, as above. There are two places for classes:

- `class` goes on the wrapper. Use `dcui-ia-switches` for a set of switches (dimmed until the item is `active`), `dcui-ia-large` for a larger icon, or `dcui-content-right` to push the item to the right.
- `classes` goes on the item itself. Pass `active` to mark the current switch.

`@click`, `title` and other attributes also land on the wrapper. Give every icon button a `title`, because the icon is all the user sees.

<aside>
⚠️ `loading` only shows a spinner in place of the icon. Clicks still go through, so ignore them in your handler while the work runs. The button isn't a real `<button>`, so it can't be reached with the Tab key or pressed from the keyboard. Don't make an icon button the only way to reach an action.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `icon` | String | `""` | Font Awesome classes, such as `fa-solid fa-list`. Ignored when `image` is set. |
| `classes` | String | `""` | Classes for the clickable item, such as `active`. |
| `image` | String | `""` | URL of a small image to show instead of the icon. |
| `loading` | Boolean | `false` | Shows a spinner in place of the icon. |

**Events**

None. Listeners such as `@click` are passed to the wrapper `div`.

---

## DcSplitButton

A filled button with a caret menu attached. The label half runs the primary action. The caret opens a menu of alternatives, and picking a row runs that action at once. Use it where a screen's footer would otherwise carry two competing filled buttons: the main action keeps the button and the others move into the menu.

```jsx
import { DcSplitButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcSplitButton },
    data() {
        return {
            save_actions: [
                { key: "draft", label: "Save Draft" },
                { key: "close", label: "Save and Close" },
            ],
        };
    },
    methods: {
        save() {
            // Save and stay on the form.
        },
        on_action(key) {
            // key is the picked row's key: "draft" or "close".
        },
    },
    template: `
    <dc-split-button label="Save" icon="fa-regular fa-floppy-disk" :actions="save_actions"
        @click="save" @action="on_action" />
    `,
};
```

How it behaves:

- **The menu.** Each row is `{ key, label }`, shown in array order. Keys must be unique. Picking a row closes the menu and emits `action` with its `key`. Picking the same row again runs it again: the menu keeps no selection.
- **Placement.** The menu opens below the button, right-aligned to the caret. It opens above only when it doesn't fit below and there's more room above. If it fits neither way, it scrolls. It stays attached while the page scrolls or resizes, and a click anywhere else closes it.
- **Disabled.** `disabled` disables both halves, so the menu can't be opened either. Set it while a save runs.

The menu is built on [DcDropdown](./Selects%20And%20Pickers.md#dcdropdown) and is opened by the kit's global click handler.

<aside>
⚠️ The menu opens only with a mouse click or tap. The caret can take focus with the Tab key, but Enter and Space don't open it, and the rows can't be reached from the keyboard. Make sure keyboard users have another way to reach those actions.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | String | required | The text on the primary half. |
| `icon` | String | `""` | Font Awesome classes for an icon before the label. Empty shows no icon. |
| `actions` | Array | `[]` | The menu rows: `{ key, label }`. |
| `disabled` | Boolean | `false` | Disables the primary half and the caret. |
| `menuTitle` | String | `"More options"` | Hover text on the caret, which has no text of its own. Pass it as `menu-title`. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `click` | none | The primary half was clicked. Run the main action. |
| `action` | the row's `key` | A menu row was picked. Run that action. |

The admin-panel registry doesn't export `DcSplitButton`.

---

## DcLink

A text link: an `<a>` in the kit's link style, black text that turns dark grey and underlines on hover. Put the link text in the default slot.

```jsx
import { DcLink } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcLink },
    template: `
    <p>
        Need help setting up?
        <dc-link href="https://example.com/support" target="_blank">Visit Support</dc-link>
    </p>
    `,
};
```

`href`, `target`, `@click` and other attributes and listeners go straight to the `<a>`. It's a plain link, not a `router-link`, so an `href` to a page of your app reloads the whole page. To move to a route without a reload, keep the `href` and push the route on click:

```jsx
template: `
<dc-link :href="$router.resolve({ name: 'myapp_orders' }).href"
    @click.prevent="$router.push({ name: 'myapp_orders' })">All orders</dc-link>
`,
```

A `DcLink` with only `@click` and no `href` works with a mouse, but it can't be reached with the Tab key. Give every link an `href`.

<aside>
⚠️ The `class` you set is read once, when the link is created. Binding `class` to a value that changes later (`:class="{ active: is_active }"`) has no effect after the first render. To change it, give the link a new `key` so it's created again.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `class` | String | `""` | Extra classes for the `<a>`. Read once; see above. |

**Events**

None. Listeners such as `@click` are passed to the `<a>`.

**Slots**

| Name | Description |
| --- | --- |
| default | The link text. |

---

## DcBoxIcon

A Font Awesome icon centred in a square box with a thick rounded border. The framework uses it at the start of the heading on its setup screens, beside a title with the class `dc-cp-b-h-title`.

```jsx
import { DcBoxIcon } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcBoxIcon },
    template: `
    <div class="dc-cp-b-header dcui-flex-item dcui-align-center">
        <dc-box-icon icon="fa-regular fa-code" class="dcui-m-r-20" />
        <h2 class="dc-cp-b-h-title">Framework Installation</h2>
    </div>
    `,
};
```

The box is drawn only inside an element with the class `dc-cp-b-header`, as above. Anywhere else, the component shows the icon centred with no box around it. The heading pattern belongs inside a framework card such as `DcConfCard` (see [DcConfCard](./Framework%20Screens.md#dcconfcard)).

<aside>
⚠️ `icon` and `class` are read once, when the component is created. Changing either later doesn't update the box. To show a different icon, give the component a new `key` so it's created again.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `icon` | String | `""` | Font Awesome classes, such as `fa-regular fa-code`. Read once. |
| `class` | String | `""` | Extra classes for the box, such as a margin class. Read once. |

**Events**

None.

---

## A form footer

A form's actions usually sit together at the bottom: an outline button to leave without saving, and the save action on the right. When saving has variants, put them in a `DcSplitButton` rather than a row of filled buttons, and disable everything while a save runs.

```jsx
import { DcButton, DcSplitButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcButton, DcSplitButton },
    props: ["order"],
    data() {
        return {
            saving: false,
            save_actions: [
                { key: "draft", label: "Save as Draft" },
                { key: "close", label: "Save and Close" },
            ],
        };
    },
    methods: {
        async save(status) {
            if (this.saving) return false;
            this.saving = true;
            try {
                const form = new FormData();
                form.append("id", this.order.id);
                form.append("status", status);
                const res = await myapp_services.save_order(form);
                return res.response.success;
            } finally {
                this.saving = false;
            }
        },
        async on_action(key) {
            if (key === "draft") {
                await this.save("draft");
            } else if (key === "close" && (await this.save("active"))) {
                this.$router.push({ name: "myapp_orders" });
            }
        },
    },
    template: `
    <div class="dcui-flex-item dcui-justify-space-between dcui-align-center dcui-m-t-15">
        <dc-button class="dcui-button-no-fill" :disabled="saving" @click="$router.push({ name: 'myapp_orders' })">Discard</dc-button>
        <dc-split-button label="Save" :actions="save_actions" :disabled="saving"
            @click="save('active')" @action="on_action" />
    </div>
    `,
};
```

- The primary half and every menu row call the same `save` method, so the guard and the disabled state cover all of them.
- `DcSplitButton` has no busy animation. Disabling it while `saving` is true shows the save is running and stops a second one.
