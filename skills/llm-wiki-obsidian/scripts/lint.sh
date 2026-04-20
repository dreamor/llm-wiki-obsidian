#!/bin/bash
#
# Wiki Lint - 知识库健康检查脚本
# 用法: ./lint.sh [vault_path] [--fix] [--verbose]
#
# 检查项目：
# 1. 死链接 - 链接目标不存在
# 2. 孤立页面 - 没有任何页面链接到它
# 3. 矛盾标注 - 检查 ⚠️ 标记
# 4. 大页面 - 超过 1200 词的页面
# 5. 缺失 frontmatter - 缺少必要的元数据
# 6. 索引完整性 - index.md 是否包含所有页面
# 7. 频繁引用但缺失的页面
# 8. 格式一致性
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
WIKI_DIR="${WIKI_DIR:-wiki}"
VERBOSE=false
FIX_MODE=false
MAX_WORDS=1200
REPORT_FILE=""

# 计数器
TOTAL_ISSUES=0
CRITICAL_ISSUES=0
WARNING_ISSUES=0
INFO_ISSUES=0

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

# 工具函数
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
  ((INFO_ISSUES++))
  ((TOTAL_ISSUES++))
}

log_warning() {
  echo -e "${YELLOW}[WARN]${NC} $1"
  ((WARNING_ISSUES++))
  ((TOTAL_ISSUES++))
}

log_critical() {
  echo -e "${RED}[CRIT]${NC} $1"
  ((CRITICAL_ISSUES++))
  ((TOTAL_ISSUES++))
}

log_success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_verbose() {
  if [ "$VERBOSE" = true ]; then
    echo -e "       $1"
  fi
}

# 检查目录是否存在
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

