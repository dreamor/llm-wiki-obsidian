# Contributing to LLM Wiki Obsidian

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Ways to Contribute

### Report Bugs

If you find a bug, please open an issue with:
- A clear title and description
- Steps to reproduce
- Expected behavior
- Actual behavior
- Your environment (OS, Obsidian version, Claude Code version)

### Suggest Features

We welcome feature suggestions! Please open an issue with:
- A clear title describing the feature
- Use case and motivation
- Proposed solution (if any)

### Improve Documentation

Documentation improvements are always welcome:
- Fix typos or unclear explanations
- Add examples
- Translate to other languages

### Submit Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit with clear messages (`git commit -m 'Add amazing feature'`)
5. Push to your fork (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/llm-wiki-obsidian.git

# Navigate to the project
cd llm-wiki-obsidian

# Run setup script
bash skills/llm-wiki-obsidian/scripts/setup.sh
```

## Project Structure

```
llm-wiki-obsidian/
├── .claude-plugin/          # Claude Code Plugin configuration
│   ├── plugin.json          # Plugin metadata
│   └── marketplace.json     # Marketplace configuration
├── skills/
│   └── llm-wiki-obsidian/
│       ├── SKILL.md         # Skill definition
│       ├── references/      # Reference documentation
│       └── scripts/
│           └── setup.sh     # Installation script
├── CLAUDE.md                # Standalone guide
├── README.md                # Chinese documentation
└── README_EN.md             # English documentation
```

## Coding Standards

### SKILL.md

- Use YAML frontmatter with `name`, `description`, `allowed-tools`, `license`
- Keep descriptions concise but informative
- Include trigger conditions in description
- Use clear section headers
- Provide code examples for commands

### Scripts

- Use `#!/bin/bash` shebang
- Use `set -e` for error handling
- Add comments for complex logic
- Check for dependencies gracefully

### Documentation

- Write in clear, simple language
- Include examples for all features
- Keep both Chinese and English versions in sync

## Testing

Before submitting a PR:

1. Test the skill in Claude Code
2. Verify Obsidian CLI commands work as expected
3. Test installation script on a clean system
4. Check documentation for accuracy

## Questions?

Feel free to open an issue for any questions or discussions.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.