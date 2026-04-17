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

## Installation

### Option A: Claude Code Plugin (Recommended)

```bash
# Add marketplace
/plugin marketplace add dreamor/llm-wiki-obsidian

# Install plugin
/plugin install llm-wiki-obsidian@llm-wiki-obsidian
```

### Option B: Git Clone

```bash
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.claude/skills/llm-wiki-obsidian
cd ~/.claude/skills/llm-wiki-obsidian
bash skills/llm-wiki-obsidian/scripts/setup.sh
```

### Option C: CLAUDE.md Only

```bash
# New project
curl -o CLAUDE.md https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md

# Existing project (append)
echo "" >> CLAUDE.md
curl https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md >> CLAUDE.md
```

## Prerequisites

- Obsidian 1.9+ with CLI enabled (`obsidian.json`: `{ "cli": true }`)
- Obsidian must be running when using the skill

## Core Features

### Ingest

Add new materials to the wiki:
```
1. Save raw material → raw/ corresponding directory
2. Extract key information
3. Create source summary → wiki/sources/
4. Update related entity/concept pages
5. Update index.md
6. Log the operation
```

### Query

Answer questions based on the wiki:
```bash
obsidian search query="keyword" limit=10
obsidian read file="PageName"
obsidian backlinks file="PageName"
```

### Lint

Check wiki health:
- Contradiction detection
- Outdated information
- Orphaned pages
- Missing concepts
- Cross-references

## Architecture

```
knowledge-base/
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

## Key Principles

1. **Raw sources immutable** — Never modify `raw/`
2. **LLM owns wiki** — Auto create, update, maintain Wiki
3. **Cross-reference everything** — Bidirectional `[[]]` links
4. **Flag contradictions** — Mark with `⚠️ Contradicts [[X]]`
5. **Keep index current** — Update after each change
6. **Append to log** — Record every operation

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