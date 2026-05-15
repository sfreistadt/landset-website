# Landset Website Editing Guide

## The Problem

The current `about.html` and `index.html` files are **bundled/compiled** HTML files. They contain:
- Inline base64-encoded images
- JSON-escaped HTML templates in `<script type="__bundler/template">` tags
- All resources embedded in a single file

**This makes them very difficult to edit directly.**

## Solutions for the Future

### Option 1: Find and Edit Source Files (RECOMMENDED)

These bundled files were likely generated from source files. Look for:

```bash
# Common source directories
src/
pages/
content/
templates/

# Common build tools
package.json
vite.config.js
webpack.config.js
rollup.config.js
```

**What to do:**
1. Find where these files were originally created
2. Edit the source files (likely regular HTML with separate CSS/JS)
3. Re-run the build process to generate new bundled files
4. Commit both source AND bundled files to git

### Option 2: Create Unbundled Versions

Extract the content into regular HTML files:

```bash
# Create a new directory for editable versions
mkdir src/
```

Then create:
- `src/about.html` - Regular HTML (no bundling)
- `src/data/profiles.json` - Founder data as JSON
- `src/css/styles.css` - Extracted styles
- `src/js/main.js` - Extracted JavaScript

**Benefits:**
- Easy to edit with any text editor
- Clear separation of content and presentation
- Can use version control effectively

### Option 3: Use a Content Management System

For frequently-changing content like bios, use:

1. **JSON data files**:
   ```json
   // data/founders.json
   {
     "steve": {
       "name": "Steve",
       "role": "Co-founder · Product & Engineering",
       "bio": ["paragraph 1", "paragraph 2"],
       "background": "Product management at Fortune 500 companies"
     },
     "danny": { ... }
   }
   ```

2. **Simple template system**: Load JSON and populate HTML templates

3. **Static site generator**: Consider using:
   - Eleventy
   - Hugo
   - Jekyll
   - Next.js (static export)

### Option 4: Keep Source in Git, Deploy Bundled

**Best practice workflow:**
```
┌─────────────┐
│   Source    │  ← Edit these (human-readable)
│   Files     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Build    │  ← Automated process
│   Process   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Bundled   │  ← Deploy these (optimized)
│    Files    │
└─────────────┘
```

## For Now: Editing Bundled Files

If you must edit the bundled files directly:

### Method 1: Use the Python Script

```python
import json

# Read file
with open('about.html', 'r') as f:
    lines = f.readlines()

# Edit line 179 (the template)
template = json.loads(lines[178].strip())

# Make changes
template = template.replace('old text', 'new text')

# Write back
lines[178] = json.dumps(template, ensure_ascii=False) + '\n'

with open('about.html', 'w') as f:
    f.writelines(lines)
```

### Method 2: Use Browser DevTools

1. Open the page in browser
2. Press `F12` for DevTools
3. Go to Console tab
4. Run:
   ```javascript
   const template = document.querySelector('script[type="__bundler/template"]').textContent;
   const html = JSON.parse(template);
   // Copy and edit html, then create new file
   ```

## What NOT to Do

❌ Don't edit bundled files in a visual editor (will corrupt the encoding)
❌ Don't use HTML escape/unescape tools (breaks the JSON)
❌ Don't manually edit the JSON string (very error-prone)
❌ Don't format/prettify bundled files (breaks the structure)

## Questions to Answer

To set up the right system, find out:

1. **Where did these files come from?**
   - Was there a build tool used?
   - Are there source files somewhere?
   - Who created the original files?

2. **What's the deployment workflow?**
   - How do changes get published?
   - Is there a CI/CD process?
   - Are these files in version control?

3. **How often will content change?**
   - Just this one time? → Direct edit is OK
   - Monthly updates? → Create editable sources
   - Weekly updates? → Use CMS/data files

## Recommended Next Steps

1. **Search for source files**:
   ```bash
   cd /Users/steve/Documents/GitHub/landset-website
   git log --all --full-history -- about.html
   # Check who created it and when
   ```

2. **Create a backup workflow**:
   ```bash
   # Before editing bundled files, always:
   cp about.html about.html.backup
   ```

3. **Document the creation process**:
   - Add a README explaining how these files were created
   - Include the build command if there is one
   - Note any tools or services used

4. **Consider unbundling**:
   - Create `src/about-clean.html` with extracted content
   - Edit that for future changes
   - Keep bundled version for deployment only

---

**Remember:** Bundled files are meant to be *generated*, not *edited*. Finding and editing the source is always better than editing the output.
