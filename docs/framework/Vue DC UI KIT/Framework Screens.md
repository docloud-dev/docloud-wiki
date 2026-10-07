---
title: Framework Screens
sidebar_label: Framework Screens
---

# Framework Screens

# Introduction

These components are the building blocks of the framework's own standalone screens. The admin panel's Get Started wizard (setup type, the self system check, the API and database steps, "Ready for action") is built from `DcConfLogo`, `DcConfCard`, `DcConfTimeline`, `DcConfCheckList` and `DcConfFooter`. The sign-in, forgot password, create password and welcome screens use `DcConfCard` and `DcAuthFooter`.

They are not page chrome for an ordinary app screen. Reach for them when your app needs a focused, centred screen of its own outside the usual list-and-form layout: a first-run setup wizard, a requirements or connection check before the app starts, or a short onboarding flow. `DcConfCard`, `DcConfTimeline`, `DcConfCheckList` and `DcConfCheckListItem` carry no branding and suit any app. The logos and footers show DoCloud's branding and links, so use them only on screens that should look like part of the framework, and put your own logo and footer on your app's screens.

| Component | Use it for |
| --- | --- |
| `DcConfLogo` | The DoCloud logo with the "Framework" wordmark |
| `DcConfDevLogo` | The DoCloud logo with the "Developer" wordmark |
| `DcConfFooter` | The copyright line and privacy link under a setup screen |
| `DcConfCard` | The white body box of a setup or sign-in screen |
| `DcConfTimeline` | A row of numbered steps for a wizard |
| `DcConfCheckList` | A list of checks, such as system requirements |
| `DcConfCheckListItem` | One check, with a pending, running, passed or failed indicator |
| `DcConfNeedSupport` | A "Need Support? Contact us" line |
| `DcDoCloudLogo` | The DoCloud logo on its own |
| `DcAuthFooter` | The "Powered by DoCloud." line under a sign-in screen |

Every example imports from the kit's registry. The path below is from a component in `apps/myapp/components/`:

```jsx
import { DcConfCard } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
```

Register each imported component in the `components` option before you use its tag. See [Vue DC UI KIT](./Vue%20DC%20UI%20KIT.md) for the setup.

### The screen layout

The styles for these components only apply inside a wrapper, so build the screen the way the framework does:

- An outer `div` with the class `dc-conf-panel`. It's a centred column 480px wide. Add `dc-cp-large` for 700px, as the wizard does, or `dc-auth-panel` for the roomier sign-in look.
- A header `div` with the class `dc-cp-header` around the logo. Without it, the logo images aren't sized.
- A `DcConfCard` for the body, then a footer.

Inside the card, these classes give the framework's heading style: `dc-cp-b-header` for the heading row, `dc-cp-b-h-title` on its `h2`, `dc-cp-b-sub-heading` on a step's `h3`, and `dc-cp-b-corner-link` for a link pinned to the card's top right corner. A [DcBoxIcon](./Buttons%20And%20Links.md) in the heading row draws the square icon beside the title.

The admin panel's registry exports all ten components, and its copies are the same as the main ones.

---

## DcConfLogo

The DoCloud logo (dark) followed by the "Framework" wordmark. The admin panel's Get Started screens show it above the card.

```jsx
import { DcConfLogo } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcConfLogo },
    template: `
    <div class="dc-cp-header dcui-flex-item dcui-justify-center dcui-m-b-20">
        <dc-conf-logo></dc-conf-logo>
    </div>
    `,
};
```

The component renders two sibling elements, the logo and the wordmark, so a flex header lays them out side by side. With two root elements, a `class` set on the tag isn't applied. Put spacing on the header instead. The images load from `/assets/images/` at the site root.

**Props**

None.

**Events**

None.

---

## DcConfDevLogo

The DoCloud logo (in colour) followed by the "Developer" wordmark. Use it the same way as `DcConfLogo`, inside a `dc-cp-header`. The framework doesn't use it on any of its own screens at 0.0.44.

```jsx
import { DcConfDevLogo } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcConfDevLogo },
    template: `
    <div class="dc-cp-header dcui-flex-item dcui-justify-center dcui-m-b-20">
        <dc-conf-dev-logo></dc-conf-dev-logo>
    </div>
    `,
};
```

Like `DcConfLogo`, it renders two root elements, so a `class` on the tag isn't applied.

**Props**

None.

**Events**

None.

---

## DcConfFooter

