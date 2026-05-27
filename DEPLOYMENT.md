# Landset Frontend Deployment Guide

## 🔐 Security Validation - PASSED ✅

Last validated: May 26, 2026

### Security Checklist

| Check | Status | Notes |
|-------|--------|-------|
| `.env` in `.gitignore` (backend) | ✅ PASS | Line 2 of backend `.gitignore` |
| No API keys in frontend | ✅ PASS | Only safe config values |
| Backend auth/authorization | ✅ PASS | `requireAuth` middleware on all protected routes |
| DB credentials server-only | ✅ PASS | No credentials in frontend code |
| Sensitive logic in backend | ✅ PASS | Report generation (71KB), analysis (38KB) server-side |
| API URL configuration | ✅ PASS | Uses production URL from config |

### Automated Security Checks

**Run security checks before deploying:**
```bash
# Quick check - run all security scans
.github/scripts/run-all-checks.sh
```

These automated checks scan for:
- Hardcoded secrets and API keys
- XSS vulnerabilities (eval, innerHTML, etc.)
- Oversized files
- Dangerous file types
- JSON syntax errors

For details, see: `SECURITY.md`

### What's Public vs. Private

**✅ Public (Frontend - Visible in Browser):**
- HTML, CSS, JavaScript files
- API client code (`app/api.js`)
- Auth modal UI (`app/auth.js`)
- Form validation
- API endpoint URLs

**❌ Private (Backend - Server Only):**
- Report generation algorithms (`src/report.js` - 71KB)
- AI analysis logic (`src/analysis.js` - 38KB)
- Database queries (`src/permits.js`)
- API keys and secrets (`.env`)
- Authentication logic (`src/auth.js`)
- Business logic and data processing

---

## 🚀 Deployment Options

### Option 1: Frontend Only (Recommended for Launch)

**Current State:**
- ✅ Auth feature flag: `AUTH_ENABLED: false`
- ✅ Users see "Get early access" → Tally waitlist form
- ✅ No backend required yet

**Deploy To:**
- GitHub Pages (free)
- Netlify (free)
- Vercel (free)
- Cloudflare Pages (free)

**Steps:**
1. Push to GitHub
2. Enable GitHub Pages in repo settings
3. Done! Site is live.

---

### Option 2: Full Stack (Frontend + Backend)

**Requirements:**
1. ✅ Deploy backend server
2. ✅ Set up PostgreSQL database
3. ✅ Set up Redis
4. ✅ Update `app/config.js` with production API URL
5. ✅ Enable auth: `AUTH_ENABLED: true`

---

## 📦 Backend Deployment (When Ready)

### Recommended: Railway

**Why Railway?**
- ✅ Free PostgreSQL included
- ✅ Free Redis included
- ✅ Auto-deploys from GitHub
- ✅ Simple environment variables
- ✅ ~$5-20/month

**Steps:**

