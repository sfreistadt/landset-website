#!/bin/bash

# Secret Scanning Script for Landset Website
# Detects hardcoded API keys, tokens, passwords, and other secrets

set -e

echo "🔍 Starting secret scanning..."
echo "================================"

FOUND_SECRETS=0
SCAN_LOG="security-scan-secrets.log"

# Clear previous log
> "$SCAN_LOG"

# Define patterns to search for
declare -a SECRET_PATTERNS=(
    # API Keys
    "api[_-]?key['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}"
    "apikey['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}"

    # Generic secrets
    "secret['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}"
    "password['\"]?\s*[:=]\s*['\"][^'\"\s]{8,}"
    "passwd['\"]?\s*[:=]\s*['\"][^'\"\s]{8,}"
    "pwd['\"]?\s*[:=]\s*['\"][^'\"\s]{8,}"

    # Tokens
    "token['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}"
    "access[_-]?token['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}"
    "auth[_-]?token['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}"
    "bearer['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}"

    # AWS
    "AKIA[0-9A-Z]{16}"
    "aws[_-]?access[_-]?key"
    "aws[_-]?secret[_-]?key"

    # Google API
    "AIza[0-9A-Za-z_-]{35}"

    # Stripe
    "sk_live_[0-9a-zA-Z]{24,}"
    "pk_live_[0-9a-zA-Z]{24,}"

    # GitHub
    "gh[pousr]_[0-9a-zA-Z]{36}"

    # Private keys
    "-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----"
    "-----BEGIN OPENSSH PRIVATE KEY-----"

    # Database connection strings
    "postgres://[^:]+:[^@]+@"
    "mysql://[^:]+:[^@]+@"
    "mongodb://[^:]+:[^@]+@"
    "redis://[^:]+:[^@]+@"

    # JWTs (base64.base64.base64 pattern)
    "eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}"
)

# Files to scan (excluding certain directories)
FILES_TO_SCAN=$(find . -type f \
    \( -name "*.html" -o -name "*.js" -o -name "*.json" -o -name "*.md" \) \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*")

echo "Scanning files for secrets..."
echo ""

# Scan for each pattern
for pattern in "${SECRET_PATTERNS[@]}"; do
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Use grep with Perl regex for more powerful matching
            MATCHES=$(grep -iPn "$pattern" "$file" 2>/dev/null || true)

            if [ ! -z "$MATCHES" ]; then
                echo "❌ POTENTIAL SECRET FOUND in $file:" | tee -a "$SCAN_LOG"
                echo "$MATCHES" | head -3 | tee -a "$SCAN_LOG"
                echo "" | tee -a "$SCAN_LOG"
                FOUND_SECRETS=$((FOUND_SECRETS + 1))
            fi
        fi
    done <<< "$FILES_TO_SCAN"
done

# Additional checks for common mistake patterns
echo "Checking for common security mistakes..."

# Check for .env files that shouldn't be committed
if find . -name ".env" -not -path "*/.git/*" | grep -q .; then
    echo "❌ ERROR: .env file found in repository!" | tee -a "$SCAN_LOG"
    find . -name ".env" -not -path "*/.git/*" | tee -a "$SCAN_LOG"
    FOUND_SECRETS=$((FOUND_SECRETS + 1))
fi

# Check for common config files with secrets
CONFIG_FILES=(".npmrc" ".pypirc" "credentials" "credentials.json" "service-account.json")
for config_file in "${CONFIG_FILES[@]}"; do
    if find . -name "$config_file" -not -path "*/.git/*" | grep -q .; then
        echo "⚠️  WARNING: $config_file found in repository" | tee -a "$SCAN_LOG"
        find . -name "$config_file" -not -path "*/.git/*" | tee -a "$SCAN_LOG"
    fi
done

# Check for hardcoded IPs (might indicate internal services)
echo ""
echo "Checking for hardcoded IP addresses..."
HARDCODED_IPS=$(grep -rIPn '\b(?:10|172\.(?:1[6-9]|2[0-9]|3[01])|192\.168)\.\d{1,3}\.\d{1,3}\b' \
    --include="*.js" --include="*.html" --exclude-dir=".git" . 2>/dev/null || true)

if [ ! -z "$HARDCODED_IPS" ]; then
    echo "⚠️  WARNING: Hardcoded private IP addresses found:" | tee -a "$SCAN_LOG"
    echo "$HARDCODED_IPS" | tee -a "$SCAN_LOG"
fi

# Check for TODO/FIXME with security keywords
echo ""
echo "Checking for security-related TODOs..."
SECURITY_TODOS=$(grep -rIPn '(TODO|FIXME|XXX).*?(security|password|token|secret|key)' \
    --include="*.js" --include="*.html" --exclude-dir=".git" . 2>/dev/null || true)

if [ ! -z "$SECURITY_TODOS" ]; then
    echo "⚠️  WARNING: Security-related TODOs found:" | tee -a "$SCAN_LOG"
    echo "$SECURITY_TODOS" | tee -a "$SCAN_LOG"
fi

# Summary
echo ""
echo "================================"
if [ $FOUND_SECRETS -gt 0 ]; then
    echo "❌ SECRET SCAN FAILED: Found $FOUND_SECRETS potential secret(s)"
    echo "Review the output above and $SCAN_LOG for details"
    echo ""
    echo "Common fixes:"
    echo "1. Remove secrets from code and use environment variables"
    echo "2. Add sensitive files to .gitignore"
    echo "3. If secrets were committed, rotate them immediately"
    echo "4. Use git-filter-repo or BFG to remove from history"
    exit 1
else
    echo "✅ SECRET SCAN PASSED: No obvious secrets detected"
    echo ""
    echo "Note: This is an automated scan. Always review code manually for sensitive data."
fi

echo "================================"
