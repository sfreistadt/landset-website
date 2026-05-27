#!/bin/bash

# File Integrity and Size Validation Script for Landset Website
# Detects oversized files, unexpected file types, and validates file integrity

set -e

echo "📦 Starting file integrity checks..."
echo "================================"

FOUND_ISSUES=0
SCAN_LOG="security-scan-files.log"

# Clear previous log
> "$SCAN_LOG"

# Configuration
MAX_HTML_SIZE_KB=3000    # 3MB max for HTML files
MAX_JS_SIZE_KB=500       # 500KB max for JS files
MAX_CSS_SIZE_KB=500      # 500KB max for CSS files
MAX_IMAGE_SIZE_KB=2000   # 2MB max for images
MAX_TOTAL_SIZE_MB=50     # 50MB max for entire repository

# Check 1: File size limits
echo "1. Checking file sizes..."
echo ""

# Check HTML files
while IFS= read -r file; do
    if [ -f "$file" ]; then
        SIZE_KB=$(du -k "$file" | cut -f1)
        if [ $SIZE_KB -gt $MAX_HTML_SIZE_KB ]; then
            echo "❌ ERROR: HTML file too large: $file (${SIZE_KB}KB > ${MAX_HTML_SIZE_KB}KB)" | tee -a "$SCAN_LOG"
            echo "  Recommendation: Optimize or split the file" | tee -a "$SCAN_LOG"
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        elif [ $SIZE_KB -gt 1000 ]; then
            echo "⚠️  WARNING: Large HTML file: $file (${SIZE_KB}KB)" | tee -a "$SCAN_LOG"
        fi
    fi
done < <(find . -name "*.html" -not -path "*/.git/*" -not -path "*/node_modules/*")

# Check JavaScript files
while IFS= read -r file; do
    if [ -f "$file" ]; then
        SIZE_KB=$(du -k "$file" | cut -f1)
        if [ $SIZE_KB -gt $MAX_JS_SIZE_KB ]; then
            echo "❌ ERROR: JavaScript file too large: $file (${SIZE_KB}KB > ${MAX_JS_SIZE_KB}KB)" | tee -a "$SCAN_LOG"
            echo "  Recommendation: Minify or split the file" | tee -a "$SCAN_LOG"
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        elif [ $SIZE_KB -gt 200 ]; then
            echo "⚠️  WARNING: Large JavaScript file: $file (${SIZE_KB}KB)" | tee -a "$SCAN_LOG"
        fi
    fi
done < <(find . -name "*.js" -not -path "*/.git/*" -not -path "*/node_modules/*")

# Check CSS files
while IFS= read -r file; do
    if [ -f "$file" ]; then
        SIZE_KB=$(du -k "$file" | cut -f1)
        if [ $SIZE_KB -gt $MAX_CSS_SIZE_KB ]; then
            echo "❌ ERROR: CSS file too large: $file (${SIZE_KB}KB > ${MAX_CSS_SIZE_KB}KB)" | tee -a "$SCAN_LOG"
            echo "  Recommendation: Minify or split the file" | tee -a "$SCAN_LOG"
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        fi
    fi
done < <(find . -name "*.css" -not -path "*/.git/*" -not -path "*/node_modules/*")

# Check image files
while IFS= read -r file; do
    if [ -f "$file" ]; then
        SIZE_KB=$(du -k "$file" | cut -f1)
        if [ $SIZE_KB -gt $MAX_IMAGE_SIZE_KB ]; then
            echo "⚠️  WARNING: Large image file: $file (${SIZE_KB}KB)" | tee -a "$SCAN_LOG"
            echo "  Recommendation: Compress or optimize the image" | tee -a "$SCAN_LOG"
        fi
    fi
