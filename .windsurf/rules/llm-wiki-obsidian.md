# llm-wiki-obsidian

Personal knowledge base management with Obsidian.

## Commands

- organize knowledge base - Run full organize workflow
- ingest [article] - Add new source to wiki
- query [topic] - Search and answer from wiki
- lint wiki - Health check
- sync clippings - Move clippings to raw/

## Architecture

```
knowledge-base/
├── raw/                    # Raw materials (immutable)
├── wiki/                   # LLM-generated Wiki
│   ├── entities/          # Entity pages
│   ├── concepts/         # Concept pages
│   ├── sources/          # Source summaries
│   └── synthesis/        # Synthesis analysis
├── index.md               # Content catalog
└── log.md                # Operation log
```

## Core Principles

1. Raw/ immutable — Never modify raw sources
2. LLM owns wiki/ — Auto maintain
3. Cross-reference everything — [[wikilinks]]
4. Flag contradictions — ⚠️ Contradicts [[X]]
5. Update index.md — After each change
6. Log operations — To daily note

## Obsidian Syntax Rules

### Mermaid Flowcharts
- Use ```mermaid code blocks
- Avoid Chinese in node IDs: A[中文] format
- Avoid consecutive arrows: split A --> B --> C

### Markdown Tables
- REQUIRED: Blank line between heading and table

### Wikilinks
- Correct: [[Page Name]]
- Wrong: [[Page Name|Path]]

## Page Types

- Entity: wiki/entities/ - People, organizations, projects
- Concept: wiki/concepts/ - Technical concepts, theories
- Source: wiki/sources/ - Source summaries
- Synthesis: wiki/synthesis/ - Analysis articles