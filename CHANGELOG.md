# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2026-05-08

### Added
- Node.js/TypeScript lint engine with cross-platform support
- CLI tool (`wiki-lint`) with `--json`, `--dry-run`, `--verbose` options
- Incremental lint mode (`--incremental`) for large vaults
- Incremental crosslinker (`scripts/crosslink.sh`)
- Incremental index rebuilder (`scripts/update-index.sh`)
- Shell function libraries (`scripts/lib/`) for modular scripts
- JSON Schema validation for `config.json`
- GitHub Actions CI (ShellCheck + test + JSON validate)
- Multi-agent template generation (`scripts/generate-agent-configs.sh`)
- Migration tool (`scripts/migrate.sh`) with `--dry-run`
- Troubleshooting documentation (`docs/troubleshooting.md`)
- TypeScript type definitions (`src/types.ts`)

### Changed
- Refactored monolithic `lint.sh` into 8 modular check files
- Shell scripts now source shared libraries (colors, utils, wiki-utils)
- `lint.sh` auto-detects Node.js and delegates to TypeScript version
- Simplified agent files to metadata + reference pointers
- Renamed `setup.sh` to `install.sh` (multi-agent symlink installer)

### Performance
- Single-pass index build replaces 8x file traversals
- Incremental processing skips unchanged files
- Node.js version ~5-8x faster than bash on large vaults

## [1.1.0] - 2026-04-20

### Added
- Synthesis page type and `wiki/synthesis/` directory
- Source summary pages with URL tracking
- Contradiction detection (`⚠️` markers)
- Large page detection (>1200 words)
- Frontmatter validation (type, date fields)

### Changed
- Updated page templates with frontmatter requirements
- Improved wikilink extraction regex

## [1.0.0] - 2026-04-17

### Added
- Initial release
- Obsidian CLI integration
- Wiki structure: entities, concepts, sources
- Basic lint checks: dead links, orphan pages, index completeness
- `CLAUDE.md` skill definition
- Multi-agent support (Claude Code, Cursor, Windsurf, etc.)
