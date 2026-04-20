---
name: llm-wiki-obsidian
version: 1.1.0
description: >
  基于 Karpathy LLM Knowledge Base 模式的个人知识库管理技能。通过 Obsidian CLI
  与本地 Obsidian Vault 交互。核心思想：LLM 不是在查询时从原始文档重新发现知识，
  而是增量构建和维护一个持久的 Wiki——结构化的、互联的 Markdown 文件集合。
  当添加新资料时，LLM 会读取、提取关键信息并整合到现有 Wiki 中。
  **触发条件**：用户提到知识库、Wiki、整理知识、建立知识体系、Obsidian、摄入资料、
  查询知识、维护个人知识库、或讨论 Karpathy/Wiki 模式。
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, mcp__fetch__fetch
license: MIT
features:
  - ingest: 摄入新资料到 Wiki
  - query: 查询知识库
  - lint: 健康检查（死链接、孤立页面等）
  - crosslinker: 自动双向链接
  - performance: 大型 Wiki 优化
---

# 个人知识库管理技能 — llm-wiki-obsidian

基于 Karpathy LLM Wiki 模式，通过 Obsidian CLI 操作本地 Obsidian Vault。

## 核心思想

**不是 RAG，是持久 Wiki！**

| RAG | 持久 Wiki |
|------|----------|
| 每次查询从原始文档重新发现知识 | 知识被编译并**持续保持最新** |
| 无积累，问5个文档的综合问题每次都要重新拼凑 | 交叉引用已存在，矛盾已标注，综合已形成 |
| NotebookLM、ChatGPT 文件上传 | Obsidian + LLM = IDE + 程序员 |

**关键洞察**：Wiki 是一个**持久、复利的产物**。每添加一份资料，Wiki 就变得更丰富。

**人类的工作**：策划来源、引导分析、提出好问题、思考意义。
**LLM 的工作**：其他一切（bookkeeping 工作：更新交叉引用、保持摘要最新、标注矛盾）。

---

## 何时使用此技能

当用户进行以下操作时激活此技能：

- **构建知识库**：要求建立或整理个人知识管理系统
- **Ingest（摄入）**：提供新资料（文章、论文、文档）要求整理到知识库
- **Query（查询）**：向知识库提问，寻求综合分析
- **Lint（体检）**：要求检查知识库的健康状况
- **维护 Wiki**：更新、修订、补充交叉引用
- **讨论知识管理**：关于如何组织知识、构建 Zettelkasten、卡片盒等方法论

---

## 架构（三层）

```
知识库/
├── raw/                    # 原始资料（不可变，只读）
│   ├── minimind/          # 按主题/项目分类
│   ├── articles/          # 文章
│   ├── papers/            # 论文
│   └── assets/           # 图片、附件
├── wiki/                   # LLM 生成的 Wiki（AI 全权维护）
│   ├── entities/          # 实体页（人物、组织、项目、产品）
│   ├── concepts/         # 概念页（技术概念、理论、方法论）
│   ├── sources/          # 来源摘要页
│   └── synthesis/        # 综合分析页
├── index.md               # 内容目录
├── log.md                # 操作日志
└── AGENTS.md             # 规则文件
```

---

## 核心操作

### 1. Ingest（摄入新资料）

当用户提供新资料时：

```
1. 保存原始资料 → raw/ 对应目录
2. 阅读资料，提取关键信息
3. 使用 obsidian create 创建来源摘要页 → wiki/sources/
4. 更新相关实体/概念页（obsidian append）
5. 更新 index.md
6. obsidian daily:append 记录到日志
```

### 2. Query（查询知识）

**通过 Obsidian CLI 查询**：
```bash
# 搜索相关页面
obsidian search query="关键词" limit=10

# 读取页面内容
obsidian read file="页面名"

# 查看反向链接（谁引用了这个页面）
obsidian backlinks file="页面名"
```

回答流程：
```
1. obsidian search 搜索相关页面
2. obsidian read 读取匹配页面
3. 综合回答（带引用）
4. 有价值的新洞察 → obsidian create 创建 synthesis 页
5. obsidian daily:append 记录查询
```

**重要**：好的答案应该**沉淀回 Wiki**！

### 3. Lint（知识库体检）

