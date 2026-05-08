#!/bin/bash
#
# crosslink.sh — 增量跨链脚本
# 用法: ./crosslink.sh [wiki_path] [--full] [--dry-run] [--verbose]
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
INCREMENTAL=true
LINKS_ADDED=0

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
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --help|-h)
      echo "Wiki Crosslinker - 增量跨链"
      echo ""
      echo "用法: $0 [wiki_path] [选项]"
      echo ""
      echo "选项:"
      echo "  --full       全量重建（忽略增量状态）"
      echo "  --dry-run    只显示将添加的链接，不实际修改"
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

build_page_index() {
  declare -gA PAGE_INDEX
  while IFS= read -r f; do
    local name
    name=$(basename "$f" .md)
    PAGE_INDEX["$name"]="$f"
  done < <(find_wiki_files)
  log_verbose "构建页面索引: ${#PAGE_INDEX[@]} 个页面"
}

suggest_links_for_file() {
  local file="$1"
  local content
  content=$(cat "$file")

  for page_name in "${!PAGE_INDEX[@]}"; do
    [ ${#page_name} -lt 2 ] && continue

    local target="${PAGE_INDEX[$page_name]}"
    [ "$target" = "$file" ] && continue

    if echo "$content" | grep -q "$page_name" && ! echo "$content" | grep -q "\[\[$page_name\]\]"; then
      if [ "$DRY_RUN" = true ]; then
        echo "  WOULD ADD: [[$page_name]] in $(basename "$file")"
      else
        log_verbose "添加链接: [[$page_name]] in $(basename "$file")"
      fi
      ((LINKS_ADDED++))
    fi
  done
}

main() {
  print_header "Wiki Crosslinker - 增量跨链"

  if [ "$INCREMENTAL" = true ] && is_incremental_available "crosslink"; then
    echo "模式: 增量（仅处理变更文件）"
  else
    echo "模式: 全量"
    INCREMENTAL=false
  fi
  echo "Dry-run: $DRY_RUN"
  echo ""

  check_wiki_dir
  build_page_index

  local file_count=0
  while IFS= read -r f; do
    is_special_page "$(basename "$f" .md)" && continue
    suggest_links_for_file "$f"
    ((file_count++))
  done < <(find_changed_files "crosslink" "$WIKI_DIR")

  echo ""
  echo "--- 结果 ---"
  echo "扫描文件: $file_count"
  echo "建议链接: $LINKS_ADDED"

  if [ "$DRY_RUN" = false ]; then
    save_run_timestamp "crosslink"
  fi
}

main