# Round 1: 死链接检查
check_dead_links() {
  echo ""
  echo "=== Round 1: 死链接检查 ==="

  local dead_count=0
  local temp_links=$(mktemp)

  # 提取所有 wiki 链接
  grep -roh '\[\[[^]]*\]\]' "$WIKI_DIR" 2>/dev/null | \
    sed 's/\[\[\(.*\)\]\]/\1/' | \
    sed 's/|.*//' | \
    sort | uniq -c | sort -rn > "$temp_links"

  log_verbose "找到 $(wc -l < "$temp_links") 个唯一链接"

  while read -r count link; do
    # 跳过空链接
    [ -z "$link" ] && continue

    # 尝试多种可能的文件路径
    local found=false
    for dir in entities concepts sources synthesis; do
      if [ -f "$WIKI_DIR/$dir/${link}.md" ]; then
        found=true
        break
      fi
    done

    # 也检查根目录
    if [ "$found" = false ] && [ -f "$WIKI_DIR/${link}.md" ]; then
      found=true
    fi

    if [ "$found" = false ]; then
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

# Round 2: 孤立页面检查
check_orphan_pages() {
  echo ""
  echo "=== Round 2: 孤立页面检查 ==="

  local orphan_count=0
  local temp_file=$(mktemp)

  # 获取所有页面名称
  find "$WIKI_DIR" -name "*.md" -type f | while read -r f; do
    local page_name=$(basename "$f" .md)

    # 跳过特殊页面
    if [ "$page_name" = "index" ] || [ "$page_name" = "log" ]; then
      continue
    fi

    # 检查是否有其他页面链接到它
    if ! grep -rq "\[\[$page_name\]\]" "$WIKI_DIR" --exclude="$(basename "$f")" 2>/dev/null; then
      log_warning "孤立页面: $f (无入链)"
      echo "$f" >> "$temp_file"
    fi
  done

  orphan_count=$(wc -l < "$temp_file" 2>/dev/null || echo "0")
  rm -f "$temp_file"

  if [ "$orphan_count" -eq 0 ]; then
    log_success "无孤立页面"
  else
    log_warning "发现 $orphan_count 个孤立页面"
  fi
}

# Round 3: 索引完整性
check_index_completeness() {
  echo ""
  echo "=== Round 3: 索引完整性检查 ==="

  local index_file="$WIKI_DIR/index.md"

  if [ ! -f "$index_file" ]; then
    log_critical "index.md 不存在"
    return
  fi

  local missing_count=0

  # 检查各个目录的页面是否被索引
  for dir in entities concepts sources synthesis; do
    for f in "$WIKI_DIR/$dir"/*.md 2>/dev/null; do
      [ -f "$f" ] || continue
      local page_name=$(basename "$f" .md)

      if ! grep -q "\[\[$page_name\]\]" "$index_file" 2>/dev/null; then
        log_warning "索引缺失: $page_name (在 $dir/)"
        ((missing_count++))
      fi
    done
  done

  if [ $missing_count -eq 0 ]; then
    log_success "索引完整"
  else
    log_warning "索引缺少 $missing_count 个页面"
  fi
}

# Round 4: 频繁引用但缺失的页面
check_missing_concepts() {
  echo ""
  echo "=== Round 4: 缺失概念页检查 ==="

  local temp_file=$(mktemp)

  # 提取所有被引用但页面不存在的概念
  grep -roh '\[\[[^]]*\]\]' "$WIKI_DIR" 2>/dev/null | \
    sed 's/\[\[\(.*\)\]\]/\1/' | \
    sed 's/|.*//' | \
    sort | uniq -c | sort -rn | \
    awk '$1 >= 3' > "$temp_file"

  local missing_count=0

  while read -r count link; do
    [ -z "$link" ] && continue

    local found=false
    for dir in entities concepts sources synthesis; do
      [ -f "$WIKI_DIR/$dir/${link}.md" ] && found=true && break
    done

    if [ "$found" = false ]; then
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

# Round 5: 矛盾检查
check_contradictions() {
  echo ""
  echo "=== Round 5: 矛盾标注检查 ==="

  local contradiction_count=0

  # 搜索矛盾标记
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      local file=$(echo "$line" | cut -d: -f1)
      local content=$(echo "$line" | cut -d: -f2-)
      log_warning "矛盾标记: $file"
      log_verbose "  内容: $content"
      ((contradiction_count++))
    fi
  done < <(grep -rn "⚠️\|矛盾\|冲突\|contradict" "$WIKI_DIR" 2>/dev/null || true)

  if [ $contradiction_count -eq 0 ]; then
    log_success "无矛盾标注"
  else
    log_info "发现 $contradiction_count 处矛盾/冲突标注"
  fi
}

# Round 6: 大页面检查
check_large_pages() {
  echo ""
  echo "=== Round 6: 大页面检查 ==="

  local large_count=0

  for f in $(find "$WIKI_DIR" -name "*.md" -type f); do
    local words=$(wc -w < "$f" 2>/dev/null || echo "0")

    if [ "$words" -gt "$MAX_WORDS" ]; then
      local page_name=$(basename "$f" .md)
      log_info "大页面: $page_name ($words 词，建议拆分)"
      ((large_count++))
    fi
  done

  if [ $large_count -eq 0 ]; then
    log_success "无超大页面"
  else
    log_info "发现 $large_count 个大页面（>$MAX_WORDS 词）"
  fi
}

# Round 7: Frontmatter 检查
check_frontmatter() {
  echo ""
  echo "=== Round 7: Frontmatter 完整性检查 ==="

  local missing_count=0
  local required_fields=("type" "date")

  for f in $(find "$WIKI_DIR" -name "*.md" -type f); do
    local page_name=$(basename "$f" .md)

    # 跳过特殊页面
    [ "$page_name" = "index" ] || [ "$page_name" = "log" ] && continue

    # 检查是否有 frontmatter
    if ! head -1 "$f" | grep -q "^---$"; then
      log_warning "缺少 frontmatter: $f"
      ((missing_count++))
      continue
    fi

    # 检查必要字段
    for field in "${required_fields[@]}"; do
      if ! grep -q "^$field:" "$f"; then
        log_warning "缺少字段 '$field': $f"
        ((missing_count++))
      fi
    done
  done

  if [ $missing_count -eq 0 ]; then
    log_success "Frontmatter 完整"
  else
    log_warning "发现 $missing_count 个 frontmatter 问题"
  fi
}

# Round 8: 格式一致性
check_format_consistency() {
  echo ""
  echo "=== Round 8: 格式一致性检查 ==="

  local format_issues=0

  # 检查表格格式（标题与表格之间应有空行）
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local file=$(echo "$line" | cut -d: -f1)
    local content=$(echo "$line" | cut -d: -f2-)
    log_info "表格格式问题: $file"
    ((format_issues++))
  done < <(grep -rn "^[^|].*$" "$WIKI_DIR" -A1 | grep "^\s*|" | grep -v "^--" || true)

  # 检查 Mermaid 语法
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    log_info "可能的 Mermaid 语法问题: $line"
    ((format_issues++))
  done < <(grep -rn "```mermaid" "$WIKI_DIR" -A20 | grep -E "^\s*$" -B1 | grep -v "^\s*$" | grep -v "mermaid" || true)

  if [ $format_issues -eq 0 ]; then
    log_success "格式一致"
  else
    log_info "发现 $format_issues 个格式问题"
  fi
}

# 生成报告
generate_report() {
  echo ""
  echo "=========================================="
  echo "           Wiki Lint 报告"
  echo "=========================================="
  echo ""
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

# 主函数
main() {
  echo "=========================================="
  echo "    Wiki Lint - 知识库健康检查"
  echo "=========================================="
  echo ""
  echo "Wiki 目录: $WIKI_DIR"
  echo "修复模式: $FIX_MODE"
  echo "详细输出: $VERBOSE"
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

  generate_report
}

# 运行
main