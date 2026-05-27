#!/bin/bash

# JSON Validation in JavaScript Templates Script
# Validates JSON structures embedded in JavaScript files
# Special attention to landset-website's index.html with escaped HTML in JS templates

set -e

echo "🔍 Validating JSON structures in JavaScript..."
echo "================================"

FOUND_ISSUES=0

# Check 1: Validate JSON objects in JavaScript files
echo "1. Checking for malformed JSON in JS files..."

JS_FILES=$(find . -type f -name "*.js" -not -path "*/.git/*" -not -path "*/node_modules/*")

while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Extract potential JSON objects (simple heuristic)
        # Look for objects that look like JSON (start with { and end with })

        # Use a simple check: try to find obvious JSON syntax errors
        # Look for common issues: trailing commas, unquoted keys, etc.

        # Check for trailing commas in objects/arrays
        TRAILING_COMMAS=$(grep -n ',\s*[\]}]' "$file" 2>/dev/null || true)
        if [ ! -z "$TRAILING_COMMAS" ]; then
            echo "⚠️  WARNING: Potential trailing comma in $file:"
            echo "$TRAILING_COMMAS" | head -3
            echo ""
        fi

        # Check for unmatched braces
        OPEN_BRACES=$(grep -o '{' "$file" | wc -l)
        CLOSE_BRACES=$(grep -o '}' "$file" | wc -l)
        if [ $OPEN_BRACES -ne $CLOSE_BRACES ]; then
            echo "⚠️  WARNING: Unmatched braces in $file"
            echo "  Open: $OPEN_BRACES, Close: $CLOSE_BRACES"
            echo ""
        fi
    fi
done <<< "$JS_FILES"

# Check 2: Validate JSON in HTML script tags (special attention to index.html)
echo "2. Checking JSON in HTML script tags..."

HTML_FILES=$(find . -type f -name "*.html" -not -path "*/.git/*" -not -path "*/node_modules/*")

while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Check if file has script tags with JSON-like content
        if grep -q '<script' "$file"; then
            echo "Checking $file for JSON structures..."

            # Look for common JSON errors in script tags
            # Check for unescaped quotes in JSON strings
            UNESCAPED_QUOTES=$(grep -n '[^\\]"\s*:\s*"[^"]*"[^"]*"' "$file" 2>/dev/null | head -3 || true)
            if [ ! -z "$UNESCAPED_QUOTES" ]; then
                echo "⚠️  WARNING: Potential unescaped quotes in $file:"
                echo "$UNESCAPED_QUOTES"
                echo ""
            fi
        fi
    fi
done <<< "$HTML_FILES"

# Check 3: Validate escaped HTML in JavaScript templates
echo "3. Checking for properly escaped HTML in JavaScript templates..."

while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Check for template literals with HTML
        if grep -q '`.*<.*>.*`' "$file" 2>/dev/null; then
            echo "ℹ️  INFO: HTML template literals found in $file"

            # Check for potential escaping issues
            UNESCAPED_HTML=$(grep -nP '`[^`]*<[^>]+>[^`]*\$\{[^}]+\}[^`]*<' "$file" 2>/dev/null | head -3 || true)
            if [ ! -z "$UNESCAPED_HTML" ]; then
                echo "⚠️  WARNING: Template literal with user input in HTML context:"
                echo "$UNESCAPED_HTML"
                echo "  Ensure user input is properly escaped to prevent XSS"
                echo ""
            fi
        fi
    fi
done <<< "$JS_FILES"

# Check 4: Special check for index.html (based on memory note)
echo "4. Running special validation for index.html..."

if [ -f "./index.html" ]; then
    echo "Checking index.html for JSON structure integrity..."

    # Extract script content and check for JSON parsing
    SCRIPT_SECTIONS=$(grep -n '<script' index.html | wc -l)
    echo "  Found $SCRIPT_SECTIONS script sections"

    # Check for JSON.parse usage
    JSON_PARSE=$(grep -n 'JSON\.parse\|JSON\.stringify' index.html || true)
    if [ ! -z "$JSON_PARSE" ]; then
        echo "  JSON operations found:"
        echo "$JSON_PARSE" | head -3
    fi

    # Look for potential JSON syntax errors in large script blocks
    # Check for common mistakes: single quotes instead of double quotes in JSON
    SINGLE_QUOTE_JSON=$(grep -n "{\s*'[^']*'\s*:" index.html 2>/dev/null | head -3 || true)
    if [ ! -z "$SINGLE_QUOTE_JSON" ]; then
        echo "⚠️  WARNING: Single quotes in object notation (should be double quotes for JSON):"
        echo "$SINGLE_QUOTE_JSON"
        echo ""
    fi
else
    echo "  index.html not found in current directory"
fi

# Check 5: Validate config.js structure
echo "5. Validating config.js structure..."

if [ -f "./app/config.js" ]; then
    echo "Checking app/config.js..."

    # Check for syntax errors in config
    node -c app/config.js 2>&1 || {
        echo "❌ ERROR: Syntax error in app/config.js"
        FOUND_ISSUES=$((FOUND_ISSUES + 1))
    }

    # Check for required config properties
    CONFIG_REQUIRED=("API_BASE_URL" "AUTH_ENABLED")
    for prop in "${CONFIG_REQUIRED[@]}"; do
        if ! grep -q "$prop" app/config.js; then
            echo "⚠️  WARNING: Missing expected config property: $prop"
        fi
    done
else
    echo "  app/config.js not found"
fi

# Check 6: Validate all JS files with Node.js syntax checker
echo ""
echo "6. Running Node.js syntax validation on all JS files..."

SYNTAX_ERRORS=0
while IFS= read -r file; do
    if [ -f "$file" ]; then
        # Use Node.js to check syntax
        ERROR_OUTPUT=$(node -c "$file" 2>&1)
        if [ $? -ne 0 ]; then
            echo "❌ ERROR: Syntax error in $file"
            echo "$ERROR_OUTPUT"
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        fi
    fi
done <<< "$JS_FILES"

if [ $SYNTAX_ERRORS -eq 0 ]; then
    echo "✅ All JavaScript files have valid syntax"
fi

# Summary
echo ""
echo "================================"
if [ $FOUND_ISSUES -gt 0 ]; then
    echo "❌ JSON VALIDATION FAILED: Found $FOUND_ISSUES critical issue(s)"
    echo ""
    echo "Common fixes:"
    echo "1. Fix trailing commas in JSON objects"
    echo "2. Use double quotes for JSON keys and values"
    echo "3. Ensure all braces and brackets are matched"
    echo "4. Validate JSON with JSON.parse() before use"
    exit 1
else
    echo "✅ JSON VALIDATION PASSED"
    echo ""
    echo "Note: This is a basic validation. Always test in browser."
fi

echo "================================"
