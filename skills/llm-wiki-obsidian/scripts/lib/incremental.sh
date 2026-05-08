#!/bin/bash
# incremental.sh — Incremental processing state management
# Requires: lib/colors.sh, lib/utils.sh sourced first

STATE_DIR="${STATE_DIR:-.wiki-state}"
INCREMENTAL="${INCREMENTAL:-false}"

init_state_dir() {
  if [ ! -d "$STATE_DIR" ]; then
    mkdir -p "$STATE_DIR"
    log_verbose "创建状态目录: $STATE_DIR"
  fi
}

get_last_run_timestamp() {
  local operation="$1"
  local ts_file="$STATE_DIR/${operation}-timestamp"
  if [ -f "$ts_file" ]; then
    cat "$ts_file"
  else
    echo "0"
  fi
}

save_run_timestamp() {
  local operation="$1"
  init_state_dir
  date +%s > "$STATE_DIR/${operation}-timestamp"
}

find_changed_files() {
  local operation="$1"
  local search_dir="$2"

  local ts_file="$STATE_DIR/${operation}-timestamp"

  if [ "$INCREMENTAL" = true ] && [ -f "$ts_file" ]; then
    find "$search_dir" -name "*.md" -type f -newer "$ts_file"
  else
    find "$search_dir" -name "*.md" -type f
  fi
}

is_incremental_available() {
  local operation="$1"
  local ts_file="$STATE_DIR/${operation}-timestamp"
  [ -f "$ts_file" ]
}
