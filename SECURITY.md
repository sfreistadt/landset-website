# Security Checks Documentation

## Overview

The Landset website has automated security checks that run on every push and pull request to protect against common vulnerabilities and security issues.

## 🔒 Security Checks

### 1. Secret Scanning
**What it checks:**
- Hardcoded API keys, tokens, passwords
- AWS credentials
- Google API keys
- Stripe keys
- GitHub tokens
- Private keys
- Database connection strings
- JWT tokens
- `.env` files in repository

**Why it matters:**
Exposed secrets can lead to unauthorized access, data breaches, and financial loss.

**How to fix:**
1. Remove secrets from code immediately
2. Use environment variables instead
3. Add sensitive files to `.gitignore`
4. If secrets were committed, rotate them immediately
5. Use `git-filter-repo` to remove from history

### 2. XSS Vulnerability Detection
**What it checks:**
- `eval()` and `Function()` constructor usage
- Unsafe `innerHTML` assignments
- `document.write()` calls
- Inline event handlers in HTML
- `javascript:` and `data:` URLs
- Unsafe DOM manipulation (`insertAdjacentHTML`, `outerHTML`)
- URL parameters used in dangerous contexts
- Template literals with user input

**Why it matters:**
Cross-Site Scripting (XSS) allows attackers to inject malicious scripts into your website, potentially stealing user data or hijacking sessions.

**How to fix:**
1. Replace `eval()` with safer alternatives
2. Use `textContent` instead of `innerHTML` for user input
3. Sanitize HTML with DOMPurify before inserting
4. Use `addEventListener()` instead of inline event handlers
5. Implement Content Security Policy (CSP)
6. Always validate and encode user input

### 3. File Integrity Checks
**What it checks:**
- Oversized HTML files (>3MB)
- Oversized JavaScript files (>500KB)
- Oversized CSS files (>500KB)
- Large images (>2MB)
- Total repository size (>50MB)
- Unexpected file types
- Dangerous executables (`.exe`, `.dll`, `.so`, etc.)
- Duplicate files
- Empty files
- Suspicious file permissions

**Why it matters:**
Large files slow down your website and Git repository. Unexpected files might indicate malware or mistakes.

**How to fix:**
1. Minify and compress assets
2. Use Git LFS for large files
3. Remove executables and unnecessary files
4. Optimize images (compress, use WebP)
5. Split large files into smaller modules

### 4. JSON Validation
**What it checks:**
- Malformed JSON in JavaScript files
- Trailing commas
- Unmatched braces
- Unescaped quotes in JSON
- Syntax errors in all JS files
- Config file integrity

**Why it matters:**
JSON errors can break your application at runtime. The index.html has complex escaped HTML in JS templates that requires careful validation.

**How to fix:**
1. Remove trailing commas in objects/arrays
2. Use double quotes for JSON keys/values
3. Ensure all braces/brackets are matched
4. Validate JSON with `JSON.parse()` before use
5. Use a code formatter (Prettier) to catch issues

### 5. Dependency Checks
**What it checks:**
- Vulnerable CDN dependencies (old jQuery, AngularJS)
- External scripts from CDNs
- Library versions

**Why it matters:**
Outdated libraries have known security vulnerabilities that attackers can exploit.

**How to fix:**
1. Update to latest stable versions
2. Use Subresource Integrity (SRI) for CDN scripts
3. Consider self-hosting critical dependencies
4. Remove unused libraries

