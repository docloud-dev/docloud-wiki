# Email

Owner: Nuwan Danushka

# Email App

## Introduction

The "Email App" serves as a fundamental tool for sending email messages efficiently and reliably. it offers a streamlined way to communicate information, updates, and messages to users or clients.

---

## Usage

### Send Plain Email

To send an email using the Email App, follow these steps:

1. **Define Email Properties:**
    
    
    ```php
         $recipient = array(
                'recipient_email' => $user_email,
                'recipient_name' => $last_name
            );
    ```
    
    ```php
    $email_property = new EmailProperty();
    $email_property->setRecipient($recipient);
    $email_property->setSubject($email_subject);
    $email_property->setSenderEmail($sender_email);
    $email_property->setSenderName($sender_name);
    $email_property->setHtml($email_body_html);
    ```
    
    Here, you define the email properties including the recipient's email address, subject, sender's email address, sender's name, and the HTML content of the email body.
    
2. **Send Email:**
    
    ```php
    $email_app = AppManager::CreateAppInstance('xp_email');
    $email_app->sendMail($email_property);
    ```
    
    Finally, the email is sent using the Email App with the specified email properties.
    
    In summary, this code demonstrates how to send an email through the Email App by defining email properties and using the **`sendEmail`** method of the**`xp-mail`** class.
    

---

### Send Template Email

To send an email using a predefined template through the Email App, follow these steps:

1. **Define Email Template Properties:**
    
    First, prepare the email template content using a suitable method. For example:
    
    ```php
     ob_start();
     $emailTemplate = new xp_emailTemplates();
     $emailTemplate->resetpassword($data);
     $html = ob_get_clean();
    ```
    
    Here, the **`resetpassword`** method of the **`xp_emailTemplates`** class generates the HTML content for the email template, based on the provided data. The output HTML content is captured using output buffering.
    
2. **Define Email Properties:**
    
    Next, define the email properties including the recipient's email address, subject, sender's email address, sender's name, and the HTML content of the email body:
    
    ```php
         $recipient = array(
                'recipient_email' => $user_email,
                'recipient_name' => $last_name
            );
    ```
    
    ```php
    $email_property = new EmailProperty();
    $email_property->setRecipient($recipient);
    $email_property->setSubject($email_subject);
    $email_property->setSenderEmail($sender_email);
    $email_property->setSenderName($sender_name);
    $email_property->setHtml($html); // Use the HTML content generated from the email template
    ```
    

1. **Send Email:**
    
    Finally, send the email using the Email App:
    
    ```php
    $email_app = AppManager::CreateAppInstance('xp_email');
    $email_app->sendMail($email_property);
    ```
    
    Here, the **`CreateAppInstance`** method of the **`AppManager`** class creates an instance of the Email App, and the **`sendMail`** method is used to send the email with the specified email properties.
    
    In summary, this code demonstrates how to send an email with a predefined template through the Email App by defining email properties and using the **`sendMail`** method of the **`xp_email`** class. This approach allows for easy customization and reuse of email templates for various email communication needs.
    

---

# Email Templates

### How to create a template.

```php
<?PHP

 public function setpasswordforfirst($data) {
        $first_name = $data['first_name'];
        $last_name = $data['last_name'];
        ?>

<table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%">
 <tbody>
    <tr>
	    <td height="20">Dear <?php echo $first_name; ?> <?php echo $last_name; ?>,</td>
    </tr>
    <tr>
	    <td align="left">
		    <span style="color:#48545d;font-size:15px;line-height:24px">
					Lorem ipsum dolor sit amet consectetur adipiscing elit rhoncus,
					 ullamcorper vulputate himenaeos posuere lacinia aliquet blandit pellentesque,
	      </span>
      </td>
    </tr>
 </tbody>
</table>
        <?php
    }
```