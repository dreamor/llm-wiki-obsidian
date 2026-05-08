#!/bin/bash
# wiki-utils.sh — Wiki file operations
# Requires: lib/colors.sh, lib/utils.sh sourced first

WIKI_DIR="${WIKI_DIR:-wiki}"
MAX_WORDS="${MAX_WORDS:-1200}"

check_wiki_dir() {
  if [ ! -d "$WIKI_DIR" ]; then
    log_critical "Wiki 目录不存在: $WIKI_DIR"
    exit 1
  fi

  local required_dirs=("entities" "concepts" "sources" "synthesis")
  for dir in "${required_dirs[@]}"; do
    if [ ! -d "$WIKI_DIR/$dir" ]; then
      log_warning "缺少目录: $WIKI_DIR/$dir"
      if [ "$FIX_MODE" = true ]; then
        mkdir -p "$WIKI_DIR/$dir"
        log_info "已创建目录: $WIKI_DIR/$dir"
      fi
    fi
  done
}

find_wiki_files() {
  find "$WIKI_DIR" -name "*.md" -type f
}

extract_wikilinks() {
  local file="$1"
  grep -oh '\[\[[^]]*\]\]' "$file" 2>/dev/null | \
    sed 's/\[\[\(.*\)\]\]/\1/' | \
    sed 's/|.*//'
}

extract_all_wikilinks() {
  grep -roh '\[\[[^]]*\]\]' "$WIKI_DIR" 2>/dev/null | \
    sed 's/\[\[\(.*\)\]\]/\1/' | \
    sed 's/|.*//' | \
    sort | uniq -c | sort -rn
}

page_exists() {
  local link="$1"
  for dir in entities concepts sources synthesis; do
    [ -f "$WIKI_DIR/$dir/${link}.md" ] && return 0
  done
  [ -f "$WIKI_DIR/${link}.md" ] && return 0
  return 1
}

count_words() {
  local file="$1"
  wc -w < "$file" 2>/dev/null || echo "0"
}

is_special_page() {
  local page_name="$1"
  [ "$page_name" = "index" ] || [ "$page_name" = "log" ]
}
