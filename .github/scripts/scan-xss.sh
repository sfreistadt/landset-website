#!/bin/bash

# XSS Vulnerability Detection Script for Landset Website
# Detects potential Cross-Site Scripting (XSS) vulnerabilities

set -e

echo "🛡️  Starting XSS vulnerability scan..."
echo "================================"

FOUND_ISSUES=0
SCAN_LOG="security-scan-xss.log"

# Clear previous log
> "$SCAN_LOG"

echo "Scanning JavaScript files for XSS vulnerabilities..."
echo ""

# Files to scan
JS_FILES=$(find . -type f -name "*.js" \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*")

HTML_FILES=$(find . -type f -name "*.html" \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*")

# Check 1: Dangerous functions - eval(), Function constructor
echo "1. Checking for eval() and Function constructor..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Check for eval()
        EVAL_MATCHES=$(grep -n "eval\s*(" "$file" 2>/dev/null || true)
        if [ ! -z "$EVAL_MATCHES" ]; then
            echo "❌ CRITICAL: eval() found in $file:" | tee -a "$SCAN_LOG"
            echo "$EVAL_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: Remote code execution" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        fi

        # Check for Function constructor
        FUNCTION_MATCHES=$(grep -n "new\s\+Function\s*(" "$file" 2>/dev/null || true)
        if [ ! -z "$FUNCTION_MATCHES" ]; then
            echo "❌ CRITICAL: Function constructor found in $file:" | tee -a "$SCAN_LOG"
            echo "$FUNCTION_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: Similar to eval(), allows code injection" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        fi
    fi
done <<< "$JS_FILES"

# Check 2: innerHTML without sanitization
echo "2. Checking for innerHTML usage..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        INNERHTML_MATCHES=$(grep -n "\.innerHTML\s*=" "$file" 2>/dev/null || true)
        if [ ! -z "$INNERHTML_MATCHES" ]; then
            echo "⚠️  WARNING: innerHTML assignment found in $file:" | tee -a "$SCAN_LOG"
            echo "$INNERHTML_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: XSS if user input is not sanitized" | tee -a "$SCAN_LOG"
            echo "  Recommendation: Use textContent or sanitize with DOMPurify" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
        fi
    fi
done <<< "$JS_FILES"

# Check 3: document.write()
echo "3. Checking for document.write()..."
ALL_FILES=$(echo -e "$JS_FILES\n$HTML_FILES")
while IFS= read -r file; do
    if [ -f "$file" ]; then
        DOCWRITE_MATCHES=$(grep -n "document\.write\s*(" "$file" 2>/dev/null || true)
        if [ ! -z "$DOCWRITE_MATCHES" ]; then
            echo "⚠️  WARNING: document.write() found in $file:" | tee -a "$SCAN_LOG"
            echo "$DOCWRITE_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: Can be exploited for XSS, blocks page rendering" | tee -a "$SCAN_LOG"
            echo "  Recommendation: Use DOM manipulation instead" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
        fi
    fi
done <<< "$ALL_FILES"

# Check 4: Unsafe event handlers in HTML
echo "4. Checking for inline event handlers in HTML..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        EVENT_MATCHES=$(grep -niP 'on(click|load|error|mouseover|submit|change)\s*=' "$file" 2>/dev/null || true)
        if [ ! -z "$EVENT_MATCHES" ]; then
            echo "⚠️  WARNING: Inline event handlers found in $file:" | tee -a "$SCAN_LOG"
            echo "$EVENT_MATCHES" | head -5 | tee -a "$SCAN_LOG"
            echo "  Risk: Inline event handlers can be XSS vectors" | tee -a "$SCAN_LOG"
            echo "  Recommendation: Use addEventListener() instead" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
        fi
    fi
done <<< "$HTML_FILES"

# Check 5: Dangerous URL schemes (javascript:, data:)
echo "5. Checking for javascript: and data: URLs..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Check for javascript: URLs
        JS_URL_MATCHES=$(grep -niP '(href|src)\s*=\s*["\']javascript:' "$file" 2>/dev/null || true)
        if [ ! -z "$JS_URL_MATCHES" ]; then
            echo "❌ CRITICAL: javascript: URL found in $file:" | tee -a "$SCAN_LOG"
            echo "$JS_URL_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: XSS vulnerability" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        fi

        # Check for data: URLs (can be risky with user input)
        DATA_URL_MATCHES=$(grep -niP '(href|src)\s*=\s*["\']data:' "$file" 2>/dev/null || true)
        if [ ! -z "$DATA_URL_MATCHES" ]; then
            echo "⚠️  WARNING: data: URL found in $file:" | tee -a "$SCAN_LOG"
            echo "$DATA_URL_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: Can be XSS vector if user-controlled" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
        fi
    fi
done <<< "$HTML_FILES"

# Check 6: Unsafe DOM manipulation
echo "6. Checking for unsafe DOM manipulation patterns..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Check for insertAdjacentHTML
        INSERT_MATCHES=$(grep -n "insertAdjacentHTML\s*(" "$file" 2>/dev/null || true)
        if [ ! -z "$INSERT_MATCHES" ]; then
            echo "⚠️  WARNING: insertAdjacentHTML found in $file:" | tee -a "$SCAN_LOG"
            echo "$INSERT_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: XSS if user input is not sanitized" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
        fi

        # Check for outerHTML
        OUTER_MATCHES=$(grep -n "\.outerHTML\s*=" "$file" 2>/dev/null || true)
        if [ ! -z "$OUTER_MATCHES" ]; then
            echo "⚠️  WARNING: outerHTML assignment found in $file:" | tee -a "$SCAN_LOG"
            echo "$OUTER_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: XSS if user input is not sanitized" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
        fi
    fi
done <<< "$JS_FILES"

# Check 7: User input handling
echo "7. Checking for potential user input handling issues..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Look for location.search, location.hash usage
        LOCATION_MATCHES=$(grep -n "location\.\(search\|hash\|href\)" "$file" 2>/dev/null || true)
        if [ ! -z "$LOCATION_MATCHES" ]; then
            # Only flag if it's being used in potentially dangerous ways
            DANGEROUS_LOCATION=$(echo "$LOCATION_MATCHES" | grep -iE "(innerHTML|eval|Function|document\.write)" || true)
            if [ ! -z "$DANGEROUS_LOCATION" ]; then
                echo "❌ CRITICAL: URL parameters used unsafely in $file:" | tee -a "$SCAN_LOG"
                echo "$DANGEROUS_LOCATION" | tee -a "$SCAN_LOG"
                echo "  Risk: Reflected XSS vulnerability" | tee -a "$SCAN_LOG"
                echo "" | tee -a "$SCAN_LOG"
                FOUND_ISSUES=$((FOUND_ISSUES + 1))
            fi
        fi

        # Check for URLSearchParams without validation
        URLPARAMS_MATCHES=$(grep -n "URLSearchParams\|getParameter" "$file" 2>/dev/null || true)
        if [ ! -z "$URLPARAMS_MATCHES" ]; then
            echo "ℹ️  INFO: URL parameter parsing found in $file:" | tee -a "$SCAN_LOG"
            echo "$URLPARAMS_MATCHES" | head -3 | tee -a "$SCAN_LOG"
            echo "  Review: Ensure user input is validated and sanitized" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
        fi
    fi
done <<< "$JS_FILES"

# Check 8: Template literals with user input
echo "8. Checking for template literals that might include user input..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        # This is a heuristic check - look for template literals used with innerHTML
        TEMPLATE_MATCHES=$(grep -n '\.innerHTML.*`.*\${' "$file" 2>/dev/null || true)
        if [ ! -z "$TEMPLATE_MATCHES" ]; then
            echo "⚠️  WARNING: Template literal in innerHTML in $file:" | tee -a "$SCAN_LOG"
            echo "$TEMPLATE_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: XSS if template includes user input" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
        fi
    fi
done <<< "$JS_FILES"

# Check 9: Unsafe regular expressions (ReDoS potential)
echo "9. Checking for potentially unsafe regular expressions..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Look for regex patterns with nested quantifiers
        REDOS_MATCHES=$(grep -nP '/\([^)]*\+[^)]*\)\+|/\([^)]*\*[^)]*\)\*' "$file" 2>/dev/null || true)
        if [ ! -z "$REDOS_MATCHES" ]; then
            echo "⚠️  WARNING: Potentially vulnerable regex in $file:" | tee -a "$SCAN_LOG"
            echo "$REDOS_MATCHES" | tee -a "$SCAN_LOG"
            echo "  Risk: ReDoS (Regular Expression Denial of Service)" | tee -a "$SCAN_LOG"
            echo "" | tee -a "$SCAN_LOG"
        fi
    fi
done <<< "$JS_FILES"

# Summary
echo ""
echo "================================"
if [ $FOUND_ISSUES -gt 0 ]; then
    echo "❌ XSS SCAN FAILED: Found $FOUND_ISSUES critical issue(s)"
    echo "Review the output above and $SCAN_LOG for details"
    echo ""
    echo "Common fixes:"
    echo "1. Replace eval() and Function() with safer alternatives"
    echo "2. Use textContent instead of innerHTML for user input"
    echo "3. Sanitize HTML with DOMPurify before inserting"
    echo "4. Implement Content Security Policy (CSP)"
    echo "5. Validate and encode all user input"
    exit 1
else
    echo "✅ XSS SCAN PASSED: No critical XSS vulnerabilities detected"
    echo ""
    echo "Note: Review warnings manually. Not all patterns are vulnerabilities."
    echo "Always validate and sanitize user input."
fi

echo "================================"
