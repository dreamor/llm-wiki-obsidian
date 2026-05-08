#!/bin/bash
#
# generate-agent-configs.sh — Generate agent bootstrap files from template
# Usage: ./generate-agent-configs.sh [--check]
#
# Generates consistent bootstrap/rules files for all supported agents
# from a single source template.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$ROOT_DIR/templates/agent-bootstrap.tmpl"
CHECK_MODE=false

if [ "$1" = "--check" ]; then
  CHECK_MODE=true
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "ERROR: Template not found: $TEMPLATE"
  exit 1
fi

TEMPLATE_CONTENT=$(cat "$TEMPLATE")

generate_file() {
  local target="$1"
  local target_dir
  target_dir=$(dirname "$target")

  mkdir -p "$target_dir"

  if [ "$CHECK_MODE" = true ]; then
    if [ ! -f "$target" ]; then
      echo "MISSING: $target"
      return 1
    fi
    if ! diff -q <(echo "$TEMPLATE_CONTENT") "$target" &>/dev/null; then
      echo "OUT OF SYNC: $target"
      return 1
    fi
    return 0
  fi

  echo "$TEMPLATE_CONTENT" > "$target"
  echo "Generated: $target"
}

ERRORS=0

targets=(
  "$ROOT_DIR/.cursor/rules/llm-wiki-obsidian.mdc"
  "$ROOT_DIR/.windsurf/rules/llm-wiki-obsidian.md"
  "$ROOT_DIR/.github/copilot-instructions.md"
  "$ROOT_DIR/.hermes.md"
)

for target in "${targets[@]}"; do
  if ! generate_file "$target"; then
    ((ERRORS++))
  fi
done

if [ "$CHECK_MODE" = true ]; then
  if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "FAIL: $ERRORS file(s) out of sync. Run: bash scripts/generate-agent-configs.sh"
    exit 1
  else
    echo "OK: All agent configs are in sync with template."
    exit 0
  fi
fi

echo ""
echo "Done. Generated ${#targets[@]} agent config files from template."