1. **Create Railway Account**
   - Go to [railway.app](https://railway.app)
   - Sign in with GitHub

2. **Create New Project**
   - "New Project" → "Deploy from GitHub"
   - Select `landset` repository
   - Railway will detect Node.js and auto-configure

3. **Add Database Services**
   - Click "+ New" → "Database" → "PostgreSQL"
   - Click "+ New" → "Database" → "Redis"
   - Railway auto-connects via environment variables

4. **Set Environment Variables**

   Railway auto-sets:
   - `DATABASE_URL` (from PostgreSQL)
   - `REDIS_URL` (from Redis)

   Add manually:
   ```bash
   NODE_ENV=production
   JWT_SECRET=<generate with: openssl rand -base64 32>
   CSRF_SECRET=<generate with: openssl rand -base64 32>
   PORT=3000
   ```

5. **Initialize Database**

   After first deploy, run migrations:
   ```bash
   # In Railway console:
   bash db/init-auth.sh
   ```

6. **Get Your API URL**

   Railway provides:
   ```
   https://landset-api-production.up.railway.app
   ```

   Copy this URL for frontend config.

---

### Alternative: Render

**Steps:**
1. Go to [render.com](https://render.com)
2. "New +" → "Web Service"
3. Connect `landset` repo
4. Set build command: `npm install`
5. Set start command: `npm start`
6. Add PostgreSQL (free tier available)
7. Add Redis
8. Set environment variables
9. Deploy

---

## 🔧 Frontend Configuration

### Update API URL (When Backend is Deployed)

**File:** `app/config.js`

**Change line 25:**
```javascript
// Before:
: 'https://api.landset.co',  // Update with your production API URL

// After:
: 'https://landset-api-production.up.railway.app',  // Your actual Railway URL
```

Or if using custom domain:
```javascript
: 'https://api.landset.co',  // Your custom domain
```

---

## 🎯 Current Deployment Strategy

### Phase 1: Launch Waitlist (NOW) ✅

**Status:** Ready to deploy

**Configuration:**
- `AUTH_ENABLED: false` (already set)
- Backend: Not needed
- Database: Not needed

**What Users See:**
1. Homepage loads
2. Click "Get early access" → Scrolls to bottom
3. Click "GET EARLY ACCESS →" → Tally form modal opens
4. User submits waitlist form

**Deploy:**
```bash
cd /Users/steve/Documents/GitHub/landset-website
git add .
git commit -m "Add auth feature flag system and Tally waitlist integration"
git push origin main
```

Then enable GitHub Pages:
- Repo → Settings → Pages
- Source: `main` branch
- Save

Site will be live at: `https://yourusername.github.io/landset-website/`

---

### Phase 2: Deploy Backend (LATER)

**When you're ready:**
1. Deploy backend to Railway/Render
2. Initialize database
3. Test API endpoints
4. Update `app/config.js` with production URL
5. Redeploy frontend

---

### Phase 3: Enable Authentication (LATER)

**After backend is live:**

1. **Update config:**
   ```javascript
   // app/config.js
   AUTH_ENABLED: true  // Change from false
   ```

2. **Push update:**
   ```bash
   git add app/config.js
   git commit -m "Enable authentication"
   git push origin main
   ```

3. **Users now see:**
   - "LOGIN" button (not "Get early access")
   - Can register/login
   - Access dashboard
   - Generate reports

---

## 🧪 Testing Before Production

### Test Locally with Auth Enabled

```bash
# Terminal 1: Backend
cd /Users/steve/Documents/GitHub/landset
npm run dev

# Terminal 2: Frontend
cd /Users/steve/Documents/GitHub/landset-website
python3 -m http.server 8080

# Browser console:
enableAuth()
# Refresh page - should see "LOGIN" button
```

### Test with ngrok (Public URL)

```bash
# Terminal 1: Backend
cd /Users/steve/Documents/GitHub/landset
npm run dev

# Terminal 2: Expose publicly
ngrok http 3000
# Copy the https://xxxx.ngrok.io URL

# Terminal 3: Update frontend config temporarily
# Change baseURL to ngrok URL
# Serve frontend and test
```

---

## 📋 Pre-Deployment Checklist

### Before Pushing Frontend:

- [ ] **Run security checks:** `.github/scripts/run-all-checks.sh` ✅ ALL PASSED
- [x] `AUTH_ENABLED: false` (for waitlist-only launch)
- [x] Tally form URL correct: `https://tally.so/r/RGbKZ9`
- [x] No API keys in code
- [x] `.gitignore` excludes sensitive files
- [x] Test locally: `python3 -m http.server 8080`
- [x] Test Tally modal opens correctly
- [x] Test "Get early access" scroll behavior

### Before Enabling Auth:

- [ ] Backend deployed and accessible
- [ ] Database initialized (`bash db/init-auth.sh`)
- [ ] Environment variables set
- [ ] `app/config.js` has production API URL
- [ ] Test registration/login
- [ ] Test report generation
- [ ] Update `AUTH_ENABLED: true`

---

## 🆘 Troubleshooting

### Issue: "Get early access" doesn't scroll

**Fix:** Clear browser cache, hard refresh (`Cmd+Shift+R`)

### Issue: Tally modal doesn't open

**Check:**
1. Console for JavaScript errors
2. Tally embed script loaded
3. `openTallyModal()` function exists

### Issue: Infinite redirect loop (when auth enabled)

**Fix:** Already fixed in `utils.js` - `api.onUnauthorized` only redirects on protected pages

### Issue: Login doesn't work in production

**Check:**
1. Backend is deployed and running
2. `app/config.js` points to correct backend URL
3. Backend CORS allows your frontend domain
4. Browser console for network errors

---

## 📞 Support

- **Frontend repo:** `/Users/steve/Documents/GitHub/landset-website`
- **Backend repo:** `/Users/steve/Documents/GitHub/landset`
- **Docs:** `AUTH_ROLLOUT.md`, `TROUBLESHOOTING.md`, `DEPLOYMENT.md`

---

## 🎉 Summary

**Current state:** Ready to deploy frontend-only with waitlist

**Next steps:**
1. ✅ Push to GitHub
2. ✅ Enable GitHub Pages
3. ⏳ Deploy backend when ready
4. ⏳ Enable auth when backend is live

**You're all set!** 🚀
