# Vue DC UI KIT

Owner: Thilina Deepal

# How To Install Vue DC UI KIT

What is Vue DC UI KIT?

### **Download Vue DC UI Kit:**

- Obtain the Vue DC UI Kit from the official source or repository.

### **Place DC UI Kit Directory:**

- Move the DC UI Kit directory to the **`assets/libs`** directory in your project. This is where you'll store external libraries and assets.

### **Register to the System:**

- You need to register DC UI Kit within your project. This typically involves importing the necessary files and components.

### **Update xp-config:**

- Locate the **`xp-config`** file in your project. This file may contain configurations for your project, including script and resource paths.
- Include the path to the DC UI Kit in the **`xp-config`** file. This might involve adding the path to the script and resources sections.

Here's a general example of what your **`xp-config`** file might look like :

```jsx

"resources": {
        "scripts": [
					  // ... other script paths
						{ "url": "./assets/libs/dc-ui-kit/0.0.2/dc-ui-kit.js" }
					],
				"styles": [
						{ "url": "./assets/libs/dc-ui-kit/0.0.2/dc-ui-kit.css" },
						{ "url": "./assets/libs/dc-ui-kit/0.0.2/dc-style.css" }
					]
},
 // ... other configurations
```

Make sure to adjust the paths according to your project structure and the actual location of the DC UI Kit files.

---

# How To Use Vue DC UI KIT

## **Step 1: Import Needed Components**

This step involves bringing in specific parts (components) from the DC UI KIT library.

```jsx
// Import necessary components from the dc_ui_kit_components directory
import  DcCard  from "../../xp_system/components/dc_ui_kit_components/DcCard.js";
import  DcButton  from "../../xp_system/components/dc_ui_kit_components/DcButton.js";
//etc
```

## **Step 2: Register Components in Your Component**

Here, you're telling Vue.js that you want to use these components in your file. It's like saying, "Hey Vue, I have these cool components – be ready to use them!”

```jsx
// Register the imported components in your Vue.js component
components: {
  DcConfLogo,
  DcConfFooter,
  DcCard,
  DcBoxIcon,
  DcButton,
  DcLink,
  DcConfCheckList,
  DcConfCheckListItem,
  Data_Loader
},
```

## **Step 3: Use Components in Your Template**

Now, you can use the registered components in your template as if you were placing building blocks.

```jsx
template: `
  <!-- Use the registered components in your template -->
  <dc-box-icon icon="fa-regular fa-code" class="dcui-m-r-20"></dc-box-icon>
`,
```

In this example, you're using the **`dc-box-icon`** component and giving it a specific icon ("fa-regular fa-code") with an additional custom class ("dcui-m-r-20").

---

# Components:

<aside>
💡 Beyond specifying properties, components can be further customized by applying additional attributes such as ‘class’, ‘alt’ etc, providing flexibility for tailoring their behavior.

</aside>

## DcBoxIcon

The **`DcBoxIcon`** component is a box-shaped icon that utilizes Font Awesome icons. Below is an example of how to use the **`DcBoxIcon`** component along with its properties:

```jsx
<dc-box-icon icon="fa-regular fa-code" class="dcui-m-b-15">
```

### **Properties of `DcBoxIcon`**

| Property | Description |
| --- | --- |
| icon | This property specifies the class name of the Font Awesome icon to be displayed within the box. |
| class | This property allows you to add additional classes to the container element, providing flexibility for styling or other customizations. |

By using the **`DcBoxIcon`** component with these properties, you can easily incorporate a box-shaped icon with a specified Font Awesome icon and apply additional styling if needed.

---

## DcCard

The **`DcCard`** component is used to create a card element with customizable content. Here's an example of how to use the **`DcCard`** component along with its properties:

```jsx
<dc-card>
	<h1>Hello World!!</h1>
  <p>Lorem ipsum dolor sit amet consectetur, adipiscing elit suspendisse torquent rutrum.</p>
</dc-card>
```

**Content**: The content placed inside the **`DcCard`** component, such as headings, paragraphs, images, or other HTML elements, defines the content of the card.

