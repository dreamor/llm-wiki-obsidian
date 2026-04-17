# LLM Wiki Obsidian

Personal knowledge base management skill based on [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). Interact with local Obsidian Vault through Obsidian CLI to build and maintain a persistent wiki.

## Core Concept

**Not RAG, but Persistent Wiki!**

| RAG | Persistent Wiki |
|-----|-----------------|
| Re-discovers knowledge at query time | Knowledge **compiled and kept up-to-date** |
| No accumulation, re-assembles 5 docs each time | Cross-references exist, contradictions flagged |
| NotebookLM, ChatGPT file upload | Obsidian + LLM = IDE + Programmer |

**Key Insight**: Wiki is a **persistent, compounding artifact**. Each added source enriches it.

**Human's job**: Curate sources, guide analysis, ask good questions.
**LLM's job**: Bookkeeping (update cross-references, keep summaries current, flag contradictions).

## Agent Compatibility

| Agent | Plugin Mode | Skill Mode | Interface |
|-------|-------------|------------|-----------|
| Claude Code | ✅ Full | ✅ Full | Native tools + Obsidian CLI |
| Cursor | ❌ | ✅ Full | Bash + File operations |
| Windsurf | ❌ | ✅ Full | Bash + File operations |
| Cline | ❌ | ✅ Full | Bash + File operations |
| Aider | ❌ | ✅ Full | Bash + File operations |
| MCP-compatible | ❌ | ✅ Full | MCP tools |

> **Note**: Plugin mode is Claude Code exclusive. Skill mode works with any agent that supports file operations and bash commands.

## Installation

### Option A: Claude Code Plugin (Claude Only)

```bash
# Add marketplace
/plugin marketplace add dreamor/llm-wiki-obsidian

# Install plugin
/plugin install llm-wiki-obsidian@llm-wiki-obsidian
```

### Option B: Install as Global Skill (All Agents)

Install to `~/.claude/skills/` or `~/.agents/skills/` for global availability:

```bash
# For Claude Code
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.claude/skills/llm-wiki-obsidian

# For Cursor / Windsurf / Cline / Aider
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.agents/skills/llm-wiki-obsidian

# Run setup script
cd ~/.claude/skills/llm-wiki-obsidian  # or ~/.agents/skills/llm-wiki-obsidian
bash skills/llm-wiki-obsidian/scripts/setup.sh
```

### Option C: Project-Level CLAUDE.md

For project-specific usage without installing as a skill:

```bash
# New project
curl -o CLAUDE.md https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md

# Existing project (append)
echo "" >> CLAUDE.md
curl https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md >> CLAUDE.md
```

### Installation Comparison

| Method | Scope | Agents | Auto-trigger | Use Case |
|--------|-------|--------|--------------|----------|
| Plugin | Global | Claude Code only | ✅ Yes | Claude users (recommended) |
| Global Skill | Global | All agents | ✅ Yes | Multi-agent users |
| CLAUDE.md | Project | All agents | ❌ No | Project-specific, lightweight |

## Prerequisites

- Obsidian 1.9+ with CLI enabled (`obsidian.json`: `{ "cli": true }`)
- Obsidian must be running when using the skill

## Architecture (4 Layers)

```
knowledge-base/
├── clippings/              # Pending clips (temporary, moved after processing)
│   └── *.md               # Web Clipper saved clips
├── raw/                    # Raw materials (immutable, read-only)
│   ├── articles/          # Articles
│   ├── papers/            # Papers
│   └── assets/           # Images, attachments
├── wiki/                   # LLM-generated Wiki (AI maintains)
│   ├── entities/          # Entity pages (people, orgs, projects)
│   ├── concepts/         # Concept pages (technical concepts)
│   ├── sources/          # Source summary pages
│   └── synthesis/        # Synthesis analysis pages
├── index.md               # Content catalog
└── log.md                # Operation log
```

**Directory Description**:
- `clippings/` — Temporary storage for pending web clips
- `raw/` — Archived raw materials, classified by topic, read-only
- `wiki/` — Structured knowledge maintained by LLM

## Core Features

### 0. Sync (Clippings → Raw)

**Execute first on each organize**: Move Clippings content to raw/

```
1. Check clippings/ for pending files
2. For each file:
   a. Read content, determine topic classification
   b. Generate filename (date prefix + title)
   c. Move to raw/ subdirectory
   d. Record the move operation
3. Clear clippings/ directory
4. Proceed to Ingest
```

### 1. Ingest

Add new materials to the wiki:

```
1. Scan raw/ for new/unprocessed files
2. For each new file:
   a. Extract key information
   b. Create source summary → wiki/sources/
   c. Update related entity/concept pages
   d. Mark file as processed
3. Update index.md
4. Log the operation
5. Execute Synthesize
```

### 2. Synthesize

**Auto-execute after Ingest**: Generate synthesis based on wiki content

```
1. Read index.md to understand wiki overview
2. Identify synthesis-worthy topics:
   - Multiple sources discussing same concept
   - Relationships between related entities
   - Cross-domain topic connections
3. For each topic:
   a. Read related pages
   b. Synthesize, extract commonalities, differences, insights
   c. Create wiki/synthesis/ page
   d. Update cross-references
4. Update index.md synthesis section
5. Log the operation
```

### 3. Query

Answer questions based on the wiki:

```bash
obsidian search query="keyword" limit=10
obsidian read file="PageName"
obsidian backlinks file="PageName"
```

### 4. Lint

Check wiki health:
- Contradiction detection
- Outdated information
- Orphaned pages
- Missing concepts
- Cross-references

## Key Principles

1. **Clippings → Raw** — Move clippings/ to raw/ first on each organize
2. **Raw sources immutable** — Never modify `raw/`
3. **LLM owns wiki** — Auto create, update, maintain Wiki
4. **Cross-reference everything** — Bidirectional `[[]]` links
5. **Flag contradictions** — Mark with `⚠️ Contradicts [[X]]`
6. **Synthesize after ingest** — Auto-generate synthesis after each ingest
7. **Keep index current** — Update after each change
8. **Append to log** — Record every operation

## Workflow

When organizing the knowledge base:

```
User requests organize
    ↓
Sync: clippings/ → raw/
    ↓
Ingest: Process raw/ files, create wiki pages
    ↓
Synthesize: Identify synthesis topics, generate pages
    ↓
Update index.md, log operations
```

## Why It Works

The tedious part of maintaining a knowledge base is not reading or thinking — it's **bookkeeping**: updating cross-references, keeping summaries current, flagging contradictions, maintaining consistency. Humans abandon wikis because maintenance burden grows faster than value. LLMs don't get bored, don't forget to update a cross-reference, can touch 15 files in one pass.

## Recommended Tools

- **Obsidian Web Clipper**: Browser extension to convert web articles to Markdown
- **Dataview**: Query page frontmatter, generate dynamic tables
- **graph view**: View Wiki structure, find orphaned pages
- **qmd** (optional): BM25 + vector search for large wikis
- **Git**: Version control and collaboration

## License

MIT License

## References

- [Karpathy LLM Knowledge Base Pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Obsidian CLI Documentation](https://help.obsidian.md/obsidian-uri)