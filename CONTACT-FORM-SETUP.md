# Contact Form Setup Guide

The about page now has a contact form that sends to both danny@landset.co and steve@landset.co. You need to configure two services:

## 1. Set Up Formspree (Form Backend)

Formspree is a free service for handling form submissions on static sites.

### Steps:

1. **Go to [Formspree.io](https://formspree.io/)** and sign up for a free account

2. **Create a new form:**
   - Click "New Form"
   - Name it: "Landset Contact Form"
   - Set email to: `steve@landset.co, danny@landset.co`
   - Click "Create Form"

3. **Get your Form ID:**
   - After creating, you'll see a form endpoint like: `https://formspree.io/f/xyzabc123`
   - Copy the form ID (the part after `/f/`): `xyzabc123`

4. **Update about-clean.html:**
   - Find this line: `<form id="contactForm" action="https://formspree.io/f/YOUR_FORM_ID" method="POST">`
   - Replace `YOUR_FORM_ID` with your actual form ID: `xyzabc123`

5. **Configure Formspree settings:**
   - In Formspree dashboard, go to form settings
   - **Notifications:** Confirm both steve@landset.co and danny@landset.co are set
   - **Spam Protection:** Enable built-in spam protection
   - **Email Template:** Customize if desired

### Free Plan Limits:
- 50 submissions/month
- Perfect for starting out
- Upgrade to paid plan if needed (starts at $10/mo for 1,000 submissions)

---

## 2. Set Up Google reCAPTCHA (Spam Protection)

reCAPTCHA protects your form from bots and spam.

### Steps:

1. **Go to [Google reCAPTCHA Admin](https://www.google.com/recaptcha/admin)**

2. **Register a new site:**
   - **Label:** "Landset Contact Form"
   - **reCAPTCHA type:** Select "reCAPTCHA v2" → "I'm not a robot" Checkbox
   - **Domains:** Add:
     - `www.landset.co`
     - `landset.co`
     - `sfreistadt.github.io` (for testing)
   - Accept terms and click "Submit"

3. **Get your Site Key:**
   - After submitting, you'll see two keys:
     - **Site Key** (public) - starts with `6Le...`
     - **Secret Key** (private) - keep this secret
   - Copy the **Site Key**

4. **Update about-clean.html:**
   - Find this line: `<div class="g-recaptcha" data-sitekey="YOUR_RECAPTCHA_SITE_KEY"></div>`
   - Replace `YOUR_RECAPTCHA_SITE_KEY` with your actual site key

5. **Add Secret Key to Formspree:**
   - Go back to Formspree dashboard
   - Click on your form → Settings → Integrations
   - Add "Google reCAPTCHA"
   - Paste your **Secret Key**
   - Save

---

## 3. Test the Form

1. Update both files with your keys
2. Commit and push to GitHub
3. Wait 1-2 minutes for deployment
4. Go to https://www.landset.co/about-clean.html
5. Scroll to the contact form
6. Fill it out and test:
   - Make sure reCAPTCHA appears
   - Submit a test message
   - Check both steve@landset.co and danny@landset.co for the email

---

## Alternative: Use Netlify Forms (If you switch from GitHub Pages)

If you ever move to Netlify hosting, you can use their built-in forms:

1. Add `netlify` attribute to form tag:
   ```html
   <form name="contact" netlify netlify-recaptcha>
   ```

2. No backend needed - Netlify handles everything
3. Free plan: 100 submissions/month
4. Built-in spam protection

---

## Troubleshooting

### Form not sending
- Check browser console for errors
- Verify Formspree Form ID is correct
- Make sure you're using the form on the live domain (not `file://`)

### reCAPTCHA not showing
- Check browser console for errors
- Verify site key is correct
- Make sure domain is registered in reCAPTCHA admin

### Emails not received
- Check spam folder
- Verify email addresses in Formspree dashboard
- Check Formspree dashboard for submission logs

### "Please complete the reCAPTCHA" error
- Make sure reCAPTCHA loaded (check console)
- Try refreshing the page
- Verify reCAPTCHA site key is correct

---

## Quick Reference

**Files to update:**
- `about-clean.html` (2 places)

**Find and replace:**
1. `YOUR_FORM_ID` → Your Formspree form ID
2. `YOUR_RECAPTCHA_SITE_KEY` → Your Google reCAPTCHA site key

**After updating:**
```bash
git add about-clean.html
git commit -m "Configure contact form with Formspree and reCAPTCHA"
git push origin main
```

---

## Privacy & Security Notes

- **Site Key is public** - safe to put in HTML
- **Secret Key is private** - only add to Formspree, never in code
- Formspree uses TLS encryption for submissions
- reCAPTCHA data is governed by Google's privacy policy
- Consider adding a link to your privacy policy near the form

---

## Need Help?

- **Formspree Support:** https://help.formspree.io/
- **reCAPTCHA Help:** https://developers.google.com/recaptcha/docs/display

Once configured, your contact form will be live and both Steve and Danny will receive submissions!