### 6. Permissions Check
**What it checks:**
- Files with suspicious permissions
- Executable HTML/CSS/MD files (shouldn't be executable)
- Non-executable shell scripts (should be executable)
- World-writable files

**Why it matters:**
Incorrect file permissions can expose sensitive files or allow unauthorized modifications.

**How to fix:**
```bash
# Remove executable bit from HTML/CSS files
chmod -x file.html

# Add executable bit to shell scripts
chmod +x script.sh

# Remove world-writable permissions
chmod 644 file.txt
```

### 7. Build Validation
**What it checks:**
- Debug code in production (`console.log`, `debugger`)
- Security-related TODO/FIXME comments
- Test/debug files in repository

**Why it matters:**
Debug code can leak sensitive information and slow down production performance.

**How to fix:**
1. Remove all `console.log` statements before committing
2. Use proper logging libraries with log levels
3. Complete or remove security TODOs
4. Add `debug*.html` and `test*.html` to `.gitignore`

## 🚀 Running Checks Locally

### Run All Checks
```bash
cd /Users/steve/Documents/GitHub/landset-website

# Run all security checks
.github/scripts/scan-secrets.sh
.github/scripts/scan-xss.sh
.github/scripts/check-file-integrity.sh
.github/scripts/validate-json-in-js.sh
```

### Run Individual Checks

**Secret Scanning:**
```bash
.github/scripts/scan-secrets.sh
```

**XSS Detection:**
```bash
.github/scripts/scan-xss.sh
```

**File Integrity:**
```bash
.github/scripts/check-file-integrity.sh
```

**JSON Validation:**
```bash
.github/scripts/validate-json-in-js.sh
```

### Review Results
All scripts create log files:
- `security-scan-secrets.log` - Secret scanning results
- `security-scan-xss.log` - XSS vulnerability results
- `security-scan-files.log` - File integrity results

## 📋 Pre-Commit Checklist

Before committing code, ensure:

- [ ] No API keys, tokens, or passwords in code
- [ ] No `eval()` or `Function()` constructor
- [ ] User input is sanitized before using in DOM
- [ ] No `console.log` or `debugger` statements
- [ ] Files are under size limits
- [ ] No executables committed
- [ ] All JavaScript files have valid syntax
- [ ] No security TODOs left unresolved

## 🔧 GitHub Actions Workflow

The security checks run automatically via GitHub Actions (`.github/workflows/security-checks.yml`) on:
- Every push to `main` or `develop` branches
- Every pull request to `main` or `develop`
- Manual trigger via "Actions" tab

**Workflow Jobs:**
1. `security-scan` - Runs secret scanning, XSS detection, file integrity
2. `dependency-check` - Checks for vulnerable CDN dependencies
3. `permissions-check` - Validates file permissions
4. `build-validation` - Checks for debug code and validates JSON
5. `summary` - Aggregates all results

**Artifacts:**
Security scan results are uploaded as artifacts and retained for 30 days.

## ⚠️ Interpreting Results

### Exit Codes
- `0` - All checks passed ✅
- `1` - Critical issues found ❌

### Severity Levels

**❌ ERROR (Blocks deployment):**
- Hardcoded secrets
- `eval()` usage
- Dangerous file types
- Syntax errors

**⚠️  WARNING (Review required):**
- Large files
- `innerHTML` usage
- Inline event handlers
- Debug code

**ℹ️  INFO (Informational):**
- File statistics
- Suggestions for improvement
- Best practices

## 🛡️ Security Best Practices

### 1. Content Security Policy (CSP)
Add CSP meta tags to all HTML files:
```html
<meta http-equiv="Content-Security-Policy"
      content="default-src 'self'; script-src 'self' 'unsafe-inline' https://trusted-cdn.com; style-src 'self' 'unsafe-inline';">
```

### 2. Subresource Integrity (SRI)
Use SRI for external scripts:
```html
<script src="https://cdn.example.com/library.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>
```

### 3. Input Validation
Always validate and sanitize user input:
```javascript
// Bad
element.innerHTML = userInput;

// Good
element.textContent = userInput;

// Or use DOMPurify
element.innerHTML = DOMPurify.sanitize(userInput);
```

### 4. Environment Variables
Never hardcode secrets:
```javascript
// Bad
const API_KEY = 'sk_live_abc123...';

// Good
const API_KEY = process.env.API_KEY;
```

### 5. HTTPS Only
Always use HTTPS for production:
```javascript
// Ensure API URLs use HTTPS
const API_URL = 'https://api.landset.co';
```

## 🆘 Troubleshooting

### Check Failed: "eval() found"
**Problem:** Code uses `eval()` which is dangerous.
**Solution:** Rewrite code to avoid `eval()`. Use `JSON.parse()` for JSON, or proper function calls.

### Check Failed: "API key detected"
**Problem:** Hardcoded API key found.
**Solution:**
1. Remove key from code immediately
2. Rotate the key (generate new one)
3. Use environment variables
4. Add `.env` to `.gitignore`

### Check Failed: "File too large"
**Problem:** File exceeds size limit.
**Solution:**
1. Minify JavaScript/CSS: `npx terser input.js -o output.min.js`
2. Compress images: Use ImageOptim, Squoosh, or WebP format
3. Split large files into modules

### Check Failed: "Syntax error in JavaScript"
**Problem:** JavaScript has syntax errors.
**Solution:**
1. Run `node -c filename.js` to identify error
2. Use ESLint for better error messages
3. Use a code editor with syntax highlighting

### Check Failed: "Executable HTML file"
**Problem:** HTML file has executable permissions.
**Solution:**
```bash
chmod 644 *.html
```

## 📞 Support

For security concerns or questions:
1. Review this documentation
2. Check the security scan logs
3. Review related docs: `DEPLOYMENT.md`, `TROUBLESHOOTING.md`
4. For vulnerabilities, report privately (don't create public issues)

## 🔄 Continuous Improvement

Security is an ongoing process. This system:
- ✅ Catches common mistakes automatically
- ✅ Provides actionable feedback
- ✅ Documents best practices
- ✅ Runs on every change

But remember:
- These checks are not exhaustive
- Manual code review is still important
- Stay updated on security best practices
- Test thoroughly before deployment

## 📚 Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Content Security Policy Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [DOMPurify Library](https://github.com/cure53/DOMPurify)
- [Git Filter Repo](https://github.com/newren/git-filter-repo)

---

**Last Updated:** May 27, 2026

**Maintained By:** Landset Security Team
