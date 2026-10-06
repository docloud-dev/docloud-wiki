---
title: Data Display
sidebar_label: Data Display
---

# Data Display

# Introduction

These components show records: tables, lists, cards, feeds and the states around them (paging, loading more, nothing to show). They only display data and raise events. Your app fetches the data, keeps it in the page's `data()` and passes it in.

| Component | Use it for |
| --- | --- |
| `DcTable` | Rows of records, with sorting and row selection |
| `DcPagination` | Page numbers under a table |
| `DcLoadMore` | Loading more items as a list or feed is scrolled |
| `DcCard` | A white content box |
| `DcCardPlain` | A card with a top bar (left and right) and a body |
| `DcInfoPanel` | A card with a top section and a two-column body |
| `DcPointList` | A vertical list with a dot per item |
| `DcBubbleAvatar` | A round profile photo |
| `DcEmptyState` | The "nothing here" message for a table, list or picker |
| `DcActivityFeed` | A record's history, newest first, with paging |
| `DcCommentFeed` | A record's comment thread, with the box to write one |

Every example imports from the kit's registry. The path below is from a component in `apps/myapp/components/`:

```jsx
import { DcTable } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Register each imported component in the `components` option before you use its tag. See [Vue DC UI KIT](./Vue%20DC%20UI%20KIT.md) for the setup.

---

## DcTable

A table of records. You supply the header row and render each row's cells yourself, through the `table-data` slot. It can sort the rows on screen and show a checkbox per row for bulk actions.

```jsx
import { DcTable } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcTable },
    data() {
        return {
            headers: [
                { label: "Name", key: "name", sort: true },
                { label: "Email", key: "email" },
            ],
            customers: [
                { id: 1, name: "Sam Perera", email: "sam@example.com" },
                { id: 2, name: "Alex Silva", email: "alex@example.com" },
            ],
        };
    },
    template: `
    <dc-table :headers="headers" :items="customers">
        <template #table-data="{ item }">
            <td>{{ item.name }}</td>
            <td>{{ item.email }}</td>
        </template>
    </dc-table>
    `,
};
```

Render one `<td>` per header, in the same order as `headers`. The table draws the `<tr>` and, when checkboxes are on, the checkbox cell.

### A complete table: selection, empty state and pages

This orders screen loads one page at a time from the server, lets the user tick orders and mark them as shipped, disables the checkbox of orders that already shipped, and shows an empty state when there are no orders. `myapp_services` stands for your app's `services.js` (see [Frontend Runtime (XP)](../Frontend%20Runtime%20(XP).md)).

```jsx
import { DcTable, DcPagination, DcButton, DcEmptyState } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcTable, DcPagination, DcButton, DcEmptyState },
    data() {
        return {
            headers: [
                { label: "Order", key: "number", sort: true },
                { label: "Customer", key: "customer", sort: true },
                { label: "Total", key: "total", sort: true },
                { label: "Status", key: "status" },
            ],
            orders: [],
            selected: [],
            page: 1,
            per_page: 20,
            total: 0,
            loading: false,
        };
    },
    computed: {
        total_pages() {
            return Math.ceil(this.total / this.per_page);
        },
        // Ids of orders that can't be ticked. Matched against unique_identifier_key.
        shipped_ids() {
            return this.orders.filter((order) => order.status === "Shipped").map((order) => order.id);
        },
    },
    methods: {
        async load_page(page) {
            this.loading = true;
            try {
                const res = await myapp_services.list_orders({ page, per_page: this.per_page });
                if (res.response.success) {
                    this.page = page;
                    this.orders = res.data.orders;
                    this.total = res.data.total;
                    // The table remembers ticks by row position, so clear them for the new rows.
                    this.$refs.table.clear_checkboxes();
                }
            } finally {
                this.loading = false;
            }
        },
        on_selected(items) {
            // An array of the ticked row objects, or "" when none are ticked.
            this.selected = items || [];
        },
        open_order(order) {
            // Go to the order's page.
        },
        async ship_selected() {
            const form = new FormData();
            this.selected.forEach((order) => form.append("ids[]", order.id));
            const res = await myapp_services.ship_orders(form);
            if (res.response.success) {
                this.load_page(this.page);
            }
        },
    },
    mounted() {
        this.load_page(1);
    },
    template: `
    <div class="dcui-flex-item dcui-justify-space-between dcui-align-center dcui-m-b-15">
        <span class="dcui-text-light">{{ selected.length }} selected</span>
        <dc-button :disabled="!selected.length" @click="ship_selected">Mark as shipped</dc-button>
    </div>
    <dc-table ref="table" :headers="headers" :items="orders"
        :show_checkbox="true" :show_check_all="true"
        unique_identifier_key="id" :hidden_checkbox_items="shipped_ids"
        disabled_checkbox_title="This order has already shipped."
        @selected_items="on_selected" @clicked_row="open_order">
        <template #table-data="{ item }">
            <td>{{ item.number }}</td>
            <td>{{ item.customer }}</td>
            <td>{{ item.total }}</td>
            <td><span :class="item.status === 'Shipped' ? 'dcui-text-success' : 'dcui-text-warning'">{{ item.status }}</span></td>
        </template>
        <template #custom-table-row>
            <tr v-if="!orders.length && !loading">
                <td colspan="4"><dc-empty-state>No orders yet. New orders appear here.</dc-empty-state></td>
            </tr>
        </template>
    </dc-table>
    <dc-pagination class="dcui-m-t-15" :current-page="page" :total-pages="total_pages"
        :total="total" :per-page="per_page" @pagechanged="load_page" />
    `,
};
```

How the parts work:

- **Selection.** `show_checkbox` adds a checkbox column, and `show_check_all` adds a select-all box to its header. The header box shows a dash when only some rows are ticked. Select-all skips disabled rows. The checkbox column is left out while `items` is empty, which is why the empty row above spans 4 columns, not 5.
- **Disabled rows.** `hidden_checkbox_items` lists values of the `unique_identifier_key` field. Those rows still show a checkbox, but it's disabled, and hovering it shows `disabled_checkbox_title`. Set a title, because a disabled box looks the same as an enabled one.
- **`selected_items`.** Fires each time the ticks change, and once when the table is created. The payload is an array of row objects, or an empty string `""` when nothing is ticked.
- **`clear_checkboxes()`.** Unticks every row. Call it through a `ref` after you replace the rows, and after a bulk action finishes.
- **`custom-table-row`.** Goes inside `<tbody>`, after the rows. Use it for an empty-state row, a totals row or a loading row. Write the `<tr>` yourself.
- **Clicking a row** emits `clicked_row` with the row object and its index. Clicks on the checkbox cell don't. Put `@click.stop` on any button inside a cell, or the click also opens the row.
- **Sorting.** A header with a truthy `sort` can be clicked to sort the rows on screen: strings ignoring case, numbers and `Date` objects by value. Rows with other value types (`null`, mixed types) keep their order. It sorts only the rows the table has, so with server paging it sorts the current page.

<aside>
⚠️ The table remembers ticks by row position, not by record. Replacing `items` keeps the ticks on the same positions, so they land on different records (or past the end, which puts `undefined` in `selected_items`). Sorting does the same: the ticks stay on the same lines while the rows move under them. Call `clear_checkboxes()` whenever the rows change. Checkbox ids are `tb-check-0`, `tb-check-1` and so on in every table, so with two selectable tables on one screen, clicking a box in the second can tick the first. Use one selectable table per screen.

</aside>

The first header with `sort` is marked as sorted ascending when the table loads, but the rows aren't sorted until a header is clicked. Pass the rows already sorted by that column, or the arrow is wrong. The first click on that header then sorts descending.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `headers` | Array | `[]` | The columns. Each entry is `{ label, key, sort }`: the header text, the row field to sort on, and whether the header sorts. |
| `items` | Array | `[]` | The rows. Replace the array to show new rows. |
| `class` | String | `""` | Classes for the `<table>` element. |
| `container_class` | String | `""` | Classes for the wrapper `div`, which scrolls sideways when the table is too wide. |
| `show_checkbox` | Boolean | `false` | Adds a checkbox to each row. |
| `show_check_all` | Boolean | `false` | Adds a select-all checkbox to the header. Needs `show_checkbox`. |
| `unique_identifier_key` | String | none | The row field that identifies a record, such as `id`. Used by `hidden_checkbox_items`. |
| `hidden_checkbox_items` | Array | `[]` | Values of `unique_identifier_key` whose checkbox is disabled. |
| `disabled_checkbox_title` | String | `""` | Hover text on a disabled checkbox, saying why it can't be ticked. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `clicked_row` | `item`, `index` | A row was clicked. |
| `selected_items` | Array or `""` | The ticked rows changed. Also fires once on creation. |

**Slots**

| Name | Scope | Description |
| --- | --- | --- |
| `table-data` | `item`, `index` | The cells of one row: one `<td>` per header. |
| `custom-table-row` | none | Extra rows at the end of `<tbody>`. |

**Methods**

| Name | Description |
| --- | --- |
| `clear_checkboxes()` | Unticks every row. |

---

## DcPagination

Page numbers for a table. It's the framework's `Pagination` component from `components/helpers.js`, exported under a kit name. The parent owns the current page: the component emits `pagechanged` and you pass the new page back as `current-page`.

```jsx
import { DcPagination } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcPagination },
    data() {
        return { page: 1, per_page: 10, total: 95 };
    },
    methods: {
        load_page(page) {
            // Fetch this page from the server, then:
            this.page = page;
        },
    },
    template: `
    <dc-pagination :current-page="page" :total-pages="Math.ceil(total / per_page)"
        :total="total" :per-page="per_page" @pagechanged="load_page" />
    `,
};
```

It shows first, previous, next and last buttons around a few page numbers, and disables the ones that don't apply. It hides itself when `total` isn't more than `per-page`. See [DcTable](#dctable) for a table that uses it.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `currentPage` | Number | required | The page being shown. |
| `totalPages` | Number | required | How many pages there are. |
| `total` | Number | required | How many records there are. |
| `perPage` | Number | required | Records per page. |
| `maxVisibleButtons` | Number | `3` | How many page numbers to show at once. |
| `darkmode` | Boolean | none | Dark styling. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `pagechanged` | page number | A page button was pressed. Load that page. |

<aside>
⚠️ Keep `maxVisibleButtons` at its default of 3. With a higher value, a short list on its last page shows page numbers of 0 or less (for example, 5 buttons and 2 pages shows -2 and -1), and pressing one emits that number.

</aside>

The admin-panel registry doesn't export `DcPagination`. In the admin panel, the same component is registered globally as `Pagination`.

---

## DcLoadMore

Loads more items as the user scrolls a list or feed. It watches a scroll container that you name by id. When the user reaches the bottom it emits `scroll-to-bottom`. Every second time, it shows a **Load More** button instead and waits for a click, so the user can reach whatever sits below the list. Use it for card lists and feeds; use [DcPagination](#dcpagination) for tables.

```jsx
import { DcLoadMore, DcCard } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcLoadMore, DcCard },
    data() {
        return { notes: [], loading: false, has_more: true };
    },
    methods: {
        async load_more() {
            if (this.loading || !this.has_more) return;
            this.loading = true;
            try {
                const res = await myapp_services.list_notes({ offset: this.notes.length, limit: 20 });
                if (res.response.success) {
                    this.notes = this.notes.concat(res.data.notes);
                    this.has_more = res.data.has_more;
                }
            } finally {
                this.loading = false;
            }
        },
    },
    mounted() {
        this.load_more();
    },
    template: `
    <div id="myapp-notes" class="scroll-container dcui-h-300">
        <dc-load-more scroll-container-id="myapp-notes" :has-more-items="has_more" :loading="loading"
            :empty="!notes.length && !loading" :show_check_new="false"
            @scroll-to-bottom="load_more" @load-more="load_more">
            <dc-card v-for="note in notes" :key="note.id" class="dcui-m-b-10">
                <div class="dcui-text-semibold">{{ note.title }}</div>
                <div class="dcui-text-light">{{ note.date }}</div>
            </dc-card>
        </dc-load-more>
    </div>
    `,
};
```

Handle both `scroll-to-bottom` and `load-more` with the same method, and guard it against running twice. When `has-more-items` turns false, the component shows a **Get Latest** button that emits `get-latest`. Set `show_check_new` to `false` if your list has no use for it.

The element with `scroll-container-id` must already be in the page when `DcLoadMore` mounts. Put `DcLoadMore` inside it, as above, so they render together.

While `loading` is true it shows a loader and a "Loading" label. Both use class names the framework's stylesheets don't define, so the label appears as plain text.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `scrollContainerId` | String | required | The id of the element that scrolls. |
| `hasMoreItems` | Boolean | `true` | Whether more items can be loaded. When false, scrolling stops emitting and the Get Latest button shows. |
| `loading` | Boolean | `false` | Shows the loader. |
| `empty` | Boolean | `false` | The list is empty: hides the buttons and loader and stops emitting. |
| `debounceTime` | Number | `200` | Milliseconds to wait after scrolling stops before checking the position. |
| `container_class` | String | `""` | Classes for the component's wrapper `div`. |
| `show_check_new` | Boolean | `true` | Shows the Get Latest button once `hasMoreItems` is false. |
| `load_more_btn_disabled` | Boolean | `false` | Never shows the Load More button: every time the user reaches the bottom, `scroll-to-bottom` fires. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `scroll-to-bottom` | none | The user scrolled to within 10px of the bottom. Load the next items. |
| `load-more` | none | The Load More button was pressed. Load the next items. |
| `get-latest` | none | The Get Latest button was pressed. Fetch items newer than the first one shown. |

**Slots**

| Name | Description |
| --- | --- |
| default | The list. |

**Methods**

| Name | Description |
| --- | --- |
| `resetLoadMore()` | Resets the count of times the bottom was reached. Call it when you reload the list from the start, for example after a filter changes. |

---

## DcCard

A white box for content. It has no props: put anything in its default slot. Classes you add land on the card, so spacing and width stay with the screen that uses it.

```jsx
import { DcCard } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcCard },
    template: `
    <dc-card class="dcui-m-b-15">
        <h3>Opening hours</h3>
        <p>Monday to Friday, 9 am to 5 pm.</p>
    </dc-card>
    `,
};
```

**Props**

None.

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| default | The card's content. |

---

## DcCardPlain

A `DcCard` with an optional top bar and a body. The top bar has a left and a right slot, for example a title on the left and actions on the right. It's only drawn when at least one of the two slots is used.

```jsx
import { DcCardPlain, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcCardPlain, DcButton },
    template: `
    <dc-card-plain>
        <template #top-left>
            <h3>Delivery address</h3>
        </template>
        <template #top-right>
            <dc-button class="dcui-button-no-fill">Edit</dc-button>
        </template>
        <template #middle>
            <p>12 Main Street, Colombo 03</p>
        </template>
    </dc-card-plain>
    `,
};
```

The component lives in the kit's `layouts/` folder. Import it from the registry like any other.

**Props**

None.

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| `top-left` | The left side of the top bar. |
| `top-right` | The right side of the top bar. |
| `middle` | The body. |

---

## DcInfoPanel

A `DcCard` laid out as a top section above two columns: a scrolling content column on the left and an action column on the right. Use it for a record's details with its actions beside them.

```jsx
import { DcInfoPanel, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcInfoPanel, DcButton },
    template: `
    <dc-info-panel :leftContainerWidth="70" :rightContainerWidth="30">
        <template #top-section>
            <h3>Order ORD-1042</h3>
        </template>
        <template #middle-left-section>
            <p>Customer: Sam Perera</p>
            <p>Total: 12,500.00</p>
        </template>
        <template #middle-right-action-section>
            <dc-button>Mark as shipped</dc-button>
        </template>
    </dc-info-panel>
    `,
};
```

The component lives in the kit's `panels/` folder. Import it from the registry like any other.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `leftContainerWidth` | Number | `60` | Width of the left column, in percent. |
| `rightContainerWidth` | Number | `40` | Width of the right column, in percent. |

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| `top-section` | The section above the columns. |
| `middle-left-section` | The left column. It scrolls. |
| `middle-right-action-section` | The right column, for actions. |

The admin panel's copy has no width props: its columns have fixed widths.

---

## DcPointList

A vertical list that marks each item with a dot, like a timeline. You render each item through the default slot. Its scope variable is called `list`, but it holds one item.

```jsx
import { DcPointList } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcPointList },
    data() {
        return {
            steps: [
                { id: 1, text: "Order placed" },
                { id: 2, text: "Payment received" },
            ],
            loading: false,
        };
    },
    template: `
    <dc-point-list :list="steps" :loading="loading">
        <template #default="{ list: step }">
            {{ step.text }}
        </template>
        <template #empty-list>
            No steps yet.
        </template>
    </dc-point-list>
    `,
};
```

The `empty-list` slot shows when `list` is empty and `loading` is false. Without it, the list says "No Items.".

The registry exports the `DcPointList` in the kit's top folder. Don't import `panels/DcPointList.js`: it's styled with classes the framework doesn't define.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `list` | Array | `[]` | The items. |
| `loading` | Boolean | `false` | Shows a loader over the list and hides the empty message. |

**Events**

None.

**Slots**

| Name | Scope | Description |
| --- | --- | --- |
| default | `list` (one item) | One item's content. |
| `empty-list` | none | Shown when there are no items. |

The admin-panel registry doesn't export `DcPointList`.

---

## DcBubbleAvatar

A round profile photo, 35px across. Without `avatar_image` it shows the framework's default user picture. If the image fails to load, it shows `placeholder_image`, or the default picture when that's empty too.

```jsx
import { DcBubbleAvatar } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcBubbleAvatar },
    data() {
        return { user: { name: "Sam Perera", photo: "/apps/myapp/assets/images/sam.jpg" } };
    },
    template: `
    <div class="dcui-flex-item dcui-align-center">
        <dc-bubble-avatar :avatar_image="user.photo" :alt="user.name" class="dcui-m-r-10" />
        {{ user.name }}
    </div>
    `,
};
```

Add the class `dcui-large` for a 40px avatar, or `dcui-xl` for 50px. Set `alt` to the person's name.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `avatar_image` | String | `""` | The photo's URL. Empty shows the default user picture. |
| `placeholder_image` | String | `""` | Shown if the photo fails to load. Empty falls back to the default user picture. |
| `alt` | String | `""` | The image's alternative text. |

**Events**

None.

---

## DcEmptyState

The message for a table, list, picker or tree with nothing to show: an info icon and your text, in muted grey. The text goes in the default slot. The component never hides itself, so show it with `v-if`.

```jsx
import { DcEmptyState } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcEmptyState },
    data() {
        return { locations: [], search: "" };
    },
    template: `
    <dc-empty-state v-if="!locations.length && !search">No locations yet. Add the first one with Add Location.</dc-empty-state>
    <dc-empty-state v-else-if="!locations.length" inline>No locations match your search.</dc-empty-state>
    `,
};
```

Say what will appear and how to add the first one. When a search or filter hides everything, say that instead of calling the list empty. Inside a table, put it in a full-width row in the `custom-table-row` slot (see [DcTable](#dctable)).

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `inline` | Boolean | `false` | A compact, left-aligned version for dropdowns and narrow lists. |

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| default | The message. |

The admin-panel registry doesn't export `DcEmptyState`.

---

## DcActivityFeed

A record's history as a dotted list, newest first, with paging. It shows the entries and asks for more; the app fetches them and formats the dates. When the user scrolls near the bottom, or presses **Load more**, it emits `load-more`. If the first page doesn't fill the box, it asks for the next one straight away.

```jsx
import { DcActivityFeed } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcActivityFeed },
    data() {
        return { activity: [], loading: false, has_more: true, error: "" };
    },
    methods: {
        async load_more() {
            this.loading = true;
            this.error = "";
            try {
                const res = await myapp_services.list_activity({ offset: this.activity.length, limit: 25 });
                if (!res.response.success) throw new Error(res.response.statusMsg);
                this.activity = this.activity.concat(res.data.activity);
                this.has_more = res.data.has_more;
            } catch (e) {
                this.error = "Couldn't load more activity.";
            } finally {
                this.loading = false;
            }
        },
    },
    template: `
    <dc-activity-feed :items="activity" :loading="loading" :has-more="has_more" :error="error"
        @load-more="load_more" />
    `,
};
```

By default each entry shows `author` in bold, then `message`, then `dateLabel`, from items shaped like this:

```json
{ "id": 1, "author": "Sam Perera", "message": "changed the status to Shipped.", "dateLabel": "2 hours ago", "datetime": "2026-10-01T09:05:00+05:30" }
```

`datetime` goes on the `<time>` element's `datetime` attribute. Use the `item` slot for anything else, such as bold values or links:

```jsx
template: `
<dc-activity-feed :items="activity" title="">
    <template #item="{ item }">
        <span class="dcui-text-semibold">{{ item.author }}</span> {{ item.action }}
        <time class="dcui-activity-feed__time dcui-text-light" :datetime="item.datetime" :title="item.dateTitle">{{ item.dateLabel }}</time>
    </template>
</dc-activity-feed>
`,
```

When `error` is set, the feed shows it and stops asking for more. If `has-more` is true it also shows a **Retry** button, which emits `load-more` again, so clear `error` at the start of your handler. An empty title hides the heading.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | Array | `[]` | The entries, newest first. |
| `title` | String | `"Activities"` | The heading. Empty hides it. |
| `loading` | Boolean | `false` | A page is loading. Shows `loadingText` and blocks `load-more`. |
| `hasMore` | Boolean | `false` | More entries can be loaded. |
| `error` | String | `""` | A failed load's message. Stops automatic loading. |
| `threshold` | Number | `64` | How close to the bottom, in pixels, a scroll asks for more. |
| `emptyText` | String | `"No activities yet."` | Shown when there are no entries. |
| `loadingText` | String | `"Loading activities..."` | Shown while loading. |
| `moreText` | String | `"Load more"` | The Load more button's label. |
| `retryText` | String | `"Retry"` | The Retry button's label. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `load-more` | none | Fetch the next page, append it to `items` and update `hasMore`. |

**Slots**

| Name | Scope | Description |
| --- | --- | --- |
| `item` | `item` | One entry's content. |
| `header` | none | Replaces the heading. |
| `empty` | none | Replaces the empty message. |
| `footer` | none | Below the scrolling area. |

The admin-panel registry doesn't export `DcActivityFeed`.

---

## DcCommentFeed

A record's comment thread: comments oldest to newest, with the box to write one at the bottom. Added in framework 0.0.42.

It only displays the thread and raises events. Your app:

- fetches the comments and formats their times;
- keeps the draft with `v-model`;
- posts a new comment when the feed emits `send`;
- fetches older comments when it emits `load-older`, and loads again when it emits `retry`.

Keep the draft in the page, not in the feed. When the feed sits in a [DcCollapsibleSidePanel](./Navigation%20And%20Layout.md), folding the panel removes the feed, and anything kept inside it would be lost.

```jsx
import { DcCommentFeed } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcCommentFeed },
    props: ["order_id"],
    data() {
        return {
            comments: [],
            draft: "",
            sending: false,
            send_error: "",
            loading: false,
            load_error: "",
            has_older: false,
            loading_older: false,
        };
    },
    methods: {
        async load_comments() {
            this.loading = true;
            this.load_error = "";
            try {
                const res = await myapp_services.list_comments({ order_id: this.order_id });
                if (!res.response.success) throw new Error(res.response.statusMsg);
                this.comments = res.data.comments;
                this.has_older = res.data.has_more;
            } catch (e) {
                this.load_error = "Couldn't load comments.";
            } finally {
                this.loading = false;
            }
        },
        async load_older() {
            this.loading_older = true;
            try {
                const res = await myapp_services.list_comments({ order_id: this.order_id, before: this.comments[0]?.id });
                if (res.response.success) {
                    // A new array, with the older page in front.
                    this.comments = res.data.comments.concat(this.comments);
                    this.has_older = res.data.has_more;
                } else {
                    this.has_older = false;
                }
            } catch (e) {
                this.has_older = false;
            } finally {
                this.loading_older = false;
            }
        },
        async send(text) {
            this.sending = true;
            this.send_error = "";
            try {
                const form = new FormData();
                form.append("order_id", this.order_id);
                form.append("text", text);
                const res = await myapp_services.add_comment(form);
                if (res.response.success) {
                    this.comments = this.comments.concat(res.data.comment);
                    this.draft = "";
                } else {
                    this.send_error = res.response.statusMsg;
                }
            } catch (e) {
                this.send_error = "Couldn't send your comment. Try again.";
            } finally {
                this.sending = false;
            }
        },
    },
    mounted() {
        this.load_comments();
    },
    template: `
    <dc-comment-feed :items="comments" v-model="draft"
        :sending="sending" :send-error="send_error"
        :loading="loading" :error="load_error"
        :has-older="has_older" :loading-older="loading_older"
        @send="send" @load-older="load_older" @retry="load_comments" />
    `,
};
```

Each comment is an object like this:

```json
{ "id": 7, "author": "Sam Perera", "avatar": "", "text": "Fabric arrived today.\nCutting starts tomorrow.", "dateLabel": "2 hours ago", "dateTitle": "2026-10-01 at 9:05 am", "datetime": "2026-10-01T09:05:00+05:30" }
```

`avatar` and `dateTitle` are optional. `dateTitle` is the hover text on the time (it falls back to `dateLabel`). The text is shown as plain text and keeps its line breaks, so don't pre-format it as HTML.

How it behaves:

- **Sending.** Enter sends; Shift+Enter starts a new line. Ctrl+Enter and Cmd+Enter also send. `send` carries the trimmed text and isn't raised for an empty draft. While `sending` is true the box is read-only and the button shows a spinner. Clear the `v-model` only once the server has saved the comment. If it fails, set `send-error` and the text stays in the box. The new comment appearing is the confirmation, so don't show a success notice.
- **Older comments.** When the user scrolls to the top while `has-older` is true, the feed emits `load-older`. Replace `items` with a new array that has the older page in front, and the feed keeps the reader's place. Any other change to `items` (first load, a new comment) scrolls to the newest comment.
- **Load errors.** Set `error` when loading fails. The feed shows the message and a **Retry** button, which emits `retry`, instead of "No comments yet.".

<aside>
⚠️ The feed asks for older comments again whenever it's at the top and `has-older` is true, including right after a page arrives that doesn't fill the box. If loading an older page fails, set `error` or set `has-older` to false. Otherwise it keeps sending requests.

</aside>

**Disabled and read-only.** Two props stop people from commenting, for different reasons:

- `readonly` hides the comment box. Use it for users who may never comment, for example users without the permission.
- `disabled` keeps the box on screen but disables it and the send button. Use it when the record's state blocks comments for now, and give the reason in `disabled-reason`, which shows under the box.

```jsx
template: `
<dc-comment-feed :items="comments" v-model="draft" :readonly="!can_comment"
    :disabled="order.status === 'Closed'"
    disabled-reason="This order is closed, so it can't take new comments." />
`,
```

A `send-error` message takes the place of the disabled reason while it's set.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | Array | `[]` | The comments, oldest first. Replace the array rather than changing it in place. |
| `modelValue` | String | `""` | The draft. Bind it with `v-model`. |
| `sending` | Boolean | `false` | A comment is being posted. Makes the box read-only and shows a spinner on the button. |
| `sendError` | String | `""` | Why the last send failed. Shown under the box. |
| `loading` | Boolean | `false` | The first load is running. Shows a loader. |
| `loadingOlder` | Boolean | `false` | An older page is loading. Shows `loadingOlderText` at the top. |
| `hasOlder` | Boolean | `false` | Older comments can be loaded. |
| `error` | String | `""` | Why loading failed. Shows the message and a Retry button. |
| `disabled` | Boolean | `false` | Disables the box and the send button. |
| `disabledReason` | String | `""` | Shown under the box while `disabled` is true. |
| `readonly` | Boolean | `false` | Hides the box. |
| `id` | String | random | The id of the text box. |
| `listLabel` | String | `"Comments"` | Accessible name of the comment list. |
| `inputLabel` | String | `"Comment"` | Accessible name of the text box. |
| `placeholder` | String | `"Write a comment"` | The text box's placeholder. |
| `emptyText` | String | `"No comments yet."` | Shown when there are no comments. |
| `loadingOlderText` | String | `"Loading older comments…"` | Shown while an older page loads. |
| `retryText` | String | `"Retry"` | The Retry button's label. |
| `sendLabel` | String | `"Send comment"` | The send button's accessible name and hover text. |

**Events**

| Name | Payload | Description |
| --- | --- | --- |
| `update:modelValue` | String | The draft changed. Handled by `v-model`. |
| `send` | text | Enter or the send button was pressed. Post the text; on success, add the saved comment to `items` and clear the draft; on failure, set `sendError`. |
| `load-older` | none | The user reached the top while `hasOlder` is true. Fetch the previous page and put it in front of `items`. |
| `retry` | none | Retry was pressed after a load error. Load the comments again and clear `error`. |

The admin-panel registry doesn't export `DcCommentFeed`.

---

## Comments and activity beside a record

A record's comments and history usually sit together in a panel beside it: a [DcCollapsibleSidePanel](./Navigation%20And%20Layout.md) holding a [DcTabs](./Navigation%20And%20Layout.md) pair, Comments | Activity. Wrap the tabs in a `div` with the class `dcui-activity-panel`. It stretches the tabs to the panel's full height, so each feed fills the open tab and scrolls inside it.

```jsx
template: `
<dc-collapsible-side-panel v-model:collapsed="panel_collapsed" title="Comments and Activity" :expand-below="900">
    <div class="dcui-activity-panel">
        <dc-tabs :tabs="tabs" v-model="tab" model_key="key">
            <template #comments>
                <dc-comment-feed :items="comments" v-model="draft" :sending="sending" :send-error="send_error"
                    :has-older="has_older" :loading-older="loading_older"
                    @send="send" @load-older="load_older" />
            </template>
            <template #activity>
                <dc-activity-feed :items="activity" title="" :loading="loading_activity"
                    :has-more="has_more_activity" @load-more="load_activity" />
            </template>
        </dc-tabs>
    </div>
</dc-collapsible-side-panel>
`,
```

Here `tabs` is `[{ name: "Comments", key: "comments" }, { name: "Activity", key: "activity" }]` and `tab` starts as `"comments"`, so Comments opens first.

- Keep the comments, the activity, the draft and the open tab in the page's `data()`. The side panel removes its content when folded.
- Comments run oldest to newest with the box at the bottom, and load older pages from the top. Activity runs newest first and loads more from the bottom.
- Reload the activity after any change to the record.
