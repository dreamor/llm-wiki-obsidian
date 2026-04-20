# Wiki Cross-Linker 自动跨链功能

自动检测和创建双向链接，确保 Wiki 页面之间的互联性。

## 核心概念

**双向链接**：当页面 A 链接到页面 B 时，页面 B 应该知道页面 A 链接了它。Obsidian 的 `[[wikilink]]` 语法天然支持反向链接查询，但我们需要确保：

1. 相关概念之间有明确的链接
2. 新创建的页面被正确链接到现有页面
3. 链接目标存在（无死链接）

## 自动跨链策略

### 1. 概念识别

当创建或更新页面时，识别以下模式并自动创建链接：

```markdown
# 识别模式
- 专有名词（大写开头的英文、中文术语）
- 已存在的 Wiki 页面名称
- 常见缩写（LLM、RAG、MoE 等）
- 技术术语（Transformer、Attention、LoRA 等）
```

### 2. 链接生成规则

| 场景 | 操作 |
|------|------|
| 创建 Entity 页 | 自动链接到相关的 Concept 页 |
| 创建 Concept 页 | 在定义中引用相关概念 |
| 创建 Source 页 | 链接到提及的所有 Entity 和 Concept |
| 创建 Synthesis 页 | 链接到所有引用的 Source 页 |

### 3. 反向链接检查

使用 `obsidian backlinks` 检查哪些页面链接到当前页面：

```bash
obsidian backlinks file="Page Name"
```

如果重要概念页面没有反向链接，说明需要补充链接。

## 自动跨链工作流

### Ingest 时自动跨链

```
1. 分析新资料，提取关键概念
2. 创建 Source 页面
3. 对于每个提及的概念：
   a. 如果概念页存在 → 添加 [[Concept]]
   b. 如果概念页不存在 → 创建概念页 + 添加 [[Concept]]
4. 更新相关 Entity/Concept 页，添加对新 Source 的引用
5. 更新 index.md
```

### Lint 时检查链接完整性

```
1. 扫描所有 wiki 链接 [[...]]
2. 检查目标页面是否存在
3. 报告死链接
4. 报告孤立页面（无入链）
5. 建议可能缺失的链接
```

## 链接建议算法

### 基于关键词匹配

```bash
# 对于每个页面，提取关键词
# 检查是否有其他页面包含这些关键词
# 如果匹配度 > 阈值，建议添加链接

grep -l "关键词" wiki/**/*.md
```

### 基于语义相似度（可选）

对于大型 Wiki，可以使用向量搜索：

```bash
# 使用 qmd 进行语义搜索
qmd search "query" --top 10
```

## 实现脚本

### crosslink-check.sh

```bash
#!/bin/bash
# 检查所有 wiki 链接是否有效

WIKI_DIR="${WIKI_DIR:-wiki}"

echo "=== Wiki Cross-Link Check ==="
echo ""

# 提取所有 wiki 链接
echo "## Extracting wiki links..."
grep -roh '\[\[[^]]*\]\]' "$WIKI_DIR" | \
  sed 's/\[\[\(.*\)\]\]/\1/' | \
  sort | uniq -c | sort -rn > /tmp/all_links.txt

echo "Found $(wc -l < /tmp/all_links.txt) unique links"
echo ""

# 检查死链接
echo "## Checking for dead links..."
dead_links=0
while read -r count link; do
  # 尝试多种可能的文件名
  found=0
  for dir in entities concepts sources synthesis; do
    if [ -f "$WIKI_DIR/$dir/${link}.md" ]; then
      found=1
      break
    fi
  done
  
  if [ $found -eq 0 ]; then
    echo "  DEAD LINK: [[$link]] (referenced $count times)"
    ((dead_links++))
  fi
done < /tmp/all_links.txt

echo ""
echo "Total dead links: $dead_links"
```

### find-orphans.sh