By using the **`DcCard`** component in this manner, you can easily create a card with the specified content, and additional properties can be added to customize the card according to your needs.

---

## DcButton

The **`DcButton`** component is a button element that can be customized with various properties. Here's an example of how to use the **`DcButton`** component along with its properties:

```jsx
<dc-button type="submit" :disabled="true">
```

### **Properties of `DcButton`**

| Property | Description |
| --- | --- |
| type | this property specifies the type of the button, and in the given example, it is set to "submit." This is commonly used for form submission buttons. |
| disabled | This property specifies whether the button should be disabled. By default, this property is set to `false`. |

By utilizing the **`DcButton`** component with the specified properties, you can easily create a button with the desired type, and additional properties can be added based on your specific requirements.

---

## DcLink

```jsx
<dc-link href="www.google.com" target="_blank" class="dc-cp-b-corner-link">Click This Link</dc-link>
```

**Content**: The content placed inside the DcLink component, such as text, images, icons, or other suitable HTML elements, defines the content of the link.

---

## DcSelect

The **`DcSelect`** component is used for creating a customizable dropdown/select input. Below is an example of how to use the **`DcSelect`** component along with its properties:

```jsx
 data() {
    return {
       select_value:"",
				list: [
                {label: "Option1", value: "1"},
                {label: "Option2", value: "2"},
            ],
		};
},
template:`
<dc-select v-model="select_value" :options="list" id="dc-fld-select">
    <template v-slot:label>
     Select Title
    </template>
</dc-select>
`
```

### **Properties of** `DcSelect`

| Property | Description |
| --- | --- |
|  options | Array or object of select options
This property specifies the options available in the dropdown. Each option is an object with **`label`** for display and **`value`** for the corresponding value. |
| id | The ID of the select tag |
| valueKey | If the array or object has different keys for the value, define it here
This property allows you to specify the key in the options array or object that represents the value of each option. |
| labelKey | If the array or object has different keys for the label, define it in the labelKey property
Similar to valueKey, this property lets you specify the key in the options array or object that represents the label or display text for each option. |
| placeholder | Placeholder of the select component |

By using these properties, you can customize the **`DcSelect`** component to suit your needs, providing flexibility in handling different data structures and styling options.

---

## DcInputField

The **`DcInputField`** component is designed for creating customizable input fields. Below is an example of how to use the **`DcInputField`** component along with its properties:

```jsx
<dc-input-field placeholder="Enter Something" v-model="input_value" id="dc-fld-input" containerClasses="custom-class">
   <template v-slot:label>
    Label of the input field
    </template>
</dc-input-field>
```

### **Properties of** `DcInputField`

| Property | Description |
| --- | --- |
| **containerClasses** | Class for the container
This property allows you to apply custom classes to the container of the input field.  It accepts class names,  providing flexibility for styling or layout customization. |
| readonly | Set readonly to true for read only inputfield |
| type | type of the input field |

By using the **`DcInputField`** component with the specified properties, you can create an input field with a placeholder, label, and customize the container class based on your requirements.

---

## DcPasswordField

The **`DcPasswordField`** component is designed for creating customizable password input fields. Below is an example of how to use the **`DcPasswordField`** component along with its properties:

```jsx
<dc-password-field placeholder="Enter the password" v-model="password_value" id="dc-fld-password"
 containerClasses="custom-class">
   <template v-slot:label>
    Label of the password field
    </template>
</dc-password-field>     
```

### **Properties of** `DcPasswordField`

| Property | Description |
| --- | --- |
| containerClasses | This property allows you to apply custom classes to the container of the password field. It accepts class names, providing flexibility for styling or layout customization. |

By using the **`DcPasswordField`** component with the specified properties, you can create a password input field with a placeholder, label, and customize the container class based on your requirements.

---

## DcCheckbox

The **`DcCheckbox`** component is used for creating customizable checkbox inputs. Below is an example of how to use the **`DcCheckbox`** component along with its properties:

```jsx
<dc-checkbox id="dc-chk-box" value="positive" v-model="checkbox_value">
  Checkbox Text
</dc-checkbox>   
```

### **Properties of** `DcCheckbox`

