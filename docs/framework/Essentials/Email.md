---
title: Email
sidebar_label: Email
---

# Email

Owner: Nuwan Danushka

# Introduction

The `xp_email` system app sends HTML email. You describe the message with an `EmailProperty` object and pass it to the app's `sendMail()` method. The app hands the message to one of two backends:

- **LOCAL** sends with PHP's `mail()` function. This is the default.
- **SMTP** sends through an SMTP server with PHPMailer.

`xp_email` also ships `xp_emailTemplates`, the HTML templates the framework uses for its own account emails.

---

# How to choose the email provider

The provider and the SMTP settings live in `api/config.<environment>.xml`, the per-environment overlay. See [Configuration Files](./Configuration%20Files.md) for how the environment is chosen. Admins can also change them on **Settings > Email** in the admin panel.

```xml
<config>
  <system>
    <!-- SMTP or LOCAL -->
    <email_provider>SMTP</email_provider>
    <system_email>noreply@example.com</system_email>
  </system>
  <email>
    <smtp>
      <smtp_host>smtp.example.com</smtp_host>
      <smtp_user_name>noreply@example.com</smtp_user_name>
      <smtp_password>secret</smtp_password>
      <smtp_port>587</smtp_port>
    </smtp>
  </email>
</config>
```

- **`<email_provider>`**: `SMTP` uses the SMTP backend. Any other value, or no value, uses LOCAL.
- **`<smtp_host>`**, **`<smtp_user_name>`**, **`<smtp_password>`**: The server and login. SMTP authentication is always on.
- **`<smtp_port>`**: Port `465` connects with implicit TLS (SMTPS). Every other port uses STARTTLS, so the server must support it. The shipped templates set `456`. Replace it with your provider's port.

<aside>
⚠️ The admin panel's **Settings > Email** also offers **AWS**, and the config has an `<aws>` block. `xp_email` has no AWS backend. With `AWS` selected, mail goes out through LOCAL (`mail()`).

</aside>

## What the recipient sees

The two backends don't build the headers the same way:

| Header | LOCAL | SMTP |
| --- | --- | --- |
| From address | The sender email you set | `<smtp_user_name>`. The sender email you set is ignored. |
| From name | The sender name you set | The sender name you set |
| Reply-To | Not set | Always `Support <support@docloud.lk>` |

<aside>
⚠️ With SMTP, replies to your email go to `support@docloud.lk`, not to you. The address is hard-coded in `xp_email` and can't be changed from config. If you need replies, use LOCAL. Also, `<smtp_user_name>` must be a valid email address with SMTP: if your provider uses a login such as `apikey`, setting the From address fails and `sendMail()` returns `false`.

</aside>

---

# How to send an email

1. Build the message. Get the `EmailProperty` object from the `Email` module:

    ```php
    $email_property = Email::EmailProperty();
    $email_property->setRecipient(array(
        'recipient_email' => $user_email,
        'recipient_name' => $first_name
    ));
    $email_property->setSubject('Your order has shipped');
    $email_property->setSender_email(system_config::get('system', 'system_email'));
    $email_property->setSender_name('My App');
    $email_property->setHtml($html);
    ```

2. Send it through the `xp_email` app:

    ```php
    $email_app = AppManager::CreateAppInstance('xp_email');

    if ($email_app && $email_app->sendMail($email_property)) {
        // sent
    }
    ```

    `xp_email` ships with `<app_permissions allow="all">`, so any app may create an instance and you don't need to edit its manifest. `CreateAppInstance()` still returns `false` when it can't tell which app is calling, which happens when the call isn't made from a file inside an app folder. See [App Manager](../Modules/App%20Manager.md).

<aside>
⚠️ Don't write `new EmailProperty()`. The class sits inside the `Email` module folder and the autoloader can't find it on its own, so PHP stops with `Class "EmailProperty" not found` unless the `Email` module has already been loaded in the same request. `Email::EmailProperty()` loads the module first.

</aside>

## Send to several recipients

`setRecipient()` adds one recipient per call. Call it once for each address:

```php
foreach ($users as $user) {
    $email_property->setRecipient(array(
        'recipient_email' => $user['email'],
        'recipient_name' => $user['name']
    ));
}
```

All recipients go in the To header, so each one sees the others' addresses.

## Cc, Bcc and attachments

`EmailProperty` has `setCc()`, `setBcc()`, `setAttachment()`, `setRaw_attachment()` and `setReplyAddresses()`. Neither backend reads them, so the values are dropped. To keep addresses private, send one email per recipient.

---

# How to send a template email

A template is a method that **prints** HTML. Capture the output with output buffering and pass it to `setHtml()`:

```php
ob_start();
$templates = new xp_emailTemplates();
$templates->resetpassword($data);
$html = ob_get_clean();

$email_property->setHtml($html);
```

## Built-in templates

`xp_emailTemplates` holds the templates the framework's auth app uses. Their wording is fixed, so they suit those flows only. Each takes one `$data` array:

| Method | Used for | `$data` keys |
| --- | --- | --- |
| `resetpassword` | Password reset link | `link`, `logo_url`, `do_logo_url`, `first_name`, `last_name`, `system_name`, `expire_time` |
| `setpasswordforfirst` | Welcome email with a link to set the first password | `link`, `logo_url`, `do_logo_url`, `first_name`, `last_name`, `system_name` |
| `send2faemail` | Two-factor login code | `logo_url`, `do_logo_url`, `two_fa_code` |
| `sendAuthMail` | Authorization code | `logo_url`, `do_logo_url`, `code` |

`logo_url` and `do_logo_url` are full image URLs.

## Write your own template

Put template methods in a class in your own app, not in `xp_emailTemplates`: a framework update replaces the `xp_email` app. Close the PHP tag, write the HTML, and echo the values:

```php
<?php

class myappEmailTemplates
{
    public function welcome($data)
    {
        $first_name = htmlspecialchars($data['first_name']);
        ?>
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tbody>
            <tr>
                <td>Dear <?php echo $first_name; ?>,</td>
            </tr>
            <tr>
                <td>Welcome to My App.</td>
            </tr>
            </tbody>
        </table>
        <?php
    }
}
```

Use inline styles and tables. Many email clients ignore `<style>` blocks.

---

# Methods

## xp_email

### sendMail

Description:

The **`sendMail`** method sends the message with the provider set in `<email_provider>`.

Syntax:

```php
$email_app = AppManager::CreateAppInstance('xp_email');
$sent = $email_app->sendMail($email_property);
```

**Parameters:**

- **`$property`**: An `EmailProperty` object with at least one recipient.

**Return Value:**

- **`Boolean`**: `true` when the message was handed to the mail server. `false` when there are no recipients or sending failed. With SMTP, the error is written to the error log. See [Logging](./Logging.md).

---

## EmailProperty

Get one with `Email::EmailProperty()`. The setters used by the backends:

| Method | Value |
| --- | --- |
| `setRecipient($recipient)` | An array with `recipient_email` and `recipient_name`. Adds one recipient. |
| `setSubject($subject)` | The subject line. |
| `setHtml($html)` | The HTML body. |
| `setSender_email($email)` | The From address. LOCAL only; SMTP uses `<smtp_user_name>`. |
| `setSender_name($name)` | The From name. |

`setCc()`, `setBcc()`, `setAttachment()`, `setRaw_attachment()`, `setReplyAddresses()` and `setMessage()` store a value that neither backend sends. Each setter has a matching getter, such as `getRecipient()`.
