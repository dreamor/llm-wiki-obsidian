# Karpathy LLM Knowledge Base Pattern

> Based on [Andrej Karpathy's gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)

## Core Philosophy

**Not RAG, but Persistent Wiki!**

| Approach | RAG | Persistent Wiki |
|----------|-----|-----------------|
| Knowledge retrieval | Query-time discovery from raw docs | Pre-compiled, continuously updated |
| Accumulation | None - each query starts fresh | Compounds over time |
| Cross-references | Must be recomputed each time | Already exist |
| Contradictions | Not tracked | Flagged and documented |
| Synthesis | Ad-hoc | Pre-formed and refined |

## The Problem with RAG

RAG systems have a fundamental limitation: they treat knowledge as a retrieval problem, not a management problem.

1. **No memory**: Each query starts from scratch
2. **No synthesis**: Complex questions require re-assembling multiple docs
3. **No contradiction tracking**: Conflicting information isn't flagged
4. **No accumulation**: Adding more docs doesn't make the system smarter

## The Wiki Approach

A persistent wiki solves these problems by treating knowledge as a **compounding asset**:

1. **Memory**: Previous work is preserved
2. **Synthesis**: Cross-references and summaries are pre-built
3. **Contradiction tracking**: Conflicts are explicitly flagged
4. **Accumulation**: Each addition enriches the whole

## Role Division

### Human's Job
- Curate sources (what's worth adding?)
- Guide analysis (what's important?)
- Ask good questions (what do I want to understand?)
- Think about meaning (what does this mean for me?)

### LLM's Job
- Bookkeeping (the tedious part humans hate)
- Update cross-references
- Keep summaries current
- Flag contradictions
- Maintain consistency
- Touch 15+ files in one pass

## Why This Works

Humans abandon wikis because **maintenance burden grows faster than value**:

- Adding a page is easy
- Keeping it linked is hard
- Updating when things change is harder
- Finding contradictions is nearly impossible

LLMs don't get bored, don't forget, and can touch many files simultaneously.

## Implementation Pattern

### Three-Layer Architecture

```
knowledge-base/
├── raw/                    # Layer 1: Immutable sources
│   ├── articles/
│   ├── papers/
│   └── assets/
├── wiki/                   # Layer 2: LLM-maintained wiki
│   ├── entities/          # People, orgs, projects
│   ├── concepts/          # Technical concepts
│   ├── sources/           # Source summaries
│   └── synthesis/         # Analysis pages
└── AGENTS.md              # Layer 3: Rules/schema
```

### Key Principles

1. **Raw sources are immutable**: Never modify `raw/`
2. **LLM owns wiki**: Full authority over `wiki/`
3. **Cross-reference everything**: Bidirectional `[[]]` links
4. **Flag contradictions**: `⚠️ Contradicts [[X]]`
5. **Keep index current**: Update after each change
6. **Append-only log**: Track all operations

### Workflow

**Ingest (Add new material)**:
1. Save raw material to `raw/`
2. Extract key information
3. Create source summary in `wiki/sources/`
4. Update related entity/concept pages
5. Update index
6. Log the operation

**Query (Ask questions)**:
1. Search for relevant pages
2. Read matching pages
3. Synthesize answer with citations
4. Optionally create synthesis page for valuable insights
5. Log the query

**Lint (Health check)**:
1. Find contradictions between pages
2. Identify outdated information
3. Find orphaned pages (no incoming links)
4. Identify missing concept pages
5. Add missing cross-references

## Benefits Over Time

| Time | RAG | Wiki |
|------|-----|------|
| Day 1 | Query returns 5 docs | Same as RAG |
| Day 30 | Query returns 5 docs (same quality) | Query returns synthesized answer |
| Day 100 | Query returns 5 docs (same quality) | Query returns rich, cross-referenced answer |
| Day 365 | Query returns 5 docs (same quality) | Query returns expert-level synthesis |

The wiki **compounds**. RAG **does not**.

## Tools

- **Obsidian**: Markdown editor with wikilinks
- **Obsidian CLI**: Command-line interface for automation
- **qmd** (optional): BM25 + vector search for large wikis
- **Git**: Version control and collaboration

## References

- Original gist: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- Obsidian: https://obsidian.md
- Obsidian CLI: https://help.obsidian.md/obsidian-uri