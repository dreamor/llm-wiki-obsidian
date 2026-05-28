# CLAUDE.md — LLM Wiki Obsidian

Personal knowledge base management based on Karpathy's LLM Wiki pattern. Use with Obsidian CLI.

## Core Concept

**Not RAG, Persistent Wiki!** Each source enriches the wiki. Cross-references exist, contradictions flagged.

| RAG | Persistent Wiki |
|-----|-----------------|
| Re-discovers knowledge at query time | Knowledge **compiled and kept up-to-date** |
| No accumulation, re-assembles 5 docs each time | Cross-references exist, contradictions flagged |
| NotebookLM, ChatGPT file upload | Obsidian + LLM = IDE + Programmer |

**Key Insight**: Wiki is a **persistent, compounding artifact**. Each added source enriches it.

**Human's job**: Curate sources, guide analysis, ask good questions.
**LLM's job**: Bookkeeping (update cross-references, keep summaries current, flag contradictions).

## Quick Reference

### Ingest (Add New Material)
```bash
obsidian create name="wiki/sources/Title" content="# Title\n\nSummary..."
obsidian append file="EntityName" content="New info"
obsidian daily:append content="## [date] ingest | Title"
```

### Query (Search Knowledge)
```bash
obsidian search query="keyword" limit=10
obsidian read file="PageName"
obsidian backlinks file="PageName"
```

### Lint (Health Check)

执行完整健康检查（7 轮）：

#### Round 1: 死链接检查
```bash
# 查找所有 wiki 链接
grep -rh '\[\[' wiki/ | grep -oP '\[\K[^\]]+' | sort -u > /tmp/all_links.txt
# 检查目标页面是否存在
for link in $(cat /tmp/all_links.txt); do
  if ! find wiki/ -name "${link}.md" -o -name "${link}.md" 2>/dev/null | grep -q .; then
    echo "DEAD LINK: [[$link]]"
  fi
done
```

#### Round 2: 孤立页面检查
```bash
# 没有任何页面链接到它
for f in wiki/**/*.md; do
  if ! grep -q "\[\[$(basename $f .md)\]\]" wiki/**/*.md 2>/dev/null; then
    echo "ORPHAN: $f"
  fi
done
```

#### Round 3: 索引完整性
- 检查 index.md 是否包含所有实体/概念/来源
- 检查是否有页面未被 index 引用

#### Round 4: 频繁引用但缺失的页面
- 统计哪些概念被频繁引用但没有独立页面
- 考虑创建对应概念页

#### Round 5: 矛盾检查
```bash
grep -r "⚠️\|矛盾\|冲突" wiki/
```

#### Round 6: 大页面拆分检查
- 单个概念页超过 1200 词 → 建议拆分
- 检查 `wiki/concepts/` 下是否有子目录结构

#### Round 7: 格式一致性
- 检查 frontmatter 完整性（type, tags, date）
- 检查表格格式（标题与表格之间有空行）
- 检查 Mermaid 流程图语法正确性

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

## Principles

1. **Raw/ immutable** — Never modify raw sources
2. **LLM owns wiki/** — Auto maintain
3. **Cross-reference everything** — `[[]]` links
4. **Flag contradictions** — `⚠️ Contradicts [[X]]`
5. **Update index.md** — After each change
6. **Log operations** — To daily note

## Obsidian CLI Commands

```bash
# Read & Search
obsidian read file="PageName"
obsidian search query="keyword" limit=10
obsidian backlinks file="PageName"
obsidian tags sort=count counts

# Create & Update
obsidian create name="New Page" content="# Title\n\nContent" silent
obsidian append file="PageName" content="New paragraph"
obsidian property:set name="status" value="done" file="My Note"
obsidian daily:append content="- [ ] New task"

# Vault targeting
obsidian vault="VaultName" search query="keyword"
```

## Page Templates

### Entity (wiki/entities/)
```markdown
---
type: entity
category: person|project|organization
tags: [tag1]
date: 2026-04-17
---
# Entity Name
## Basic Info
## Relations
- [[Related Entity]]
## Sources
```

### Concept (wiki/concepts/)
```markdown
---
type: concept
tags: [tag1]
date: 2026-04-17
sources: [raw/original.md]
---
# Concept Name
> One-sentence definition
## Key Points
## Related Concepts
```

### Source (wiki/sources/)
```markdown
---
type: source
date: 2026-04-17
url: https://...
tags: [LLM, RAG]
---
# Material Title
## Summary
## Key Info
## Relations
```

### Synthesis (wiki/synthesis/)
```markdown
---
type: synthesis
tags: [analysis]
date: 2026-04-17
---
# Synthesis: XXX
## Key Findings
## Analysis
## Sources
```

## Installation

### Option A: Claude Code Plugin (Recommended)
```bash
/plugin marketplace add dreamor/llm-wiki-obsidian
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

## Why It Works

The tedious part of maintaining a knowledge base is not reading or thinking — it's **bookkeeping**: updating cross-references, keeping summaries current, flagging contradictions, maintaining consistency. Humans abandon wikis because maintenance burden grows faster than value. LLMs don't get bored, don't forget to update a cross-reference, can touch 15 files in one pass.

---

See full documentation at [GitHub](https://github.com/dreamor/llm-wiki-obsidian).
