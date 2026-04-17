# llm-wiki-obsidian

Personal knowledge base with Obsidian.

## Key Commands

- organize knowledge base - Run full organize workflow
- ingest article - Add new source to wiki
- query knowledge - Search and answer from wiki
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

## Page Types

- Entity: wiki/entities/ - People, orgs, projects
- Concept: wiki/concepts/ - Technical concepts
- Source: wiki/sources/ - Source summaries
- Synthesis: wiki/synthesis/ - Analysis