A centred line under the card: "© (current year) DoCloud. All rights reserved" and a Privacy Policy link to DoMedia's privacy policy, which opens in a new tab. The Get Started screens end with it.

```jsx
import { DcConfCard, DcConfFooter } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcConfCard, DcConfFooter },
    template: `
    <div class="dc-conf-panel">
        <dc-conf-card>Step content</dc-conf-card>
        <dc-conf-footer></dc-conf-footer>
    </div>
    `,
};
```

The year comes from the framework's global `moment`. The text and link are fixed.

**Props**

None.

**Events**

None.

---

## DcConfCard

The white box that holds a setup or sign-in screen's content: a border, rounded corners and 30px of padding (45px inside `dc-auth-panel`). It's positioned, so a `dc-cp-b-corner-link` inside it sits in its top right corner. Every Get Started and sign-in screen puts its content in one.

```jsx
import { DcConfCard, DcBoxIcon, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcConfCard, DcBoxIcon, DcButton },
    template: `
    <div class="dc-conf-panel">
        <dc-conf-card>
            <div class="dc-cp-b-header dcui-flex-item dcui-align-center">
                <dc-box-icon icon="fa-regular fa-store" class="dcui-m-r-20"></dc-box-icon>
                <h2 class="dc-cp-b-h-title">Set up your shop</h2>
            </div>
            <p>We'll ask for your shop's name, currency and opening hours. It takes about two minutes.</p>
            <dc-button class="dcui-full-width dcui-large dcui-m-t-20" @click="start">Get started</dc-button>
        </dc-conf-card>
    </div>
    `,
    methods: {
        start() {
            // Go to the first step.
        },
    },
};
```

