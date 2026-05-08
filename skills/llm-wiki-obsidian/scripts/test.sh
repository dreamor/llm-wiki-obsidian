#!/bin/bash
#
# Wiki Test Suite - 测试脚本
# 用法: ./test.sh [--verbose] [--integration]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/colors.sh
source "$SCRIPT_DIR/lib/colors.sh"
# shellcheck source=lib/test-framework.sh
source "$SCRIPT_DIR/lib/test-framework.sh"

# 配置
VERBOSE=false
INTEGRATION=false
TEST_DIR=$(mktemp -d)

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --integration|-i)
      INTEGRATION=true
      shift
      ;;
    --help|-h)
      echo "Wiki Test Suite"
      echo ""
      echo "用法: $0 [选项]"
      echo ""
      echo "选项:"
      echo "  --verbose, -v      显示详细输出"
      echo "  --integration, -i  运行集成测试（需要 Obsidian 运行）"
      echo "  --help, -h         显示帮助信息"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

# 设置测试环境
setup_test_env() {
  echo "设置测试环境..."

  mkdir -p "$TEST_DIR/wiki"/{entities,concepts,sources,synthesis}
  mkdir -p "$TEST_DIR/raw"/{articles,papers,assets}

  cat > "$TEST_DIR/wiki/entities/TestEntity.md" << 'EOF'
---
type: entity
category: project
tags: [test]
date: 2026-04-20
---
# Test Entity

这是一个测试实体页面。

## 基本信息
- 名称: Test Entity
- 类型: 测试项目

## 关联
- [[TestConcept]]
- [[TestSource]]

## 来源
- [[TestSource]]
EOF

  cat > "$TEST_DIR/wiki/concepts/TestConcept.md" << 'EOF'
---
type: concept
tags: [test]
date: 2026-04-20
sources: [raw/articles/test.md]
---
# Test Concept

> 这是一个测试概念定义

## 核心要点
- 要点1
- 要点2

## 相关概念
- [[TestEntity]]

## 来源
- [[TestSource]]
EOF

  cat > "$TEST_DIR/wiki/sources/TestSource.md" << 'EOF'
---
type: source
date: 2026-04-20
url: https://example.com/test
tags: [test]
---
# Test Source

## 摘要
这是一个测试来源页面。

## 关键信息
- 信息1
- 信息2

## 关联
- [[TestEntity]]
- [[TestConcept]]
EOF

  cat > "$TEST_DIR/wiki/index.md" << 'EOF'
# 📚 个人知识库索引

## 实体
| 页面 | 摘要 | 更新 |
|------|------|------|
| [[TestEntity]] | 测试实体 | 2026-04-20 |

## 概念
| 页面 | 摘要 | 更新 |
|------|------|------|
| [[TestConcept]] | 测试概念 | 2026-04-20 |

## 来源
| 页面 | 摘要 | 日期 |
|------|------|------|
| [[TestSource]] | 测试来源 | 2026-04-20 |
EOF

  echo -e "${GREEN}测试环境已创建: $TEST_DIR${NC}"
}

cleanup_test_env() {
  echo "清理测试环境..."
  rm -rf "$TEST_DIR"
  echo -e "${GREEN}测试环境已清理${NC}"
}

# ============================================
# 单元测试
# ============================================

test_directory_structure() {
  echo ""
  echo "=== 测试: 目录结构 ==="

  test_start "wiki 目录存在"
  assert_dir_exists "$TEST_DIR/wiki"

  test_start "entities 目录存在"
  assert_dir_exists "$TEST_DIR/wiki/entities"

  test_start "concepts 目录存在"
  assert_dir_exists "$TEST_DIR/wiki/concepts"

  test_start "sources 目录存在"
  assert_dir_exists "$TEST_DIR/wiki/sources"

  test_start "synthesis 目录存在"
  assert_dir_exists "$TEST_DIR/wiki/synthesis"

  test_start "raw 目录存在"
  assert_dir_exists "$TEST_DIR/raw"
}

test_page_creation() {
  echo ""
  echo "=== 测试: 页面创建 ==="

  test_start "实体页面存在"
  assert_file_exists "$TEST_DIR/wiki/entities/TestEntity.md"

  test_start "概念页面存在"
  assert_file_exists "$TEST_DIR/wiki/concepts/TestConcept.md"

  test_start "来源页面存在"
  assert_file_exists "$TEST_DIR/wiki/sources/TestSource.md"

  test_start "索引页面存在"
  assert_file_exists "$TEST_DIR/wiki/index.md"
}

test_frontmatter() {
  echo ""
  echo "=== 测试: Frontmatter 格式 ==="

  test_start "实体页面有 frontmatter"
  assert_contains "$TEST_DIR/wiki/entities/TestEntity.md" "^---$" "缺少 frontmatter 开始标记"

  test_start "实体页面有 type 字段"
  assert_contains "$TEST_DIR/wiki/entities/TestEntity.md" "^type:" "缺少 type 字段"

  test_start "实体页面有 date 字段"
  assert_contains "$TEST_DIR/wiki/entities/TestEntity.md" "^date:" "缺少 date 字段"

  test_start "概念页面有 sources 字段"
  assert_contains "$TEST_DIR/wiki/concepts/TestConcept.md" "^sources:" "缺少 sources 字段"

  test_start "来源页面有 url 字段"
  assert_contains "$TEST_DIR/wiki/sources/TestSource.md" "^url:" "缺少 url 字段"
}

