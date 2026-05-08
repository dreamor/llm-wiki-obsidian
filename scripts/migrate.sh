#!/bin/bash
#
# Wiki Migration Tool - 版本迁移脚本
# 用法: ./migrate.sh [--dry-run]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/.wiki-version"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --help|-h)
      echo "Wiki Migration Tool"
      echo ""
      echo "用法: $0 [选项]"
      echo ""
      echo "选项:"
      echo "  --dry-run  预览迁移操作，不实际执行"
      echo "  --help     显示帮助信息"
      exit 0
      ;;
    *) shift ;;
  esac
done

get_current_version() {
  if [ -f "$VERSION_FILE" ]; then
    cat "$VERSION_FILE"
  else
    echo "1.0.0"
  fi
}

set_version() {
  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] 设置版本为 $1"
  else
    echo "$1" > "$VERSION_FILE"
  fi
}

migrate_1_0_to_1_1() {
  echo "=== 迁移 v1.0 → v1.1 ==="
  echo "  - 创建 wiki/synthesis/ 目录"
  echo "  - 添加 frontmatter date 字段到现有页面"

  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] 跳过实际操作"
    return
  fi

  mkdir -p "$PROJECT_ROOT/wiki/synthesis"

  for f in "$PROJECT_ROOT"/wiki/**/*.md; do
    [ -f "$f" ] || continue
    if ! head -5 "$f" | grep -q "^date:"; then
      local today
      today=$(date '+%Y-%m-%d')
      sed -i '' "s/^---$/---\ndate: $today/" "$f" 2>/dev/null || true
    fi
  done
}

migrate_1_1_to_1_2() {
  echo "=== 迁移 v1.1 → v1.2 ==="
  echo "  - 重命名 setup.sh → install.sh"
  echo "  - 创建 .wiki-state/ 目录"
  echo "  - 添加 config.json 如果不存在"

  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] 跳过实际操作"
    return
  fi

  mkdir -p "$PROJECT_ROOT/.wiki-state"

  if [ ! -f "$PROJECT_ROOT/config.json" ] && [ -f "$PROJECT_ROOT/config.example.json" ]; then
    cp "$PROJECT_ROOT/config.example.json" "$PROJECT_ROOT/config.json"
    echo "  已创建 config.json"
  fi
}

main() {
  local current
  current=$(get_current_version)
  echo "当前版本: $current"
  echo "目标版本: 1.2.0"

  if [ "$DRY_RUN" = true ]; then
    echo "模式: dry-run (不会执行任何修改)"
  fi
  echo ""

  local migrated=false

  case "$current" in
    1.0.0|1.0)
      migrate_1_0_to_1_1
      set_version "1.1.0"
      migrate_1_1_to_1_2
      set_version "1.2.0"
      migrated=true
      ;;
    1.1.0|1.1)
      migrate_1_1_to_1_2
      set_version "1.2.0"
      migrated=true
      ;;
    1.2.0|1.2)
      echo "已是最新版本，无需迁移。"
      ;;
    *)
      echo "未知版本: $current"
      exit 1
      ;;
  esac

  if [ "$migrated" = true ]; then
    echo ""
    echo "迁移完成！当前版本: $(get_current_version)"
  fi
}

main
