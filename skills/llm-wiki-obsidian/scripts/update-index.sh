#!/bin/bash
#
# update-index.sh — 增量索引重建
# 用法: ./update-index.sh [wiki_path] [--full] [--dry-run] [--diff]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/colors.sh
source "$SCRIPT_DIR/lib/colors.sh"
# shellcheck source=lib/utils.sh
source "$SCRIPT_DIR/lib/utils.sh"
# shellcheck source=lib/wiki-utils.sh
source "$SCRIPT_DIR/lib/wiki-utils.sh"
# shellcheck source=lib/incremental.sh
source "$SCRIPT_DIR/lib/incremental.sh"

DRY_RUN=false
DIFF_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --full)
      INCREMENTAL=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --diff)
      DIFF_MODE=true
      shift
      ;;
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --help|-h)
      echo "Wiki Index Updater - 增量索引重建"
      echo ""
      echo "用法: $0 [wiki_path] [选项]"
      echo ""
      echo "选项:"
      echo "  --full       全量重写索引"
      echo "  --dry-run    只显示变更，不实际修改"
      echo "  --diff       对比模式，显示增删"
      echo "  --verbose    显示详细输出"
      echo "  --help       显示帮助信息"
      exit 0
      ;;
    *)
      WIKI_DIR="$1"
      shift
      ;;
  esac
done

INDEX_FILE="$WIKI_DIR/index.md"

collect_pages() {
  local category="$1"
  local dir="$WIKI_DIR/$category"
  [ -d "$dir" ] || return

  for f in "$dir"/*.md; do
    [ -f "$f" ] || continue
    local name
    name=$(basename "$f" .md)
    echo "$name"
  done | sort
}

get_indexed_pages() {
  [ -f "$INDEX_FILE" ] || return
  grep -oP '\[\[\K[^\]]+' "$INDEX_FILE" 2>/dev/null | sort
}

show_diff() {
  local current_pages
  current_pages=$(mktemp)
  local indexed_pages
  indexed_pages=$(mktemp)

  for dir in entities concepts sources synthesis; do
    collect_pages "$dir"
  done > "$current_pages"

  get_indexed_pages > "$indexed_pages"

  local to_add
  to_add=$(comm -23 "$current_pages" "$indexed_pages")
  local to_remove
  to_remove=$(comm -13 "$current_pages" "$indexed_pages")

  if [ -n "$to_add" ]; then
    echo -e "${GREEN}+ 需添加到索引:${NC}"
    echo "$to_add" | while read -r page; do
      echo "  + [[$page]]"
    done
  fi

  if [ -n "$to_remove" ]; then
    echo -e "${RED}- 索引中已不存在:${NC}"
    echo "$to_remove" | while read -r page; do
      echo "  - [[$page]]"
    done
  fi

  if [ -z "$to_add" ] && [ -z "$to_remove" ]; then
    echo -e "${GREEN}索引已是最新${NC}"
  fi

  rm -f "$current_pages" "$indexed_pages"
}

generate_full_index() {
  local output=""
  output+="# 📚 个人知识库索引\n\n"
  output+="更新时间: $(date '+%Y-%m-%d %H:%M')\n\n"

  for category in entities concepts sources synthesis; do
    local display_name
    case "$category" in
      entities) display_name="实体" ;;
      concepts) display_name="概念" ;;
      sources) display_name="来源" ;;
      synthesis) display_name="综合分析" ;;
    esac

    local pages
    pages=$(collect_pages "$category")
    [ -z "$pages" ] && continue

    output+="## $display_name\n\n"
    output+="| 页面 | 更新 |\n"
    output+="|------|------|\n"

    while IFS= read -r page; do
      [ -z "$page" ] && continue
      local file="$WIKI_DIR/$category/${page}.md"
      local date_str=""
      if [ -f "$file" ]; then
        date_str=$(grep "^date:" "$file" 2>/dev/null | head -1 | sed 's/^date:\s*//')
      fi
      output+="| [[$page]] | ${date_str:-未知} |\n"
    done <<< "$pages"

    output+="\n"
  done

  echo -e "$output"
}

main() {
  print_header "Wiki Index Updater"
  echo "Wiki 目录: $WIKI_DIR"
  echo ""

  check_wiki_dir

  if [ "$DIFF_MODE" = true ]; then
    show_diff
    return
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "--- Dry-run: 生成的索引预览 ---"
    echo ""
    generate_full_index
    return
  fi

  generate_full_index > "$INDEX_FILE"
  log_success "索引已更新: $INDEX_FILE"
  save_run_timestamp "update-index"
}

main
