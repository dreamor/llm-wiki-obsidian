#!/bin/bash
# test-framework.sh — Lightweight test runner
# Requires: lib/colors.sh sourced first

PASSED=0
FAILED=0
SKIPPED=0

test_start() {
  echo -n "  TEST: $1... "
}

test_pass() {
  echo -e "${GREEN}PASS${NC}"
  ((PASSED++)) || true
}

test_fail() {
  echo -e "${RED}FAIL${NC}"
  if [ "$VERBOSE" = true ] && [ -n "$1" ]; then
    echo -e "       ${RED}原因: $1${NC}"
  fi
  ((FAILED++)) || true
}

test_skip() {
  echo -e "${YELLOW}SKIP${NC}"
  if [ "$VERBOSE" = true ] && [ -n "$1" ]; then
    echo -e "       ${YELLOW}原因: $1${NC}"
  fi
  ((SKIPPED++)) || true
}

assert_file_exists() {
  local file="$1"
  local msg="${2:-文件不存在: $file}"
  if [ -f "$file" ]; then test_pass; else test_fail "$msg"; fi
}

assert_dir_exists() {
  local dir="$1"
  local msg="${2:-目录不存在: $dir}"
  if [ -d "$dir" ]; then test_pass; else test_fail "$msg"; fi
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  local msg="${3:-未找到匹配: $pattern}"
  if grep -q "$pattern" "$file" 2>/dev/null; then test_pass; else test_fail "$msg"; fi
}

assert_command_exists() {
  local cmd="$1"
  local msg="${2:-命令未找到: $cmd}"
  if command -v "$cmd" &>/dev/null; then test_pass; else test_fail "$msg"; fi
}

print_test_report() {
  echo ""
  echo "=========================================="
  echo "           测试报告"
  echo "=========================================="
  echo ""
  echo "通过: $PASSED"
  echo "失败: $FAILED"
  echo "跳过: $SKIPPED"
  echo "总计: $((PASSED + FAILED + SKIPPED))"
  echo ""

  if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}状态: 存在失败测试${NC}"
    return 1
  else
    echo -e "${GREEN}状态: 所有测试通过${NC}"
    return 0
  fi
}
