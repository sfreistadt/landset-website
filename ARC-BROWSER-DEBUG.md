# ARC Browser Debug Guide

## For the user experiencing the error:

### Step 1: Check Console Logs
1. Open DevTools: `Cmd + Option + I` (Mac) or `Ctrl + Shift + I` (Windows)
2. Go to the "Console" tab
3. Refresh the page (`Cmd + R`)
4. Look for red error messages
5. Screenshot or copy the "Error details:" object that should appear

### Step 2: Try Incognito Mode
1. Open new Incognito/Private window
2. Visit `www.landset.co`
3. Does it work now?
   - **YES** → Problem is a browser extension interfering
   - **NO** → Continue to Step 3

### Step 3: Hard Refresh
1. Hold `Cmd + Shift + R` (Mac) or `Ctrl + Shift + R` (Windows)
2. This clears the cache and reloads
3. Does it work now?
   - **YES** → Was a caching issue
   - **NO** → Continue to Step 4

### Step 4: Check Script Tag
In the Console, paste this and hit Enter:
```javascript
document.querySelector('script[type="__bundler/template"]')?.textContent?.length
```

If it returns a number (should be ~60000), the template is there.
If it returns `undefined`, the script tag is missing.

### Step 5: Manual Test
In the Console, paste this to test JSON parsing:
```javascript
try {
  const el = document.querySelector('script[type="__bundler/template"]');
  const json = el.textContent.trim();
  const parsed = JSON.parse(json);
  console.log('✓ JSON parsed successfully, length:', parsed.length);
} catch (e) {
  console.error('✗ JSON parse failed:', e.message, 'at position', e.pos || 'unknown');
  console.error('Character at error:', json[e.pos], 'code:', json.charCodeAt(e.pos));
}
```

## What we're looking for:
- The specific error message
- Position where JSON parsing fails (if applicable)
- Whether it works in Incognito mode
- Browser version (check in ARC → About ARC)

## Send back:
Screenshot of Console showing the error details.