test_wikilinks() {
  echo ""
  echo "=== 测试: Wiki 链接 ==="

  test_start "实体页面包含链接"
  assert_contains "$TEST_DIR/wiki/entities/TestEntity.md" "\[\[" "缺少 wiki 链接"

  test_start "概念页面包含链接"
  assert_contains "$TEST_DIR/wiki/concepts/TestConcept.md" "\[\[" "缺少 wiki 链接"

  test_start "链接格式正确"
  grep -qE "\[\[[A-Za-z0-9 -]+\]\]" "$TEST_DIR/wiki/entities/TestEntity.md" && test_pass || test_fail "链接格式不正确"
}

test_dead_links() {
  echo ""
  echo "=== 测试: 死链接检测 ==="

  local links
  links=$(grep -roh '\[\[[^]]*\]\]' "$TEST_DIR/wiki" | sed 's/\[\[\(.*\)\]\]/\1/' | sed 's/|.*//' | sort -u)

  test_start "无死链接"
  local has_dead=false
  for link in $links; do
    local found=false
    for dir in entities concepts sources synthesis; do
      [ -f "$TEST_DIR/wiki/$dir/${link}.md" ] && found=true && break
    done
    [ -f "$TEST_DIR/wiki/${link}.md" ] && found=true

    if [ "$found" = false ]; then
      if [ "$VERBOSE" = true ]; then
        echo ""
        echo -e "       ${RED}死链接: [[$link]]${NC}"
      fi
      has_dead=true
    fi
  done

  [ "$has_dead" = false ] && test_pass || test_fail "发现死链接"
}

test_orphan_pages() {
  echo ""
  echo "=== 测试: 孤立页面检测 ==="

  test_start "无孤立页面"
  local has_orphan=false

  for f in $(find "$TEST_DIR/wiki" -name "*.md" -type f); do
    local page_name
    page_name=$(basename "$f" .md)

    [ "$page_name" = "index" ] || [ "$page_name" = "log" ] && continue

    if ! grep -rq "\[\[$page_name\]\]" "$TEST_DIR/wiki" --exclude="$(basename "$f")" 2>/dev/null; then
      if [ "$VERBOSE" = true ]; then
        echo ""
        echo -e "       ${YELLOW}孤立页面: $f${NC}"
      fi
      has_orphan=true
    fi
  done

  [ "$has_orphan" = false ] && test_pass || test_fail "发现孤立页面"
}

test_index_completeness() {
  echo ""
  echo "=== 测试: 索引完整性 ==="

  test_start "索引包含所有页面"
  local missing=0

  for dir in entities concepts sources synthesis; do
    while IFS= read -r f; do
      [ -f "$f" ] || continue
      local page_name
      page_name=$(basename "$f" .md)

      if ! grep -q "\[\[$page_name\]\]" "$TEST_DIR/wiki/index.md" 2>/dev/null; then
        ((missing++))
      fi
    done < <(find "$TEST_DIR/wiki/$dir" -name "*.md" -type f 2>/dev/null)
  done

  [ $missing -eq 0 ] && test_pass || test_fail "索引缺少 $missing 个页面"
}

# ============================================
# 集成测试
# ============================================

test_obsidian_cli() {
  echo ""
  echo "=== 测试: Obsidian CLI 集成 ==="

  if [ "$INTEGRATION" = false ]; then
    test_start "obsidian 命令可用"
    test_skip "需要 --integration 参数"
    return
  fi

  test_start "obsidian 命令可用"
  assert_command_exists "obsidian" "obsidian 命令未找到"

  test_start "Obsidian 正在运行"
  pgrep -x "Obsidian" > /dev/null && test_pass || test_fail "Obsidian 未运行"
}

test_obsidian_commands() {
  echo ""
  echo "=== 测试: Obsidian CLI 命令 ==="

  if [ "$INTEGRATION" = false ]; then
    test_start "obsidian search 命令"
    test_skip "需要 --integration 参数"
    return
  fi

  test_start "obsidian search 命令"
  test_skip "需要配置 vault 路径"

  test_start "obsidian read 命令"
  test_skip "需要配置 vault 路径"
}

# ============================================
# 脚本自检
# ============================================

test_lint_script() {
  echo ""
  echo "=== 测试: Lint 脚本 ==="

  local lint_script="$SCRIPT_DIR/lint.sh"

  test_start "lint.sh 脚本存在"
  assert_file_exists "$lint_script"

  test_start "lint.sh 可执行"
  [ -x "$lint_script" ] && test_pass || test_fail "lint.sh 不可执行"

  test_start "lint.sh 语法正确"
  bash -n "$lint_script" 2>/dev/null && test_pass || test_fail "lint.sh 语法错误"
}

test_config_file() {
  echo ""
  echo "=== 测试: 配置文件 ==="

  local config_example="$SCRIPT_DIR/../config.example.json"

  test_start "config.example.json 存在"
  assert_file_exists "$config_example"

  test_start "config.example.json 是有效 JSON"
  python3 -c "import json; json.load(open('$config_example'))" 2>/dev/null && test_pass || test_fail "JSON 格式无效"

  test_start "配置包含必要字段"
  python3 -c "
import json
config = json.load(open('$config_example'))
required = ['vault', 'wiki', 'crosslinker', 'lint']
for field in required:
    assert field in config, f'Missing field: {field}'
" 2>/dev/null && test_pass || test_fail "缺少必要配置字段"
}

# ============================================
# Main
# ============================================

main() {
  print_header "Wiki Test Suite - 测试套件"
  echo "测试目录: $TEST_DIR"
  echo "详细输出: $VERBOSE"
  echo "集成测试: $INTEGRATION"
  echo ""

  setup_test_env

  test_directory_structure
  test_page_creation
  test_frontmatter
  test_wikilinks
  test_dead_links
  test_orphan_pages
  test_index_completeness
  test_obsidian_cli
  test_obsidian_commands
  test_lint_script
  test_config_file

  cleanup_test_env
  print_test_report
}

main
