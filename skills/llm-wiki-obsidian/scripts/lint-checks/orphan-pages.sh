#!/bin/bash
# orphan-pages.sh — Round 2: 孤立页面检查
# Requires: lib/colors.sh, lib/utils.sh, lib/wiki-utils.sh

check_orphan_pages() {
  print_section "Round 2: 孤立页面检查"

  local orphan_count=0

  while IFS= read -r f; do
    local page_name
    page_name=$(basename "$f" .md)

    is_special_page "$page_name" && continue

    if ! grep -rq "\[\[$page_name\]\]" "$WIKI_DIR" --exclude="$(basename "$f")" 2>/dev/null; then
      log_warning "孤立页面: $f (无入链)"
      ((orphan_count++))
    fi
  done < <(find_wiki_files)

  if [ $orphan_count -eq 0 ]; then
    log_success "无孤立页面"
  else
    log_warning "发现 $orphan_count 个孤立页面"
  fi
}
