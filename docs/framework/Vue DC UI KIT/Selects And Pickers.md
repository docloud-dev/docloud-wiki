---
title: Selects And Pickers
sidebar_label: Selects And Pickers
---

# Selects And Pickers

# Introduction

These components let the user choose a value from a list, a date or date range from a calendar, or an icon from a grid. They hold no data of their own: you pass the options in, bind the chosen value with `v-model`, and save it yourself.

| Component | Use it for |
| --- | --- |
| `DcSelect` | A native `<select>` in a form, with a label |
| `DcDropdown` | The kit's dropdown panel, with your own trigger and rows |
| `DcAutoComplete` | A text box that suggests values as the user types |
| `DcSearchDropdown` | A searchable dropdown, with keyboard support and server paging |
| `DcTagDropdown` | Choosing several options, shown as tags |
| `DcDatepicker` | The kit's calendar, for one date or a range |
| `DcNativeDatePicker` | The browser's own date input |
| `DcDateRangePicker` | A From and To pair of `DcDatepicker` fields |
| `DcCalendarRangePicker` | A From and To range in one calendar, with Apply and Cancel |
| `DcFontAwesomeIconPicker` | A popup grid of Font Awesome icons |

**Choosing a select.**

- Use `DcSelect` for a short, fixed list in a form, such as a country or a status. It's the browser's own `<select>`: no search, but it works with the keyboard and on phones like any form field.
- Use `DcSearchDropdown` for most other pickers: long lists, lists the user needs to search, and records loaded from the server one page at a time. Its `v-model` holds a plain value such as an id.
- Use `DcDropdown` when you need to draw the trigger or the rows yourself. It's the panel that `DcSearchDropdown` is built on. It has no search or keyboard support, and its `v-model` holds the whole option object.
- Use `DcAutoComplete` when the user may type a value that isn't in the list, and the list only offers suggestions. The value is the text in the box.
- Use `DcTagDropdown` to pick several options from a list. It has no styles of its own (see its entry). For free-form tags the user types, see `DcTagInput` in [Form Fields](./Form%20Fields.md).

**Choosing a date picker.**

- Use `DcNativeDatePicker` for a simple date field, especially on forms people fill in on phones. The browser draws the calendar, and the value is a `YYYY-MM-DD` string.
- Use `DcDatepicker` when you need the kit's own calendar: a consistent look across browsers, dates the user can't pick, or a range shown as two calendars side by side.
- Use `DcCalendarRangePicker` for a date range filter, such as "orders created between". The user picks both ends in one calendar and confirms with Apply, so your page reloads once, not twice. It has minimum and maximum dates and full keyboard support.
- `DcDateRangePicker` also gives a From and To pair, as two separate `DcDatepicker` fields that save as soon as either date is picked. It doesn't stop the To date being earlier than the From date. Prefer `DcCalendarRangePicker` for new screens.

Every example imports from the kit's registry. The path below is from a component in `apps/myapp/components/`:

