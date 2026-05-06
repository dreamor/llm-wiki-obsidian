# Wiki Ingest — 摄入新资料

> 本文档是 [SKILL.md](SKILL.md) 的子技能，定义摄入操作的完整流程。

## 何时使用

- 用户提供新资料（文章、论文、文档、URL）
- 用户要求"摄入"、"整理"、"添加到知识库"
- 用户粘贴大段内容需要归档

---

## 摄入流程

```
1. 保存原始资料 → raw/ 对应目录
2. 阅读资料，提取关键信息
3. 使用 obsidian create 创建来源摘要页 → wiki/sources/
4. 更新相关实体/概念页（obsidian append）
5. 更新 index.md
6. obsidian daily:append 记录到日志
```

### 详细步骤

#### Step 1: 保存原始资料

将原始内容保存到 `raw/` 目录下的对应子目录：

| 资料类型 | 目录 | 示例 |
|----------|------|------|
| 项目相关 | `raw/{project-name}/` | `raw/minimind/` |
| 文章 | `raw/articles/` | `raw/articles/` |
| 论文 | `raw/papers/` | `raw/papers/` |
| 图片/附件 | `raw/assets/` | `raw/assets/` |

**原则**：`raw/` 是不可变的（immutable），绝不修改原始资料。

#### Step 2: 提取关键信息

阅读资料后，识别：
- **实体**：人物、组织、项目、产品
- **概念**：技术概念、理论、方法论
- **关系**：实体与概念之间的关联
- **矛盾**：与已有知识冲突的信息

#### Step 3: 创建来源摘要页

使用 Source 页模板创建 `wiki/sources/` 页面：

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

命令：
```bash
obsidian create name="wiki/sources/资料标题" content="# 资料标题\n\n..." silent
```

#### Step 4: 更新实体/概念页

对资料中涉及的每个实体和概念：

1. **已存在**：使用 `obsidian append` 追加新信息
2. **不存在**：使用 `obsidian create` 创建新页面

**Entity 页模板**（`wiki/entities/`）：

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

**Concept 页模板**（`wiki/concepts/`）：

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

#### Step 5: 更新 index.md

在 `index.md` 的对应分类表格中添加新页面条目：

```markdown
## 最近更新
- [[新页面名]] - 一句话描述 (2026-04-17)
```

#### Step 6: 记录日志

```bash
obsidian daily:append content="## [2026-04-17] ingest | 资料标题\n- 创建 wiki/sources/页面.md\n- 更新 3 个实体页、2 个概念页\n- 更新 index.md"
```

---

## 批量摄入

当用户提供多个资料时：

1. 逐个保存原始资料到 `raw/`
2. 并行提取关键信息
3. 批量创建来源页
4. 汇总更新实体/概念页（避免重复修改同一页面）
5. 一次性更新 index.md
6. 记录批量日志

---

## 矛盾处理

当新资料与已有知识冲突时：

1. 在相关页面添加矛盾标注：
   ```markdown
   > [!contradiction] 与 [[页面名]] 矛盾
   > 本资料指出 X，但 [[页面名]] 认为 Y。
   > 来源：[[来源页]]
   ```
2. 不要删除旧信息，保留双方并标注
3. 在日志中记录矛盾

---

## 命名规范

| 类型 | 命名规则 | 示例 |
|------|----------|------|
| **Entity** | 英文 Proper Nouns 或中文产品名 | `MiniMind`, `运动姿势检测App` |
| **Concept** | 中文 + 英文术语 | `Continuous Batching 连续批处理`, `注意力机制` |
| **Source** | `来源-` 前缀 + 标题 | `来源-Continuous Batching LLM推理` |
| **Synthesis** | `综合分析-` 前缀 + 主题 | `综合分析-LLM推理优化策略` |

---

## 引用

- 主技能：[SKILL.md](SKILL.md)
- 自动跨链：[wiki-crosslinker.md](wiki-crosslinker.md)
- 性能优化：[performance-guide.md](performance-guide.md)