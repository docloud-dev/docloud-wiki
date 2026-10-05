---
sidebar_position: 20
title: Docloud
sidebar_label: Docloud
---

# Docloud

Owner: Thilina Deepal

# Introduction

DoCloud ([dof.docloud.lk](https://dof.docloud.lk/)) is where you get the Do Framework and publish your apps. With a DoCloud developer account you can download the framework, sign in to your systems' admin panels, and add apps to the App Library so systems can install them.

This page covers the account, the framework download and adding an app to the library, and then what a framework install does with DoCloud.

---

# How to create a Docloud developer account

1. **Request access.** Go to [dof.docloud.lk](https://dof.docloud.lk/) and request a developer account, either by filling out the form or by asking your system administrator to create one for you.
2. **Check your email.** Once your request is processed, you get a welcome email with a set-up link.
3. **Set up the account.** Click the link and create a password.
4. **Log in.** After you set the password, you're taken to the Docloud developer system.

<aside>
💡 The set-up link expires after 15 minutes.

</aside>

---

# How to get the Do Framework

1. Log in to DoCloud and go to **Frameworks**.
2. Download the latest Do Framework with the icon in the action column.

Then install it as described in [Get Started](./Get%20Started.md).

---

# How to add an app to DoCloud

1. **Export the app.** In your system's admin panel, export the app as a zip. See [Packaging And Updates](./Building%20Apps/Packaging%20And%20Updates.md) for how to export and what the zip contains.
2. **Log in to DoCloud** with your developer account.
3. **Open the App Library** from the menu.
4. **Upload the app.** Choose to add an app to the library and select the zip you exported.
5. **Confirm the app.** Check the details DoCloud shows and click **Add App**.

The app is then available in the App Library, and systems connected to DoCloud can install it.

---

# How the framework uses DoCloud

A framework install talks to DoCloud over HTTPS with the PHP `curl` extension. Two settings in `api/config.xml` control the connection:

```xml
<do_cloud>
    <system_token>your-system-token</system_token>
    <docloud_url>https://dof.docloud.lk</docloud_url>
</do_cloud>
```

- **`<system_token>`** identifies this system to DoCloud. Setup saves it when you install with **Get Started with DoCloud**. Otherwise it's empty until you add one.
- **`<docloud_url>`** is the DoCloud address. The template sets it to `https://dof.docloud.lk`.

You can change both in the admin panel under **Settings > System**, in the **Do Cloud** section. Saving there also writes the DoCloud URL into `<allowed_domains>`. See [Configuration Files](./Essentials/Configuration%20Files.md) for that side effect and the rest of `api/config.xml`.

Before each call the framework checks that `<docloud_url>` answers. If it doesn't, the admin panel shows "Docloud has no response." or "Couldn't get a response from Do cloud."

The framework uses DoCloud for:

| Feature | Where | What happens |
| --- | --- | --- |
| Install | Installer, **Get Started with DoCloud** | You sign in on DoCloud, which sends you back to the installer with your name, email, system name and a system token. See [Get Started](./Get%20Started.md). |
| Admin panel sign-in | Admin panel sign-in page, **Sign in with DoCloud** | You sign in on DoCloud, which sends you back to `/api/admin/auth/`. The framework checks the returned token and a one-time code it stored in your session, then signs you in. The link is valid for 5 minutes. |
| App store | **Apps > DoCloud App Store** | Lists the apps in the DoCloud App Library and installs the version you pick. For installed apps it also lists newer versions. See [Packaging And Updates](./Building%20Apps/Packaging%20And%20Updates.md). |
| Framework updates | **Settings > System**, **Check for updates** | Asks DoCloud for a newer framework version. Installing an update downloads the zip from DoCloud. Needs a system token. |
| Manual framework updates | **Settings > System**, **Choose Update Zip** | Before applying an uploaded framework zip, the framework sends its checksum to DoCloud and applies it only if DoCloud recognises the file. |
| System export | **Settings > System**, **Export the system** | Records the export with DoCloud. |

<aside>
⚠️ **Export the system** only succeeds when a system token is set and DoCloud accepts the export. Without a token it still builds the zip but answers "Error connecting to docloud." and gives you no download link. Exporting a single app doesn't need DoCloud.

</aside>

<aside>
💡 Manual framework updates also need DoCloud. An install that can't reach DoCloud can't apply a framework update zip.

</aside>
