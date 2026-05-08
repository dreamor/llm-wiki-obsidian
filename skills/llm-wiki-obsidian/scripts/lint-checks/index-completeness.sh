#!/bin/bash
# index-completeness.sh — Round 3: 索引完整性检查
# Requires: lib/colors.sh, lib/utils.sh, lib/wiki-utils.sh

check_index_completeness() {
  print_section "Round 3: 索引完整性检查"

  local index_file="$WIKI_DIR/index.md"

  if [ ! -f "$index_file" ]; then
    log_critical "index.md 不存在"
    return
  fi

  local missing_count=0

  for dir in entities concepts sources synthesis; do
    for f in "$WIKI_DIR/$dir"/*.md 2>/dev/null; do
      [ -f "$f" ] || continue
      local page_name
      page_name=$(basename "$f" .md)

      if ! grep -q "\[\[$page_name\]\]" "$index_file" 2>/dev/null; then
        log_warning "索引缺失: $page_name (在 $dir/)"
        ((missing_count++))
      fi
    done
  done

  if [ $missing_count -eq 0 ]; then
    log_success "索引完整"
  else
    log_warning "索引缺少 $missing_count 个页面"
  fi
}