| Property | Description |
| --- | --- |
| `value` | Value of the checkbox
This property specifies the value associated with the checkbox. When the checkbox is checked, the checkbox_value in the v-model will be set to the specified value. |
| `nod_label` | Set it true to hide the label |

By using the **`DcCheckbox`** component with the specified properties, you can create a checkbox input with custom text and associate it with a specific value in your application logic.

---

## DcCheckboxGroup

The `DcCheckboxGroup` component is a wrapper for checkbox’s and its a  inline container. Below is an example of how to use the `DcCheckboxGroup` component

```jsx
<dc-checkbox-group>
	 <dc-checkbox></dc-checkbox>
	 <dc-checkbox></dc-checkbox>
</dc-checkbox>
```

---

## DcFormGroup

The **`DcFormGroup`** component is utilized for grouping form elements together. Here's an example of how to use the **`DcFormGroup`** component:

```jsx
<dc-form-group>
   <label class="dcui-fld-label">Multiple Checkboxes</label>
    <div class="dcui-checkbox-radio-inline">
        <dc-checkbox id="dc-chk-box-1" value="1" v-model="check_boxes_value">One</dc-checkbox>
				<dc-checkbox id="dc-chk-box-2" value="2" v-model="check_boxes_value">Two</dc-checkbox>         
    </div>
</dc-form-group>
```

### **Properties of `DcFormGroup`**

- The **`DcFormGroup`** component itself primarily serves as a container for grouping form-related elements.

In the provided example, it encapsulates a label and a set of checkboxes within a **`div`** element. The checkboxes are instances of the **`DcCheckbox`** component, and they have their own properties, such as **`id`**, **`value`**, and **`v-model`**.

By using **`DcFormGroup`**, you can structure and group related form elements, making your form organization cleaner and more readable. This is particularly useful when dealing with multiple related input fields.

---

## DcPasswordGenerator

The **`DcPasswordGenerator`** component is designed for generating passwords with specified properties. Here's an example of how to use the **`DcPasswordGenerator`** component along with its properties:

```jsx
<dc-password-generator v-model="password_generator_value" id="dc-fld-password-gen" length="12">
     <template v-slot:label>
       Label for password generator
     </template>
</dc-password-generator>  
```

### **Properties of** `DcPasswordGenerator`

| Property | Description |
| --- | --- |
| length | This property specifies the length of the generated password. In the provided example, it is set to 12 characters. |

By using the **`DcPasswordGenerator`** component with the specified properties, you can create a password generator input field with a label and customize the length of the generated password based on your requirements. The generated password includes a mix of lowercase letters, uppercase letters, and numbers.

---

## DcTextField

The `DcTextField` component is designed for creating a customizable input area. 

Here's an example of how to use the `DcTextField` component along with its properties:

```jsx
<dc-text-field v-model="text_area_value" id="dc-fld-text-area"></dc-text-field>
```

### **Properties of** `DcTextField`

| Property | Description |
| --- | --- |
| `containerClasses` | this property specifies the type of the button, and in the given example, it is set to "submit." This is commonly used for form submission buttons. |
| `label` | label |
| `placeholder` | placeholder |
| `readlonly` | set readonly to true |
| `resize` | enable/disable the resize |

By using the **`DcTextField`** component with the specified properties, you can create a text area with customizable container classes based on your styling needs.

---

## DcTable

The **`DcTable`** component is used to create customizable tables. Below is an example of how to use the **`DcTable`** component along with its properties:

```html
<dc-table :headers="table_headers" :items="item_list" class="dc-table">
    <template  v-slot:table-data="{ item }">
         <td><div>{{ item?.name }}</div></td>
         <td><div>{{ item?.location_name }}</div></td>
         <td><div>{{ item?.meta_data?.contact_person_phone }}</div></td>
     </template>
</dc-table> 
```

```jsx
table_headers:[
   {label: "ID", key: "id"},
   {label: "Comments", key: "comment"},
   {label: "Created Date", key: "created_date", sort:"ASC"},
];
```

### **Properties of `DcTable`**

