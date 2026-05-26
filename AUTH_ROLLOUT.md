# Authentication Feature Rollout Guide

## Current Status

🔒 **Authentication is DISABLED in production** (hidden from users)

The authentication backend is fully functional, but the UI is hidden from public users using a feature flag system.

---

## Feature Flag System

All feature flags are controlled in `/app/config.js`

### Current Configuration

```javascript
features: {
  AUTH_ENABLED: false  // ← Set to true when ready for public rollout
}
```

---

## Testing Authentication (Before Public Rollout)

You have **3 ways** to enable auth for testing without changing production config:

### Option 1: Browser Console (Easiest for Quick Testing)

Open browser DevTools console and run:

```javascript
enableAuth()
```

Then refresh the page. To disable:

```javascript
disableAuth()
```

### Option 2: URL Parameter (Share with Beta Testers)

Add `?auth_enabled=true` to any URL:

```
https://landset.co/?auth_enabled=true
https://landset.co/request-report.html?auth_enabled=true
```

This enables auth for that page load only.

### Option 3: localStorage (Persistent Beta Access)

For persistent beta testing, run this once in console:

```javascript
localStorage.setItem('landset_auth_enabled', 'true')
```

This enables auth permanently for that browser until cleared with:

```javascript
localStorage.removeItem('landset_auth_enabled')
```

---

## Rollout Phases

### Phase 1: Internal Testing ✅ (Current Phase)

- Auth backend deployed and running
- Auth UI hidden from public
- Internal team tests using `enableAuth()` or URL parameter
- **Action:** Test all auth flows locally

### Phase 2: Beta Testing

1. **Select 10-50 beta testers**
2. **Send them the magic URL:**
   ```
   https://landset.co/?auth_enabled=true
   ```
3. **Or guide them to enable it:**
   - Visit landset.co
   - Open DevTools console (F12)
   - Run: `enableAuth()`
   - Refresh page

4. **Monitor for issues:**
   - Check server logs for errors
   - Collect user feedback
   - Fix any bugs before full launch

### Phase 3: Soft Launch

1. **Update `app/config.js`:**
   ```javascript
   AUTH_ENABLED: true  // Enable for everyone
   ```

2. **Deploy updated config**

3. **Verify:**
   - Visit landset.co in incognito
   - Confirm auth UI is visible
   - Test registration flow

### Phase 4: Full Launch

1. **Add prominent CTAs:**
   - "Sign In" button in navigation
   - "Get Started" on homepage
   - Update marketing materials

2. **Announce:**
   - Email to existing users
   - Social media
   - Update website copy

---

## Checking Current Auth Status

### In Development (localhost)

When you load the page, check the console:

```
🔐 Auth enabled: false
💡 To enable auth: enableAuth() or visit ?auth_enabled=true
```

### In Production

Run in console:

```javascript
LandsetConfig.isFeatureEnabled('AUTH_ENABLED')
```

Returns `true` if enabled, `false` if disabled.

---

## What Happens When Auth is Disabled?

✅ **Backend still works** - API endpoints are active
✅ **Existing sessions preserved** - Logged-in users stay logged in
✅ **Direct API calls work** - For testing with curl/Postman

❌ **Auth modal hidden** - UI won't appear
❌ **Login buttons hidden** - CTAs removed from page
❌ **New users can't register** - No UI to sign up

---

## Troubleshooting

### "I enabled auth but don't see the login modal"

1. Clear browser cache (Cmd+Shift+R / Ctrl+Shift+F5)
2. Check console for errors
3. Verify config.js is loaded:
   ```javascript
   window.LandsetConfig
   ```
4. Check feature status:
   ```javascript
   LandsetConfig.isFeatureEnabled('AUTH_ENABLED')
   ```

### "I want to reset to default settings"

```javascript
resetAuth()
```

Or manually:

```javascript
localStorage.removeItem('landset_auth_enabled')
```

### "I deployed config.js but auth still disabled"

1. Verify config file deployed:
   ```
   curl https://landset.co/app/config.js
   ```

2. Check line with `AUTH_ENABLED`:
   ```javascript
   AUTH_ENABLED: true  // Should be true
   ```

3. Hard refresh browser (Cmd+Shift+R)

---

## Testing Checklist Before Public Launch

- [ ] Backend server running (port 3000)
- [ ] Database initialized (`bash db/init-auth.sh`)
- [ ] Redis running
- [ ] Environment variables set (JWT_SECRET, DATABASE_URL, REDIS_URL)
- [ ] Test registration with `enableAuth()` or `?auth_enabled=true`
- [ ] Test login flow
- [ ] Test logout
- [ ] Test session persistence (refresh page)
- [ ] Test rate limiting (5 failed logins)
- [ ] Test report generation while authenticated
- [ ] Test dashboard access
- [ ] Verify cookies set correctly (HttpOnly, Secure in prod)
- [ ] Test on mobile devices
- [ ] Check HTTPS works in production
- [ ] Monitor server logs for errors

---

## Deployment Commands

### Deploy Frontend (GitHub Pages / Static Host)

```bash
cd /Users/steve/Documents/GitHub/landset-website
git add app/config.js app/auth.js app/utils.js index.html dashboard.html
git commit -m "Add auth feature flag system"
git push origin main
```

### Enable Auth in Production

Edit `app/config.js`:

```diff
- AUTH_ENABLED: false,
+ AUTH_ENABLED: true,
```

Then commit and deploy:

```bash
git add app/config.js
git commit -m "Enable authentication for public rollout"
git push origin main
```

---

## Questions?

- **Backend not responding?** Check that backend server is running on port 3000
- **CORS errors?** Verify backend allows `landset.co` origin
- **Cookies not set?** Check backend is using `credentials: 'include'` and frontend origin is whitelisted
- **Need to rollback?** Set `AUTH_ENABLED: false` and redeploy

---

## Files Modified

- ✅ `/app/config.js` - Feature flag configuration (NEW)
- ✅ `/app/auth.js` - Respects AUTH_ENABLED flag
- ✅ `/app/utils.js` - Hides CTAs when auth disabled
- ✅ `/index.html` - Loads config.js
- ✅ `/dashboard.html` - Loads config.js
