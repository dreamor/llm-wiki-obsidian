# Obsidian CLI Reference

> Complete reference for Obsidian CLI commands (Obsidian 1.9+)

## Prerequisites

- Obsidian 1.9 or later
- CLI enabled in `obsidian.json`:
  ```json
  { "cli": true }
  ```
- Obsidian application must be running

## Global Flags

| Flag | Description |
|------|-------------|
| `--help`, `-h` | Show help |
| `--version`, `-v` | Show version |
| `--copy` | Copy output to clipboard |
| `--json` | Output in JSON format |

## Read Commands

### `obsidian read`

Read a note's content.

```bash
obsidian read file="NoteName"
obsidian read file="path/to/note"
```

**Parameters**:
- `file` (required): Note name or path

**Examples**:
```bash
# Read by name
obsidian read file="My Note"

# Read by path
obsidian read file="folder/subfolder/note"

# Copy to clipboard
obsidian read file="My Note" --copy
```

### `obsidian search`

Search for notes matching a query.

```bash
obsidian search query="search term" limit=10
```

**Parameters**:
- `query` (required): Search term
- `limit` (optional): Max results (default: 10)

**Examples**:
```bash
# Basic search
obsidian search query="machine learning"

# Limit results
obsidian search query="RAG" limit=5

# Search in specific vault
obsidian vault="Work" search query="meeting"
```

### `obsidian backlinks`

Get all notes that link to a specific note.

```bash
obsidian backlinks file="NoteName"
```

**Parameters**:
- `file` (required): Note name or path

**Use case**: Find orphaned pages (pages with no backlinks) or understand relationships.

### `obsidian tags`

List all tags with counts.

```bash
obsidian tags sort=count counts
```

**Parameters**:
- `sort` (optional): Sort by `count` or `name`
- `counts` (optional): Show usage counts

### `obsidian daily:read`

Read today's daily note.

```bash
obsidian daily:read
```

## Write Commands

### `obsidian create`

Create a new note.

```bash
obsidian create name="New Note" content="# Title\n\nContent" silent
```

**Parameters**:
- `name` (required): Note name or path
- `content` (required): Note content (use `\n` for newlines)
- `silent` (optional): Don't open the note after creation
- `overwrite` (optional): Overwrite if exists

**Examples**:
```bash
# Simple note
obsidian create name="My Note" content="# My Note\n\nThis is the content."

# Create in subfolder
obsidian create name="wiki/sources/Article" content="# Article\n\nSummary..."

# Don't open after creation
obsidian create name="Temp" content="..." silent

# Overwrite existing
obsidian create name="Existing" content="new content" overwrite
```

### `obsidian append`

Append content to an existing note.

```bash
obsidian append file="NoteName" content="New paragraph"
```

**Parameters**:
- `file` (required): Note name or path
- `content` (required): Content to append

**Examples**:
```bash
# Add to end of note
obsidian append file="My Note" content="\n\n## New Section\n\nContent here."

# Add task to daily note
obsidian append file="Daily Note" content="- [ ] New task"
```

### `obsidian property:set`

Set a frontmatter property.

```bash
obsidian property:set name="status" value="done" file="My Note"
```

**Parameters**:
- `name` (required): Property name
- `value` (required): Property value
- `file` (required): Note name or path

**Examples**:
```bash
# Set status
obsidian property:set name="status" value="done" file="Project Note"

# Set tags (array)
obsidian property:set name="tags" value="['tag1', 'tag2']" file="My Note"

# Set date
obsidian property:set name="date" value="2026-04-17" file="Daily Note"
```

### `obsidian daily:append`

Append content to today's daily note.

```bash
obsidian daily:append content="- [ ] New task"
```

**Parameters**:
- `content` (required): Content to append

**Examples**:
```bash
# Add task
obsidian daily:append content="- [ ] Review PR"

# Add log entry
obsidian daily:append content="\n## Log\n- Completed task A"

# Add meeting note
obsidian daily:append content="\n### Meeting: Team Sync\n- Discussed roadmap"
```

## Vault Targeting

### `obsidian vault`

Specify which vault to use (when multiple vaults are open).

```bash
obsidian vault="VaultName" command
```

**Examples**:
```bash
# Search in specific vault
obsidian vault="PersonalKB" search query="project"

# Create in specific vault
obsidian vault="Work" create name="Meeting Notes" content="..."
```

## Common Patterns

### Ingest New Material

```bash
# 1. Create source summary
obsidian create name="wiki/sources/Article Title" content="# Article Title\n\n## Summary\n...\n\n## Key Points\n- ...\n\n## Relations\n- [[Concept]]" silent

# 2. Update related pages
obsidian append file="wiki/concepts/Concept" content="\n\n## Related Sources\n- [[Article Title]]"

# 3. Log the operation
obsidian daily:append content="## [2026-04-17] ingest | Article Title\n- Created wiki/sources/Article Title\n- Updated wiki/concepts/Concept"
```

### Query Knowledge

```bash
# 1. Search
obsidian search query="machine learning" limit=10

# 2. Read relevant pages
obsidian read file="wiki/concepts/Machine Learning"

# 3. Check backlinks
obsidian backlinks file="wiki/concepts/Machine Learning"

# 4. Log query
obsidian daily:append content="## [2026-04-17] query | machine learning\n- Found 5 relevant pages\n- Main answer: ..."
```

### Lint Wiki

```bash
# Find orphaned pages (no backlinks)
for page in $(obsidian search query="type:concept" --json | jq -r '.files[]'); do
  backlinks=$(obsidian backlinks file="$page" --json | jq '.count')
  if [ "$backlinks" -eq 0 ]; then
    echo "Orphaned: $page"
  fi
done
```

## Troubleshooting

### "Obsidian CLI not found"
- Ensure Obsidian 1.9+ is installed
- Enable CLI in `obsidian.json`: `{ "cli": true }`
- Restart Obsidian

### "Vault not found"
- Ensure Obsidian is running
- Check vault name matches exactly
- Use `obsidian vault="ExactName"` with correct capitalization

### "Note not found"
- Check exact spelling and path
- Use full path if note name is ambiguous
- Ensure note exists in the vault

## Tips

1. **Use `silent` flag**: Prevents opening notes when batch processing
2. **Use `--copy`**: Quickly copy content to clipboard
3. **Use `--json`**: Parse output programmatically
4. **Use full paths**: Avoid ambiguity with duplicate names
5. **Log operations**: Always append to daily note for audit trail