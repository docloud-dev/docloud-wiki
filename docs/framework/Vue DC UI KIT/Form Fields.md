---
title: Form Fields
sidebar_label: Form Fields
---

# Form Fields

# Introduction

These components take input: text boxes, a text area, password fields, a search box, checkboxes, radio buttons, a toggle switch and a tag box. The text fields draw the framework's field markup (`dcui-form-group`, `dcui-fld-label`, `dcui-form-control`), so a form built from them looks like every other DoFramework screen. Keep the values in the page's `data()` and bind them with `v-model`.

| Component | Use it for |
| --- | --- |
| `DcInputField` | A one-line text box, with an optional icon or text such as a currency |
| `DcTextField` | A multi-line text area |
| `DcPasswordField` | A password box with a show/hide button |
| `DcPasswordGenerator` | A text box with a Generate button that fills in a random password |
| `DcSearchField` | A search box that reports what the user typed, after a short pause |
| `DcFormGroup` | Spacing and a label around fields that don't have their own |
| `DcCheckbox` | One checkbox, alone or as one of a set |
| `DcCheckboxGroup` | Checkboxes side by side |
| `DcRadioGroup` | One choice from a short list |
| `DcToggleSwitch` | An on/off setting |
| `DcTagInput` | A list of free-text tags, added with Enter |

For dropdowns, date pickers and other pickers, see [Selects And Pickers](./Selects%20And%20Pickers.md).

Every example imports from the kit's registry. The path below is from a component in `apps/myapp/components/`:

```jsx
import { DcInputField } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Register each imported component in the `components` option before you use its tag. See [Vue DC UI KIT](./Vue%20DC%20UI%20KIT.md) for the setup.

Most of these fields take a `class` prop for the input itself. They read it once, when the field is created, so a class that changes later (for example an error class added after validation) never reaches the input. Show validation messages as text instead, as the example at the end of this page does.

---

## DcInputField

A one-line text box with a label. It can show an icon, or a short text such as a currency, on either side of the box.

```jsx
import { DcInputField } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcInputField },
    data() {
        return { name: "" };
    },
    template: `
    <dc-input-field id="myapp-customer-name" label="Name" v-model="name" placeholder="Full name">
        <template #label>Name</template>
    </dc-input-field>
    `,
};
```

The visible label comes from the `label` slot. The `label` prop is required, but it isn't shown. Without the slot there is no `<label>` element.

Any attribute that isn't a prop goes on the `<input>`: `disabled`, `maxlength`, `autocomplete`, `inputmode`, and listeners such as `@blur` or `@keyup.enter`. That includes the `update:modelValue` listener, which is how `v-model` reaches the input. Both `v-model` and `:model-value` with `@update:model-value` update the parent on every keystroke.

### With an icon

Set `icon` to Font Awesome classes, or put text in the `icon` slot. The icon sits on the left unless `iconPosition` is `"right"`. `iconFilled` gives it a grey background and a divider, which suits a button. Clicking the icon emits `icon-click`.

```jsx
import { DcInputField } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcInputField },
    data() {
        return { email: "", price: "", coupon: "" };
    },
    methods: {
        apply_coupon() {
            // Check the code with the server.
        },
    },
    template: `
    <dc-input-field id="myapp-email" label="Email" v-model="email" icon="fa-regular fa-envelope"
        inputmode="email" autocomplete="email">
        <template #label>Email</template>
    </dc-input-field>

    <dc-input-field id="myapp-price" label="Price" v-model="price" inputmode="decimal">
        <template #label>Price</template>
        <template #icon>LKR</template>
    </dc-input-field>

    <dc-input-field id="myapp-coupon" label="Coupon" v-model="coupon" icon="fa-regular fa-arrow-right"
        icon-position="right" :icon-filled="true" @icon-click="apply_coupon">
        <template #label>Coupon code</template>
    </dc-input-field>
    `,
};
```

Use the `custom` slot for anything under the box, such as help text or a validation message.

<aside>
⚠️ The `type` prop has no effect: the input is always `type="text"`. `type="email"`, `type="number"` and `type="date"` all give a plain text box, and `v-model` always holds a string. Use `inputmode` for the right phone keyboard, check the value yourself, and use [Selects And Pickers](./Selects%20And%20Pickers.md) for dates.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | String | required | The input's id. The label points at it. |
| `label` | String | required | Required, but not shown. Put the visible label in the `label` slot. |
| `modelValue` | String | `""` | The text. Use `v-model`. |
| `placeholder` | String | none | The placeholder. |
| `readonly` | Boolean | `false` | Makes the input read-only. |
| `type` | String | `"text"` | Has no effect. See the note above. |
| `class` | String | `""` | Classes for the `<input>`. Read once, when the field is created. |
| `containerClasses` | String | `""` | Classes for the wrapper `div` (`dcui-form-group`). |
| `icon` | String | `""` | Font Awesome classes for an icon beside the box, such as `fa-regular fa-envelope`. |
| `iconPosition` | String | `"left"` | `"left"` or `"right"`. |
| `iconFilled` | Boolean | `false` | Gives the icon a grey background and a divider. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | String | The text changed. Handled by `v-model`. |
| `icon-click` | the click event | The icon was clicked. |

**Slots**

| Name | Description |
| --- | --- |
| `label` | The label text. |
| `icon` | Text or markup in place of `icon`, such as a currency. |
| `custom` | Content under the box. |

The admin panel has an older copy of this component. It has no `icon`, `iconPosition` or `iconFilled` props, no `icon` slot, and doesn't emit `icon-click`.

---

## DcTextField

A multi-line text area with a label, for notes, descriptions and addresses.

```jsx
import { DcTextField } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcTextField },
    data() {
        return { notes: "" };
    },
    template: `
    <dc-text-field id="myapp-order-notes" label="Notes" v-model="notes" placeholder="Delivery instructions"
        :auto-resize="true" maxlength="500">
        <template #label>Notes</template>
    </dc-text-field>
    `,
};
```

The box is at least 110px and at most 200px tall. Users can drag it taller, up to that limit, unless `resize` is `false`. With `autoResize`, it grows as the user types, up to the 200px limit, and then scrolls. It sizes itself only on typing, not on text you load into it.

Any attribute that isn't a prop goes on the `<textarea>`, for example `rows`, `maxlength` or `disabled`. The `<label>` is always drawn, even without the `label` slot.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | String | required | The text area's id. The label points at it. |
| `label` | String | required | Required, but not shown. Put the visible label in the `label` slot. |
| `modelValue` | String | `""` | The text. Use `v-model`. |
| `placeholder` | String | none | The placeholder. |
| `readonly` | Boolean | `false` | Makes the text area read-only. |
| `resize` | Boolean | `true` | Lets the user drag the box taller. |
| `autoResize` | Boolean | `false` | Grows the box as the user types. |
| `type` | String | `"text"` | Not used. |
| `class` | String | `""` | Classes for the `<textarea>`. Read once, when the field is created. |
| `containerClasses` | String | `""` | Classes for the wrapper `div` (`dcui-form-group`). |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | String | The text changed. Handled by `v-model`. |

**Slots**

| Name | Description |
| --- | --- |
| `label` | The label text. |

The admin panel has an older copy of this component, without `autoResize`.

---

## DcPasswordField

A password box with an eye button that shows and hides what was typed.

```jsx
import { DcPasswordField } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcPasswordField },
    data() {
        return { password: "" };
    },
    template: `
    <dc-password-field id="myapp-password" v-model="password" autocomplete="new-password">
        <template #label>Password</template>
        <template #custom>
            <span class="dcui-text-light">At least 8 characters.</span>
        </template>
    </dc-password-field>
    `,
};
```

It has no `label` or `readonly` prop. Any attribute that isn't a prop goes on the `<input>`, so `autocomplete`, `readonly` and `disabled` work as attributes. Set `autocomplete="new-password"` on a field that sets a password, so the browser offers to save it rather than filling in an old one.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | String | required | The input's id. The label points at it. |
| `modelValue` | String | `""` | The password. Use `v-model`. |
| `placeholder` | String | none | The placeholder. |
| `class` | String | `""` | Classes for the `<input>`. Read once, when the field is created. |
| `containerClasses` | String | `""` | Classes for the wrapper `div` (`dcui-form-group`). |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | String | The password changed. Handled by `v-model`. |

**Slots**

| Name | Description |
| --- | --- |
| `label` | The label text. |
| `custom` | Content under the box. |

The admin panel's copy has no `custom` slot.

---

## DcPasswordGenerator

A text box with a **Generate** button. Pressing it fills the box with a random password of `length` characters, made of upper-case letters, lower-case letters and digits. The user can also type a password.

```jsx
import { DcPasswordGenerator } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcPasswordGenerator },
    data() {
        return { password: "" };
    },
    template: `
    <dc-password-generator id="myapp-new-password" v-model="password" :length="12">
        <template #label>Password</template>
    </dc-password-generator>
    `,
};
```

Bind `length` (`:length="12"`) so it arrives as a number.

<aside>
⚠️ Pressing **Generate** writes the password into the box but doesn't update `v-model`. The box shows the new password while your data still holds the old value (or `""`), and the model only changes when the user edits the text. Saving the form then saves the wrong password.

</aside>

Until this is fixed, use a `DcInputField` with a Generate button in its `icon` slot, and create the password in your own method so it goes straight into `v-model`:

```jsx
import { DcInputField } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcInputField },
    data() {
        return { password: "" };
    },
    methods: {
        generate_password() {
            const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            const values = crypto.getRandomValues(new Uint32Array(12));
            this.password = Array.from(values, (n) => chars[n % chars.length]).join("");
        },
    },
    template: `
    <dc-input-field id="myapp-new-password" label="Password" v-model="password"
        icon-position="right" :icon-filled="true" @icon-click="generate_password" autocomplete="off">
        <template #label>Password</template>
        <template #icon>Generate</template>
    </dc-input-field>
    `,
};
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | String | required | The input's id. The label points at it. |
| `modelValue` | String | `""` | The password. Use `v-model`. See the note above. |
| `placeholder` | String | none | The placeholder. |
| `length` | Number | `10` | How many characters Generate produces. |
| `class` | String | `""` | Accepted, but not applied to anything. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | String | The user edited the text. Handled by `v-model`. Not raised by Generate. |

