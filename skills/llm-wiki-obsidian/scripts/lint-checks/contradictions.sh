#!/bin/bash
# contradictions.sh — Round 5: 矛盾标注检查
# Requires: lib/colors.sh, lib/utils.sh, lib/wiki-utils.sh

check_contradictions() {
  print_section "Round 5: 矛盾标注检查"

  local contradiction_count=0

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local file
    file=$(echo "$line" | cut -d: -f1)
    local content
    content=$(echo "$line" | cut -d: -f2-)
    log_warning "矛盾标记: $file"
    log_verbose "  内容: $content"
    ((contradiction_count++))
  done < <(grep -rn "⚠️\|矛盾\|冲突\|contradict" "$WIKI_DIR" 2>/dev/null || true)

  if [ $contradiction_count -eq 0 ]; then
    log_success "无矛盾标注"
  else
    log_info "发现 $contradiction_count 处矛盾/冲突标注"
  fi
}
