# LLM Wiki Obsidian

[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](https://github.com/dreamor/llm-wiki-obsidian)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[English](README.md)

基于 [Karpathy LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 的个人知识库管理技能。通过 Obsidian CLI 与本地 Vault 交互，由 LLM 自动维护一个持久的、不断增值的 Wiki。

**不是 RAG，是持久 Wiki。** 每份资料都丰富 Wiki。交叉引用自动建立，矛盾自动标注，摘要自动更新。

## 安装

```bash
# 方式 A：Claude Code Plugin（推荐）
/plugin marketplace add dreamor/llm-wiki-obsidian
/plugin install llm-wiki-obsidian@llm-wiki-obsidian

# 方式 B：Git Clone
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.claude/skills/llm-wiki-obsidian
cd ~/.claude/skills/llm-wiki-obsidian
npm install        # 可选：启用 Node.js 快速路径
bash install.sh    # 创建 multi-agent 符号链接

# 方式 C：仅 CLAUDE.md
curl -o CLAUDE.md https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md
```

**前置要求**：Obsidian 1.9+ 并启用 CLI，Node.js >= 18（可选）。

## 功能

| 功能 | 说明 |
|------|------|
| **Ingest** | 将新资料整理为 wiki 页面，自动建立交叉引用 |
| **Query** | 基于编译好的知识搜索和回答问题 |
| **Lint** | 9 项健康检查，Node.js CLI（5-8x 加速）或 bash 回退 |
| **Cross-Linker** | 增量双向链接检测 |
| **AutoResearch** | 3 轮自主研究循环 |
| **Incremental** | 基于 mtime 的增量处理，仅扫描变更文件 |

### Lint

```bash
npx tsx src/cli.ts lint -w wiki              # Node.js CLI
npx tsx src/cli.ts lint -w wiki --json       # JSON 输出（适合 CI）
npx tsx src/cli.ts lint --dry-run            # 预览修复
./skills/llm-wiki-obsidian/scripts/lint.sh --incremental  # Bash 回退
```

检查项：死链接、孤立页面、索引完整性、缺失概念、矛盾标注、大页面、Frontmatter、格式一致性、陈旧页面。

## 架构

```
llm-wiki-obsidian/
├── src/                    # TypeScript CLI 引擎
│   ├── cli.ts             # 入口 (commander)
│   ├── scanner.ts         # Wiki 扫描 & 索引构建
│   └── checks/            # 9 项 lint 检查
├── skills/.../scripts/
│   ├── lib/               # Shell 共享库
│   ├── lint-checks/       # 8 个模块化 bash 检查
│   ├── lint.sh            # 入口（自动检测 Node.js）
│   ├── crosslink.sh       # 增量跨链
│   └── update-index.sh    # 增量索引重建
├── scripts/               # migrate.sh, generate-agent-configs.sh
├── docs/                  # 故障排查、指南
└── .github/workflows/     # CI/CD
```

## 知识库结构

```
vault/
├── raw/            # 不可变的原始资料
├── wiki/
│   ├── entities/   # 实体（人物、组织、项目）
│   ├── concepts/   # 技术概念
│   ├── sources/    # 来源摘要
│   └── synthesis/  # 综合分析
├── index.md        # 内容目录
└── log.md          # 操作日志
```

## 原则

1. `raw/` 不可变 — 绝不修改原始资料
2. LLM 全权维护 `wiki/` — 自动创建、更新
3. 全面交叉引用 `[[wikilinks]]`
4. 用 callout 标注矛盾
5. 每次变更后更新 `index.md`

## 配置

```bash
cp skills/llm-wiki-obsidian/config.example.json skills/llm-wiki-obsidian/config.json
```

所有配置项详见 [config.schema.json](skills/llm-wiki-obsidian/config.schema.json)。

## 测试

```bash
./skills/llm-wiki-obsidian/scripts/test.sh   # Shell 测试
npm run typecheck                             # TypeScript 检查
```

## 文档

- [故障排查](docs/troubleshooting.md)
- [更新日志](CHANGELOG.md)
- [性能指南](skills/llm-wiki-obsidian/performance-guide.md)

## 许可证

MIT