```jsx
import { DcSelect } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Register each imported component in the `components` option before you use its tag. See [Vue DC UI KIT](./Vue%20DC%20UI%20KIT.md) for the setup.

---

## DcSelect

A labelled native `<select>` for a form. Each option is an object with a label to show and a value to store.

```jsx
import { DcSelect } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcSelect },
    data() {
        return {
            country: "",
            countries: [
                { label: "Sri Lanka", value: "LK" },
                { label: "India", value: "IN" },
                { label: "Maldives", value: "MV" },
            ],
        };
    },
    template: `
    <dc-select id="myapp-country" label="Country" v-model="country" :options="countries" placeholder="Choose a country">
        <template #label>Country</template>
    </dc-select>
    `,
};
```

The visible label comes from the `label` slot. The `label` prop is required but isn't shown anywhere, so pass the same text to both.

While the model is `""`, the select shows `placeholder`. The placeholder is a disabled option, so once the user has chosen a value they can't go back to empty. Add an option such as `{ label: "None", value: "" }` if empty is a valid answer.

Attributes the component doesn't declare, such as `disabled`, `required` or `name`, go on the `<select>` element itself.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | String | required | The `<select>` element's id. The label points at it. |
| `label` | String | required | Not displayed. Use the `label` slot for the visible label. |
| `modelValue` | String | `""` | The chosen option's value. Use `v-model`. |
| `options` | Array | `[]` | The options. |
| `labelKey` | String | `"label"` | The option field shown in the list. |
| `valueKey` | String | `"value"` | The option field stored in `v-model`. |
| `placeholder` | String | `""` | Shown while nothing is chosen. |
| `class` | String | `""` | Classes for the box around the `<select>`. Read once, when the component is created. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | The option's value | An option was chosen. Handled by `v-model`. |
| `change` | The native `change` event | An option was chosen. By the time it fires, `v-model` already holds the new value. |

**Slots**

| Name | Description |
| --- | --- |
| `label` | The field's label. |

<aside>
⚠️ Don't listen for `input` on `dc-select`. The component emits `input` without the chosen value. Use `v-model`, or `change` and read the bound value.

</aside>

---

## DcDropdown

The kit's dropdown: a trigger that you draw through the `label` slot, and a panel of options under it. Clicking the trigger opens the panel; clicking an option chooses it and closes the panel; clicking the chosen option again deselects it. Clicking anywhere outside closes it, and opening one dropdown closes any other.

```jsx
import { DcDropdown } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcDropdown },
    data() {
        return {
            priority: {},
            priorities: [
                { label: "High", value: "high" },
                { label: "Normal", value: "normal" },
                { label: "Low", value: "low" },
            ],
        };
    },
    template: `
    <dc-dropdown v-model="priority" :options="priorities" :color_selected="true">
        <template #label="{ selected_value }">
            {{ selected_value?.label || "Priority" }}
        </template>
    </dc-dropdown>
    `,
};
```

`v-model` holds the chosen option object, here `{ label: "High", value: "high" }`. Deselecting sets it to `null`, and the label slot's `selected_value` becomes `null` too, so give the slot a fallback. The chosen row shows an × that deselects it.

Each option may also have a `class` field. Its classes go on that row's link, for example `dcui-text-danger` on a "Cancelled" row.

### Your own rows

Set `use_options` to `false` and draw the rows in the `content` slot. The slot gets the options, a `select(option, index)` function to call when a row is clicked, and the index of the chosen row. Write each `<li>` yourself, with an `<a>` inside to pick up the kit's row styles.

```jsx
template: `
<dc-dropdown v-model="status" :options="statuses" :use_options="false" container_class="dcui-m-b-15">
    <template #label="{ selected_value }">
        {{ selected_value?.label || "Status" }}
    </template>
    <template #content="{ options, select, selected_index }">
        <li v-for="(option, index) in options" :key="option.value" :class="{ selected: selected_index === index }"
            @click="select(option, index)">
            <a :class="option.class">{{ option.label }}</a>
        </li>
    </template>
</dc-dropdown>
`,
```

The `action` slot sits at the top of the panel, above the rows. Use it for a search field, as `DcSearchDropdown` does. If you need search, use [DcSearchDropdown](#dcsearchdropdown) instead of building it.

A `class` set on `dc-dropdown` is not applied. Use `container_class`. The dropdown works with the mouse only: the trigger can take focus, but no key opens it.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Object | required | The chosen option. Use `v-model`. Start it as `{}`. |
| `options` | Array | `[]` | The options. |
| `labelKey` | String | `"label"` | The option field shown in the built-in rows. |
| `valueKey` | String | `""` | Stores this option field in `v-model` instead of the whole option. Only works with the `content` slot; see the note below. |
| `use_options` | Boolean | `true` | Draws the built-in rows. Set it to `false` when you use the `content` slot. |
| `align` | String | `"left"` | `right` lines the panel up with the trigger's right edge. |
| `arrow_tip` | Boolean | `false` | Adds a small arrow at the top of the panel. |
| `icon_only` | Boolean | `false` | Styles the trigger for an icon with no text. |
| `color_selected` | Boolean | `false` | Highlights the chosen row. |
| `disabled` | Boolean | `false` | The trigger no longer opens the panel. |
| `container_class` | String | `""` | Classes for the dropdown's outer element. |
| `panel_class` | String | `""` | Classes for the element around the rows, such as `scroll-container` for a long list. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | The option, or `null` | An option was chosen or deselected. Handled by `v-model`. |
| `change` | The option, or `null` | Same as above. |
| `cleared` | none | The chosen option was clicked again, or `clear_selected()` was called. |
| `blur` | The native `blur` event | The trigger lost focus. |

**Slots**

| Name | Scope | Description |
| --- | --- | --- |
| `label` | `selected_value` | The trigger's content. Without it the trigger is empty. |
| `action` | none | Content at the top of the panel. |
| `content` | `options`, `select`, `selected_index` | Your own rows. |

**Methods**

| Name | Description |
| --- | --- |
| `close_dropdown()` | Closes the panel. |
| `clear_selected()` | Deselects, sets the model to `null` and emits `cleared`. |

<aside>
⚠️ Start the model as `{}` or an option, never `null` or `undefined`: the dropdown reads it with `Object.keys` when it mounts, and `null` throws an error. A dropdown that is shown again with `v-if` after a deselect has `null` in its model, so reset it to `{}` first. With `valueKey` set and the built-in rows, clicking a row still puts the whole option in the model, and the chosen row loses its highlight. Use `valueKey` only with the `content` slot.

</aside>

---

## DcAutoComplete

A text box with a list of suggestions under it. The list shows the options whose label contains what the user has typed, ignoring case. The user can pick one, or keep typing something that isn't in the list.

```jsx
import { DcAutoComplete } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcAutoComplete },
    data() {
        return {
            city: "",
            cities: [
                { label: "Colombo", value: "Colombo" },
                { label: "Kandy", value: "Kandy" },
                { label: "Galle", value: "Galle" },
            ],
        };
    },
    template: `
    <dc-auto-complete id="myapp-city" v-model="city" :options="cities" placeholder="Type a city" :show_on_focus="true">
        <template #label>City</template>
    </dc-auto-complete>
    `,
};
```

Every keystroke updates `v-model` with the text in the box. Picking a suggestion sets the model to its `valueKey` field and emits `select` with the whole option. Enter closes the list and keeps the typed text. There's no arrow-key navigation through the suggestions.

The text box always shows the model. So after a pick, it shows the option's value, not its label. Give each option the same label and value, as above. To store an id, use [DcSearchDropdown](#dcsearchdropdown) instead.

Attributes the component doesn't declare, such as `name` or `maxlength`, go on the text box.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | String | required | The text box's id. |
| `modelValue` | String, Number | `""` | The text in the box. Use `v-model`. Use strings; see the note below. |
| `options` | Array | `[]` | The suggestions. |
| `labelKey` | String | `"label"` | The option field shown and searched. |
| `valueKey` | String | `"value"` | The option field put in the model when a suggestion is picked. |
| `placeholder` | String | `""` | The text box's placeholder. |
| `readonly` | Boolean | `false` | Makes the text box read-only. |
| `show_on_focus` | Boolean | `false` | Opens the list when the box takes focus, if any options match. Otherwise it opens once the user types. |
| `class` | String | `""` | Classes for the text box. Read once, when the component is created. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | String | The user typed, pressed Enter or picked a suggestion. Handled by `v-model`. |
| `select` | The option | A suggestion was picked. |
| `dropdown_open` | Boolean | The list opened or closed. Also fires once, with `false`, when the component is created. |

**Slots**

| Name | Description |
| --- | --- |
| `label` | The field's label. Left out when the slot isn't used. |

<aside>
⚠️ Keep the model a string. With a number in it, focusing the box with `show_on_focus` set throws an error instead of opening the list.

</aside>

---

## DcSearchDropdown

A dropdown with an optional search box, keyboard support, and an optional mode that loads options from the server one page at a time. It's built on [DcDropdown](#dcdropdown) and draws its own trigger, rows and empty message, so you only pass data.

```jsx
import { DcSearchDropdown } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcSearchDropdown },
    data() {
        return {
            warehouse_id: "",
            warehouses: [
                { id: 1, name: "Colombo", city: "Western Province" },
                { id: 2, name: "Kandy", city: "Central Province" },
            ],
        };
    },
    template: `
    <dc-search-dropdown v-model="warehouse_id" :options="warehouses" value-key="id" label-key="name"
        sub-key="city" :searchable="true" placeholder="Choose a warehouse" />
    `,
};
```

**The value.** With `valueKey` set, `v-model` holds that field of the chosen option, here the id. Without it, `v-model` holds the whole option. Ids are matched loosely, so a model of `"1"` selects the option with id `1`.

**Searching.** With `searchable`, the panel has a search box that filters the options as the user types. It matches the label, or the fields in `searchKeys`, ignoring case. The search box is cleared each time the panel opens.

**Keyboard.** When the trigger has focus, Enter, Space or the arrow keys open the panel. The arrow keys then move through the rows, Enter picks one, Escape closes the panel and Tab moves on.

**Deselecting.** The chosen row shows an × that deselects it. An option whose value is `""`, such as `{ name: "All warehouses", id: "" }`, can't be deselected. In a list passed through `options`, its label also shows while the model is `""`. Set `clearable` to `false` when there must always be a value, or name one more option that can't be deselected in `nonClearableValue`.

The panel opens below the trigger, or above it when it doesn't fit below and there's more room above, and stays inside the window. A `class` set on `dc-search-dropdown` is not applied: put the dropdown in a `div` with your classes.

### Loading options from the server

Pass a `fetcher` function and the dropdown loads its options itself, ignoring `options`. It calls `fetcher(page, search)` for page 1 when it mounts, and for the next page when the user scrolls near the bottom of the list. Searching calls it again for page 1, 250 ms after the user stops typing, with the search text. Return an array of rows. A page with fewer than `pageSize` rows is taken as the last.

When the model holds a value that isn't on a loaded page, for example a saved customer on page 9, the dropdown calls `fetchSelected(value)` to get that one row, so its label shows.

```jsx
import { DcSearchDropdown } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcSearchDropdown },
    data() {
        return { customer_id: "" };
    },
    methods: {
        async fetch_customers(page, search) {
            const res = await myapp_services.list_customers({ page, per_page: 50, search });
            if (!res.response.success) throw new Error(res.response.statusMsg);
            return res.data.customers;
        },
        async fetch_customer(id) {
            const res = await myapp_services.get_customer({ id });
            return res.response.success ? res.data.customer : null;
        },
    },
    template: `
    <dc-search-dropdown v-model="customer_id" :fetcher="fetch_customers" :fetch-selected="fetch_customer"
        :page-size="50" value-key="id" label-key="name" sub-key="email" :searchable="true"
        placeholder="Choose a customer" empty-text="No customers match." />
    `,
};
```

Ask the server for `pageSize` rows per page. If a fetch fails, paging stops and no error is shown; the list shows what it already has, or `emptyText`.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | any | `""` | The chosen option's `valueKey` field, or the whole option without `valueKey`. Use `v-model`. |
| `options` | Array | `[]` | The options. Ignored when `fetcher` is set. |
| `labelKey` | String | `"label"` | The option field shown in the rows and the trigger. |
| `valueKey` | String | `""` | The option field stored in `v-model`. |
| `subKey` | String | `""` | An option field shown as a second, muted line under the label, for options that have it. |
| `subInChip` | Boolean | `false` | Also shows the `subKey` line in the closed trigger. Needs `subKey`. |
| `avatarKey` | String | `""` | An option field holding a user's photo. Shows a round avatar before each row and in the trigger. The field can be a URL, or a user's image field with `thumbnail`, `medium` and `original` sizes. |
| `placeholder` | String | `"Select…"` | Shown in the trigger while nothing is chosen. |
| `emptyText` | String | `"No items."` | Shown when there are no options. Say why the list is empty when you know. |
| `labelClass` | String, Array, Object | `""` | Classes for the chosen label in the trigger. |
| `searchable` | Boolean | `false` | Adds the search box. |
| `searchKeys` | Array | `[]` | The option fields that search matches. Empty means `labelKey`. |
| `disabled` | Boolean | `false` | The trigger no longer opens the panel. |
| `flush` | Boolean | `false` | No border or fill on the trigger and search box, for a row that draws its own border. |
| `id` | String | `""` | Used for the search box's id. Empty gives each dropdown its own. |
| `createLabel` | String | `""` | Adds a row with this text, pinned to the bottom of the panel. Clicking it closes the panel and emits `create`. |
| `clearable` | Boolean | `true` | Whether the chosen option can be deselected. |
| `nonClearableValue` | any | `null` | The value of one option that can't be deselected. |
| `pinnedOption` | Object | `null` | Server mode only: an option always listed first while not searching, such as "All customers". |
| `fetcher` | Function | `null` | Server mode: called with `(page, search)`, returns an array of rows or a Promise of one. |
| `fetchSelected` | Function | `null` | Server mode: called with a value that isn't on a loaded page, returns its row or a Promise of it. |
| `pageSize` | Number | `50` | Server mode: rows per page. A shorter page ends paging. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | The value | An option was chosen or deselected. Handled by `v-model`. |
| `change` | The value, or `null` | Same as above. |
| `blur` | The native `blur` event | The trigger lost focus. |
| `create` | none | The `createLabel` row was clicked. Open your create form; when it saves, set `v-model` to the new record. |

<aside>
⚠️ `change` and `blur` run your handler twice for each selection, and deselecting leaves `null` in the model, not `""`. The component doesn't declare its events, so your listeners also attach to the `DcDropdown` inside it. Watch the bound value instead of handling `change`, and treat `null` and `""` the same way.

</aside>

The admin-panel registry doesn't export `DcSearchDropdown`.

---

## DcTagDropdown

Picks several options from a list. Clicking the box opens the list; clicking an option adds it or, if it's already chosen, removes it. The chosen options show as tags under the box, each with a button that removes it.

```jsx
import { DcTagDropdown } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcTagDropdown },
    data() {
        return {
            column_ids: [1],
            columns: [
                { id: 1, field_name: "Name" },
                { id: 2, field_name: "Email" },
                { id: 3, field_name: "Phone" },
            ],
        };
    },
    template: `
    <dc-tag-dropdown v-model="column_ids" :options="columns" placeholder="Choose columns" />
    `,
};
```

Options must use the fields `id` and `field_name`; there are no props to change them. `v-model` holds an array of the chosen `id`s.

Each click on an option also closes the list, so choosing three options takes three openings. Clicking outside doesn't close the list; clicking the box again does.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Array | `[]` | The chosen options' ids. Use `v-model`. |
| `options` | Array | `[]` | The options, as `{ id, field_name }`. |
| `placeholder` | String | `"Select options"` | Shown in the box. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | Array of ids | An option was added or removed. Handled by `v-model`. |

<aside>
⚠️ The framework has no styles for this component. The list, its rows and the tags render as plain, unstyled text, the list pushes the content under it down, and the remove button is a bare "X". Check it on your screen before you use it.

</aside>

---

## DcDatepicker

A read-only text field that opens the kit's calendar. It picks one date, or with `range`, a start and an end date on two calendars side by side. The header button switches the calendar to a month grid and then a year grid, for jumping far ahead or back. Clicking outside closes it.

```jsx
import { DcDatepicker } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcDatepicker },
    data() {
        return {
            due_date: "",
            // Dates before today can't be picked.
            no_past_dates: { from: null, to: new Date() },
        };
    },
    template: `
    <dc-datepicker v-model="due_date" :string-date="true" :show-clear-button="true"
        placeholder="Due date" :disabled-start-date="no_past_dates" />
    `,
};
```

**The value.** By default `v-model` gets a `Date` set to midnight, local time. With `string-date` it gets a `YYYY-MM-DD` string, which is usually what you send to the server, and the field shows that string as it is. With `range`, `v-model` is an array `[start, end]`, and the calendar stays open until both are picked. Start a range model as `[null, null]`.

**Display.** Without `string-date`, the field shows the date through `toLocaleDateString`, using `lang` and `dateFormat`. The defaults give "Oct 06, 2026". Month names follow `lang`; the weekday names over the grid are always English ("Mo", "Tu" and so on).

**Dates that can't be picked.** `disabledStartDate` and `disabledEndDate` take an object `{ from, to }` of `Date` objects, and the names read backwards: `from` is the **last** date that can be picked and `to` is the **first**. Either can be `null`. `{ from: new Date(), to: null }` blocks future dates; `{ from: null, to: new Date() }` blocks past ones.

- One date: `disabledStartDate` limits it.
- A range: `disabledEndDate` limits the end date. The start calendar blocks dates after the chosen end, and the end calendar blocks dates before the chosen start. Leave `disabledStartDate` unset (see the note below).

```jsx
template: `
<dc-datepicker v-model="stay" :range="true" range-seperator="to" position="right"
    :disabled-end-date="{ from: null, to: new Date() }" />
`,
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Date, String, Array | none | The chosen date, or `[start, end]` with `range`. Use `v-model`. |
| `range` | Boolean | `false` | Picks a start and an end date, on two calendars. |
| `stringDate` | Boolean | `false` | Emits `YYYY-MM-DD` strings instead of `Date` objects. See the note below. |
| `placeholder` | String | `"Select Date"` | Shown in the field while no date is chosen. |
| `disabled` | Boolean | `false` | Greys the field out and stops the calendar opening. |
| `showClearButton` | Boolean | `false` | Shows an × in the field that clears it: once a date is chosen, or always with `range`. |
| `disabledStartDate` | Object | `{ from: null, to: null }` | Limits the date (or a range's start): `from` is the last date allowed, `to` the first. |
| `disabledEndDate` | Object | `{ from: null, to: null }` | Limits a range's end date, the same way. |
| `position` | String | `"left"` | Where the calendar opens: `left`, `right`, `center`, `top` or `bottom`. |
| `lang` | String | `"en"` | The locale for the field's text and the month names. |
| `dateFormat` | Object | `{ day: '2-digit', month: 'short', year: 'numeric' }` | `toLocaleDateString` options for the field's text. Not used with `stringDate`. |
| `textFormat` | String | `"short"` | How month names are written in the calendar header: `short`, `long` or `narrow`. |
| `firstDayOfWeek` | String | `"monday"` | `monday` or `sunday`. |
| `rangeSeperator` | String | `"-"` | The text between the two dates in the field. The prop name is spelled this way. |
| `circle` | Boolean | `false` | Draws the chosen day as a circle. |
| `showPickerInital` | Boolean | `false` | Opens the calendar when the component mounts. The prop name is spelled this way. |
| `inputClass` | String | `""` | Classes for the text field. |
| `format` | String | `""` | Not used. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | The date, string or array | A date was picked or cleared. Also fires when the component mounts, and when the bound value changes. Handled by `v-model`. |
| `change` | The date, string or array | The chosen date changed. |
| `reset` | none | The clear button was pressed. |

<aside>
⚠️ Three combinations break the picker:

- **`range` with `string-date`.** The picker emits a new array each time it reads its value back, so it and the page keep updating each other and the page stops responding. Use `Date` values for a range, or use `DcCalendarRangePicker`.
- **`range` with `disabledStartDate.from` set.** Opening the calendar fails with an error until an end date is chosen, and after that nearly every start date is blocked. Use `disabledEndDate`, or `DcCalendarRangePicker` with `min-date` and `max-date`.
- **`string-date` on a computer whose time zone is behind UTC** (the Americas, for example). The picker reads a `YYYY-MM-DD` value as midnight UTC, which there is the evening before, so each time it reads the value back it moves a day earlier, without end. Use `Date` values, or `DcNativeDatePicker`, if your users may be in those time zones.

</aside>

The admin panel's copy doesn't fully honour `disabled`: clicking the calendar icon still opens the calendar, and the clear button still shows.

---

## DcNativeDatePicker

The browser's own date input, with an optional label. Its value is a `YYYY-MM-DD` string, and the browser draws the calendar, which opens as soon as the field takes focus. Use it for simple date fields; on phones it brings up the system's date wheel or calendar.

```jsx
import { DcNativeDatePicker } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcNativeDatePicker },
    data() {
        return { delivery_date: "" };
    },
    template: `
    <dc-native-date-picker id="myapp-delivery-date" v-model="delivery_date">
        <template #label>Delivery date</template>
    </dc-native-date-picker>
    `,
};
```

The browser shows the date in the user's own format, but `v-model` is always `YYYY-MM-DD`, or `""` when the field is empty. Start the model as `""`.

The component has no props for `min`, `max`, `disabled` or `required`, and attributes set on the tag land on the wrapper, not on the input. If you need those, use [DcDatepicker](#dcdatepicker).

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | String | required | The date as `YYYY-MM-DD`, or `""`. Use `v-model`. |
| `id` | String | `""` | The input's id. The label points at it. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | String | The date changed. Handled by `v-model`. |

**Slots**

| Name | Description |
| --- | --- |
| `label` | The field's label. Left out when the slot isn't used. |

---

## DcDateRangePicker

A From field and a To field, each a [DcDatepicker](#dcdatepicker), bound together as one `{ from, to }` value of `YYYY-MM-DD` strings. Each field opens its own calendar and has a clear button. The value updates as soon as either date is picked or cleared.

```jsx
import { DcDateRangePicker } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcDateRangePicker },
    data() {
        return {
            period: { from: "", to: "" },
            // Future dates can't be picked.
            no_future_dates: { from: new Date(), to: null },
        };
    },
    template: `
    <dc-date-range-picker v-model="period" label="Period" :disabled-start-date="no_future_dates" />
    `,
};
```

`disabledStartDate` is passed to both fields unchanged, and works as on `DcDatepicker`: `from` is the last date allowed and `to` the first. The To field doesn't block dates before the chosen From date, so check `from <= to` before you use the range. The fields show the dates as `YYYY-MM-DD`; the `format` prop has no effect.

For a filter bar, [DcCalendarRangePicker](#dccalendarrangepicker) is usually the better choice: one calendar for both ends, a range that can't run backwards, and one update when the user presses Apply.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Object | `{ from: '', to: '' }` | The range, as `YYYY-MM-DD` strings. Use `v-model`. |
| `label` | String | `""` | A label before the fields. Empty shows none. |
| `icon` | String | `"fa-regular fa-calendar"` | Font Awesome classes for an icon in the label. Shown only with `label`. |
| `fromPlaceholder` | String | `"From"` | The From field's placeholder. |
| `toPlaceholder` | String | `"To"` | The To field's placeholder. |
| `separator` | String | `"-"` | The text between the fields. |
| `disabledStartDate` | Object | `null` | Limits both fields: `{ from, to }`, where `from` is the last date allowed and `to` the first. |
| `format` | String | `"YYYY/MM/DD"` | Not used. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | `{ from, to }` | Either date changed. Handled by `v-model`. |
| `change` | `{ from, to }` | Same as above. |

This component uses `DcDatepicker` with `string-date`, so the time-zone problem in the note under [DcDatepicker](#dcdatepicker) applies to it too.

The admin-panel registry doesn't export `DcDateRangePicker`.

---

## DcCalendarRangePicker

A From and To pair that opens one calendar for the whole range. The user clicks a start day and an end day, sees the days in between highlighted and a count of the days, and presses **Apply**. **Cancel**, Escape or clicking outside leaves the value as it was. The value is `{ from, to }` as `YYYY-MM-DD` strings.

```jsx
import { DcCalendarRangePicker } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcCalendarRangePicker },
    data() {
        return {
            period: { from: "", to: "" },
            today: new Date(),
        };
    },
    methods: {
        load_orders() {
            // Fetch the orders created between this.period.from and this.period.to.
        },
    },
    template: `
    <dc-calendar-range-picker v-model="period" label="Created" :max-date="today"
        format="DD MMM YYYY" @change="load_orders" />
    `,
};
```

How it behaves:

- **Picking.** Clicking the From field starts with the start date, and clicking the To field with the end date. If the user picks an end date earlier than the start, the two are swapped. While choosing the end, hovering a day previews the range.
- **Applying.** `update:modelValue` and `change` fire only on Apply, and only when the range changed. Apply is available when both dates are set, or both are empty. A range with only one end can't be applied.
- **Clearing.** The × on a field opens the calendar with that date removed; the user then picks a new one or presses Apply. The **Clear** button in the calendar removes both, and Apply then saves an empty range.
- **Limits.** `min-date` and `max-date` take a `YYYY-MM-DD` string or a `Date`. Days outside them are disabled, and the calendar won't move to months outside them.
- **Keyboard.** The arrow keys move by a day or a week, Home and End go to the start and end of the week, Page Up and Page Down change the month, Enter or Space picks the focused day, and Escape cancels.
- **Display.** `format` sets how the fields show the dates, from the tokens `YYYY`, `YY`, `MMMM` (month name), `MMM` (short month name), `MM`, `M`, `DD` and `D`. Month and weekday names follow `locale`.

If `v-model` changes while the calendar is open, the calendar closes without applying and emits `cancel`. A value that isn't a valid `YYYY-MM-DD` string counts as empty.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | Object | `{ from: '', to: '' }` | The range, as `YYYY-MM-DD` strings. Use `v-model`. |
| `minDate` | String, Date | `null` | The first date that can be picked. |
| `maxDate` | String, Date | `null` | The last date that can be picked. |
| `label` | String | `""` | A label before the fields. Empty shows none. |
| `icon` | String | `"fa-regular fa-calendar"` | Font Awesome classes for an icon in the label. Shown only with `label`. |
| `format` | String | `"YYYY/MM/DD"` | How the fields show the dates. |
| `fromPlaceholder` | String | `"From"` | Shown in the From field while it's empty. |
| `toPlaceholder` | String | `"To"` | Shown in the To field while it's empty. |
| `separator` | String | `"-"` | The text between the fields. |
| `disabled` | Boolean | `false` | Disables the fields. Closes the calendar if it's open. |
| `firstDayOfWeek` | String | `"monday"` | `monday` or `sunday`. |
| `locale` | String | `"en"` | The locale for month and weekday names. |
| `disabledStartDate` | Object | `null` | The older way to set limits, kept for compatibility: `to` is the first date allowed and `from` the last. Prefer `minDate` and `maxDate`. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | `{ from, to }` | Apply was pressed and the range changed. Handled by `v-model`. |
| `change` | `{ from, to }` | Same as above. Reload your data here. |
| `apply` | `{ from, to }` | Apply was pressed, whether or not the range changed. |
| `cancel` | none | The calendar closed without applying. |

The admin-panel registry doesn't export `DcCalendarRangePicker`.

---

## DcFontAwesomeIconPicker

A popup with a searchable grid of Font Awesome 6 icons, for letting the user choose an icon for a category, a link or a tile. The component has no field or button of its own: add your own button and open the popup through a `ref`.

```jsx
import { DcFontAwesomeIconPicker, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcFontAwesomeIconPicker, DcButton },
    data() {
        return { icon: "fa-star" };
    },
    template: `
    <div class="dcui-flex-item dcui-align-center">
        <i class="dcui-m-r-10" :class="'fa-solid ' + icon"></i>
        <dc-button class="dcui-button-no-fill" @click="$refs.icon_picker.show()">Choose icon</dc-button>
    </div>
    <dc-font-awesome-icon-picker ref="icon_picker" v-model="icon" />
    `,
};
```

The value is the icon's name only, such as `fa-star`, with no style class. Add the style when you draw it, as above with `fa-solid`. Clicking an icon sets the value and closes the popup.

The grid shows the first 100 icons and adds more as the user scrolls. Typing in the search box filters all of them by name, for example "arrow". The search text is kept between openings. The popup doesn't mark the current icon. Its title reads "Chose Icon" and can't be changed.

The end of the list holds brand icons, such as `fa-github`. The picker draws every icon in the solid style, so brand icons show as empty buttons, and a chosen brand icon needs `fa-brands` instead of `fa-solid` to show.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `modelValue` | String | `""` | The chosen icon's name. Use `v-model`. |
| `return_name_only` | Boolean | `false` | Has no effect: the value is always the name only. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | String | An icon was clicked. Handled by `v-model`. |
| `change` | String | Same as above. |

**Methods**

| Name | Description |
| --- | --- |
| `show()` | Opens the popup. |
| `close_popup()` | Closes the popup. |

---

## A filter bar

A list screen often has a row of filters above its table: a status, a record picked from the server, and a date range. This one reloads the orders whenever any filter changes. `myapp_services` stands for your app's `services.js` (see [Frontend Runtime (XP)](../Frontend%20Runtime%20(XP).md)).

```jsx
import { DcSearchDropdown, DcCalendarRangePicker } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcSearchDropdown, DcCalendarRangePicker },
    data() {
        return {
            filters: { status: "", customer_id: "", period: { from: "", to: "" } },
            statuses: [
                { label: "All statuses", value: "" },
                { label: "Open", value: "open" },
                { label: "Shipped", value: "shipped" },
                { label: "Cancelled", value: "cancelled" },
            ],
            all_customers: { id: "", name: "All customers" },
            orders: [],
        };
    },
    watch: {
        // One reload per change, whichever filter changed.
        filters: {
            deep: true,
            handler() {
                this.load_orders();
            },
        },
    },
    methods: {
        async fetch_customers(page, search) {
            const res = await myapp_services.list_customers({ page, per_page: 50, search });
            if (!res.response.success) throw new Error(res.response.statusMsg);
            return res.data.customers;
        },
        async fetch_customer(id) {
            const res = await myapp_services.get_customer({ id });
            return res.response.success ? res.data.customer : null;
        },
        async load_orders() {
            const res = await myapp_services.list_orders({
                status: this.filters.status,
                // A deselected dropdown leaves null.
                customer_id: this.filters.customer_id ?? "",
                from: this.filters.period.from,
                to: this.filters.period.to,
            });
            if (res.response.success) {
                this.orders = res.data.orders;
            }
        },
    },
    mounted() {
        this.load_orders();
    },
    template: `
    <div class="dcui-flex-item dcui-align-center dcui-m-b-15">
        <div class="dcui-m-r-10">
            <dc-search-dropdown v-model="filters.status" :options="statuses" value-key="value" />
        </div>
        <div class="dcui-m-r-10">
            <dc-search-dropdown v-model="filters.customer_id" :fetcher="fetch_customers"
                :fetch-selected="fetch_customer" :pinned-option="all_customers"
                value-key="id" label-key="name" :searchable="true" placeholder="All customers" />
        </div>
        <dc-calendar-range-picker v-model="filters.period" label="Created" />
    </div>
    `,
};
```

- **Watch the values, not the events.** `DcSearchDropdown` runs `change` handlers twice, and `DcCalendarRangePicker` only updates its value on Apply, so one deep watcher on `filters` reloads once per real change.
- **"All" options.** The status list's `{ label: "All statuses", value: "" }` shows its label while the filter is empty and can't be deselected. For a server list, `pinned-option` keeps an "All customers" row at the top of the list. In server mode an empty value shows the placeholder, not the pinned option's label, so set `placeholder` to the same text.
- **Wrappers for spacing.** A class on `dc-search-dropdown` isn't applied, so each dropdown sits in a `div` that carries the margin.
