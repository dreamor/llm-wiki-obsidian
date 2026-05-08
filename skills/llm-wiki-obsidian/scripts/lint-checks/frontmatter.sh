#!/bin/bash
# frontmatter.sh — Round 7: Frontmatter 完整性检查
# Requires: lib/colors.sh, lib/utils.sh, lib/wiki-utils.sh

check_frontmatter() {
  print_section "Round 7: Frontmatter 完整性检查"

  local missing_count=0
  local required_fields=("type" "date")

  while IFS= read -r f; do
    local page_name
    page_name=$(basename "$f" .md)

    is_special_page "$page_name" && continue

    if ! head -1 "$f" | grep -q "^---$"; then
      log_warning "缺少 frontmatter: $f"
      ((missing_count++))
      continue
    fi

    for field in "${required_fields[@]}"; do
      if ! grep -q "^$field:" "$f"; then
        log_warning "缺少字段 '$field': $f"
        ((missing_count++))
      fi
    done
  done < <(find_wiki_files)

  if [ $missing_count -eq 0 ]; then
    log_success "Frontmatter 完整"
  else
    log_warning "发现 $missing_count 个 frontmatter 问题"
  fi
}
