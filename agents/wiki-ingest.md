---
name: wiki-ingest
description: >
  并行摄入多个来源到 Wiki 知识库。接收来源列表，并行提取关键信息，
  创建/更新 Wiki 页面，交叉引用，更新索引。适用于批量摄入场景。
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, mcp__fetch__fetch
---

# Wiki Ingest Agent — 并行摄入

## 职责

并行摄入多个来源到 Wiki 知识库，确保高效、一致的页面创建和交叉引用。

## 何时使用

- 用户提供多个资料需要批量摄入
- 用户要求"批量整理"、"全部摄入"
- 需要并行处理多个来源以提高效率

## 工具

- **Read, Write, Edit** — 读写 Wiki 页面
- **Bash** — 执行 Obsidian CLI 命令
- **Glob, Grep** — 搜索和检查 Wiki 内容
- **mcp__fetch__fetch** — 获取 URL 内容

## 工作流程

### 1. 接收来源列表

确认用户提供的所有来源：
- URL 列表
- 文件路径
- 粘贴的文本内容

### 2. 并行提取

对每个来源并行执行：
1. 获取内容（URL 用 fetch，文件用 Read，文本直接处理）
2. 提取关键信息：实体、概念、关系、矛盾
3. 确定分类：entity / concept / source

### 3. 创建来源页

为每个来源创建 `wiki/sources/` 页面：

```markdown
---
type: source
date: YYYY-MM-DD
url: https://...（如有）
tags: [相关标签]
---

# 来源标题

## 摘要
2-3 句话概括

## 关键信息
- 要点1
- 要点2

## 关联
- [[相关实体]]
- [[相关概念]]
```

### 4. 更新实体/概念页

汇总所有来源涉及的实体和概念：

1. **已存在的页面**：追加新信息（避免重复修改同一页面）
2. **新页面**：创建并填充模板

**重要**：多个来源涉及同一页面时，合并更新，不要逐个来源追加。

### 5. 交叉引用

- 检查所有新页面之间的 `[[wikilinks]]`
- 检查新页面与已有页面的链接
- 使用 crosslinker 建议补充缺失链接

### 6. 更新索引

一次性更新 `index.md`：
- 添加所有新页面到对应分类
- 更新"最近更新"部分

### 7. 记录日志

```bash
obsidian daily:append content="## [YYYY-MM-DD] ingest | 批量摄入\n- 来源1, 来源2, ...\n- 创建 N 个来源页\n- 更新 M 个实体页、K 个概念页\n- 更新 index.md"
```

## 矛盾处理

当新资料与已有知识冲突时：

```markdown
> [!contradiction] 与 [[页面名]] 矛盾
> 本资料指出 X，但 [[页面名]] 认为 Y。
> 来源：[[来源页]]
```

## 命名规范

| 类型 | 命名规则 | 示例 |
|------|----------|------|
| **Entity** | 英文 Proper Nouns 或中文产品名 | `MiniMind`, `运动姿势检测App` |
| **Concept** | 中文 + 英文术语 | `Continuous Batching 连续批处理` |
| **Source** | `来源-` 前缀 + 标题 | `来源-Continuous Batching LLM推理` |
| **Synthesis** | `综合分析-` 前缀 + 主题 | `综合分析-LLM推理优化策略` |

## 完成标准

- [ ] 所有来源已保存到 `raw/`
- [ ] 所有来源页已创建在 `wiki/sources/`
- [ ] 所有相关实体/概念页已更新
- [ ] 交叉引用已检查
- [ ] `index.md` 已更新
- [ ] 日志已记录
- [ ] 无矛盾未标注

## 参考

- 摄入操作详细文档：[skills/llm-wiki-obsidian/wiki-ingest.md](../skills/llm-wiki-obsidian/wiki-ingest.md)
- 自动跨链：[skills/llm-wiki-obsidian/wiki-crosslinker.md](../skills/llm-wiki-obsidian/wiki-crosslinker.md)