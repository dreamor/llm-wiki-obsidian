# llm-wiki-obsidian

Personal knowledge base management with Obsidian using the LLM Wiki pattern.

## Commands

- organize my knowledge base
- ingest [article/URL]
- query [topic]
- lint wiki

## Architecture

```
wiki/
├── entities/   # People, orgs, projects
├── concepts/   # Technical concepts
├── sources/    # Source summaries
└── synthesis/  # Analysis pages
```

## Naming

| Type | Rule | Example |
|------|------|---------|
| Entity | Proper nouns | `MiniMind` |
| Concept | Chinese + English | `Continuous Batching 连续批处理` |
| Source | `来源-` prefix | `来源-Continuous Batching LLM推理` |
| Synthesis | `综合分析-` prefix | `综合分析-LLM推理优化策略` |

## Principles

1. Raw/ immutable — never modify raw sources
2. LLM owns wiki/ — auto maintain
3. Cross-reference everything — `[[]]` links
4. Flag contradictions — `⚠️ Contradicts [[X]]`
5. Update index.md — after each change

See CLAUDE.md for full documentation.