| Property | Description |
| --- | --- |
| `headers` | An array of objects representing the table headers. Each object should include: 
 - label: The display name of the header. 
 - key: The corresponding key from the item data used for the header's value.
- sort: The sorting method the column ASC for ascending. default is descending  |
| `items` | An array of data objects representing the rows in the table. |
| `class` | A CSS class or classes to apply to the table for styling. |
| `show_checkbox` | A boolean that, when set to `true`, displays a checkbox at the beginning of each row. |
| `show_check_all` | A boolean that, when set to `true`, adds a "Select All" checkbox at the top of the checkbox column to allow for selecting or deselecting all rows at once. |
| `hidden_checkbox_items` | An array of items for which the checkbox should be hidden. Use this to exclude specific rows from being selectable. |
| `unique_identifier_key` | A key that uniquely identifies each item in the `items` array. This is particularly useful for managing hidden checkboxes. |
| `show_checkbox` | Show checkboxs to select rows |
| `show_check_all` | Show check all checkbox |
| `hidden_checkbox_items` | Pass array of `unique_identifiers` to hide checkbox in front of the table. |

### **Events of `DcTable`**

| Event | Description |
| --- | --- |
| `clicked_row` | Trigger the function when clicked a row |

By using the **`DcTable`** component with the specified properties, you can create a table with custom text and associate it with a specific value in your application logic.

---

## DcBubbleAvatar

The `DcBubbleAvatar` component is designed for creating a circle avatar placeholder. 

Here's an example of how to use the `DcBubbleAvatar` component along with its properties:

```jsx
<dc-bubble-avatar avatar_image="" alt=""></dc-bubble-avatar>
```

### **Properties of** `DcBubbleAvatar`

| Property | Description |
| --- | --- |
| `alt` | this property specifies the alternate text for the image |
| `avatar_image` | Specifies the path to the image |
| `placeholder_image` | Displays an alternative image if the primary image fails to load. |

By using the `DcBubbleAvatar` component with the specified properties, you can create an avatar placeholder with customizable container classes based on your styling needs.

---

## DcIconButton

The `DcIconButton` component is designed for creating a square button with an icon. 

Here's an example of how to use the `DcIconButton` component along with its properties:

```jsx
 <dc-icon-button @click="this.grid_type = 'table'" icon="fa-solid fa-list"  :classes="{'active':this.grid_type == 'table'}"></dc-icon-button>
```

### **Properties of** `DcIconButton`

| Property | Description |
| --- | --- |
| `icon`  | This property specifies the font awesome 6 class |
| `classes` | The classes for  |
| `loading` | Set it to true display a spinner. default its sets to false |
| `image` | path of image if the icon is not present (optional) |

By using the `DcIconButton` component with the specified properties, you can create a square icon button.  customizable container classes based on your styling needs.

---

## DcPopup

The `DcPopup` component is designed for creating popups. 

Here's an example of how to use the `DcPopup` component along with its properties:

<aside>
💡 The width of the popup should be given.

</aside>

```jsx
 <dc-popup ref="reject_confirmation" title="Confirm reject" class="w-600">
		 <template v-slot:trigger="{ onToggle }"> //for toggle show/hide popup
        <button type="button" @click="onToggle" class="button relative button-minwidth m-r-10">
              Open Popup
         </button>
     </template>
		 <template v-slot:content>
				 //content inside the popup
	   </template>
  </dc-popup>
```

### **Properties of** `DcPopup`

| Property | Description |
| --- | --- |
| `title`  | The popup title |
| `class` | The classes for popup |

### **Methods of** `DcPopup`

| Method | Description |
| --- | --- |
| `show`  | The method that will show the popup. |
| `hide` | The method that will hide the popup. |
| `toggle` | The method that will show / hide the popup. |

By using the `DcPopup` component with the specified properties, you can create an popup.  customizable container classes based on your styling needs.

---

## DcSearchField

The `DcSearchField` component is designed to create a search field that triggers a search method when text is entered.

Here's an example of how to use the `DcSearchField` component along with its properties:

```jsx
<dc-search-field @search="search_in_models" containerClasses="lv-input-filed-no-outline has-search-field" icon_align="left"></dc-search-field>
```