定期检查：
- **矛盾**：不同页面的信息是否冲突
- **过时**：是否有被新资料推翻的旧结论
- **孤立**：是否有页面没有被其他页面引用（用 `obsidian backlinks` 检查）
- **缺失**：是否有重要概念没有独立页面
- **交叉引用**：补充缺失的双向链接 `[[]]`

---

## Obsidian CLI 命令参考

Vault 名称从 `obsidian.json` 获取，Obsidian 应用必须正在运行。

### 读取与搜索

```bash
# 读取笔记
obsidian read file="页面名"

# 搜索 vault
obsidian search query="搜索词" limit=10

# 查看反向链接（谁引用了此页面）
obsidian backlinks file="页面名"

# 标签统计
obsidian tags sort=count counts

# 获取每日笔记
obsidian daily:read
```

### 创建与更新

```bash
# 创建新笔记（多行用 \n）
obsidian create name="新页面" content="# 标题\n\n内容" silent

# 追加内容到现有笔记
obsidian append file="页面名" content="新段落"

# 设置属性
obsidian property:set name="status" value="done" file="我的笔记"

# 追加到每日笔记
obsidian daily:append content="- [ ] 新任务"
```

### Vault 定位

```bash
# 指定 vault（当多 vault 时）
obsidian vault="个人知识库" search query="关键词"
```

### 实用标志

- `silent` — 不打开文件
- `--copy` — 复制输出到剪贴板
- `overwrite` — 覆盖已存在的文件

---

## Wiki 页面模板

### Entity 页（wiki/entities/）

```markdown
---
type: entity
category: person|project|organization
tags: [tag1]
date: 2026-04-17
---

# 实体名称

## 基本信息
- 属性1
- 属性2

## 关联
- [[相关实体]]
- [[相关概念]]

## 来源
- [[来源页]]
```

### Concept 页（wiki/concepts/）

```markdown
---
type: concept
tags: [tag1]
date: 2026-04-17
sources: [raw/原始文件.md]
---

# 概念名称

> 一句话定义

## 核心要点
- 要点1
- 要点2

## 相关概念
- [[相关概念]]

## 来源
- [[来源文件]]
```

### Source 页（wiki/sources/）

```markdown
---
type: source
date: 2026-04-17
url: https://...
tags: [LLM, RAG]
---

# 资料标题

## 摘要
2-3 句话概括

## 关键信息
- 要点1
- 要点2

## 关联
- [[相关实体]]
- [[相关概念]]
```

### Synthesis 页（wiki/synthesis/）

```markdown
---
type: synthesis
tags: [分析]
date: 2026-04-17
---

# 综合分析：XXX

## 核心发现
- 发现1
- 发现2

## 分析
[综合分析内容]

## 来源
- [[来源1]]
- [[来源2]]
```

---

## 关键原则

1. **Raw sources immutable** — `raw/` 是只读的，绝不修改
2. **LLM owns wiki** — 自动创建、更新、维护 Wiki
3. **Cross-reference everything** — 双向 `[[wikilinks]]`
4. **Flag contradictions** — 发现矛盾时标注 `⚠️ 与 [[X]] 矛盾`
5. **Keep index current** — 每次变更后更新 index.md
6. **Append to log** — 每次操作记录到 log.md

---

## index.md 格式

```markdown
# 📚 个人知识库索引

## 最近更新
- [[页面名]] - 一句话描述 (2026-04-17)

## 实体
| 页面 | 摘要 | 来源 | 更新 |
|------|------|------|------|

## 概念
| 页面 | 摘要 | 来源 | 更新 |
|------|------|------|------|

## 来源
| 页面 | 摘要 | 日期 |
|------|------|------|
```

## log.md 格式（追加到每日笔记）

```markdown
## [2026-04-17] ingest | 资料标题
- 创建 wiki/sources/页面.md
- 更新 3 个实体页、2 个概念页
- 更新 index.md

## [2026-04-17] query | 用户问题
简要回答，涉及的页面

## [2026-04-17] lint
发现的问题，解决的孤立页面
```

---

## 实用技巧

### Obsidian Web Clipper
浏览器扩展，将网页文章转 Markdown，快速获取资料到 raw/。

