#!/bin/bash

# Post-installation setup script for llm-wiki-obsidian skill
# Runs after npm installs the skill package or git clone

set -e

echo "🔧 Setting up llm-wiki-obsidian skill..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"

# Check for required dependencies
echo "📋 Checking dependencies..."

# Check obsidian-cli (optional but recommended)
if command -v obsidian &> /dev/null; then
    echo "✅ obsidian CLI found: $(obsidian --version 2>/dev/null || echo 'version unknown')"
else
    echo "⚠️  obsidian CLI not found"
    echo "   Obsidian 1.9+ includes built-in CLI. Enable it in obsidian.json:"
    echo '   { "cli": true }'
    echo ""
fi

# Check for qmd (optional, for enhanced search)
if command -v qmd &> /dev/null; then
    echo "✅ qmd found: $(qmd --version 2>/dev/null || echo 'version unknown')"
else
    echo "ℹ️  qmd not found (optional for enhanced search)"
    echo "   Install: https://github.com/tobi/qmd"
    echo ""
fi

# Create config file if it doesn't exist
CONFIG_FILE="$SKILL_ROOT/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "📝 Creating default configuration..."

    cat > "$CONFIG_FILE" <<EOF
{
  "version": "1.0.0",
  "vault": {
    "name": null,
    "path": null
  },
  "wiki": {
    "raw_dir": "raw",
    "wiki_dir": "wiki",
    "entities_dir": "wiki/entities",
    "concepts_dir": "wiki/concepts",
    "sources_dir": "wiki/sources",
    "synthesis_dir": "wiki/synthesis"
  },
  "options": {
    "auto_update_index": true,
    "auto_log": true,
    "default_tags": []
  }
}
EOF

    echo "✅ Created configuration at $CONFIG_FILE"
else
    echo "✅ Configuration already exists at $CONFIG_FILE"
fi

# Create knowledge base directory structure template
KB_TEMPLATE="$SKILL_ROOT/kb-template"

if [ ! -d "$KB_TEMPLATE" ]; then
    echo "📁 Creating knowledge base template structure..."

    mkdir -p "$KB_TEMPLATE"/{raw/{articles,papers,assets},wiki/{entities,concepts,sources,synthesis,meta,canvases}}

    # Create index.md template
    cat > "$KB_TEMPLATE/index.md" <<'EOF'
# 📚 Personal Knowledge Base Index

## Recent Updates
<!-- Auto-updated by LLM -->

## Entities
| Page | Summary | Source | Updated |
|------|---------|--------|---------|

## Concepts
| Page | Summary | Source | Updated |
|------|---------|--------|---------|

## Sources
| Page | Summary | Date |
|------|---------|------|
EOF

    # Create log.md template
    cat > "$KB_TEMPLATE/log.md" <<'EOF'
# Knowledge Base Log

<!-- Append-only log of all operations -->
EOF

    echo "✅ Created knowledge base template at $KB_TEMPLATE"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "  1. Ensure Obsidian is running with CLI enabled (obsidian.json: { \"cli\": true })"
echo "  2. Start a knowledge base: cp -r $KB_TEMPLATE /path/to/your/kb"
echo "  3. Open the vault in Obsidian"
echo "  4. In Claude Code, say: 'Help me ingest this article into my knowledge base'"
echo ""
echo "📖 Full documentation: $SKILL_ROOT/SKILL.md"

# --- Obsidian Vault Configuration ---
# Run with --configure-vault <vault-path> to set up Obsidian config

VAULT_PATH="${2:-}"

if [ "$1" = "--configure-vault" ] && [ -n "$VAULT_PATH" ]; then
    echo ""
    echo "🎨 Configuring Obsidian vault at $VAULT_PATH..."

    OBSIDIAN_DIR="$VAULT_PATH/.obsidian"
    SNIPPETS_DIR="$OBSIDIAN_DIR/snippets"

    # Create snippets directory
    mkdir -p "$SNIPPETS_DIR"

    # Create vault-colors.css for color-coded file explorer
    cat > "$SNIPPETS_DIR/vault-colors.css" <<'CSSEOF'
/* LLM Wiki Vault Colors - Color-coded file explorer by note type */

/* Entity pages - Blue */
.nav-file-title[data-path^="wiki/entities/"] .nav-file-title-content,
.tree-item-inner[data-path^="wiki/entities/"] {
    color: #4a9eff;
}

/* Concept pages - Green */
.nav-file-title[data-path^="wiki/concepts/"] .nav-file-title-content,
.tree-item-inner[data-path^="wiki/concepts/"] {
    color: #4caf50;
}

/* Source pages - Orange */
.nav-file-title[data-path^="wiki/sources/"] .nav-file-title-content,
.tree-item-inner[data-path^="wiki/sources/"] {
    color: #ff9800;
}

/* Synthesis pages - Purple */
.nav-file-title[data-path^="wiki/synthesis/"] .nav-file-title-content,
.tree-item-inner[data-path^="wiki/synthesis/"] {
    color: #ab47bc;
}

/* Raw materials - Dimmed */
.nav-file-title[data-path^="raw/"] .nav-file-title-content,
.tree-item-inner[data-path^="raw/"] {
    color: #888;
    font-style: italic;
}