### **Properties of** `DcSearchField`

| Property | Description |
| --- | --- |
| `icon_align` | Specifies the alignment of the search icon (magnifying glass). Set to either `left` or `right`. |
| `placeholder` | The placeholder text is displayed in the search field when it is empty. |
| `class` | CSS classes to apply to the search field for custom styling. |
| `containerClasses` | CSS classes to apply to the container that wraps the search field. |

### **Methods of** `DcSearchField`

| Method | Description |
| --- | --- |
| `clearSearch` | Clears the current search text in the search field. |
| `getSearchValue` | Get the search value. |

### **Emits of** `DcSearchField`

| Method | Description |
| --- | --- |
| `@search` | Emits the entered search text when the user types in the field. |

Using the `DcSearchField` component with these properties allows you to create a customizable search field that fits your application's design and functionality needs.

---

## DcTabs

The `DcTabs` component is designed to create tabs.

Here's an example of how to use the `DcTabs` component along with its properties:

```jsx
<dc-tabs :tabs="tabs" class="lv-tabs" v-model="selected_tab" :class="tab_class" @tab_changed="tab_changed_fnc">
   <template v-for="(tab, index) in tabs" :key="index" v-slot:[tab.key]>
	   <div v-if="tab.key === 'tab_1'" class="full-height">
		   //content
	   </div>
	   <div v-if="tab.key === 'tab_2'" class="full-height">
	     //content
	   </div>
   </template>
</dc-tabs>
```

### **Properties of** `DcTabs`

| Property | Description |
| --- | --- |
| `tabs` | An array of objects representing the tabs. Each object should include: `name` (display name) and `key` (unique key). |
| `modelValue` | The key of the currently active tab. |
| `model_key` | The property name in the tab objects used as the unique identifier (e.g., "key"). |

```jsx
tabs:[
   {name: "Comments", key: "tab_1"},
   {name: "Activity", key: "tab_2"},
   {name: "Tasks",    key: "tab_3"},
];
```

### **Emits of** `DcTabs`

| Method | Description |
| --- | --- |
| `@tab_changed` | Emitted when the active tab changes. |

By using the `DcTabs` component with the specified properties, you can create a tab component with customizable container classes based on your needs.

---

## DcDropDown

The `DcDropdown` component is designed to create a customizable dropdown menu with various options for alignment, selection, and appearance.

### Example Usages of `DcDropdown`

Here are two ways you can use the `DcDropdown` component:

### 1. Advanced Usage with Custom Action, Label, and Content Slots

In this example, the `DcDropdown` is used with custom slots for actions, labels, and content. It integrates a search field and displays a list of users with avatars.

```html
<dc-dropdown 
	container_class="lv-dropdown" 
	:use_options="false" 
	:options="user_list" 
	panel_class="scroll-container lv-dropdown-scrollable" 
	@blur="validate('style_assignee')" 
	@change="validate('style_assignee')"
	v-model="inputs.style_assignee" 
	:disabled="disable">
	   <template v-slot:action>
	      <dc-search-field 
	      @search="search_in_users" 
	      containerClasses="lv-input-filed-no-outline has-search-field" 
	      icon_align="left"></dc-search-field>
	   </template>
   <template v-slot:label="{selected_value}">
      <!-- default dress type -->
       <div v-if="selected_value" class="dcui-flex-item align-center">
          <div>                                  
              <dc-bubble-avatar  
                   alt="User" 
                   :avatar_image="selected_value?.image?.thumbnail" 
                    class="dcui-xsmall m-r-5 lv-avatar-cover">
               </dc-bubble-avatar>
          </div>
          <div v-if="selected_value.full_name != null">{{selected_value.full_name}}</div>
          <div v-else>User removed from the system.</div>
       </div>
        <div v-else class="dcui-flex-item align-center">
           <div>
             <dc-bubble-avatar  
	             alt="User" 
	             avatar_image="" 
	             class="dcui-xsmall m-r-5 lv-avatar-cover">
             </dc-bubble-avatar>
            </div>
            <div>Select a user</div>
        </div>
    </template>
    <template  v-slot:content="slotProps">
        <li 
        v-for="(user,index) in slotProps.options" 
        :key="index" 
        @click="slotProps.select(user,index)" 
        :class="{'selected':slotProps.selected_index === index}">
	        <a>
             <span 
	             class="dcui-select-dropdown-close"
	              v-if="slotProps.selected_index === index">
		              <i class="fa-regular fa-xmark"></i>
		         </span>
             <div class="dcui-flex-item align-center">
                 <div>
                    <dc-bubble-avatar 
	                    alt="User" 
	                    :avatar_image="user?.image?.thumbnail" 
	                    class="dcui-xsmall m-r-5 lv-avatar-cover">
                    </dc-bubble-avatar>
                  </div>
                  <div>{{user.full_name}}</div>
               </div>
           </a>
         </li>
         <li v-if="slotProps.options.length === 0">
	            <div class="text-center">
		               <i class="fa-regular fa-circle-info"></i>
		                No items.
	            </div>
         </li>
	</template>
</dc-dropdown>

```

