# LLM Wiki Obsidian

[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](https://github.com/dreamor/llm-wiki-obsidian)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[English](#english) | [中文](#中文)

---

<a id="english"></a>

## English

Personal knowledge base management skill based on [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). Interact with your local Obsidian Vault via CLI to build and maintain a persistent Wiki.

### Core Idea

**Not RAG, Persistent Wiki!**

| RAG | Persistent Wiki |
|-----|-----------------|
| Re-discovers knowledge at query time | Knowledge **compiled and kept up-to-date** |
| No accumulation, re-assembles docs each time | Cross-references exist, contradictions flagged |
| NotebookLM, ChatGPT file upload | Obsidian + LLM = IDE + Programmer |

**Key Insight**: Wiki is a **persistent, compounding artifact**. Each added source enriches it.

### What's New in v1.2.0

- 🚀 **Node.js CLI** — Cross-platform TypeScript lint engine, 5-8x faster
- 🔄 **Incremental Processing** — Only scans changed files, sub-second on large Vaults
- 🛠️ **Modular Scripts** — 8 independent lint checks + shared function libraries
- 📋 **JSON Schema** — IDE autocompletion + validation for config files
- 🔬 **AutoResearch** — 3-round autonomous research loop (search → fetch → synthesize → ingest)
- 📊 **Bases Dashboard** — Obsidian 1.9.10+ native knowledge base overview
- 🗺️ **Canvas Visualization** — Knowledge graph canvas + onboarding canvas
- 📝 **Templater Templates** — Entity/Concept/Source/Synthesis templates
- 🔗 **Auto Cross-linking** — Incremental bidirectional link detection
- 🔍 **Health Checks** — 9 lint checks (including stale page archival suggestions)
- ⚡ **Performance** — Single-pass index build + incremental mode
- 🧪 **Test Suite** — Full unit and integration tests
- ⚙️ **Config System** — JSON Schema validation + flexible configuration
- 🤖 **Dedicated Agents** — Parallel ingest agent + standalone lint agent
- 📂 **CI/CD** — GitHub Actions (ShellCheck + test + JSON validate)

### Installation

#### Option A: Claude Code Plugin (Recommended)

```bash
/plugin marketplace add dreamor/llm-wiki-obsidian
/plugin install llm-wiki-obsidian@llm-wiki-obsidian
```

#### Option B: Git Clone

```bash
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.claude/skills/llm-wiki-obsidian
cd ~/.claude/skills/llm-wiki-obsidian
npm install          # Install TypeScript deps (optional, enables Node.js fast path)
bash install.sh      # Create multi-agent symlinks
```

#### Option C: CLAUDE.md Only

```bash
# New project
curl -o CLAUDE.md https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md

# Existing project (append)
echo "" >> CLAUDE.md
curl https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md >> CLAUDE.md
```

### Prerequisites

- Obsidian 1.9+ with CLI enabled (`obsidian.json`: `{ "cli": true }`)
- Obsidian must be running when using the skill
- Node.js >= 18 (optional, for TypeScript CLI engine)

### Core Features

#### Ingest

Organize new material into the Wiki:
```
1. Save raw material → raw/ directory
2. Read material, extract key information
3. Create source summary page → wiki/sources/
4. Update related entity/concept pages
5. Update index.md
6. Log the operation
```

#### Query

Answer questions based on Wiki knowledge:
```bash
obsidian search query="keyword" limit=10
obsidian read file="PageName"
obsidian backlinks file="PageName"
```

#### Lint

Check knowledge base health:
```bash
# Node.js CLI (recommended, auto-detected)
npx tsx src/cli.ts lint -w /path/to/wiki

# JSON output (for CI)
npx tsx src/cli.ts lint -w wiki --json

# Shell script (auto fallback to bash)
./skills/llm-wiki-obsidian/scripts/lint.sh /path/to/wiki

# Incremental mode (only check changed files)
./skills/llm-wiki-obsidian/scripts/lint.sh --incremental

# Dry-run preview
npx tsx src/cli.ts lint --dry-run
```

9 checks: dead links, orphan pages, index completeness, missing concepts, contradictions, large pages (>1200 words), frontmatter validation, format consistency, stale page archival (90+ days, 0 inlinks).

#### Cross-Linker

Incremental bidirectional link detection:
```bash
./skills/llm-wiki-obsidian/scripts/crosslink.sh /path/to/wiki
./skills/llm-wiki-obsidian/scripts/crosslink.sh --full      # Full rebuild
./skills/llm-wiki-obsidian/scripts/crosslink.sh --dry-run   # Preview
```

#### AutoResearch

3-round iterative loop: search → fetch → synthesize → ingest
```
/autoresearch [topic]        # 3 rounds (default)
/autoresearch [topic] --deep # 5 rounds
/autoresearch [topic] --quick # 1 round
```

### Architecture

#### Knowledge Base Structure
```
knowledge-base/
├── raw/                    # Raw materials (immutable, read-only)
│   ├── articles/
│   ├── papers/
│   └── assets/
├── wiki/                   # LLM-generated Wiki (AI maintains)
│   ├── entities/          # Entity pages (people, orgs, projects)
│   ├── concepts/          # Concept pages (technical concepts)
│   ├── sources/           # Source summary pages
│   ├── synthesis/         # Synthesis analysis pages
│   ├── meta/              # Bases dashboard
│   └── canvases/          # Canvas visualizations
├── _templates/            # Templater templates
├── index.md               # Content catalog
└── log.md                 # Operation log
```

#### Project Structure
```
llm-wiki-obsidian/
├── src/                    # TypeScript CLI engine
│   ├── cli.ts             # CLI entry point (commander)
│   ├── scanner.ts         # Wiki scan & index build
│   ├── config.ts          # Config loading
│   ├── changelog.ts       # Git changelog generation
│   ├── types.ts           # Type definitions
│   └── checks/            # 9 lint checks
├── skills/                 # Skill definitions + Shell scripts
│   └── llm-wiki-obsidian/
│       └── scripts/
│           ├── lib/        # Shared function libraries
│           ├── lint-checks/ # Modular checks
│           ├── lint.sh     # Entry (auto-detect Node.js)
│           ├── crosslink.sh
│           └── update-index.sh
├── scripts/                # Project maintenance
│   ├── migrate.sh         # Version migration
│   └── generate-agent-configs.sh
├── templates/              # Multi-agent templates
├── docs/                   # Documentation
└── .github/workflows/      # CI/CD
```

### Principles

1. **Raw sources immutable** — `raw/` is read-only, never modify
2. **LLM owns wiki** — Auto create, update, maintain Wiki
3. **Cross-reference everything** — Bidirectional `[[wikilinks]]`
4. **Flag contradictions** — Use Obsidian callout: `> [!contradiction] Contradicts [[X]]`
5. **Keep index current** — Update index.md after each change
6. **Append to log** — Record every operation to log.md

### Why It Works

The tedious part of maintaining a knowledge base is not reading or thinking — it's **bookkeeping**: updating cross-references, keeping summaries current, flagging contradictions. Humans abandon wikis because maintenance burden grows faster than value. LLMs don't get bored, don't forget to update a cross-reference, can touch 15 files in one pass.

### Testing

```bash
./skills/llm-wiki-obsidian/scripts/test.sh    # Unit tests
npm run typecheck                              # TypeScript check
./skills/llm-wiki-obsidian/scripts/test.sh --verbose
```

### Configuration

```bash
cp skills/llm-wiki-obsidian/config.example.json skills/llm-wiki-obsidian/config.json
```

| Key | Description | Default |
|-----|-------------|---------|
| `vault.path` | Obsidian Vault path | — |
| `wiki.subdirs` | Wiki subdirectory config | entities/concepts/sources/synthesis |
| `lint.enabled_checks` | Enabled lint checks | all |
| `lint.max_page_words` | Large page threshold | `1200` |
| `lint.required_frontmatter_fields` | Required frontmatter fields | `["type", "date"]` |

### References

- [Karpathy LLM Knowledge Base Pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Obsidian CLI Documentation](https://help.obsidian.md/obsidian-uri)

---

<a id="中文"></a>

## 中文

基于 [Karpathy LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 的个人知识库管理技能。通过 Obsidian CLI 与本地 Obsidian Vault 交互，构建和维护持久的 Wiki。

### 核心思想

**不是 RAG，是持久 Wiki！**

| RAG | 持久 Wiki |
|-----|-----------|
| 每次查询从原始文档重新发现知识 | 知识被编译并**持续保持最新** |
| 无积累，综合问题每次都要重新拼凑 | 交叉引用已存在，矛盾已标注，综合已形成 |
| NotebookLM、ChatGPT 文件上传 | Obsidian + LLM = IDE + 程序员 |

**关键洞察**：Wiki 是一个**持久、复利的产物**。每添加一份资料，Wiki 就变得更丰富。

### v1.2.0 新特性

- 🚀 **Node.js CLI** - 跨平台 TypeScript lint 引擎，5-8x 性能提升
- 🔄 **增量处理** - 仅扫描变更文件，大型 Vault 秒级响应
- 🛠️ **模块化脚本** - 8 个独立 lint 检查 + 共享函数库
- 📋 **JSON Schema** - 配置文件 IDE 补全 + 验证
- 🔬 **AutoResearch** - 3 轮自主研究循环（搜索→抓取→综合→摄入）
- 📊 **Bases Dashboard** - Obsidian 1.9.10+ 原生知识库概览仪表盘
- 🗺️ **Canvas 可视化** - 知识图谱画布 + 新用户引导画布
- 📝 **Templater 模板** - Entity/Concept/Source/Synthesis 四种模板
- 🔗 **自动跨链** - 增量检测和创建双向链接
- 🔍 **健康检查** - 9 项 Lint 检查（含陈旧页面归档建议）
- ⚡ **性能优化** - 单遍索引构建 + 增量模式
- 🧪 **测试套件** - 完整的单元测试和集成测试
- ⚙️ **配置系统** - JSON Schema 验证 + 灵活配置
- 🤖 **专用 Agents** - 并行摄入 Agent + 独立 Lint Agent
- 📂 **CI/CD** - GitHub Actions 自动检查（ShellCheck + test + JSON validate）

### 安装

#### 方式 A：Claude Code Plugin（推荐）

```bash
/plugin marketplace add dreamor/llm-wiki-obsidian
/plugin install llm-wiki-obsidian@llm-wiki-obsidian
```

#### 方式 B：Git Clone

```bash
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.claude/skills/llm-wiki-obsidian
cd ~/.claude/skills/llm-wiki-obsidian
npm install          # 安装 TypeScript 依赖（可选，启用 Node.js 快速路径）
bash install.sh      # 创建 multi-agent 符号链接
```

#### 方式 C：CLAUDE.md 独立使用

```bash
# 新项目
curl -o CLAUDE.md https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md

# 现有项目（追加）
echo "" >> CLAUDE.md
curl https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md >> CLAUDE.md
```

### 前置要求

- Obsidian 1.9+ 并启用 CLI（在 `obsidian.json` 中设置 `{ "cli": true }`）
- 使用技能时 Obsidian 必须正在运行
- Node.js >= 18（可选，用于 TypeScript CLI 引擎）

### 核心功能

#### Ingest（摄入）

将新资料整理到 Wiki：
```
1. 保存原始资料 → raw/ 对应目录
2. 阅读资料，提取关键信息
3. 创建来源摘要页 → wiki/sources/
4. 更新相关实体/概念页
5. 更新 index.md
6. 记录到日志
```

#### Query（查询）

基于 Wiki 综合回答问题：
```bash
obsidian search query="关键词" limit=10
obsidian read file="页面名"
obsidian backlinks file="页面名"
```

#### Lint（体检）

检查知识库健康状况：
```bash
# Node.js CLI（推荐，自动检测）
npx tsx src/cli.ts lint -w /path/to/wiki

# JSON 输出（适合 CI）
npx tsx src/cli.ts lint -w wiki --json

# Shell 脚本（自动 fallback 到 bash）
./skills/llm-wiki-obsidian/scripts/lint.sh /path/to/wiki

# 增量模式（仅检查变更文件）
./skills/llm-wiki-obsidian/scripts/lint.sh --incremental

# 预览修复操作
npx tsx src/cli.ts lint --dry-run
```

检查项目（9 项）：死链接、孤立页面、索引完整性、高频引用缺失概念、矛盾标注、大页面（>1200 词）、Frontmatter 完整性、格式一致性、陈旧页面归档建议（90天+无入链）。

#### Cross-Linker（自动跨链）

增量检测和创建双向链接：
```bash
./skills/llm-wiki-obsidian/scripts/crosslink.sh /path/to/wiki
./skills/llm-wiki-obsidian/scripts/crosslink.sh --full      # 全量重建
./skills/llm-wiki-obsidian/scripts/crosslink.sh --dry-run   # 预览模式
```

#### AutoResearch（自主研究）

3 轮迭代循环：搜索 → 抓取 → 综合 → 摄入
```
/autoresearch [主题]        # 3 轮研究（默认）
/autoresearch [主题] --deep # 5 轮深度研究
/autoresearch [主题] --quick # 1 轮快速研究
```

### 架构

#### 知识库结构
```
知识库/
├── raw/                    # 原始资料（不可变，只读）
│   ├── articles/          # 文章
│   ├── papers/            # 论文
│   └── assets/           # 图片、附件
├── wiki/                   # LLM 生成的 Wiki（AI 全权维护）
│   ├── entities/          # 实体页（人物、组织、项目）
│   ├── concepts/         # 概念页（技术概念、理论）
│   ├── sources/          # 来源摘要页
│   ├── synthesis/        # 综合分析页
│   ├── meta/             # Bases 仪表盘
│   └── canvases/         # Canvas 可视化
├── _templates/            # Templater 模板
├── index.md               # 内容目录
└── log.md                # 操作日志
```

#### 项目结构
```
llm-wiki-obsidian/
├── src/                    # TypeScript CLI 引擎
│   ├── cli.ts             # 命令行入口 (commander)
│   ├── scanner.ts         # Wiki 扫描 & 索引构建
│   ├── config.ts          # 配置加载
│   ├── changelog.ts       # Git 变更日志生成
│   ├── types.ts           # 类型定义
│   └── checks/            # 9 项 lint 检查
├── skills/                 # Skill 定义 + Shell 脚本
│   └── llm-wiki-obsidian/
│       └── scripts/
│           ├── lib/        # 共享函数库
│           ├── lint-checks/ # 模块化检查
│           ├── lint.sh     # 入口（auto-detect Node.js）
│           ├── crosslink.sh
│           └── update-index.sh
├── scripts/                # 项目维护脚本
│   ├── migrate.sh         # 版本迁移
│   └── generate-agent-configs.sh
├── templates/              # Multi-agent 模板
├── docs/                   # 文档
└── .github/workflows/      # CI/CD
```

### 关键原则

1. **Raw 不可变** — `raw/` 是只读的，绝不修改
2. **LLM 全权维护 wiki** — 自动创建、更新、维护
3. **全面交叉引用** — 双向 `[[wikilinks]]`
4. **标注矛盾** — `> [!contradiction] 与 [[X]] 矛盾`
5. **保持索引最新** — 每次变更后更新 index.md
6. **追加日志** — 每次操作记录到 log.md

### 为什么有效

维护知识库最繁琐的部分不是阅读或思考，而是 **bookkeeping（记账工作）**：更新交叉引用、保持摘要最新、标注矛盾、保持一致性。人类放弃 Wiki 是因为维护负担增长比价值快。LLM 不会厌倦、不会忘记更新交叉引用、可以一次触及 15 个文件。

### 测试

```bash
./skills/llm-wiki-obsidian/scripts/test.sh    # 单元测试
npm run typecheck                              # TypeScript 类型检查
./skills/llm-wiki-obsidian/scripts/test.sh --verbose
```

### 配置

```bash
cp skills/llm-wiki-obsidian/config.example.json skills/llm-wiki-obsidian/config.json
```

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `vault.path` | Obsidian Vault 路径 | — |
| `wiki.subdirs` | Wiki 子目录配置 | entities/concepts/sources/synthesis |
| `lint.enabled_checks` | Lint 检查项 | 全部 |
| `lint.max_page_words` | 大页面阈值 | `1200` |
| `lint.required_frontmatter_fields` | 必需 frontmatter 字段 | `["type", "date"]` |

### 推荐工具

- **Obsidian Web Clipper** — 浏览器扩展，将网页转 Markdown
- **Dataview / Bases** — 查询页面 frontmatter，生成动态表格
- **Graph View** — 查看 Wiki 结构，发现孤立页面
- **Templater** — 使用 `_templates/` 模板快速创建页面
- **qmd**（可选）— BM25 + 向量搜索，适合大型 Wiki
- **Git** — 版本控制和协作

### 参考

- [Karpathy LLM Knowledge Base Pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Obsidian CLI Documentation](https://help.obsidian.md/obsidian-uri)

---

## License

MIT
