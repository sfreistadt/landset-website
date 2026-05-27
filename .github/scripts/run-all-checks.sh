#!/bin/bash

# Run All Security Checks
# Convenient script to run all security checks locally

set -e

echo "🔒 Running All Security Checks for Landset Website"
echo "==================================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILED_CHECKS=0

# Function to run a check and track results
run_check() {
    local check_name="$1"
    local check_script="$2"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Running: $check_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if bash "$SCRIPT_DIR/$check_script"; then
        echo "✅ $check_name: PASSED"
    else
        echo "❌ $check_name: FAILED"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Run all checks
run_check "Secret Scanning" "scan-secrets.sh"
run_check "XSS Vulnerability Detection" "scan-xss.sh"
run_check "File Integrity Checks" "check-file-integrity.sh"
run_check "JSON Validation" "validate-json-in-js.sh"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SECURITY CHECK SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo "✅ ALL CHECKS PASSED!"
    echo ""
    echo "Your code is ready to commit. Great job! 🎉"
    echo ""
    echo "Next steps:"
    echo "1. Review any warnings in the output above"
    echo "2. Commit your changes: git add . && git commit -m 'Your message'"
    echo "3. Push to GitHub: git push"
    exit 0
else
    echo "❌ $FAILED_CHECKS CHECK(S) FAILED"
    echo ""
    echo "Please fix the issues above before committing."
    echo ""
    echo "Common fixes:"
    echo "- Remove hardcoded secrets (use environment variables)"
    echo "- Replace eval() with safer alternatives"
    echo "- Sanitize user input before using in DOM"
    echo "- Optimize large files (minify, compress)"
    echo "- Fix syntax errors in JavaScript"
    echo ""
    echo "Review logs:"
    ls -1 security-scan-*.log 2>/dev/null | while read log; do
        echo "  - $log"
    done
    echo ""
    echo "For help, see: SECURITY.md"
    exit 1
fi
