# LLM Wiki Obsidian

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](https://github.com/dreamor/llm-wiki-obsidian)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

基于 [Karpathy LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 的个人知识库管理技能。通过 Obsidian CLI 与本地 Obsidian Vault 交互，构建和维护持久的 Wiki。

## 核心思想

**不是 RAG，是持久 Wiki！**

| RAG | 持久 Wiki |
|-----|-----------|
| 每次查询从原始文档重新发现知识 | 知识被编译并**持续保持最新** |
| 无积累，综合问题每次都要重新拼凑 | 交叉引用已存在，矛盾已标注，综合已形成 |
| NotebookLM、ChatGPT 文件上传 | Obsidian + LLM = IDE + 程序员 |

**关键洞察**：Wiki 是一个**持久、复利的产物**。每添加一份资料，Wiki 就变得更丰富。

## ✨ v1.1.0 新特性

- 🔗 **自动跨链** - 自动检测和创建双向链接
- 🔍 **健康检查** - Lint 脚本检查死链接、孤立页面等
- ⚡ **性能优化** - 大型 Wiki（>1000 页）优化指南
- 🧪 **测试套件** - 完整的单元测试和集成测试
- ⚙️ **配置系统** - 灵活的 JSON 配置文件

## 安装

### 方式 A：Claude Code Plugin（推荐）

```bash
# 添加市场
/plugin marketplace add dreamor/llm-wiki-obsidian

# 安装插件
/plugin install llm-wiki-obsidian@llm-wiki-obsidian
```

### 方式 B：Git Clone

```bash
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.claude/skills/llm-wiki-obsidian
cd ~/.claude/skills/llm-wiki-obsidian
bash skills/llm-wiki-obsidian/scripts/setup.sh
```

### 方式 C：CLAUDE.md 独立使用

```bash
# 新项目
curl -o CLAUDE.md https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md

# 现有项目（追加）
echo "" >> CLAUDE.md
curl https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md >> CLAUDE.md
```

## 前置要求

- Obsidian 1.9+ 并启用 CLI（在 `obsidian.json` 中设置 `{ "cli": true }`）
- 使用技能时 Obsidian 必须正在运行

## 核心功能

### Ingest（摄入）

将新资料整理到 Wiki：
```
1. 保存原始资料 → raw/ 对应目录
2. 阅读资料，提取关键信息
3. 创建来源摘要页 → wiki/sources/
4. 更新相关实体/概念页
5. 更新 index.md
6. 记录到日志
```

### Query（查询）

基于 Wiki 综合回答问题：
```bash
obsidian search query="关键词" limit=10
obsidian read file="页面名"
obsidian backlinks file="页面名"
```

### Lint（体检）

检查知识库健康状况：
```bash
# 完整检查
./scripts/lint.sh /path/to/wiki

# 详细输出
./scripts/lint.sh --verbose

# 自动修复
./scripts/lint.sh --fix
```

检查项目：
- 死链接检测
- 孤立页面发现
- 索引完整性验证
- 矛盾标注检测
- 大页面警告
- Frontmatter 完整性
- 格式一致性

### Cross-Linker（自动跨链）

自动检测和创建双向链接：
```bash
# 检查链接完整性
./scripts/crosslink-check.sh

# 查找孤立页面
./scripts/find-orphans.sh

# 建议缺失链接
./scripts/suggest-links.sh
```

### Performance（性能优化）

针对大型 Wiki 的优化策略：
- qmd 集成（BM25 + 向量搜索）
- 批处理和并行执行
- 缓存策略
- 增量处理

详见 [performance-guide.md](skills/llm-wiki-obsidian/performance-guide.md)

## 架构

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
│   └── synthesis/        # 综合分析页
├── index.md               # 内容目录
└── log.md                # 操作日志
```

## 关键原则

1. **Raw sources immutable** — `raw/` 是只读的，绝不修改
2. **LLM owns wiki** — 自动创建、更新、维护 Wiki
3. **Cross-reference everything** — 双向 `[[wikilinks]]`
4. **Flag contradictions** — 发现矛盾时标注 `⚠️ 与 [[X]] 矛盾`
5. **Keep index current** — 每次变更后更新 index.md
6. **Append to log** — 每次操作记录到 log.md

## 为什么有效

维护知识库最繁琐的部分不是阅读或思考，而是 **bookkeeping（记账工作）**：更新交叉引用、保持摘要最新、标注矛盾、保持一致性。人类放弃 Wiki 是因为维护负担增长比价值快。LLM 不会厌倦、不会忘记更新交叉引用、可以一次触及 15 个文件。

## 推荐工具

- **Obsidian Web Clipper**：浏览器扩展，将网页转 Markdown
- **Dataview**：查询页面 frontmatter，生成动态表格
- **graph view**：查看 Wiki 结构，发现孤立页面
- **qmd**（可选）：BM25 + 向量搜索，适合大型 Wiki
- **Git**：版本控制和协作

## 测试

```bash
# 单元测试
./scripts/test.sh

# 详细输出
./scripts/test.sh --verbose

# 集成测试（需要 Obsidian 运行）
./scripts/test.sh --integration
```

## 配置

```bash
# 复制配置示例
cp skills/llm-wiki-obsidian/config.example.json skills/llm-wiki-obsidian/config.json

# 编辑配置
vim skills/llm-wiki-obsidian/config.json
```

主要配置项：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `vault.path` | Obsidian Vault 路径 | - |
| `crosslinker.enabled` | 启用自动跨链 | `true` |
| `lint.enabled_checks` | Lint 检查项 | 全部 |
| `performance.use_qmd_for_search` | 使用 qmd 搜索 | `false` |
| `performance.large_wiki_threshold` | 大型 Wiki 阈值 | `1000` |

## 许可证

MIT License

## 参考

- [Karpathy LLM Knowledge Base Pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Obsidian CLI Documentation](https://help.obsidian.md/obsidian-uri)