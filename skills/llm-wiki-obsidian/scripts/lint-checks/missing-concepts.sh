#!/bin/bash
# missing-concepts.sh — Round 4: 频繁引用但缺失的页面
# Requires: lib/colors.sh, lib/utils.sh, lib/wiki-utils.sh

check_missing_concepts() {
  print_section "Round 4: 缺失概念页检查"

  local temp_file
  temp_file=$(mktemp)

  extract_all_wikilinks | awk '$1 >= 3' > "$temp_file"

  local missing_count=0

  while read -r count link; do
    [ -z "$link" ] && continue

    if ! page_exists "$link"; then
      log_info "建议创建: [[$link]] (被引用 $count 次)"
      ((missing_count++))
    fi
  done < "$temp_file"

  rm -f "$temp_file"

  if [ $missing_count -eq 0 ]; then
    log_success "无频繁引用但缺失的概念"
  else
    log_info "建议创建 $missing_count 个概念页"
  fi
}