**Slots**

| Name | Description |
| --- | --- |
| `label` | The label text. |

---

## DcSearchField

A search box with a magnifying-glass icon. It doesn't use `v-model`. Instead it emits `search` with the text once the user stops typing for half a second. When the box has text, the icon turns into an **x** that clears it.

```jsx
import { DcSearchField } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcSearchField },
    data() {
        return { query: "" };
    },
    methods: {
        on_search(text) {
            this.query = text.trim();
            // Load the first page of results for this.query.
        },
    },
    template: `
    <dc-search-field id="myapp-order-search" placeholder="Search orders" icon_align="left" @search="on_search" />
    `,
};
```

How it behaves:

- **Typing** emits `search` 500ms after the last key press. The text isn't trimmed, so trim it yourself.
- **Emptying the box**, by deleting the text or pressing the **x**, emits `search` with `""` straight away. Treat `""` as "show everything".
- **The field keeps its own text.** To clear it from code, for example when a filter is reset, call `clearSearch()` through a `ref`. That also emits `search` with `""`.
- It has no label and no bottom margin. Put it in a toolbar, or in a [DcFormGroup](#dcformgroup) with a label.
- Attributes that aren't props, such as `aria-label`, `disabled` or `autofocus`, are dropped.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | String | required | The input's id. |
| `placeholder` | String | `"Search..."` | The placeholder. |
| `icon_align` | String | `"right"` | Where the icon sits: `"left"` or `"right"`. |
| `class` | String | `""` | Classes for the `<input>`. Read once, when the field is created. |
| `containerClasses` | String | `""` | Classes for the wrapper `div`. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `search` | String | The search text, or `""` when the box was emptied. |

**Methods**

| Name | Description |
| --- | --- |
| `clearSearch()` | Empties the box and emits `search` with `""`. |
| `getSearchValue()` | Returns the current text, trimmed. |

---

## DcFormGroup

A wrapper that gives its content the same bottom margin as a field (`dcui-form-group`). The text fields above already have one. Use `DcFormGroup` around things that don't, such as a set of checkboxes, a radio group or a toggle, with a `dcui-fld-label` label on top.

```jsx
import { DcFormGroup, DcRadioGroup } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcFormGroup, DcRadioGroup },
    data() {
        return { delivery: "standard" };
    },
    template: `
    <dc-form-group>
        <label class="dcui-fld-label">Delivery</label>
        <dc-radio-group v-model="delivery" :options="[
            { label: 'Standard', value: 'standard' },
            { label: 'Express', value: 'express' },
        ]" :inline="true" />
    </dc-form-group>
    `,
};
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `class` | String | `""` | Extra classes for the wrapper. Read once, when it's created. |

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| default | The group's content. |

---

## DcCheckbox

One checkbox with its label. Bind `v-model` to a Boolean for a single yes/no box. To collect several boxes into one list, bind them all to the same array and give each a `value`: the array holds the `value` of every ticked box.

```jsx
import { DcCheckbox } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcCheckbox },
    data() {
        return { newsletter: false };
    },
    template: `
    <dc-checkbox id="myapp-newsletter" v-model="newsletter">Send me the monthly newsletter</dc-checkbox>
    `,
};
```

`modelValue` is declared as a String, but the box works with a Boolean or an array, as described above. The production build of Vue that the framework loads doesn't warn about the mismatch.

Every checkbox needs its own `id`, because the visible box is drawn by the label, which finds the input through that id. Attributes that aren't props, such as `disabled` or `title`, go on the input and on the wrapper. A disabled box is drawn greyed out.

<aside>
⚠️ A `@change` listener on `dc-checkbox` runs twice per click: once on the input and once on the wrapper. Watch the `v-model` value instead. The `class` prop lands on the hidden input, so it has no visible effect: wrap the checkbox in a `div` to space it. `no_label` adds a class that no stylesheet defines, so it changes nothing. For a box without text, such as in a table cell, leave the slot empty.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | String | required | The input's id. Must be unique on the screen. |
| `modelValue` | String | `""` | The state. Use `v-model` with a Boolean, or with an array together with `value`. |
| `value` | String | `""` | The value added to an array `v-model` when the box is ticked. |
| `no_label` | Boolean | `false` | Has no visible effect. See the note above. |
| `class` | String | `""` | Classes for the hidden input. No visible effect. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | Boolean, or the updated array | The box was ticked or unticked. Handled by `v-model`. |

**Slots**

| Name | Description |
| --- | --- |
| default | The label text. |

---

## DcCheckboxGroup

Lays checkboxes side by side, 40px apart, instead of one per line. It has no props and no `v-model`: bind each `DcCheckbox` to the same array.

```jsx
import { DcFormGroup, DcCheckboxGroup, DcCheckbox } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcFormGroup, DcCheckboxGroup, DcCheckbox },
    data() {
        return { days: ["mon", "wed"] };
    },
    template: `
    <dc-form-group>
        <label class="dcui-fld-label">Delivery days</label>
        <dc-checkbox-group>
            <dc-checkbox id="myapp-day-mon" v-model="days" value="mon">Monday</dc-checkbox>
            <dc-checkbox id="myapp-day-wed" v-model="days" value="wed">Wednesday</dc-checkbox>
            <dc-checkbox id="myapp-day-fri" v-model="days" value="fri">Friday</dc-checkbox>
        </dc-checkbox-group>
    </dc-form-group>
    `,
};
```

Here `days` holds the values of the ticked boxes, such as `["mon", "fri"]`. Without the group, the same checkboxes stack one per line.

**Props**

None.

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| default | The checkboxes. |

---

## DcRadioGroup

A set of radio buttons for picking one option. `v-model` holds the chosen option's `value`.

```jsx
import { DcRadioGroup } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcRadioGroup },
    data() {
        return {
            payment: "card",
            payment_options: [
                { label: "Card", value: "card" },
                { label: "Bank transfer", value: "bank" },
                { label: "Cash on delivery", value: "cod", disabled: true },
            ],
        };
    },
    template: `
    <dc-radio-group v-model="payment" :options="payment_options" />
    `,
};
```

Each option is an object `{ label, value, disabled }`, where `disabled` is optional. An option can also be a plain value, such as `"Small"`, which is then both its label and its value.

The buttons stack one per line; `inline` puts them side by side. Each group gets its own `name`, so two groups on one screen don't interfere. An option is shown as chosen only when its `value` is strictly equal to `v-model`, so `1` and `"1"` don't match. Keep the types the same.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | String, Number, Boolean | `null` | The chosen option's value. Use `v-model`. |
| `options` | Array | required | The options: `{ label, value, disabled }` objects, or plain values. |
| `inline` | Boolean | `false` | Puts the buttons side by side. |
| `disabled` | Boolean | `false` | Disables every option. |
| `name` | String | `""` | The radio inputs' `name`. Empty gives the group a unique name. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | the option's value | An option was chosen. Handled by `v-model`. |
| `change` | the option's value | An option was chosen. |

The admin-panel registry doesn't export `DcRadioGroup`.

---

## DcToggleSwitch

An on/off slider for a setting that takes effect on its own, such as a notification preference. `v-model` is a Boolean.

```jsx
import { DcToggleSwitch } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcToggleSwitch },
    data() {
        return { notify: true };
    },
    template: `
    <div class="dcui-flex-item dcui-align-center">
        <dc-toggle-switch id="myapp-notify-shipped" v-model="notify" />
        <label for="myapp-notify-shipped" class="dcui-m-l-10">Email me when an order ships</label>
    </div>
    `,
};
```

The switch has no text of its own. Put a `<label>` beside it with `for` set to the switch's `id`, as above, so clicking the text flips the switch too. Without an `id`, the switch makes one up, and you can't point a label at it. `mini` draws a smaller switch.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Boolean | `false` | Whether the switch is on. Use `v-model`. |
| `mini` | Boolean | `false` | A smaller switch. |
| `disabled` | Boolean | `false` | Stops the switch from changing. |
| `id` | String | `""` | The checkbox's id. Empty gives it a unique one. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | Boolean | The switch was flipped. Handled by `v-model`. |
| `change` | Boolean | The switch was flipped. Use it to save the setting straight away. |

The admin-panel registry doesn't export `DcToggleSwitch`.

---

## DcTagInput

A box for a list of short free-text tags. The user types a tag and presses Enter to add it. Each tag shows with a button that removes it. `v-model` is an array of strings.

```jsx
import { DcTagInput } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcTagInput },
    data() {
        return { tags: ["gift", "fragile"] };
    },
    template: `
    <dc-tag-input v-model="tags" placeholder="Add a tag and press Enter" />
    `,
};
```

Tags are trimmed, and empty ones are ignored. The same tag can be added twice.

<aside>
⚠️ `DcTagInput` reads `v-model` only when it's created. Changing the array from code afterwards doesn't change the tags on screen; to load or clear them, give the component a new `:key`. Its remove buttons have no `type`, so inside a `<form>` pressing one also submits the form: keep `DcTagInput` out of `<form>` elements. Its class names (`dcui-tags-container`, `dcui-tags-input`, `tags-list`) aren't defined by any framework stylesheet, so it appears as a plain browser input above a bulleted list of tags, each with an "X" button.

</aside>

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Array | `[]` | The tags. Use `v-model`. Read only when the component is created. |
| `placeholder` | String | `""` | The input's placeholder. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | Array of strings | A tag was added or removed. Handled by `v-model`. |

---

## A complete form

This screen creates a user account. It uses two text fields side by side, a password field, a radio group for the role, a toggle and a checkbox, and validates on save. Messages go in each field's `custom` slot, and the server's reply decides whether the form closes. `myapp_services` stands for your app's `services.js` (see [Frontend Runtime (XP)](../Frontend%20Runtime%20(XP).md)). `DcButton` is described in [Buttons And Links](./Buttons%20And%20Links.md).

```jsx
import {
    DcInputField, DcPasswordField, DcTextField, DcFormGroup,
    DcRadioGroup, DcToggleSwitch, DcCheckbox, DcButton,
} from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcInputField, DcPasswordField, DcTextField, DcFormGroup, DcRadioGroup, DcToggleSwitch, DcCheckbox, DcButton },
    data() {
        return {
            form: {
                name: "",
                email: "",
                password: "",
                role: "staff",
                send_welcome: true,
                notes: "",
                confirmed: false,
            },
            roles: [
                { label: "Staff", value: "staff" },
                { label: "Manager", value: "manager" },
            ],
            errors: {},
            saving: false,
            save_error: "",
        };
    },
    methods: {
        validate() {
            const errors = {};
            if (!this.form.name.trim()) errors.name = "Enter the user's name.";
            if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(this.form.email)) errors.email = "Enter an email address, like sam@example.com.";
            if (this.form.password.length < 8) errors.password = "Use at least 8 characters.";
            if (!this.form.confirmed) errors.confirmed = "Confirm that this person works for your company.";
            this.errors = errors;
            return Object.keys(errors).length === 0;
        },
        async save() {
            if (!this.validate()) return;
            this.saving = true;
            this.save_error = "";
            try {
                const data = new FormData();
                data.append("name", this.form.name.trim());
                data.append("email", this.form.email.trim());
                data.append("password", this.form.password);
                data.append("role", this.form.role);
                data.append("send_welcome", this.form.send_welcome ? "1" : "0");
                data.append("notes", this.form.notes);
                const res = await myapp_services.create_user(data);
                if (res.response.success) {
                    this.$emit("saved", res.data.user);
                } else {
                    this.save_error = res.response.statusMsg;
                }
            } catch (e) {
                this.save_error = "Couldn't create the user. Try again.";
            } finally {
                this.saving = false;
            }
        },
    },
    template: `
    <form @submit.prevent="save">
        <div class="dcui-row">
            <div class="dcui-col-md-6">
                <dc-input-field id="myapp-user-name" label="Name" v-model="form.name" autocomplete="name">
                    <template #label>Name <span class="dcui-f-l-required">*</span></template>
                    <template #custom>
                        <span v-if="errors.name" class="dcui-text-danger">{{ errors.name }}</span>
                    </template>
                </dc-input-field>
            </div>
            <div class="dcui-col-md-6">
                <dc-input-field id="myapp-user-email" label="Email" v-model="form.email"
                    icon="fa-regular fa-envelope" inputmode="email" autocomplete="email">
                    <template #label>Email <span class="dcui-f-l-required">*</span></template>
                    <template #custom>
                        <span v-if="errors.email" class="dcui-text-danger">{{ errors.email }}</span>
                    </template>
                </dc-input-field>
            </div>
        </div>

        <dc-password-field id="myapp-user-password" v-model="form.password" autocomplete="new-password">
            <template #label>Password <span class="dcui-f-l-required">*</span></template>
            <template #custom>
                <span :class="errors.password ? 'dcui-text-danger' : 'dcui-text-light'">
                    {{ errors.password || "At least 8 characters." }}
                </span>
            </template>
        </dc-password-field>

        <dc-form-group>
            <label class="dcui-fld-label">Role</label>
            <dc-radio-group v-model="form.role" :options="roles" :inline="true" />
        </dc-form-group>

        <dc-form-group>
            <div class="dcui-flex-item dcui-align-center">
                <dc-toggle-switch id="myapp-user-welcome" v-model="form.send_welcome" />
                <label for="myapp-user-welcome" class="dcui-m-l-10">Email the user a welcome message</label>
            </div>
        </dc-form-group>

        <dc-text-field id="myapp-user-notes" label="Notes" v-model="form.notes" :auto-resize="true">
            <template #label>Notes</template>
        </dc-text-field>

        <dc-form-group>
            <dc-checkbox id="myapp-user-confirmed" v-model="form.confirmed">This person works for our company</dc-checkbox>
            <div v-if="errors.confirmed" class="dcui-text-danger dcui-m-t-5">{{ errors.confirmed }}</div>
        </dc-form-group>

        <div class="dcui-flex-item dcui-justify-space-between dcui-align-center">
            <span class="dcui-text-danger">{{ save_error }}</span>
            <dc-button type="submit" :disabled="saving">Create user</dc-button>
        </div>
    </form>
    `,
};
```

How the parts work:

- **The `<form>`** lets Enter in any text box save, through `@submit.prevent`. `DcButton` is `type="button"` by default, so set `type="submit"` on the save button. Keep [DcTagInput](#dctaginput) out of a form like this one.
- **Validation messages** go in the `custom` slot of `DcInputField` and `DcPasswordField`, or under the field inside a `DcFormGroup`. Say what to enter, not only that the value is wrong.
- **Required fields** carry a `dcui-f-l-required` asterisk in their label.
- **Saving.** The button is disabled while the request runs, and a server error appears beside it. The form keeps everything the user typed, so they can fix it and try again.
- **The toggle** here is part of the form, so it's saved with the rest. For a setting that should save on its own, handle the switch's `change` event instead.
