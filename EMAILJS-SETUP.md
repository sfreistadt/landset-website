# EmailJS Setup for Landset Contact Form

**Time to complete:** 5 minutes
**Cost:** Free (200 emails/month)

## Step 1: Create EmailJS Account

1. Go to **https://www.emailjs.com/**
2. Click **"Sign Up"**
3. Sign up with your email (or use Google/GitHub)
4. Verify your email

---

## Step 2: Connect Your Email Service

1. **Go to Email Services** in the dashboard
2. Click **"Add New Service"**
3. Choose **"Gmail"** (recommended) or another provider
4. Click **"Connect Account"**
5. Sign in with steve@landset.co (or the email you want to send FROM)
6. **Copy the Service ID** - looks like `service_abc123`
   - Save this! You'll need it in Step 4

---

## Step 3: Create Email Template

1. **Go to Email Templates** in the dashboard
2. Click **"Create New Template"**
3. **Template Name:** "Landset Contact Form"
4. **Configure the template:**

### Template Settings:

**To Email:**
```
steve@landset.co, danny@landset.co
```

**From Name:**
```
{{name}}
```

**From Email:**
```
{{email}}
```

**Subject:**
```
New Landset Contact: {{subject}}
```

**Content (HTML):**
```html
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
  <h2 style="color: #5A7F5D;">New Contact Form Submission</h2>

  <p><strong>From:</strong> {{name}}</p>
  <p><strong>Email:</strong> {{email}}</p>
  <p><strong>Subject:</strong> {{subject}}</p>

  <div style="background: #f5f5f5; padding: 20px; border-left: 4px solid #5A7F5D; margin: 20px 0;">
    <p><strong>Message:</strong></p>
    <p>{{message}}</p>
  </div>

  <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">

  <p style="color: #666; font-size: 12px;">
    Sent from landset.co contact form
  </p>
</div>
```

5. Click **"Save"**
6. **Copy the Template ID** - looks like `template_xyz789`
   - Save this! You'll need it in Step 4

---

## Step 4: Get Your Public Key

1. Go to **"Account"** → **"General"**
2. Find **"Public Key"** (looks like `Abc123Xyz789`)
3. **Copy it** - you'll need all three IDs now

---

## Step 5: Update about-clean.html

Replace the placeholders in the file with your actual IDs:

### Find these three lines and update them:

**Line ~1705:**
```javascript
emailjs.init('YOUR_PUBLIC_KEY');
```
Replace `YOUR_PUBLIC_KEY` with your actual public key

**Line ~1718:**
```javascript
emailjs.sendForm('YOUR_SERVICE_ID', 'YOUR_TEMPLATE_ID', this)
```
Replace:
- `YOUR_SERVICE_ID` with your service ID (from Step 2)
- `YOUR_TEMPLATE_ID` with your template ID (from Step 3)

### Quick Update Script:

```bash
# In your terminal, run this (update with YOUR values):
cd /Users/steve/Documents/GitHub/landset-website

# Replace YOUR_PUBLIC_KEY
sed -i '' 's/YOUR_PUBLIC_KEY/Abc123Xyz789/g' about-clean.html

# Replace YOUR_SERVICE_ID
sed -i '' 's/YOUR_SERVICE_ID/service_abc123/g' about-clean.html

# Replace YOUR_TEMPLATE_ID
sed -i '' 's/YOUR_TEMPLATE_ID/template_xyz789/g' about-clean.html
```

---

## Step 6: Test It!

1. **Commit and push:**
   ```bash
   git add about-clean.html
   git commit -m "Configure EmailJS for contact form"
   git push origin main
   ```

2. **Wait 1-2 minutes** for GitHub Pages to deploy

3. **Test the form:**
   - Go to https://www.landset.co/about-clean.html
   - Scroll to contact form
   - Fill it out and submit
   - Check steve@landset.co and danny@landset.co for the email!

---

## Troubleshooting

### Form shows "Something went wrong"
- Check browser console (F12) for errors
- Verify all three IDs are correct (no quotes, no extra spaces)
- Make sure you're testing on the live site (not file://)

### Email not received
- Check spam folder
- Verify both emails in "To Email" field in template
- Check EmailJS dashboard → "Email History" for logs

### "User ID is required" error
- Make sure public key is set correctly in `emailjs.init()`
- Clear browser cache and try again

---

## EmailJS Dashboard Links

- **Email History:** See all sent emails
- **Usage:** Check how many emails you've sent (200/month free)
- **Settings:** Update template, add more services

---

## Benefits of EmailJS

✅ **No backend needed** - Works with GitHub Pages
✅ **Free tier:** 200 emails/month (plenty for contact form)
✅ **Reliable:** Established service, good uptime
✅ **Easy setup:** No complex configuration
✅ **Template control:** Change email format anytime in dashboard
✅ **Multiple recipients:** Both Steve and Danny get emails
✅ **Email history:** See all submissions in dashboard

---

## Need Help?

1. Check EmailJS docs: https://www.emailjs.com/docs/
2. Video tutorial: https://www.emailjs.com/docs/tutorial/overview/
3. Their support is responsive if you get stuck

Once configured, your contact form will work perfectly! 🎉
