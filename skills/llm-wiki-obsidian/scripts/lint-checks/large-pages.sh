#!/bin/bash
# large-pages.sh — Round 6: 大页面检查
# Requires: lib/colors.sh, lib/utils.sh, lib/wiki-utils.sh

check_large_pages() {
  print_section "Round 6: 大页面检查"

  local large_count=0

  while IFS= read -r f; do
    local words
    words=$(count_words "$f")

    if [ "$words" -gt "$MAX_WORDS" ]; then
      local page_name
      page_name=$(basename "$f" .md)
      log_info "大页面: $page_name ($words 词，建议拆分)"
      ((large_count++))
    fi
  done < <(find_wiki_files)

  if [ $large_count -eq 0 ]; then
    log_success "无超大页面"
  else
    log_info "发现 $large_count 个大页面（>$MAX_WORDS 词）"
  fi
}
