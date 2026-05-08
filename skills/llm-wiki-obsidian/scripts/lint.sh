#!/bin/bash
#
# Wiki Lint - 知识库健康检查脚本
# 用法: ./lint.sh [vault_path] [--fix] [--verbose]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Node.js 快速路径: 如果 node 可用且 src/cli.ts 存在，使用 TypeScript 版本
if command -v node &>/dev/null && [ -f "$PROJECT_ROOT/src/cli.ts" ]; then
  exec npx tsx "$PROJECT_ROOT/src/cli.ts" lint "$@"
fi

# Bash fallback
# shellcheck source=lib/colors.sh
source "$SCRIPT_DIR/lib/colors.sh"
# shellcheck source=lib/utils.sh
source "$SCRIPT_DIR/lib/utils.sh"
# shellcheck source=lib/wiki-utils.sh
source "$SCRIPT_DIR/lib/wiki-utils.sh"
# shellcheck source=lib/incremental.sh
source "$SCRIPT_DIR/lib/incremental.sh"

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --fix)
      FIX_MODE=true
      shift
      ;;
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --incremental)
      INCREMENTAL=true
      shift
      ;;
    --report|-r)
      REPORT_FILE="$2"
      shift 2
      ;;
    --help|-h)
      echo "Wiki Lint - 知识库健康检查"
      echo ""
      echo "用法: $0 [vault_path] [选项]"
      echo ""
      echo "选项:"
      echo "  --fix        尝试自动修复问题"
      echo "  --verbose    显示详细输出"
      echo "  --report FILE  输出报告到文件"
      echo "  --help       显示帮助信息"
      echo ""
      echo "环境变量:"
      echo "  WIKI_DIR     Wiki 目录路径 (默认: wiki)"
      exit 0
      ;;
    *)
      WIKI_DIR="$1"
      shift
      ;;
  esac
done

# 加载 lint 检查模块
for check_file in "$SCRIPT_DIR"/lint-checks/*.sh; do
  # shellcheck source=/dev/null
  source "$check_file"
done

generate_report() {
  echo ""
  print_header "Wiki Lint 报告"
  echo "Wiki 目录: $WIKI_DIR"
  echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo "--- 问题统计 ---"
  echo "严重 (CRITICAL): $CRITICAL_ISSUES"
  echo "警告 (WARNING):  $WARNING_ISSUES"
  echo "信息 (INFO):     $INFO_ISSUES"
  echo "总计:            $TOTAL_ISSUES"
  echo ""

  if [ $CRITICAL_ISSUES -gt 0 ]; then
    echo -e "${RED}状态: 需要立即修复${NC}"
    exit 1
  elif [ $WARNING_ISSUES -gt 0 ]; then
    echo -e "${YELLOW}状态: 建议修复${NC}"
    exit 0
  else
    echo -e "${GREEN}状态: 健康${NC}"
    exit 0
  fi
}

main() {
  print_header "Wiki Lint - 知识库健康检查"
  echo "Wiki 目录: $WIKI_DIR"
  echo "修复模式: $FIX_MODE"
  echo "详细输出: $VERBOSE"
  echo ""

  if [ "$INCREMENTAL" = true ] && is_incremental_available "lint"; then
    echo "模式: 增量（仅处理变更文件相关检查）"
  else
    echo "模式: 全量"
  fi
  echo ""

  check_wiki_dir
  check_dead_links
  check_orphan_pages
  check_index_completeness
  check_missing_concepts
  check_contradictions
  check_large_pages
  check_frontmatter
  check_format_consistency

  save_run_timestamp "lint"
  generate_report
}

main
