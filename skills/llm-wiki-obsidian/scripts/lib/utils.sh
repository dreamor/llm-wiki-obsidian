#!/bin/bash
# utils.sh — Logging and issue counting utilities
# Requires: lib/colors.sh sourced first

TOTAL_ISSUES=0
CRITICAL_ISSUES=0
WARNING_ISSUES=0
INFO_ISSUES=0

VERBOSE="${VERBOSE:-false}"
FIX_MODE="${FIX_MODE:-false}"

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
  ((INFO_ISSUES++)) || true
  ((TOTAL_ISSUES++)) || true
}

log_warning() {
  echo -e "${YELLOW}[WARN]${NC} $1"
  ((WARNING_ISSUES++)) || true
  ((TOTAL_ISSUES++)) || true
}

log_critical() {
  echo -e "${RED}[CRIT]${NC} $1"
  ((CRITICAL_ISSUES++)) || true
  ((TOTAL_ISSUES++)) || true
}

log_success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_verbose() {
  if [ "$VERBOSE" = true ]; then
    echo -e "       $1"
  fi
}
