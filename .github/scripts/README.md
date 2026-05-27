# Security Check Scripts

Automated security scanning scripts for the Landset website.

## Quick Start

```bash
# Run all checks at once (recommended)
.github/scripts/run-all-checks.sh

# Or run individual checks
.github/scripts/scan-secrets.sh
.github/scripts/scan-xss.sh
.github/scripts/check-file-integrity.sh
.github/scripts/validate-json-in-js.sh
```

## Scripts

### `run-all-checks.sh`
**Purpose:** Run all security checks in sequence
**When to use:** Before committing code
**Output:** Summary of all checks with pass/fail status

### `scan-secrets.sh`
**Purpose:** Detect hardcoded secrets, API keys, tokens, passwords
**Checks for:**
- API keys (AWS, Google, Stripe, GitHub)
- Passwords and tokens
- Private keys
- Database connection strings
- `.env` files in repository

**Exit code:** 0 = pass, 1 = secrets found

### `scan-xss.sh`
**Purpose:** Detect Cross-Site Scripting (XSS) vulnerabilities
**Checks for:**
- `eval()` and `Function()` constructor
- Unsafe `innerHTML`, `outerHTML`, `insertAdjacentHTML`
- `document.write()`
- Inline event handlers
- `javascript:` and `data:` URLs
- URL parameters in dangerous contexts

**Exit code:** 0 = pass, 1 = critical vulnerabilities found

### `check-file-integrity.sh`
**Purpose:** Validate file sizes, types, and integrity
**Checks for:**
- Oversized files (HTML >3MB, JS/CSS >500KB, images >2MB)
- Dangerous file types (executables)
- Duplicate files
- Suspicious permissions
- Total repository size

**Exit code:** 0 = pass, 1 = critical issues found

### `validate-json-in-js.sh`
**Purpose:** Validate JSON structures in JavaScript and HTML
**Checks for:**
- Malformed JSON objects
- Trailing commas
- Unmatched braces
- Syntax errors in all JS files
- Config file integrity

**Exit code:** 0 = pass, 1 = syntax errors found

## Output Files

All scripts generate log files:
- `security-scan-secrets.log`
- `security-scan-xss.log`
- `security-scan-files.log`

These files are gitignored and contain detailed scan results.

## CI/CD Integration

These scripts are automatically run by GitHub Actions on every:
- Push to `main` or `develop` branches
- Pull request to `main` or `develop`

See `.github/workflows/security-checks.yml` for the workflow configuration.

## Requirements

- Bash shell
- Node.js (for JavaScript syntax validation)
- Standard Unix tools: `find`, `grep`, `du`, `file`, `md5sum`

## Exit Codes

- `0` - All checks passed ✅
- `1` - Critical issues found ❌

## Examples

### Check before committing
```bash
# Run all checks
.github/scripts/run-all-checks.sh

# If passed, commit
git add .
git commit -m "Your message"
git push
```

### Check specific concerns
```bash
# Just check for secrets
.github/scripts/scan-secrets.sh

# Just check for XSS
.github/scripts/scan-xss.sh
```

### Review results
```bash
# Check if logs exist
ls -la security-scan-*.log

# Read detailed results
cat security-scan-secrets.log
```

## Troubleshooting

### Permission denied
```bash
chmod +x .github/scripts/*.sh
```

### Node command not found
Install Node.js: https://nodejs.org/

### False positives
Review the log files to see exactly what was flagged. Not all warnings are actual vulnerabilities.

## Documentation

For detailed documentation, see:
- `SECURITY.md` - Complete security documentation
- `DEPLOYMENT.md` - Deployment guide with security checklist

## Support

For questions or issues with these scripts:
1. Check `SECURITY.md` for troubleshooting
2. Review the log files for detailed error messages
3. Ensure all requirements are installed

---

**Last Updated:** May 27, 2026