```bash
#!/bin/bash
# 查找孤立页面（无入链）

WIKI_DIR="${WIKI_DIR:-wiki}"

echo "=== Finding Orphan Pages ==="
echo ""

orphans=0
for f in $(find "$WIKI_DIR" -name "*.md" -type f); do
  # 获取页面名（不含路径和扩展名）
  page_name=$(basename "$f" .md)
  
  # 跳过 index.md 和 log.md
  if [ "$page_name" = "index" ] || [ "$page_name" = "log" ]; then
    continue
  fi
  
  # 检查是否有其他页面链接到它
  if ! grep -rq "\[\[$page_name\]\]" "$WIKI_DIR" --exclude="$(basename $f)"; then
    echo "  ORPHAN: $f"
    ((orphans++))
  fi
done

echo ""
echo "Total orphan pages: $orphans"
```

### suggest-links.sh

```bash
#!/bin/bash
# 建议可能缺失的链接

WIKI_DIR="${WIKI_DIR:-wiki}"

echo "=== Suggesting Missing Links ==="
echo ""

# 获取所有概念名称
concepts=$(find "$WIKI_DIR/concepts" -name "*.md" -type f -exec basename {} .md \; 2>/dev/null)

for concept in $concepts; do
  # 查找提及该概念但没有链接的页面
  files=$(grep -rl "$concept" "$WIKI_DIR" --include="*.md" | \
    xargs grep -L "\[\[$concept\]\]" 2>/dev/null)
  
  if [ -n "$files" ]; then
    echo "## Concept: $concept"
    echo "Pages mentioning but not linking:"
    for f in $files; do
      echo "  - $f"
    done
    echo ""
  fi
done
```

## 使用 Obsidian CLI 进行跨链

### 检查反向链接

```bash
obsidian backlinks file="Concept Name"
```

### 添加链接到页面

```bash
obsidian append file="Page Name" content="\n- Related: [[Concept Name]]"
```

### 批量更新

当创建新概念页时，自动更新相关页面：

```bash
# 1. 搜索提及该概念的页面
obsidian search query="关键词" limit=20

# 2. 对每个结果，添加链接
for page in $(obsidian search query="关键词" --format=list); do
  obsidian append file="$page" content="\n- See also: [[New Concept]]"
done
```

## 配置选项

在 `config.json` 中配置跨链行为：

```json
{
  "crosslinker": {
    "auto_link_enabled": true,
    "min_confidence": 0.7,
    "exclude_patterns": [
      "index.md",
      "log.md"
    ],
    "link_styles": {
      "inline": true,
      "see_also_section": true
    }
  }
}
```

## 最佳实践

### 1. 链接密度

- 每个段落最多 3-5 个链接
- 避免链接到显而易见的词（如"的"、"是"）
- 优先链接到概念页而非来源页

### 2. 链接位置

- **内联链接**：在正文中自然出现
- **参见部分**：页面末尾的 `## 相关概念` 部分
- **来源部分**：`## 来源` 部分链接到 Source 页

### 3. 链接文本

```markdown
# 好的链接
[[Continuous Batching|连续批处理]] 技术可以...

# 避免
[[Continuous Batching]] 是一种 [[技术]]...
```

### 4. 双向确认

创建链接后，检查反向链接：

```bash
obsidian backlinks file="Continuous Batching"
```

确保链接关系是双向可见的。

## 故障排除

### 链接不显示

1. 检查页面名称是否正确（区分大小写）
2. 确认目标页面在 `wiki/` 目录下
3. 验证 Obsidian 正在运行

### 反向链接为空

1. 使用 `obsidian search` 确认链接存在
2. 检查链接语法 `[[Page Name]]`
3. 等待 Obsidian 索引更新

### 性能问题

对于大型 Wiki（>1000 页）：

1. 使用 `qmd` 进行索引搜索
2. 限制每次处理的页面数量
3. 分批执行跨链操作