### 搜索增强
- 小 Wiki（<100 页）：`index.md` + `obsidian search` 足够
- 增长中的 Wiki：使用 [qmd](https://github.com/tobi/qmd) CLI（BM25 + 向量搜索 + LLM 重排）

### 插件推荐
- **Dataview**：查询页面 frontmatter，生成动态表格
- **graph view**：查看 Wiki 结构，发现孤立页面
- **Marp**：从 Markdown 生成幻灯片
- **Obsidian CLI**：内置 CLI（1.9+），需在 obsidian.json 启用

### Git 版本控制
Wiki 就是 Git 仓库，可以获得版本历史、分支和协作能力。

---

## 为什么有效

维护知识库最繁琐的部分不是阅读或思考，而是** bookkeeping（记账工作）**：更新交叉引用、保持摘要最新、标注矛盾、保持一致性。人类放弃 Wiki 是因为维护负担增长比价值快。LLM 不会厌倦、不会忘记更新交叉引用、可以一次触及 15 个文件。

---

## 快速开始

当用户提供新资料要摄入时：
```
1. 请用户提供资料内容或 URL
2. 分析资料，提取关键信息
3. 确定放 raw/ 哪个子目录
4. obsidian create 创建 wiki/sources/ 来源摘要页
5. obsidian append 更新相关实体/概念页
6. 更新 index.md
7. obsidian daily:append 记录
```

当用户向知识库提问时：
```
1. obsidian search 搜索相关页面
2. obsidian read 读取匹配页面
3. 综合回答并标注来源
4. 询问用户是否要将回答存入 Wiki
```

---

---

## 自动跨链（Cross-Linker）

自动检测和创建双向链接，确保 Wiki 页面之间的互联性。

详细文档：[wiki-crosslinker.md](wiki-crosslinker.md)

### 快速使用

```bash
# 检查链接完整性
./scripts/crosslink-check.sh

# 查找孤立页面
./scripts/find-orphans.sh

# 建议缺失链接
./scripts/suggest-links.sh
```

### 配置

```json
{
  "crosslinker": {
    "enabled": true,
    "auto_link_on_ingest": true,
    "min_confidence": 0.7
  }
}
```

---

## 健康检查（Lint）

自动检查知识库健康状况。

详细文档：运行 `./scripts/lint.sh --help`

### 检查项目

1. **死链接** - 链接目标不存在
2. **孤立页面** - 没有入链的页面
3. **索引完整性** - index.md 是否包含所有页面
4. **缺失概念** - 频繁引用但没有独立页面的概念
5. **矛盾标注** - 检查 ⚠️ 标记
6. **大页面** - 超过 1200 词的页面
7. **Frontmatter** - 缺少必要元数据
8. **格式一致性** - 表格、Mermaid 语法等

### 使用

```bash
# 完整检查
./scripts/lint.sh /path/to/wiki

# 详细输出
./scripts/lint.sh --verbose

# 自动修复（部分问题）
./scripts/lint.sh --fix
```

---

## 性能优化

针对大型 Wiki（>1000 页）的优化策略。

详细文档：[performance-guide.md](performance-guide.md)

### 快速优化

```json
// config.json
{
  "performance": {
    "large_wiki_threshold": 1000,
    "batch_size": 50,
    "use_qmd_for_search": true
  }
}
```

### qmd 集成

```bash
# 安装 qmd
brew install qmd

# 索引 Wiki
qmd index wiki/

# 搜索
qmd search "关键词" --top 10
```

---

## 测试

运行测试套件验证功能正确性。

```bash
# 单元测试
./scripts/test.sh

# 详细输出
./scripts/test.sh --verbose

# 集成测试（需要 Obsidian 运行）
./scripts/test.sh --integration
```

---

## 配置

复制 `config.example.json` 为 `config.json` 并根据需要修改。

```bash
cp skills/llm-wiki-obsidian/config.example.json skills/llm-wiki-obsidian/config.json
```

主要配置项：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `vault.path` | Obsidian Vault 路径 | - |
| `wiki.wiki_dir` | Wiki 目录名 | `wiki` |
| `crosslinker.enabled` | 启用自动跨链 | `true` |
| `lint.enabled_checks` | Lint 检查项 | 全部 |
| `performance.use_qmd_for_search` | 使用 qmd 搜索 | `false` |

---

## 参考资料

- [Karpathy LLM Knowledge Base](references/karpathy-kb-pattern.md)
- [Obsidian CLI 完整参考](references/obsidian-cli.md)
- [自动跨链功能](wiki-crosslinker.md)
- [性能优化指南](performance-guide.md)