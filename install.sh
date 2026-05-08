#!/bin/bash

# Setup script for llm-wiki-obsidian skill
# Supports multiple AI agents through symlinks and bootstrap files

set -e

echo "🔧 Setting up llm-wiki-obsidian skill..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$SCRIPT_DIR"

# Detect OS
OS="$(uname -s)"

# Function to create symlink with fallback for existing files
create_symlink() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ]; then
        if [ -L "$target" ]; then
            # Already a symlink, remove it
            rm "$target"
        else
            # It's a real file, backup and skip
            echo "⚠️  $target exists (not a symlink), skipping"
            return 1
        fi
    fi

    # Create parent directories if needed
    local target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    # Create symlink
    ln -s "$source" "$target"
    echo "✅ Created symlink: $target → $source"
    return 0
}

echo ""
echo "📋 Installing for multiple AI agents..."

# Claude Code
CLAUDE_SKILLS="$HOME/.claude/skills"
if [ -d "$CLAUDE_SKILLS" ] || mkdir -p "$CLAUDE_SKILLS" 2>/dev/null; then
    create_symlink "$SKILL_ROOT/skills/llm-wiki-obsidian" "$CLAUDE_SKILLS/llm-wiki-obsidian" || true
    echo "✅ Claude Code skills installed"
else
    echo "⚠️  Claude Code not found, skipping"
fi

# Cursor
CURSOR_SKILLS="$HOME/.cursor/skills"
CURSOR_RULES="$HOME/.cursor/rules"
if [ -d "$CURSOR_SKILLS" ] || mkdir -p "$CURSOR_SKILLS" 2>/dev/null; then
    create_symlink "$SKILL_ROOT/skills/llm-wiki-obsidian" "$CURSOR_SKILLS/llm-wiki-obsidian" || true
fi
if [ -d "$CURSOR_RULES" ] || mkdir -p "$CURSOR_RULES" 2>/dev/null; then
    # Create Cursor rules file
    if [ ! -f "$CURSOR_RULES/llm-wiki-obsidian.mdc" ]; then
        cat > "$CURSOR_RULES/llm-wiki-obsidian.mdc" << 'EOF'
# llm-wiki-obsidian

This project manages a personal knowledge base using the LLM Wiki pattern with Obsidian.

## Quick Commands
- "organize my knowledge base" - Run full organize workflow
- "ingest this article" - Add new source to wiki
- "query my knowledge base about X" - Search and answer
- "lint my wiki" - Health check

See CLAUDE.md for full documentation.
EOF
        echo "✅ Created Cursor rules: $CURSOR_RULES/llm-wiki-obsidian.mdc"
    fi
fi
echo "✅ Cursor support installed"

# Windsurf
WINDSURF_SKILLS="$HOME/.windsurf/skills"
WINDSURF_RULES="$HOME/.windsurf/rules"
if [ -d "$WINDSURF_SKILLS" ] || mkdir -p "$WINDSURF_SKILLS" 2>/dev/null; then
    create_symlink "$SKILL_ROOT/skills/llm-wiki-obsidian" "$WINDSURF_SKILLS/llm-wiki-obsidian" || true
fi
if [ -d "$WINDSURF_RULES" ] || mkdir -p "$WINDSURF_RULES" 2>/dev/null; then
    if [ ! -f "$WINDSURF_RULES/llm-wiki-obsidian.md" ]; then
        cat > "$WINDSURF_RULES/llm-wiki-obsidian.md" << 'EOF'
# llm-wiki-obsidian

Personal knowledge base management with Obsidian.

## Commands
- organize my knowledge base
- ingest [article]
- query [topic]
- lint wiki
EOF
        echo "✅ Created Windsurf rules: $WINDSURF_RULES/llm-wiki-obsidian.md"
    fi
fi
echo "✅ Windsurf support installed"

