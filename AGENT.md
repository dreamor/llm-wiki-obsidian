# Agent Compatibility Guide

This skill supports multiple AI agents through different installation methods.

## Agent Support Matrix

| Agent | Plugin Mode | Skill Mode | Interface |
|-------|-------------|------------|-----------|
| Claude Code | ✅ Full | ✅ Full | Native tools + Obsidian CLI |
| Cursor | ❌ | ✅ Full | Bash + File operations |
| Windsurf | ❌ | ✅ Full | Bash + File operations |
| Cline | ❌ | ✅ Full | Bash + File operations |
| Aider | ❌ | ✅ Full | Bash + File operations |
| Any MCP-compatible | ❌ | ✅ Full | MCP tools |

## Installation by Agent

### Claude Code (Recommended)

**Plugin Mode** (auto-trigger, native integration):
```bash
/plugin marketplace add dreamor/llm-wiki-obsidian
/plugin install llm-wiki-obsidian@llm-wiki-obsidian
```

**Skill Mode** (manual installation):
```bash
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.claude/skills/llm-wiki-obsidian
```

### Cursor / Windsurf / Cline / Aider

Install as a global skill:
```bash
# Clone to your agent's skills directory
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.agents/skills/llm-wiki-obsidian

# Run setup
cd ~/.agents/skills/llm-wiki-obsidian
bash skills/llm-wiki-obsidian/scripts/setup.sh
```

### MCP-Compatible Agents

If your agent supports MCP (Model Context Protocol), use the Obsidian MCP server:
```bash
# Configure in your agent's MCP settings
{
  "mcpServers": {
    "obsidian": {
      "command": "obsidian-mcp"
    }
  }
}
```

## Core Operations (Agent-Agnostic)

All agents perform the same core operations:

### 1. Sync (Clippings → Raw)
```bash
# Move files from clippings to raw
mv clippings/*.md raw/articles/
```

### 2. Ingest (Process Raw Files)
```bash
# Read file
cat raw/articles/source.md

# Create wiki page
echo "# Source Title\n\n## Summary\n..." > wiki/sources/source-title.md

# Update index
echo "- [[source-title]] - Summary" >> index.md
```

### 3. Synthesize (Generate Analysis)
```bash
# Read related pages
cat wiki/sources/*.md
cat wiki/concepts/*.md

# Create synthesis page
echo "# Synthesis: Topic\n\n## Key Findings\n..." > wiki/synthesis/topic.md
```

### 4. Query (Search Knowledge)
```bash
# Search by keyword
grep -r "keyword" wiki/

# Read specific page
cat wiki/concepts/concept-name.md
```

### 5. Lint (Health Check)
```bash
# Find orphaned pages (no backlinks)
grep -L "\[\[" wiki/**/*.md

# Check for contradictions
grep -r "⚠️" wiki/
```

## Tool Requirements by Agent

### Claude Code
- `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` tools
- Optional: `mcp__fetch__fetch` for web content

### Cursor / Windsurf / Cline
- File read/write capabilities
- Bash/shell execution
- Glob pattern matching
- Grep/search functionality

### Aider
- File editing capabilities
- Shell command execution
- Git integration (optional)

## Obsidian Integration

### Method 1: Obsidian CLI (Preferred)
Requires Obsidian 1.9+ with CLI enabled:
```bash
# Enable CLI in obsidian.json
echo '{"cli": true}' > /path/to/vault/.obsidian/obsidian.json

# Usage
obsidian read file="Page Name"
obsidian create name="New Page" content="# Title\n\nContent"
obsidian search query="keyword"
```

### Method 2: Direct File Operations
Works with any agent:
```bash
# Read page
cat /path/to/vault/wiki/concepts/concept.md

# Create page
echo "# New Page\n\nContent" > /path/to/vault/wiki/sources/new-page.md

# Search
grep -r "keyword" /path/to/vault/wiki/
```

### Method 3: MCP Server
For MCP-compatible agents:
- Use `obsidian-mcp` or similar MCP server
- Provides structured tool interface

## Configuration

Create `config.json` in the skill directory:
```json
{
  "vault": {
    "path": "/path/to/your/obsidian/vault"
  },
  "wiki": {
    "raw_dir": "raw",
    "wiki_dir": "wiki"
  }
}
```

## Troubleshooting

### Obsidian CLI not found
- Ensure Obsidian 1.9+ is installed
- Enable CLI in `obsidian.json`: `{"cli": true}`
- Keep Obsidian running when using CLI

### Permission denied
- Check file permissions on vault directory
- Ensure agent has read/write access

### Pages not syncing
- Verify vault path in config.json
- Check if Obsidian is running (for CLI mode)