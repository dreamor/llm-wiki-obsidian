#!/bin/bash
# dead-links.sh — Round 1: 死链接检查
# Requires: lib/colors.sh, lib/utils.sh, lib/wiki-utils.sh

check_dead_links() {
  print_section "Round 1: 死链接检查"

  local dead_count=0
  local temp_links
  temp_links=$(mktemp)

  extract_all_wikilinks > "$temp_links"
  log_verbose "找到 $(wc -l < "$temp_links") 个唯一链接"

  while read -r count link; do
    [ -z "$link" ] && continue

    if ! page_exists "$link"; then
      log_critical "死链接: [[$link]] (引用 $count 次)"
      ((dead_count++))
    fi
  done < "$temp_links"

  rm -f "$temp_links"

  if [ $dead_count -eq 0 ]; then
    log_success "无死链接"
  else
    log_warning "发现 $dead_count 个死链接"
  fi
}
