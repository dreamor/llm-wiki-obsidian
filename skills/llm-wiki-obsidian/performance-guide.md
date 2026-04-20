# 性能优化指南

针对大型 Wiki（>1000 页）的性能优化策略和最佳实践。

## 性能瓶颈分析

### 常见瓶颈

| 瓶颈 | 症状 | 影响 |
|------|------|------|
| 文件系统遍历 | 搜索/索引慢 | O(n) 随页面数线性增长 |
| 链接解析 | Lint/跨链慢 | 每页需扫描所有链接 |
| Obsidian CLI | 命令响应慢 | 外部进程调用开销 |
| 内存占用 | 处理大页面慢 | 单页 >1200 词时明显 |

### 性能阈值

| Wiki 规模 | 建议策略 |
|-----------|----------|
| < 100 页 | 默认配置足够 |
| 100-500 页 | 启用缓存 |
| 500-1000 页 | 批处理 + 缓存 |
| > 1000 页 | qmd + 向量搜索 |

---

## 搜索优化

### 1. qmd 集成

[qmd](https://github.com/tobi/qmd) 是专为 Markdown 设计的本地搜索引擎，支持 BM25 + 向量搜索 + LLM 重排。

#### 安装

```bash
# macOS
brew install qmd

# 或从源码编译
git clone https://github.com/tobi/qmd.git
cd qmd && cargo build --release
```

#### 配置

```json
// config.json
{
  "performance": {
    "use_qmd_for_search": true,
    "qmd_path": "/usr/local/bin/qmd"
  },
  "query": {
    "search_mode": "hybrid",
    "vector_search_enabled": true,
    "bm25_enabled": true
  }
}
```

#### 使用

```bash
# 索引 Wiki
qmd index wiki/

# 搜索
qmd search "transformer attention" --top 10

# 语义搜索（需要嵌入模型）
qmd search "如何优化推理速度" --semantic --top 5
```

### 2. 缓存策略

#### 结果缓存

```json
// config.json
{
  "query": {
    "cache_results": true,
    "cache_ttl_seconds": 300
  }
}
```

#### 缓存实现

```bash
# ~/.cache/wiki-search-cache/
# 结构: query_hash -> results.json

# 清除缓存
rm -rf ~/.cache/wiki-search-cache/
```

### 3. 分层搜索

```
1. 精确匹配（标题）→ O(1) 哈希表
2. BM25 搜索（内容）→ O(log n) 倒排索引
3. 向量搜索（语义）→ O(n) 但可预计算
```

---

## 批处理优化

### 1. 批量操作

```json
// config.json
{
  "performance": {
    "batch_size": 50,
    "parallel_processing": true,
    "max_workers": 4
  }
}
```

### 2. 增量处理

只处理变更的文件：

```bash
# 使用 Git 检测变更
git diff --name-only HEAD~1 wiki/

# 只处理变更文件
for f in $(git diff --name-only HEAD~1 wiki/); do
  process_file "$f"
done
```

### 3. 延迟加载

对于大型 Wiki，按需加载页面内容：

```bash
# 先只加载标题和 frontmatter
head -20 wiki/concepts/*.md

# 需要时再加载完整内容
cat wiki/concepts/specific-concept.md
```

---

## Lint 优化

### 1. 分阶段 Lint

```bash
# 快速检查（仅死链接）
./scripts/lint.sh --quick --check dead_links

# 完整检查（所有项目）
./scripts/lint.sh --full
```

### 2. 并行 Lint

```bash
# 使用 GNU Parallel
find wiki -name "*.md" | parallel -j 4 ./scripts/lint-file.sh {}

# 或使用 xargs
find wiki -name "*.md" | xargs -P 4 -I {} ./scripts/lint-file.sh {}
```

### 3. 增量 Lint

```bash
# 只检查最近修改的文件
git diff --name-only HEAD~1 wiki/ | ./scripts/lint.sh --files -
```

---

## Obsidian CLI 优化

### 1. 批量命令

避免多次调用 CLI，使用批量操作：

```bash
# 不推荐：多次调用
obsidian read file="Page1"
obsidian read file="Page2"
obsidian read file="Page3"

# 推荐：一次读取多个
for page in Page1 Page2 Page3; do
  echo "file=$page"
done | obsidian read --batch
```

### 2. 超时配置

```json
// config.json
{
  "obsidian_cli": {
    "timeout_seconds": 30,
    "retry_count": 3,
    "retry_delay_ms": 1000
  }
}
```

### 3. 连接复用

保持 Obsidian 运行，避免冷启动：

```bash
# 检查 Obsidian 是否运行
if ! pgrep -x "Obsidian" > /dev/null; then
  open -a Obsidian
  sleep 5  # 等待启动
fi
```

---

## 内存优化

### 1. 流式处理

处理大文件时使用流式读取：

```bash
# 不推荐：加载整个文件
content=$(cat large-file.md)

# 推荐：流式处理
while IFS= read -r line; do
  process_line "$line"
done < large-file.md
```

### 2. 分页加载

```bash
# 分页读取大文件
head -100 large-file.md
tail -100 large-file.md

# 使用 sed 提取特定行
sed -n '100,200p' large-file.md
```

### 3. 大页面拆分

```bash
# 检测大页面
find wiki -name "*.md" -exec sh -c '
  words=$(wc -w < "$1")
  if [ $words -gt 1200 ]; then
    echo "$1: $words words (建议拆分)"
  fi
' _ {} \;
```

---

## 索引优化

### 1. 预构建索引

```bash
# 构建链接索引
grep -roh '\[\[[^]]*\]\]' wiki/ | \
  sed 's/\[\[\(.*\)\]\]/\1/' | \
  sort | uniq -c | sort -rn > .wiki-index/links.txt

# 构建页面索引
find wiki -name "*.md" -type f | \
  xargs -I {} basename {} .md | \
  sort > .wiki-index/pages.txt
```

### 2. 增量更新索引

```bash
# 只更新变更的索引
for f in $(git diff --name-only HEAD~1 wiki/); do
  update_index "$f"
done
```

### 3. 索引缓存

```json
// config.json
{
  "indexing": {
    "cache_dir": ".wiki-index",
    "auto_rebuild": false,
    "rebuild_interval_hours": 24
  }
}
```

---

## 监控与诊断

### 1. 性能监控

```bash
# 测量命令执行时间
time ./scripts/lint.sh

# 详细性能分析
/usr/bin/time -v ./scripts/lint.sh
```

### 2. 日志记录

```json
// config.json
{
  "logging": {
    "level": "debug",
    "log_to_file": true,
    "log_file_path": "wiki/.wiki-operations.log",
    "log_performance": true
  }
}
```

### 3. 性能基准

```bash
# 运行性能基准测试
./scripts/benchmark.sh

# 输出示例
# Wiki 规模: 1500 页
# 搜索延迟: 50ms (P50), 200ms (P99)
# Lint 时间: 30s
# 索引大小: 5MB
```

---

## 扩展策略

### 1. 分库策略

当 Wiki 超过 5000 页时，考虑分库：

```
wiki/
├── ai/           # AI 相关（独立索引）
├── programming/  # 编程相关（独立索引）
├── research/     # 研究笔记（独立索引）
└── personal/     # 个人笔记（独立索引）
```

### 2. 冷热分离

```
wiki/
├── active/       # 活跃页面（常驻内存）
└── archive/      # 归档页面（按需加载）
```

### 3. 分布式处理

对于超大规模 Wiki（>10000 页）：

- 使用 Elasticsearch 替代 qmd
- 使用 Redis 缓存热点数据
- 使用消息队列异步处理

---

## 最佳实践总结

### 小型 Wiki (< 100 页)

- 默认配置足够
- 直接使用 `obsidian search`
- 完整 Lint 每次运行

### 中型 Wiki (100-1000 页)

- 启用结果缓存
- 使用批处理
- 快速 Lint + 定期完整 Lint

### 大型 Wiki (> 1000 页)

- 集成 qmd 搜索
- 预构建索引
- 增量处理
- 并行执行
- 监控性能

### 超大型 Wiki (> 5000 页)

- 分库策略
- 冷热分离
- 分布式处理
- 专业搜索引擎