done < <(find . \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.svg" -o -name "*.webp" \) -not -path "*/.git/*" -not -path "*/node_modules/*")

# Check 2: Total repository size
echo ""
echo "2. Checking total repository size..."
TOTAL_SIZE_KB=$(du -sk . 2>/dev/null | cut -f1)
TOTAL_SIZE_MB=$((TOTAL_SIZE_KB / 1024))

echo "Total repository size: ${TOTAL_SIZE_MB}MB" | tee -a "$SCAN_LOG"

if [ $TOTAL_SIZE_MB -gt $MAX_TOTAL_SIZE_MB ]; then
    echo "⚠️  WARNING: Repository is large (${TOTAL_SIZE_MB}MB > ${MAX_TOTAL_SIZE_MB}MB)" | tee -a "$SCAN_LOG"
    echo "  Consider: removing large files, using Git LFS, or optimizing assets" | tee -a "$SCAN_LOG"
fi

# Check 3: Unexpected file types
echo ""
echo "3. Checking for unexpected file types..."

# Expected extensions for a static website
EXPECTED_EXTENSIONS=("html" "js" "css" "json" "md" "txt" "jpg" "jpeg" "png" "gif" "svg" "webp" "ico" "pdf" "xml" "sh" "yml" "yaml")

# Find all files (excluding hidden and git files)
UNEXPECTED_FILES=""
while IFS= read -r file; do
    if [ -f "$file" ]; then
        EXTENSION="${file##*.}"
        EXTENSION_LOWER=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')

        # Check if extension is in expected list
        IS_EXPECTED=0
        for ext in "${EXPECTED_EXTENSIONS[@]}"; do
            if [ "$EXTENSION_LOWER" == "$ext" ]; then
                IS_EXPECTED=1
                break
            fi
        done

        if [ $IS_EXPECTED -eq 0 ] && [[ ! "$file" =~ /\. ]]; then
            UNEXPECTED_FILES+="$file\n"
        fi
    fi
done < <(find . -type f -not -path "*/.git/*" -not -path "*/node_modules/*" -not -name ".*")

if [ ! -z "$UNEXPECTED_FILES" ]; then
    echo "⚠️  WARNING: Unexpected file types found:" | tee -a "$SCAN_LOG"
    echo -e "$UNEXPECTED_FILES" | head -10 | tee -a "$SCAN_LOG"
    echo "  Review: Ensure these files should be in the repository" | tee -a "$SCAN_LOG"
fi

# Check 4: Dangerous file types
echo ""
echo "4. Checking for potentially dangerous file types..."

DANGEROUS_EXTENSIONS=("exe" "dll" "so" "dylib" "dmg" "pkg" "deb" "rpm" "msi" "bat" "cmd" "ps1" "vbs" "app" "jar" "war" "ear")

DANGEROUS_FILES=""
for ext in "${DANGEROUS_EXTENSIONS[@]}"; do
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            DANGEROUS_FILES+="$file\n"
        fi
    done < <(find . -type f -iname "*.$ext" -not -path "*/.git/*" -not -path "*/node_modules/*")
done

if [ ! -z "$DANGEROUS_FILES" ]; then
    echo "❌ ERROR: Dangerous executable files found:" | tee -a "$SCAN_LOG"
    echo -e "$DANGEROUS_FILES" | tee -a "$SCAN_LOG"
    echo "  Risk: Executables should not be in a static website repository" | tee -a "$SCAN_LOG"
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
fi

# Check 5: Binary files that look suspicious
echo ""
echo "5. Checking for suspicious binary files..."

# Find binary files
BINARY_FILES=$(find . -type f -not -path "*/.git/*" -not -path "*/node_modules/*" -exec file {} \; | grep -v "text\|empty\|JSON\|XML" | grep -i "data\|executable\|archive" || true)

if [ ! -z "$BINARY_FILES" ]; then
    echo "ℹ️  INFO: Binary files detected:" | tee -a "$SCAN_LOG"
    echo "$BINARY_FILES" | head -5 | tee -a "$SCAN_LOG"
    echo "  Review: Ensure these are legitimate assets" | tee -a "$SCAN_LOG"
fi

# Check 6: Duplicate files (potential waste)
echo ""
echo "6. Checking for duplicate files..."

# Find files with same size and name pattern
DUPLICATE_COUNT=0
find . -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.js" -o -name "*.css" \) -not -path "*/.git/*" -not -path "*/node_modules/*" -exec md5sum {} + 2>/dev/null | \
    sort | uniq -w32 -D --all-repeated=separate | head -20 > /tmp/duplicates.txt || true

if [ -s /tmp/duplicates.txt ]; then
    DUPLICATE_COUNT=$(wc -l < /tmp/duplicates.txt)
    if [ $DUPLICATE_COUNT -gt 0 ]; then
        echo "⚠️  WARNING: Potential duplicate files found:" | tee -a "$SCAN_LOG"
        cat /tmp/duplicates.txt | head -10 | tee -a "$SCAN_LOG"
        echo "  Recommendation: Remove duplicates to reduce repository size" | tee -a "$SCAN_LOG"
    fi
fi
rm -f /tmp/duplicates.txt

# Check 7: Empty files
echo ""
echo "7. Checking for empty files..."

EMPTY_FILES=$(find . -type f -empty -not -path "*/.git/*" -not -path "*/node_modules/*" || true)

if [ ! -z "$EMPTY_FILES" ]; then
    echo "ℹ️  INFO: Empty files found:" | tee -a "$SCAN_LOG"
    echo "$EMPTY_FILES" | tee -a "$SCAN_LOG"
    echo "  Review: These may be placeholders or should be removed" | tee -a "$SCAN_LOG"
fi

# Check 8: Recently modified large files (possible accidental commits)
echo ""
echo "8. Checking for recently added large files..."

# Find files larger than 1MB added in last commit
RECENT_LARGE=$(git diff --name-only --diff-filter=A HEAD~1 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
        SIZE_KB=$(du -k "$file" 2>/dev/null | cut -f1)
        if [ $SIZE_KB -gt 1024 ]; then
            echo "$file (${SIZE_KB}KB)"
        fi
    fi
done || true)

if [ ! -z "$RECENT_LARGE" ]; then
    echo "⚠️  WARNING: Recently added large files:" | tee -a "$SCAN_LOG"
    echo "$RECENT_LARGE" | tee -a "$SCAN_LOG"
    echo "  Review: Ensure these files are necessary and optimized" | tee -a "$SCAN_LOG"
fi

# Check 9: Files with suspicious permissions
echo ""
echo "9. Checking file permissions..."

# Check for world-writable files
WRITABLE_FILES=$(find . -type f -perm -002 -not -path "*/.git/*" -not -path "*/node_modules/*" || true)

if [ ! -z "$WRITABLE_FILES" ]; then
    echo "⚠️  WARNING: World-writable files found:" | tee -a "$SCAN_LOG"
    echo "$WRITABLE_FILES" | tee -a "$SCAN_LOG"
    echo "  Security: Files should not be world-writable" | tee -a "$SCAN_LOG"
fi

# Summary
echo ""
echo "================================"
if [ $FOUND_ISSUES -gt 0 ]; then
    echo "❌ FILE INTEGRITY CHECK FAILED: Found $FOUND_ISSUES critical issue(s)"
    echo "Review the output above and $SCAN_LOG for details"
    echo ""
    echo "Common fixes:"
    echo "1. Remove or optimize oversized files"
    echo "2. Remove executables and dangerous file types"
    echo "3. Add large files to .gitignore or use Git LFS"
    echo "4. Compress images and minify JS/CSS"
    exit 1
else
    echo "✅ FILE INTEGRITY CHECK PASSED"
    echo ""
    echo "Note: Review warnings for optimization opportunities."
fi

echo "================================"
