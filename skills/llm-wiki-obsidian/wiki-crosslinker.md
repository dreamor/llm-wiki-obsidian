---
name: wiki-crosslinker
description: >
  Auto cross-linker for Obsidian wiki. Scans all wiki pages and inserts
  missing [[wikilinks]] between related concepts and entities.
triggers: cross-link, auto link, link wiki, add links
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Wiki Cross-Linker — 自动跨链

扫描所有 wiki 页面，识别可链接的概念/实体，批量插入缺失的 `[[wikilinks]]`。

## 何时使用

当用户要求：
- "cross-link" - 扫描并添加跨链
- "auto link" - 自动链接相关页面
- "link wiki" - 为知识库添加链接
- "add links" - 补充缺失的链接

## 工作流程

```
1. 扫描 wiki/ 下所有 .md 文件
2. 提取每个页面的：
   - 标题（# 标题行）
   - 关键概念（## 要点、## 核心要点下的列表项）
   - 标签（tags: [...]）
   - 已有链接（[[]]）
3. 建立概念/实体索引
4. 对每个页面：
   a. 识别可链接但尚未链接的概念
   b. 找到合适的插入位置（## 相关概念、## 关联）
   c. 插入 [[wikilinks]]
5. 避免重复链接
6. 记录操作到日志
```

## 核心算法

### 1. 建立索引

```python
# 伪代码
pages = scan("wiki/**/*.md")
index = {}
for page in pages:
    index[page.title] = {
        "path": page.path,
        "concepts": extract_concepts(page),
        "tags": page.frontmatter.tags,
        "links": extract_links(page)
    }
```

### 2. 识别可链接项

```python
# 对每个页面，找到其他页面中提到的概念
for page in pages:
    available_links = []
    for title, data in index.items():
        if title == page.title:
            continue
        # 概念匹配
        for concept in data.concepts:
            if concept in page.content and title not in page.links:
                available_links.append(title)
```

### 3. 插入位置

优先插入到以下位置：
1. `## 相关概念` 下的列表
2. `## 关联` 下的列表
3. 页面末尾的"来源"部分

## 避免重复

- 记录已存在的链接
- 插入前检查是否已存在 `[[Title]]`
- 同一概念只链接一次

## 示例

### 输入：概念页 A

```markdown
# 注意力机制

> 让模型聚焦于关键信息

## 核心要点
- 自注意力计算
- 多头注意力
- 位置编码

## 相关概念
- [[Transformer]]
```

### 扫描发现：概念页 B 有"Transformer"

```markdown
# Transformer

> 注意力机制为核心的架构
```

### 输出：自动添加链接

```markdown
# 注意力机制

> 让模型聚焦于关键信息

## 核心要点
- 自注意力计算
- 多头注意力
- 位置编码

## 相关概念
- [[Transformer]]
- [[多头注意力]]
- [[位置编码]]
```

## 注意事项

1. **不修改 raw/** — 只处理 wiki/ 目录
2. **保持只读** — raw/ 是不可变的
3. **双向链接** — 插入时考虑反向链接
4. **避免过度链接** — 每个页面 3-5 个链接为宜
5. **检查孤立页面** — 用 `obsidian backlinks` 确认

## 推荐操作顺序

1. 先运行 Lint 检查孤立页面
2. 运行 Cross-Linker 补充链接
3. 再次运行 Lint 验证
4. 记录到日志

## Obsidian CLI 辅助

```bash
# 查看页面的反向链接（谁链接了这个页面）
obsidian backlinks file="页面名"

# 查看孤立页面（没有被任何页面链接）
obsidian search query="" limit=100
# 手动检查哪些页面没有反向链接
```

## 常见问题

### Q: 如何判断两个概念相关？
A: 根据以下信号：
- 标签重叠（tags）
- 一个概念的要点中提到另一个概念
- 在 synthesis 页面中一起出现

### Q: 会不会产生过多链接？
A: 建议每个页面最多 5-7 个相关概念链接。优先链接：
1. 直接相关（同一领域）
2. 高频出现
3. 尚未被充分链接

### Q: 如何处理循环链接？
A: 允许 A→B→A 的循环，这是 Wiki 的正常结构。

---

## 触发命令

- `/wiki-crosslinker` - 运行自动跨链
- `cross-link my wiki` - 添加跨链
- `add missing links` - 补充缺失链接
- `link related concepts` - 链接相关概念