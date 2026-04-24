# Localization

Owner: Nuwan Danushka

<aside>
💡  Save the user's language preference in a cookie named "language", with the default language set to English (EN). This enables easy access to the preferred language across sessions, providing a smooth user experience.

</aside>

# **Adding Language Support to Your App**

To add languages to your app, follow these steps:

1. **Create a Languages Directory**: In the root directory of your frontend app, create a directory named **`languages`**.
2. **Create a Language JSON File**: Inside the **`languages`** directory, create a file named **`lang.json`**.
3. **Define Language Entries**: In the **`lang.json`** file, define the language entries as follows:

```json
{
  "en": {
    "add_news": "Add News",
    "author":"Author",
    "back_to_news_list":"Back to News List",
    "cancel_delete":"Cancel",
    "confirm_delete":"Confirm Delete",
    "content":"Content",
    "created_on":"Created On",
    "delete_news_message":"Are you sure you want to delete this news permanently?This action cannot be reversed.",
    "delete_news": "Delete News",
    "edit_news": "Edit News",
    "edit":"Edit",
    "excerpt":"Excerpt",
    "news": "News",
    "publish":"Publish",
    "read_more":"Read More",
    "title":"Title",
    "update":"Update",
    "visibility":"Visibility"
  },
  "de": {
    "add_news": "Neuigkeiten hinzufügen",
    "Autor": "Autor",
    "back_to_news_list": "Zurück zur Nachrichtenliste",
    "cancel_delete": "Abbrechen",
    "confirm_delete": "Löschen bestätigen",
    "content": "Inhalt",
    "created_on": "Erstellt am",
    "delete_news_message": "Sind Sie sicher, dass Sie diese Nachricht dauerhaft löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.",
    "delete_news": "Nachrichten löschen",
    "edit_news": "Nachrichten bearbeiten",
    "edit": "Bearbeiten",
    "excerpt": "Auszug",
    "news": "Neuigkeiten",
    "publish": "Veröffentlichen",
    "read_more": "Weiterlesen",
    "title": "Titel",
    "update": "Aktualisieren",
    "visibility": "Sichtbarkeit"
  }
}
```

In this JSON file:

- The top-level keys (**`en`**, **`de`**) represent language codes (e.g., English, German).
- Under each language code, there are key-value pairs where the key is the recognition and the value is the corresponding translation in the respective language.

By following these steps, your app can easily incorporate language support by utilizing the translations provided in the **`lang.json`** file.

---

<aside>
💡 Store language file data in local storage for easy access. This ensures swift retrieval and seamless integration into your application.

</aside>

# **Adding Language Support to Your Vue Component**

To integrate language support into your Vue component, follow these organized steps:

1. **Define Data Property**: Initialize the **`locale`** data property to store language translations fetched from the server.
2. **Template Usage**: Utilize placeholders like **`{{ locale?.delete_news }}`** in the template to display translated text. These placeholders access properties of the **`locale`** object, which will hold language translations.
3. **Retrieve Language Parameter**: In the **`mounted`** hook, extract the language parameter (**`lang`**) from the route parameters using **`this.$route.params.lang`**.
4. **Fetch Language Data**: Call **`XP.getLocale(lang)`** to retrieve language data for the specified language (**`lang`**). This function returns a promise resolving to an object containing translations.
5. **Update Locale Data**: Upon successfully fetching language data, update the **`locale`** property with the fetched translations.
6. **Error Handling**: Implement error handling within the **`catch`** block to manage any errors that may occur during the language data retrieval process.
7. **Additional Component Code**: Include any additional component-specific logic or functionality within the component.

```jsx
data() {
    return {
        locale: {}, // Initialize an empty object to store language translations
    };
},
template: `
    <div>
        <h1>{{ locale?.delete_news }}</h1> <!-- Display translated text for delete news -->
        <p>{{ locale?.delete_news_message }}</p> <!-- Display translated text for delete news message -->
        <button>{{ locale?.delete_news }}</button> <!-- Display translated text for delete news button -->
    </div>
`,
mounted() {
    // Retrieve language parameter from route parameters
    const lang = this.$route.params.lang;

    // Fetch language data for the specified language
    XP.getLocale(lang)
        .then(locale => {
            // Update locale data with fetched translations
            this.locale = locale;
        })
        .catch(error => {
            // Handle errors if language data retrieval fails
            console.error('Error:', error);
        });

    // Other code specific to the component
}

```

By following these steps, your Vue component will dynamically load language translations based on the specified language parameter, enhancing the user experience with multilingual support.

---