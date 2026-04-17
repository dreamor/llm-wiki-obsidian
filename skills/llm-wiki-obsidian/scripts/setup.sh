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

    mkdir -p "$KB_TEMPLATE"/{raw/{articles,papers,assets},wiki/{entities,concepts,sources,synthesis}}

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