### 2. Simple Usage with Label Slot

In this simpler example, the `DcDropdown` is used with just a label slot, making it easier to use when you only need to display a basic dropdown.

```html
<dc-dropdown :options="dropdown_options">
    <template v-slot:label>
        Priority
    </template>
</dc-dropdown>
```

These examples demonstrate the flexibility of the `DcDropdown` component, allowing for both simple and advanced implementations depending on the needs of your application.

### **Properties of**  `DcDropDown`

| Property | Description |
| --- | --- |
| `align` | Specifies the alignment of the dropdown menu. Set to `left` (default) or `right` |
| `options` | An array of objects representing the dropdown options. |
| `modelValue` | The currently selected value, bound to the parent component via v-model. It must be an object and is required. |
| `labelKey` | The key is used to display the label for each option in the dropdown. Defaults to 'label'. |
| `valueKey` | The key is used to identify the value of each option. If set, the dropdown will use this key to manage the selected option. Defaults to an empty string. |
| `arrow_tip` | A boolean that, when set to true, adds an arrow tip to the dropdown panel. Defaults to false. |
| `icon_only` | A boolean that, when set to true, displays only the icon, without the label text. Defaults to false. |
| `container_class` | CSS classes to apply to the dropdown container for custom styling. Defaults to an empty string. |
| `color_selected` | A boolean that, when set to true, highlights the selected option in the dropdown menu. Defaults to false. |
| `panel_class` | CSS classes to apply to the dropdown panel for custom styling. Defaults to an empty string. |
| `disabled` | A boolean that, when set to true, disables the dropdown, preventing user interaction. Defaults to false. |
| `use_options`  | Make this true if you using only options. |

### **Emits of** `DcDropDown`

| Method | Description |
| --- | --- |
| `@cleared` | Emitted when the selection is cleared. |
| `@change` | Emitted when a new option is selected. |
| `@blur` | Emitted when the dropdown loses focus. |

The `DcDropdown` component offers flexibility in both appearance and functionality, making it easy to integrate into various applications where dropdown menus are needed.

---

## DcProgressBar

The `DcProgressBar` component is designed to display a progress bar that can represent either a percentage or a series of steps. It provides visual feedback on the completion status of a task or process.

```jsx
<dc-progress-bar class="lv-progressbar small" :steps="total_steps" v-model="item.task_status_count.status_type_done"></dc-progress-bar>
```

### **Properties of** `DcProgressBar`

| Property | Description |
| --- | --- |
| `steps` | The total number of steps for the progress bar. If type is set to "steps", this value is used to calculate the width of the progress bar. Defaults to 0. |
| `type` | Determines the type of progress bar. Set to `"steps"` for step-based progress or `"percentage"` for percentage-based progress. Defaults to `"steps"`. |
| `in_progress` | A string that, if set, indicates that the progress is ongoing. When not null, it prevents the progress bar from appearing empty. Defaults to null. |
| `modelValue` | The current value of the progress, either as a number of steps completed or a percentage. It is bound to the parent component via v-model. Defaults to 0. |

