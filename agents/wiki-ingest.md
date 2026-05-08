---
name: wiki-ingest
description: >
  并行摄入多个来源到 Wiki 知识库。接收来源列表，并行提取关键信息，
  创建/更新 Wiki 页面，交叉引用，更新索引。适用于批量摄入场景。
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, mcp__fetch__fetch
---

# Wiki Ingest Agent — 并行摄入

@reference skills/llm-wiki-obsidian/wiki-ingest.md

## 摘要

并行摄入多个来源到 Wiki 知识库，确保高效、一致的页面创建和交叉引用。

## 触发条件

- 用户提供多个资料需要批量摄入
- 用户要求"批量整理"、"全部摄入"
- 需要并行处理多个来源以提高效率

## 完成标准

- [ ] 所有来源已保存到 `raw/`
- [ ] 所有来源页已创建在 `wiki/sources/`
- [ ] 所有相关实体/概念页已更新
- [ ] 交叉引用已检查
- [ ] `index.md` 已更新
- [ ] 日志已记录