The card's styles only apply inside a `dc-conf-panel`. Elsewhere it's an unstyled `div`; use [DcCard](./Data%20Display.md#dccard) for a card on an ordinary screen.

**Props**

None.

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| default | The card's content. |

---

## DcConfTimeline

A row of steps for a wizard, each a round icon with a label underneath, joined by a line. Steps before the current one are filled in, the current one has a thick border, and later ones are plain. The admin panel's setup steps (API, Database, Logs, Finish) use it at the top of the card.

```jsx
import { DcConfCard, DcConfTimeline } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcConfCard, DcConfTimeline },
    data() {
        return {
            step: 0,
            steps: [
                { icon: "fa-solid fa-store", label: "Shop" },
                { icon: "fa-solid fa-coins", label: "Currency" },
                { icon: "fa-solid fa-clock", label: "Hours" },
                { icon: "fa-solid fa-flag", label: "Finish" },
            ],
        };
    },
    template: `
    <div class="dc-conf-panel dc-cp-large">
        <dc-conf-card>
            <dc-conf-timeline :data="steps" :step="step"></dc-conf-timeline>
            <div v-if="step === 0">Shop details form</div>
            <div v-else-if="step === 1">Currency form</div>
        </dc-conf-card>
    </div>
    `,
};
```

The timeline only shows progress. It has no events and the steps can't be clicked, so move between steps with your own buttons by changing `step`. The connecting line is only drawn inside a `dc-conf-panel`.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | Array | `[]` | One object per step: `icon` (Font Awesome classes, such as `fa-solid fa-flag`) and `label`. |
| `step` | Number | `0` | The index of the current step, from 0. |
| `class` | String | `""` | Extra classes for the row, such as a margin. Read once, when the component mounts. |

**Events**

None.

---

## DcConfCheckList

A container for `DcConfCheckListItem` rows. It adds the class that gives each row its bottom border and padding. The admin panel's Self System Check lists the server requirements in one.

```jsx
import { DcConfCheckList, DcConfCheckListItem } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcConfCheckList, DcConfCheckListItem },
    data() {
        return { checking: false, mail_ok: false };
    },
    template: `
    <dc-conf-check-list>
        <dc-conf-check-list-item :loading="checking" :success="mail_ok">
            <template #label>Mail server</template>
        </dc-conf-check-list-item>
    </dc-conf-check-list>
    `,
};
```

See [DcConfCheckListItem](#dcconfchecklistitem) for a complete check.

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `class` | String | `""` | Extra classes for the list. Read once, when the component mounts. |

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| default | The `DcConfCheckListItem` rows. |

---

## DcConfCheckListItem

One row of a check list: a label, an optional description after it in a lighter colour, and a status indicator at the right. The indicator shows three dots until the first check starts, a spinner while `loading` is true, and then a green tick or a red cross depending on `success`.

```jsx
import { DcConfCard, DcConfCheckList, DcConfCheckListItem, DcButton } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcConfCard, DcConfCheckList, DcConfCheckListItem, DcButton },
    data() {
        return {
            checking: false,
            checks: [
                { key: "database", label: "Database", description: "", success: false },
                { key: "storage", label: "File storage", description: "", success: false },
                { key: "mail", label: "Mail server", description: "", success: false },
            ],
        };
    },
    methods: {
        async run_checks() {
            this.checking = true;
            try {
                const res = await myapp_services.check_requirements();
                // For example { database: { success: true, message: "" }, mail: { success: false, message: "Not configured" } }
                const results = res.data.results || {};
                this.checks.forEach((check) => {
                    const result = results[check.key] || {};
                    check.success = !!result.success;
                    check.description = result.message || "";
                });
            } finally {
                this.checking = false;
            }
        },
    },
    template: `
    <div class="dc-conf-panel dc-cp-large">
        <dc-conf-card>
            <dc-conf-check-list>
                <dc-conf-check-list-item v-for="check in checks" :key="check.key"
                    :loading="checking" :success="check.success">
                    <template #label>{{ check.label }}</template>
                    <template #description>
                        <span v-if="check.description"> - {{ check.description }}</span>
                    </template>
                </dc-conf-check-list-item>
            </dc-conf-check-list>
            <dc-button class="dcui-full-width dcui-large dcui-m-t-30" :disabled="checking" @click="run_checks">Run checks</dc-button>
        </dc-conf-card>
    </div>
    `,
};
```

The description slot sits right after the label on the same line, so add your own separator, as the example does with " - ".

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `loading` | Boolean | `false` | Shows the spinner. The first change to `true` also ends the initial three-dot state. |
| `success` | Boolean | `false` | Once a check has run and `loading` is `false`, `true` shows a tick and `false` a cross. |
| `class` | String | `""` | Extra classes for the row. Read once, when the component mounts. |
| `label` | String | `""` | Declared but not shown. Use the `label` slot. |
| `description` | String | `""` | Declared but not shown. Use the `description` slot. |

**Events**

None.

**Slots**

| Name | Description |
| --- | --- |
| `label` | The check's name. |
| `description` | Text after the name, in a lighter colour. |

<aside>
⚠️ The `label` and `description` props do nothing: a row built with props alone is empty. Use the slots. The row leaves its three-dot state only when `loading` changes from `false` to `true` after it has mounted. A row that mounts while `loading` is already `true`, or whose `success` is set without `loading` ever turning on, keeps showing the dots. Render the rows first, then set `loading` to start the check. Once a row has left the three-dot state it never goes back to it.

</aside>

---

## DcConfNeedSupport

A centred "Need Support? Contact us" line, meant to sit under a setup card. The framework doesn't use it on any of its own screens at 0.0.44.

```jsx
import { DcConfNeedSupport } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcConfNeedSupport },
    template: `<dc-conf-need-support></dc-conf-need-support>`,
};
```

**Props**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `class` | String | `""` | Declared but not used. Classes you pass aren't applied. |

**Events**

None.

<aside>
⚠️ "Contact us" has no link target at 0.0.44: the component reads a contact address it never defines, so the text renders as an anchor without an `href` and clicking it does nothing. Write your own support line with a [DcLink](./Buttons%20And%20Links.md) until this is fixed.

</aside>

---

## DcDoCloudLogo

The DoCloud logo in colour, without a wordmark, in a `dc-cp-h-logo` block. Put it inside a `dc-cp-header` so the image is sized.

```jsx
import { DcDoCloudLogo } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcDoCloudLogo },
    template: `
    <div class="dc-cp-header dcui-flex-item dcui-justify-center dcui-m-b-20">
        <dc-do-cloud-logo></dc-do-cloud-logo>
    </div>
    `,
};
```

The framework's sign-in and welcome screens used to show it. At 0.0.44 they show the system logo set in the admin panel instead, and the tag is commented out.

**Props**

None.

**Events**

None.

---

## DcAuthFooter

A centred "Powered by DoCloud." line with the small DoCloud icon. The sign-in and welcome screens end with it, under the card.

```jsx
import { DcConfCard, DcAuthFooter } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";

export default {
    components: { DcConfCard, DcAuthFooter },
    template: `
    <div class="dc-conf-panel dc-auth-panel">
        <dc-conf-card>Sign-in form</dc-conf-card>
        <dc-auth-footer></dc-auth-footer>
    </div>
    `,
};
```

**Props**

None.

**Events**

None.

---

## A setup wizard for an app

This first-run wizard for a shop app has three steps: shop details, a check of the services the app needs, and a finish screen. It uses the framework's layout classes, so it looks like the admin panel's own Get Started screens, but it carries no DoCloud branding. `myapp_services` stands for your app's `services.js` (see [Frontend Runtime (XP)](../Frontend%20Runtime%20(XP).md)).

```jsx
import { DcConfCard, DcConfTimeline, DcConfCheckList, DcConfCheckListItem, DcBoxIcon, DcButton, DcInputField } from "../../xp_system/components/dc_ui_kit_componenets/dc_ui_kit_registry.js";
import { myapp_services } from "../services.js";

export default {
    components: { DcConfCard, DcConfTimeline, DcConfCheckList, DcConfCheckListItem, DcBoxIcon, DcButton, DcInputField },
    data() {
        return {
            step: 0,
            steps: [
                { icon: "fa-solid fa-store", label: "Shop" },
                { icon: "fa-solid fa-list-check", label: "Checks" },
                { icon: "fa-solid fa-flag", label: "Finish" },
            ],
            shop_name: "",
            checking: false,
            checks_passed: false,
            checks: [
                { key: "database", label: "Database", success: false },
                { key: "mail", label: "Mail server", success: false },
            ],
        };
    },
    methods: {
        async run_checks() {
            this.checking = true;
            try {
                const res = await myapp_services.check_requirements();
                const results = res.data.results || {};
                this.checks.forEach((check) => {
                    check.success = !!(results[check.key] && results[check.key].success);
                });
                this.checks_passed = this.checks.every((check) => check.success);
            } finally {
                this.checking = false;
            }
        },
        async finish() {
            const form = new FormData();
            form.append("shop_name", this.shop_name);
            const res = await myapp_services.save_setup(form);
            if (res.response.success) {
                this.$router.push({ name: "myapp_dashboard" });
            }
        },
    },
    template: `
    <div class="dc-conf-panel dc-cp-large">
        <div class="dc-cp-header dcui-flex-item dcui-justify-center dcui-m-b-20">
            <h2>My Shop</h2>
        </div>
        <dc-conf-card>
            <div class="dc-cp-b-header dcui-flex-item dcui-align-center">
                <dc-box-icon icon="fa-regular fa-store" class="dcui-m-r-20"></dc-box-icon>
                <h2 class="dc-cp-b-h-title">Set up your shop</h2>
            </div>
            <dc-conf-timeline :data="steps" :step="step" class="dcui-m-t-30"></dc-conf-timeline>

            <div v-if="step === 0">
                <h3 class="dc-cp-b-sub-heading dcui-m-t-30">Shop details</h3>
                <dc-input-field v-model="shop_name" placeholder="Shop name">
                    <template #label>Shop name</template>
                </dc-input-field>
                <dc-button class="dcui-full-width dcui-large" :disabled="!shop_name" @click="step = 1">Next</dc-button>
            </div>

            <div v-else-if="step === 1">
                <h3 class="dc-cp-b-sub-heading dcui-m-t-30">Checking your server</h3>
                <dc-conf-check-list>
                    <dc-conf-check-list-item v-for="check in checks" :key="check.key"
                        :loading="checking" :success="check.success">
                        <template #label>{{ check.label }}</template>
                    </dc-conf-check-list-item>
                </dc-conf-check-list>
                <dc-button v-if="!checks_passed" class="dcui-full-width dcui-large dcui-m-t-30" :disabled="checking" @click="run_checks">Run checks</dc-button>
                <dc-button v-else class="dcui-full-width dcui-large dcui-m-t-30" @click="step = 2">Next</dc-button>
            </div>

            <div v-else>
                <h3 class="dc-cp-b-sub-heading dcui-m-t-30">All set</h3>
                <p>Your shop is ready to use.</p>
                <dc-button class="dcui-full-width dcui-large" @click="finish">Open my shop</dc-button>
            </div>
        </dc-conf-card>
    </div>
    `,
};
```

- Keep the current step and every step's answers in the page's `data()`, so going back keeps what the user typed.
- The check list rows mount when step 1 opens, before `checking` turns on, so their indicators move from the dots to the spinner and then to a tick or a cross.
- Run the wizard from a route of its own, and send the user there only until the setup is saved.
