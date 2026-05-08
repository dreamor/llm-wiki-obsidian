#!/bin/bash
# colors.sh — Terminal color definitions and output helpers

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
  echo "=========================================="
  echo "    $1"
  echo "=========================================="
  echo ""
}

print_section() {
  echo ""
  echo "=== $1 ==="
}
