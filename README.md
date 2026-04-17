# LLM Wiki Obsidian

基于 [Karpathy LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 的个人知识库管理技能。通过 Obsidian CLI 与本地 Obsidian Vault 交互，构建和维护持久的 Wiki。

## 核心思想

**不是 RAG，是持久 Wiki！**

| RAG | 持久 Wiki |
|-----|-----------|
| 每次查询从原始文档重新发现知识 | 知识被编译并**持续保持最新** |
| 无积累，综合问题每次都要重新拼凑 | 交叉引用已存在，矛盾已标注，综合已形成 |
| NotebookLM、ChatGPT 文件上传 | Obsidian + LLM = IDE + 程序员 |

**关键洞察**：Wiki 是一个**持久、复利的产物**。每添加一份资料，Wiki 就变得更丰富。

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
- 矛盾检测
- 过时信息
- 孤立页面
- 缺失概念
- 交叉引用

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

## 许可证

MIT License

## 参考

- [Karpathy LLM Knowledge Base Pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Obsidian CLI Documentation](https://help.obsidian.md/obsidian-uri)