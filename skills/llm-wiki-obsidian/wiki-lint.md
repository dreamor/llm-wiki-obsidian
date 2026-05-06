# Wiki Lint — 知识库健康检查

> 本文档是 [SKILL.md](SKILL.md) 的子技能，定义健康检查的完整流程。

## 何时使用

- 用户要求"lint"、"体检"、"检查"知识库
- 用户要求修复死链接、孤立页面
- 定期维护（建议每周一次）
- 大量摄入新资料后

---

## 8 轮检查流程

### Round 1: 死链接检查

检查所有 `[[wikilinks]]` 是否指向存在的页面。

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

**修复策略**：
- 创建缺失的页面（如果有足够信息）
- 更新链接指向正确的页面
- 移除指向已删除页面的链接

### Round 2: 孤立页面检查

查找没有任何页面链接到它的页面。

```bash
for f in wiki/**/*.md; do
  name=$(basename "$f" .md)
  if [ "$name" = "index" ] || [ "$name" = "log" ]; then continue; fi
  if ! grep -rq "\[\[$name\]\]" wiki/ 2>/dev/null; then
    echo "ORPHAN: $f"
  fi
done
```

**修复策略**：
- 从相关页面添加 `[[wikilinks]]` 指向孤立页面
- 如果页面内容有价值但无关联，考虑合并到其他页面
- 如果页面确实无用，可以删除

### Round 3: 索引完整性

检查 `index.md` 是否包含所有实体/概念/来源页面。

```bash
# 检查 index.md 是否引用了所有 wiki 页面
for f in wiki/entities/*.md wiki/concepts/*.md wiki/sources/*.md wiki/synthesis/*.md; do
  name=$(basename "$f" .md)
  if ! grep -q "\[\[$name\]\]" wiki/index.md 2>/dev/null; then
    echo "MISSING FROM INDEX: $name"
  fi
done
```

**修复策略**：
- 将缺失页面添加到 index.md 对应分类
- 更新"最近更新"部分

### Round 4: 频繁引用但缺失的页面

统计哪些概念被频繁引用但没有独立页面。

```bash
# 统计引用频率
grep -roh '\[\[[^]]*\]\]' wiki/ | sort | uniq -c | sort -rn | head -20
# 检查是否有独立页面
for link in $(grep -roh '\[\[\K[^\]]*' wiki/ | sort -u); do
  if ! find wiki/ -name "${link}.md" 2>/dev/null | grep -q .; then
    count=$(grep -rc "\[\[$link\]\]" wiki/ | awk -F: '{s+=$2}END{print s}')
    if [ "$count" -gt 2 ]; then
      echo "FREQUENTLY REFERENCED BUT MISSING: [[$link]] (referenced $count times)"
    fi
  fi
done
```

**修复策略**：
- 引用次数 ≥ 3 的概念应创建独立页面
- 引用次数 ≥ 5 的概念必须创建独立页面

### Round 5: 矛盾检查

查找矛盾标注。

```bash
grep -r "\[!contradiction\]\|⚠️\|矛盾\|冲突" wiki/ --include="*.md" -l
```

**修复策略**：
- 审查每个矛盾标注
- 如果已有定论，更新旧信息并移除矛盾标注
- 如果仍有争议，保留标注并补充最新来源

### Round 6: 大页面拆分检查

检查超过 1200 词的页面。

```bash
for f in wiki/concepts/*.md wiki/entities/*.md; do
  words=$(wc -w < "$f")
  if [ "$words" -gt 1200 ]; then
    echo "OVERSIZED: $f ($words words)"
  fi
done
```

**修复策略**：
- 将大页面拆分为子主题
- 提取独立概念创建新页面
- 在原页面保留摘要和 `[[wikilinks]]` 指向子页面

### Round 7: Frontmatter 完整性

检查页面是否包含必要的 frontmatter 字段。

**必要字段**：
- Entity: `type`, `category`, `tags`, `date`
- Concept: `type`, `tags`, `date`, `sources`
- Source: `type`, `date`, `url`, `tags`
- Synthesis: `type`, `tags`, `date`

```bash
for f in wiki/**/*.md; do
  if [ "$(basename "$f")" = "index.md" ] || [ "$(basename "$f")" = "log.md" ]; then continue; fi
  if ! head -1 "$f" | grep -q "^---"; then
    echo "MISSING FRONTMATTER: $f"
    continue
  fi
  # 检查 type 字段
  if ! grep -q "^type:" "$f"; then
    echo "MISSING TYPE: $f"
  fi
done
```

### Round 8: 格式一致性

检查格式问题：
- 表格标题与表格之间有空行
- Mermaid 流程图语法正确
- wikilinks 格式统一（`[[页面名]]` 而非 `[[页面名|显示名]]`，除非必要）
- 标题层级一致

```bash
# 检查表格格式（标题后缺少空行）
grep -Pzo '#.*\n\|' wiki/**/*.md && echo "TABLE FORMAT: Missing blank line before table"
```

---

## 使用 lint.sh

```bash
# 完整检查（8 轮）
./scripts/lint.sh /path/to/wiki

# 详细输出
./scripts/lint.sh --verbose

# 只运行特定检查
./scripts/lint.sh --check dead-links

# 自动修复（部分问题）
./scripts/lint.sh --fix

# 快速检查（只运行 Round 1-3）
./scripts/lint.sh --quick
```

### 可用检查项

| 检查项 | `--check` 参数 | 说明 |
|--------|----------------|------|
| Round 1 | `dead-links` | 死链接 |
| Round 2 | `orphans` | 孤立页面 |
| Round 3 | `index` | 索引完整性 |
| Round 4 | `missing-pages` | 频繁引用但缺失的页面 |
| Round 5 | `contradictions` | 矛盾标注 |
| Round 6 | `oversized` | 大页面 |
| Round 7 | `frontmatter` | Frontmatter 完整性 |
| Round 8 | `format` | 格式一致性 |

---

## 修复策略总结

| 问题 | 严重程度 | 修复方式 |
|------|----------|----------|
| 死链接 | 高 | 创建页面/更新链接/移除链接 |
| 孤立页面 | 中 | 添加入链/合并/删除 |
| 索引缺失 | 中 | 添加到 index.md |
| 缺失概念页 | 中 | 创建新页面 |
| 矛盾 | 高 | 审查并更新/保留标注 |
| 大页面 | 低 | 拆分为子页面 |
| 缺少 frontmatter | 低 | 补充元数据 |
| 格式问题 | 低 | 修复格式 |

---

## 引用

- 主技能：[SKILL.md](SKILL.md)
- 自动跨链：[wiki-crosslinker.md](wiki-crosslinker.md)
- 性能优化：[performance-guide.md](performance-guide.md)