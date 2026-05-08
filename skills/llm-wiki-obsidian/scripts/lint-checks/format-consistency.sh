#!/bin/bash
# format-consistency.sh — Round 8: 格式一致性检查
# Requires: lib/colors.sh, lib/utils.sh, lib/wiki-utils.sh

check_format_consistency() {
  print_section "Round 8: 格式一致性检查"

  local format_issues=0

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local file
    file=$(echo "$line" | cut -d: -f1)
    log_info "表格格式问题: $file"
    ((format_issues++))
  done < <(grep -rn "^[^|].*$" "$WIKI_DIR" -A1 2>/dev/null | grep "^\s*|" | grep -v "^--" || true)

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    log_info "可能的 Mermaid 语法问题: $line"
    ((format_issues++))
  done < <(grep -rn '```mermaid' "$WIKI_DIR" -A20 2>/dev/null | grep -E "^\s*$" -B1 | grep -v "^\s*$" | grep -v "mermaid" || true)

  if [ $format_issues -eq 0 ]; then
    log_success "格式一致"
  else
    log_info "发现 $format_issues 个格式问题"
  fi
}