# Codex (OpenAI)
CODEX_SKILLS="$HOME/.codex/skills"
if [ -d "$CODEX_SKILLS" ] || mkdir -p "$CODEX_SKILLS" 2>/dev/null; then
    create_symlink "$SKILL_ROOT/skills/llm-wiki-obsidian" "$CODEX_SKILLS/llm-wiki-obsidian" || true
    echo "✅ Codex skills installed"
fi

# Hermes
HERMES_SKILLS="$HOME/.hermes/skills"
HERMES_RULES="$HOME/.hermes"
if [ -d "$HERMES_SKILLS" ] || mkdir -p "$HERMES_SKILLS" 2>/dev/null; then
    create_symlink "$SKILL_ROOT/skills/llm-wiki-obsidian" "$HERMES_SKILLS/llm-wiki-obsidian" || true
fi
if [ -d "$HERMES_RULES" ] || mkdir -p "$HERMES_RULES" 2>/dev/null; then
    if [ ! -f "$HERMES_RULES/.hermes.md" ]; then
        cp "$SKILL_ROOT/CLAUDE.md" "$HERMES_RULES/.hermes.md" 2>/dev/null || echo "⚠️  CLAUDE.md not found"
        echo "✅ Created Hermes bootstrap: $HERMES_RULES/.hermes.md"
    fi
fi
echo "✅ Hermes support installed"

# OpenClaw
OPENCLAW_SKILLS="$HOME/.openclaw/skills"
AGENTS_SKILLS="$HOME/.agents/skills"
if [ -d "$OPENCLAW_SKILLS" ] || mkdir -p "$OPENCLAW_SKILLS" 2>/dev/null; then
    create_symlink "$SKILL_ROOT/skills/llm-wiki-obsidian" "$OPENCLAW_SKILLS/llm-wiki-obsidian" || true
fi
if [ -d "$AGENTS_SKILLS" ] || mkdir -p "$AGENTS_SKILLS" 2>/dev/null; then
    create_symlink "$SKILL_ROOT/skills/llm-wiki-obsidian" "$AGENTS_SKILLS/llm-wiki-obsidian" || true
fi
echo "✅ OpenClaw support installed"

# GitHub Copilot
COPILOT_DIR="$HOME/.github"
if [ -d "$COPILOT_DIR" ] || mkdir -p "$COPILOT_DIR" 2>/dev/null; then
    if [ ! -f "$COPILOT_DIR/copilot-instructions.md" ]; then
        cat > "$COPILOT_DIR/copilot-instructions.md" << 'EOF'
# llm-wiki-obsidian

Personal knowledge base with Obsidian.

## Key Commands
- organize knowledge base
- ingest article
- query knowledge
- lint wiki
EOF
        echo "✅ Created Copilot instructions: $COPILOT_DIR/copilot-instructions.md"
    fi
fi
echo "✅ GitHub Copilot support installed"

# Kilocode
if [ -d "$AGENTS_SKILLS" ]; then
    create_symlink "$SKILL_ROOT/skills/llm-wiki-obsidian" "$AGENTS_SKILLS/llm-wiki-obsidian-kilocode" || true
    echo "✅ Kilocode skills installed"
fi

echo ""
echo "📋 Checking dependencies..."

# Check obsidian-cli
if command -v obsidian &> /dev/null; then
    echo "✅ obsidian CLI found"
else
    echo "⚠️  obsidian CLI not found"
    echo "   Enable in obsidian.json: { \"cli\": true }"
fi

# Check for qmd (optional)
if command -v qmd &> /dev/null; then
    echo "✅ qmd found (optional for enhanced search)"
else
    echo "ℹ️  qmd not found (optional)"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "📚 Installation methods:"
echo "   1. npx skills add dreamor/llm-wiki-obsidian  (recommended)"
echo "   2. bash setup.sh  (this script)"
echo "   3. Claude Code plugin: /plugin install llm-wiki-obsidian@llm-wiki-obsidian"
echo ""
echo "📖 Full documentation: $SKILL_ROOT/README.md"