/* Index and Log - Bold */
.nav-file-title[data-path="index.md"] .nav-file-title-content,
.nav-file-title[data-path="log.md"] .nav-file-title-content,
.tree-item-inner[data-path="index.md"],
.tree-item-inner[data-path="log.md"] {
    font-weight: bold;
    color: #e0e0e0;
}

/* Contradiction callouts */
.callout[data-callout="contradiction"] {
    --callout-color: 239, 68, 68;
    --callout-icon: lucide-alert-triangle;
    border-left: 4px solid rgb(239, 68, 68);
    background-color: rgba(239, 68, 68, 0.1);
}
CSSEOF

    echo "✅ Created vault-colors.css"

    # Enable the CSS snippet in appearance.json
    APPEARANCE_FILE="$OBSIDIAN_DIR/appearance.json"
    if [ -f "$APPEARANCE_FILE" ]; then
        if ! grep -q "vault-colors" "$APPEARANCE_FILE" 2>/dev/null; then
            if command -v python3 &> /dev/null; then
                python3 -c "
import json
with open('$APPEARANCE_FILE', 'r') as f:
    data = json.load(f)
if 'enabledCssSnippets' not in
    data['enabledCssSnippets'] = []
if 'vault-colors' not in data['enabledCssSnippets']:
    data['enabledCssSnippets'].append('vault-colors')
with open('$APPEARANCE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null && echo "✅ Enabled vault-colors.css snippet" || echo "⚠️  Could not auto-enable snippet. Enable it manually in Obsidian Settings > Appearance."
            else
                echo "⚠️  Enable vault-colors.css manually in Obsidian Settings > Appearance > CSS Snippets"
            fi
        else
            echo "✅ vault-colors.css already enabled"
        fi
    else
        cat > "$APPEARANCE_FILE" <<EOF
{
  "enabledCssSnippets": ["vault-colors"]
}
EOF
        echo "✅ Created appearance.json with vault-colors enabled"
    fi

    # Configure app.json to exclude plugin dirs from search
    APP_FILE="$OBSIDIAN_DIR/app.json"
    if [ -f "$APP_FILE" ]; then
        if ! grep -q "userIgnoreFilters" "$APP_FILE" 2>/dev/null; then
            if command -v python3 &> /dev/null; then
                python3 -c "
import json
with open('$APP_FILE', 'r') as f:
    data = json.load(f)
if 'userIgnoreFilters' not in
    data['userIgnoreFilters'] = []
for f in ['.claude-plugin', '.raw', '.vault-meta']:
    if f not in data['userIgnoreFilters']:
        data['userIgnoreFilters'].append(f)
with open('$APP_FILE', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null && echo "✅ Configured search exclusions" || echo "⚠️  Could not configure exclusions automatically"
            fi
        else
            echo "✅ Search exclusions already configured"
        fi
    else
        cat > "$APP_FILE" <<EOF
{
  "userIgnoreFilters": [".claude-plugin", ".raw", ".vault-meta"]
}
EOF
        echo "✅ Created app.json with search exclusions"
    fi

    # Create graph.json with color groups
    GRAPH_FILE="$OBSIDIAN_DIR/graph.json"
    if [ ! -f "$GRAPH_FILE" ]; then
        cat > "$GRAPH_FILE" <<'EOF'
{
  "collapse-filter": true,
  "search": "",
  "showTags": true,
  "showAttachments": false,
  "hideUnresolved": false,
  "showOrphans": true,
  "collapse-colorgroups": false,
  "colorGroups": [
    {
      "query": "path:wiki/entities",
      "color": { "a": 1, "r": 74, "g": 158, "b": 255 }
    },
    {
      "query": "path:wiki/concepts",
      "color": { "a": 1, "r": 76, "g": 175, "b": 80 }
    },
    {
      "query": "path:wiki/sources",
      "color": { "a": 1, "r": 255, "g": 152, "b": 0 }
    },
    {
      "query": "path:wiki/synthesis",
      "color": { "a": 1, "r": 171, "g": 71, "b": 188 }
    }
  ],
  "collapse-display": false,
  "showArrow": false,
  "textFadeMultiplier": 0,
  "nodeSizeMultiplier": 1,
  "lineSizeMultiplier": 1,
  "collapse-forces": false,
  "centerStrength": 0.5,
  "repelStrength": 10,
  "linkStrength": 0.5,
  "linkDistance": 30,
  "scale": 1,
  "close": false
}
EOF
        echo "✅ Created graph.json with color-coded groups"
    else
        echo "✅ graph.json already exists"
    fi

    # Copy Templater templates
    TEMPLATES_SRC="$SKILL_ROOT/../../_templates"
    TEMPLATES_DST="$VAULT_PATH/_templates"

    if [ -d "$TEMPLATES_SRC" ] && [ ! -d "$TEMPLATES_DST" ]; then
        mkdir -p "$TEMPLATES_DST"
        cp "$TEMPLATES_SRC"/*.md "$TEMPLATES_DST/" 2>/dev/null
        echo "✅ Copied Templater templates to $TEMPLATES_DST"
    fi

    echo ""
    echo "🎨 Vault configuration complete!"
    echo "   - File explorer: color-coded by note type"
    echo "   - Graph view: color groups for entities/concepts/sources/synthesis"
    echo "   - Search: excludes .claude-plugin, .raw, .vault-meta"
    echo "   - Templates: _templates/ ready for Templater plugin"
fi