The `DcProgressBar` component is flexible and can be styled with custom classes to fit the design of your application. It provides clear visual feedback on task progress, making it useful for dashboards, forms, and other UI elements.

---

## DcImageUploader

The `DcImageUploader` component allows users to upload images via drag-and-drop or by browsing their devices. It supports multiple file uploads and provides functionality for previewing, selecting, and removing files. The `v-model="uploadedImages"` binds to an array of images, which can be sent to the server as binary files.

```jsx
<dc-image-uploader v-model="uploadedImages"></dc-image-uploader>
```

### **Properties of** `DcImageUploader`

| Property | Description |
| --- | --- |
| `modelValue` | An array that holds the list of uploaded files. This property is bound to the parent component via v-model. |
| `accept` | A string specifying the file types allowed for upload. Defaults to `"image/png, image/gif, image/jpeg"`. |
| `file_limit` | 0 means no limit. |

### **Methods of** `DcImageUploader`

| Method | Description |
| --- | --- |
| `clear_attachments` | Clears all uploaded files and resets the component state. |

This example demonstrates how to use the `DcImageUploader` component to allow users to upload multiple images, view previews, select files, and manage the upload list. The component is designed to handle various file interactions smoothly and provide a user-friendly interface for file management.

---

## DcLoadMore

The `DcLoadMore` component is designed to handle infinite scrolling and provide buttons for loading more items or checking for new items. It supports custom scroll containers and debouncing for improved performance.

```jsx
<dc-load-more
  :scrollContainerId="'scrollContainer'"
  :debounceTime="200"
  :hasMoreItems="moreItemsAvailable"
  :loading="isLoading"
  :container_class="'custom-class'"
  :empty="isEmpty"
  :show_check_new="true"
  :load_more_btn_disabled="false"
  @load-more="fetchMoreItems"
  @get-latest="fetchLatestItems"
>
  <!-- Content goes here -->
</dc-load-more>
```

### **Properties of** `DcLoadMore`

| Property | Description |
| --- | --- |
| `hasMoreItems` | Indicates if there are more items to load. If false, the component will show "No more items". It is required. |
| `loading` | Indicates if data is currently being loaded. If true, a loading message is shown. It is required. |
| `scrollContainerId` | The ID of the scrollable container. This is required for the component to attach scroll event listeners. |
| `debounceTime` | The debounce time (in milliseconds) for scroll events to avoid excessive calls. Defaults to `200`. |
| `container_class` | Additional CSS classes to apply to the container. Defaults to an empty string. |
| `empty` | Indicates if there are no items. Defaults to false. |
| `show_check_new` | Controls whether the "Check for New Styles" button is shown. Defaults to true. |
| `load_more_btn_disabled` | Disables the "Load More" button if true. Defaults to false. |

### **Methods of** `DcLoadMore`

| Method | Description |
| --- | --- |
| `resetLoadMore` | Resets the scroll count. |

```jsx
<template>
  <dc-load-more
    :scrollContainerId="'scrollContainer'"
    :debounceTime="200"
    :hasMoreItems="moreItemsAvailable"
    :loading="isLoading"
    :container_class="'custom-class'"
    :empty="isEmpty"
    :show_check_new="true"
    :load_more_btn_disabled="false"
    @load-more="fetchMoreItems"
    @get-latest="fetchLatestItems"
  >
    <!-- List or content to display here -->
  </dc-load-more>
</template>

<script>
import { Data_Loader, Ajax_Loader } from "../helpers.js";
import DcButton from "./DcButton.js";

export default {
  data() {
    return {
      moreItemsAvailable: true,
      isLoading: false,
      isEmpty: false
    };
  },
  methods: {
    fetchMoreItems() {
      this.isLoading = true;
      // Fetch more items logic here
    },
    fetchLatestItems() {
      this.isLoading = true;
      // Fetch latest items logic here
    }
  }
};
</script>

```

In this example, the `DcLoadMore` component is used to load additional items as the user scrolls. The `fetchMoreItems` method handles the logic for fetching more data, and the `moreItemsAvailable` and `isLoading` data properties control the state of the loading process and availability of more items.