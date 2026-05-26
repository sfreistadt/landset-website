# Troubleshooting Auth Feature Flag

## Issue: "localhost:8080 is forcing me to login"

This can happen if you previously enabled auth and the setting is cached.

### Quick Fix:

1. **Open browser console** (F12 or Cmd+Option+I)

2. **Clear localStorage:**
   ```javascript
   localStorage.clear()
   ```

3. **Hard refresh:**
   - Mac: `Cmd + Shift + R`
   - Windows/Linux: `Ctrl + Shift + F5`

4. **Verify auth is disabled:**
   ```javascript
   LandsetConfig.isFeatureEnabled('AUTH_ENABLED')
   // Should return: false
   ```

---

## Step-by-Step Verification

### Step 1: Check localStorage

Open console and run:
```javascript
localStorage.getItem('landset_auth_enabled')
```

If it returns `"true"`, that's the issue! Clear it:
```javascript
localStorage.removeItem('landset_auth_enabled')
```

### Step 2: Check URL parameters

Look at your browser address bar. If you see `?auth_enabled=true`, remove it:
```
http://localhost:8080/          ← Good
http://localhost:8080/?auth_enabled=true  ← This enables auth
```

### Step 3: Check config file loaded

```javascript
window.LandsetConfig
```

Should show the config object. If `undefined`, config.js isn't loading.

### Step 4: Check effective status

```javascript
LandsetConfig.isFeatureEnabled('AUTH_ENABLED')
```

Should return `false` if auth is disabled.

---

## Still Having Issues?

### Nuclear Option: Complete Reset

```javascript
// Clear everything
localStorage.clear()
sessionStorage.clear()

// Verify config
console.log('Auth enabled:', LandsetConfig.isFeatureEnabled('AUTH_ENABLED'))

// Force reload
location.href = location.origin
```

### Check Network Tab

1. Open DevTools → Network tab
2. Refresh page
3. Look for `config.js` - should load successfully
4. Check console for any errors

---

## Expected Behavior When Auth is DISABLED

✅ **Homepage loads normally** - No redirect
✅ **No login modal appears** - Auth UI hidden
✅ **CTA buttons hidden** - "Get Started" buttons not visible
✅ **Console shows:** `🔒 Auth is disabled. Enable with: enableAuth()`

❌ **Should NOT redirect to login**
❌ **Should NOT force authentication**

---

## Expected Behavior When Auth is ENABLED

✅ **If logged in:** Redirects to `/dashboard.html`
✅ **If not logged in:** Shows auth modal when clicking CTAs
✅ **Console shows:** `🔐 Auth modal initialized`

---

## Common Mistakes

### 1. Old localStorage from testing
**Solution:** `localStorage.clear()`

### 2. URL parameter left in address bar
**Solution:** Remove `?auth_enabled=true` from URL

### 3. Browser cache
**Solution:** Hard refresh (Cmd+Shift+R)

### 4. Wrong directory
**Solution:** Make sure you're serving `/Users/steve/Documents/GitHub/landset-website`

### 5. Server running on different port
**Solution:** Check which port - might be 8000 instead of 8080

---

## Debug Script

Run this in console to get full diagnostic info:

```javascript
console.log('=== AUTH FEATURE FLAG DEBUG ===')
console.log('Config loaded:', typeof LandsetConfig !== 'undefined')
console.log('Default config:', LandsetConfig?.features?.AUTH_ENABLED)
console.log('localStorage override:', localStorage.getItem('landset_auth_enabled'))
console.log('URL parameter:', new URLSearchParams(location.search).get('auth_enabled'))
console.log('Effective status:', LandsetConfig?.isFeatureEnabled('AUTH_ENABLED'))
console.log('Auth modal type:', typeof authModal)
console.log('================================')
```

Copy the output and share it if you need help debugging.
