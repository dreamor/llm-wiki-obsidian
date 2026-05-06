# Wiki Query — 查询知识库

> 本文档是 [SKILL.md](SKILL.md) 的子技能，定义查询操作的完整流程。

## 何时使用

- 用户向知识库提问
- 用户要求"查询"、"搜索"知识
- 用户需要综合分析多个主题
- 用户问"我对 X 了解什么？"

---

## 查询流程

```
1. obsidian search 搜索相关页面
2. obsidian read 读取匹配页面
3. 综合回答（带引用）
4. 有价值的新洞察 → obsidian create 创建 synthesis 页
5. obsidian daily:append 记录查询
```

### 详细步骤

#### Step 1: 搜索相关页面

```bash
# 关键词搜索
obsidian search query="关键词" limit=10

# 多关键词组合搜索
obsidian search query="注意力机制 Transformer" limit=10
```

搜索策略：
- 先用宽泛关键词获取候选集
- 再用精确关键词缩小范围
- 检查 `index.md` 获取全局视图

#### Step 2: 读取匹配页面

```bash
# 读取页面内容
obsidian read file="页面名"

# 查看反向链接（谁引用了这个页面）
obsidian backlinks file="页面名"
```

读取策略：
- 优先读取概念页和综合分析页（信息密度高）
- 通过反向链接发现关联页面
- 必要时追溯到来源页验证原始信息

#### Step 3: 综合回答

回答格式要求：

1. **先给结论**，再展开细节
2. **标注来源**：每个关键论点标注 `[[来源页面]]`
3. **标注矛盾**：如果存在矛盾观点，明确指出
4. **区分事实与推断**：Wiki 中的事实 vs 你的分析推断

示例回答结构：

```markdown
## 关于 X 的知识

[结论]

### 要点1
- 细节... [[相关概念页]]

### 要点2
- 细节... [[相关实体页]]

### 矛盾
> [!contradiction] [[页面A]] 与 [[页面B]] 存在分歧
> 页面A认为X，页面B认为Y

### 推断
[基于已有知识的分析，明确标注为推断]
```

#### Step 4: 沉淀新洞察

如果查询产生了有价值的新综合分析：

1. 创建 Synthesis 页：

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

2. 命令：
```bash
obsidian create name="wiki/synthesis/综合分析-XXX" content="# 综合分析：XXX\n\n..." silent
```

3. 更新 index.md 的综合分析部分

**原则**：不是每个查询都需要创建 synthesis 页，只有当回答综合了多个来源且产生了新洞察时才创建。

#### Step 5: 记录日志

```bash
obsidian daily:append content="## [2026-04-17] query | 用户问题\n简要回答，涉及的页面"
```

---

## 高级查询技巧

### 链式查询

当单一搜索不够时：
1. 先搜索核心概念
2. 通过 `obsidian backlinks` 发现关联
3. 读取关联页面获取上下文
4. 综合多个页面的信息

### 矛盾挖掘

主动查找知识库中的矛盾：
1. 搜索同一主题的多个页面
2. 对比不同来源的观点
3. 标注发现的矛盾

### 知识缺口识别

查询过程中发现的知识缺口：
1. 搜索返回结果不足
2. 页面内容陈旧
3. 概念页缺少关键要点
4. 实体页缺少关联

→ 建议用户摄入相关资料填补缺口

---

## 搜索增强

| Wiki 规模 | 推荐方案 |
|-----------|----------|
| 小（<100 页） | `index.md` + `obsidian search` |
| 中（100-1000 页） | `obsidian search` + qmd 辅助 |
| 大（>1000 页） | qmd（BM25 + 向量搜索 + LLM 重排） |

详见 [performance-guide.md](performance-guide.md)

---

## 引用

- 主技能：[SKILL.md](SKILL.md)
- 摄入操作：[wiki-ingest.md](wiki-ingest.md)
- 健康检查：[wiki-lint.md](wiki-lint.md)