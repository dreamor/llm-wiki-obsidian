# LLM Wiki Obsidian

[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](https://github.com/dreamor/llm-wiki-obsidian)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[中文文档](README.zh-CN.md)

Personal knowledge base management skill built on [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). Interact with your Obsidian Vault via CLI to build a persistent, compounding Wiki maintained by LLMs.

**Not RAG, Persistent Wiki.** Each source enriches the wiki. Cross-references exist, contradictions flagged, summaries kept current — all automatically.

## Installation

```bash
# Option A: Claude Code Plugin (recommended)
/plugin marketplace add dreamor/llm-wiki-obsidian
/plugin install llm-wiki-obsidian@llm-wiki-obsidian

# Option B: Git Clone
git clone https://github.com/dreamor/llm-wiki-obsidian.git ~/.claude/skills/llm-wiki-obsidian
cd ~/.claude/skills/llm-wiki-obsidian
npm install        # Optional: enables Node.js fast path
bash install.sh    # Create multi-agent symlinks

# Option C: CLAUDE.md only
curl -o CLAUDE.md https://raw.githubusercontent.com/dreamor/llm-wiki-obsidian/main/CLAUDE.md
```

**Prerequisites**: Obsidian 1.9+ with CLI enabled, Node.js >= 18 (optional).

## Features

| Feature | Description |
|---------|-------------|
| **Ingest** | Organize new material into wiki pages with cross-references |
| **Query** | Search and answer questions from compiled knowledge |
| **Lint** | 9 health checks with Node.js CLI (5-8x faster) or bash fallback |
| **Cross-Linker** | Incremental bidirectional link detection |
| **AutoResearch** | 3-round autonomous research loop |
| **Incremental** | mtime-based processing — only scans changed files |

### Lint

```bash
npx tsx src/cli.ts lint -w wiki              # Node.js CLI
npx tsx src/cli.ts lint -w wiki --json       # JSON output for CI
npx tsx src/cli.ts lint --dry-run            # Preview fixes
./skills/llm-wiki-obsidian/scripts/lint.sh --incremental  # Bash fallback
```

Checks: dead links, orphan pages, index completeness, missing concepts, contradictions, large pages, frontmatter, format consistency, stale pages.

## Architecture

```
llm-wiki-obsidian/
├── src/                    # TypeScript CLI engine
│   ├── cli.ts             # Entry point (commander)
│   ├── scanner.ts         # Wiki scan & index build
│   └── checks/            # 9 lint checks
├── skills/.../scripts/
│   ├── lib/               # Shared shell libraries
│   ├── lint-checks/       # 8 modular bash checks
│   ├── lint.sh            # Entry (auto-detect Node.js)
│   ├── crosslink.sh       # Incremental cross-linker
│   └── update-index.sh    # Incremental index rebuild
├── scripts/               # migrate.sh, generate-agent-configs.sh
├── docs/                  # Troubleshooting, guides
└── .github/workflows/     # CI/CD
```

## Knowledge Base Structure

```
vault/
├── raw/            # Immutable source materials
├── wiki/
│   ├── entities/   # People, orgs, projects
│   ├── concepts/   # Technical concepts
│   ├── sources/    # Source summaries
│   └── synthesis/  # Cross-cutting analysis
├── index.md        # Content catalog
└── log.md          # Operation log
```

## Principles

1. `raw/` is immutable — never modify source materials
2. LLM owns `wiki/` — auto create, update, maintain
3. Cross-reference everything via `[[wikilinks]]`
4. Flag contradictions with callouts
5. Keep `index.md` current after each change

## Configuration

```bash
cp skills/llm-wiki-obsidian/config.example.json skills/llm-wiki-obsidian/config.json
```

See [config.schema.json](skills/llm-wiki-obsidian/config.schema.json) for all options with descriptions.

## Testing

```bash
./skills/llm-wiki-obsidian/scripts/test.sh   # Shell tests
npm run typecheck                             # TypeScript check
```

## Documentation

- [Troubleshooting](docs/troubleshooting.md)
- [Changelog](CHANGELOG.md)
- [Performance Guide](skills/llm-wiki-obsidian/performance-guide.md)

## License

MIT

## References

- [Karpathy LLM Wiki Pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Obsidian CLI Documentation](https://help.obsidian.md/obsidian-uri)
