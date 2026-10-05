---
title: Localization
sidebar_label: Localization
---

# Localization

Owner: Nuwan Danushka

# Introduction

Each frontend app keeps its translations in one file, `apps/<app>/languages/lang.json`. The current language is the value of the `language` cookie, or `EN` when there is no cookie.

On every page load, `index.php` reads the current language's strings from every app's `lang.json` and stores them in local storage under `XP_LANGUAGE`, keyed by app folder name. Your components read their strings from there with `XP.getLanguageJSON()` or `XP.getLocale()`.

The admin panel works the same way, with its own copy: admin pages keep their file in `api/admin/apps/<app>/languages/lang.json`.

---

# How to add languages to your app

1. In your frontend app folder, create a folder named `languages`.
2. In it, create `lang.json`.
3. Add one top-level key per language, each holding the app's strings:

```json
{
  "EN": {
    "add_news": "Add News",
    "author": "Author",
    "back_to_news_list": "Back to News List",
    "cancel_delete": "Cancel",
    "confirm_delete": "Confirm Delete",
    "delete_news_message": "Are you sure you want to delete this news permanently? This action cannot be reversed.",
    "delete_news": "Delete News",
    "edit_news": "Edit News"
  },
  "DE": {
    "add_news": "Neuigkeiten hinzufügen",
    "author": "Autor",
    "back_to_news_list": "Zurück zur Nachrichtenliste",
    "cancel_delete": "Abbrechen",
    "confirm_delete": "Löschen bestätigen",
    "delete_news_message": "Sind Sie sicher, dass Sie diese Nachricht dauerhaft löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.",
    "delete_news": "Nachrichten löschen",
    "edit_news": "Nachrichten bearbeiten"
  }
}
```

- The top-level keys (`EN`, `DE`) are language codes. They must match the cookie value exactly, including case. With no cookie the framework loads `EN`, so a lowercase `en` key is never loaded by default.
- Under each language, the key is the string's ID and the value is the translation.
- An app with no entry for the current language gets no strings. Keep the same IDs in every language.

<aside>
⚠️ Don't put an apostrophe (`'`), an escaped double quote (`\"`) or an escape such as `\n` in any string. The page writes the strings into a single-quoted JavaScript string without escaping them. An apostrophe ends that string early, the inline script fails to parse, and the whole page breaks for every user of that language. The other two produce invalid JSON, and reading the strings throws a `SyntaxError`. Use a typographic apostrophe (’) instead.

</aside>

---

# How to use translations in a Vue component

Read your app's strings with `XP.getLanguageJSON()`, passing your app's folder name. It returns the strings for the current language, or `undefined` when there are none:

```jsx
export default {
    data() {
        return {
            locale: XP.getLanguageJSON('myapp') ?? {},
        };
    },
    template: `
        <div>
            <h1>{{ locale.delete_news ?? 'Delete News' }}</h1>
            <p>{{ locale.delete_news_message }}</p>
            <button>{{ locale.confirm_delete ?? 'Confirm Delete' }}</button>
        </div>
    `,
};
```

`XP.getLocale()` does the same without the app name. It works out the app from the URL of the file that calls it (`/apps/<app>/...`) and returns a promise:

```jsx
mounted() {
    XP.getLocale().then((locale) => {
        this.locale = locale || {};
    });
}
```

The promise resolves with `""` when the app has no strings for the language. When the calling file isn't under an `apps/` folder, `getLocale()` returns `undefined` instead of a promise, so `.then()` throws.

<aside>
⚠️ `getLocale()` only works in Chromium-based browsers. It finds the calling file by parsing the stack trace in Chromium's format. In Firefox and Safari the lookup returns `null` and `getLocale()` throws `TypeError` before returning a promise. Use `XP.getLanguageJSON('myapp')`, which works everywhere.

</aside>

---

# How to change the language

The language is chosen when the page loads, from the `language` cookie. To switch, set the cookie and reload:

```jsx
function setLanguage(code) {
    document.cookie = 'language=' + code + '; path=/; max-age=' + 60 * 60 * 24 * 30;
    window.location.reload();
}

setLanguage('DE');
```

To switch without a reload, post the language to `gateway.php` at the site root. It sets the `language` cookie for 30 days and returns every app's strings for that language. Save them to `XP_LANGUAGE` and read them again:

```jsx
const body = new FormData();
body.append('language', 'DE');

const res = await fetch('/gateway.php?action=getLanguageData', {
    method: 'POST',
    body: body,
    credentials: 'include',
});
const json = await res.json();

if (json.success) {
    XP.saveToStorage('XP_LANGUAGE', JSON.stringify(json.data.language_data));
    this.locale = XP.getLanguageJSON('myapp') ?? {};
}
```

Components that already copied their strings keep the old language until they read them again.

<aside>
⚠️ `XP.getLanguageFromServer()`, and `XP.getLocale(lang)` with a language other than the cookie's, don't work as shipped. They build the URL as `getAppUrl() + "gateway.php"` with no slash. With the default empty `app_url` in `xp-config.json` that gives `https://example.comgateway.php`, so the request fails with a network error logged to the console and the promise never resolves. Use the `fetch()` above. Setting `app_url` to a value that ends in `/` also avoids it.

</aside>

---

# Methods

These live on the `XP` object. See [Frontend Runtime (XP)](../Frontend%20Runtime%20%28XP%29.md) for the rest of it.

### getLanguageJSON

Description:

The **`getLanguageJSON`** method returns one app's strings for the current language, from `XP_LANGUAGE` in local storage.

Syntax:

```jsx
const locale = XP.getLanguageJSON('myapp') ?? {};
```

**Parameters:**

- **`app_name`**: The app's folder name under `apps/`.

**Return Value:**

- **`Object | undefined`**: The strings, or `undefined` when the app has none for this language.

---

### getLocale

Description:

The **`getLocale`** method returns the calling app's strings. Called with no argument, or with the language in the cookie, it reads local storage. Called with any other language, it first asks the server for it, which fails as described above. When no cookie is set yet, every language counts as "other", even `EN`. Chromium only.

Syntax:

```jsx
XP.getLocale().then((locale) => {
    // use locale
});
```

**Parameters:**

- **`lang`** (optional): A language code from `lang.json`.

**Return Value:**

- **`Promise`**: Resolves with the strings, or `""` when there are none. `undefined` when the caller isn't a file under `apps/`.

---

### getLanguageFromServer

Description:

The **`getLanguageFromServer`** method posts a language to `gateway.php`, saves the returned strings to `XP_LANGUAGE` and calls the callback. The server sets the `language` cookie. The request URL is missing a slash, as described above.

Syntax:

```jsx
XP.getLanguageFromServer('DE', () => {
    // XP_LANGUAGE now holds the DE strings
});
```

**Parameters:**

- **`language`**: The language code.
- **`callback`**: Called after the strings are saved. Not called when the request fails.

**Return Value:**

- **`undefined`**

---
