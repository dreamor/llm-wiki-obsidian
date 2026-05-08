#!/bin/bash
# config.sh — Configuration loading and validation
# Requires: lib/colors.sh sourced first

SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/../config.json}"

load_config() {
  if [ ! -f "$CONFIG_FILE" ]; then
    log_verbose "配置文件不存在，使用默认值: $CONFIG_FILE"
    return 1
  fi

  if ! python3 -c "import json; json.load(open('$CONFIG_FILE'))" 2>/dev/null; then
    log_warning "配置文件格式错误: $CONFIG_FILE"
    return 1
  fi

  return 0
}

get_config_value() {
  local key="$1"
  local default="$2"

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "$default"
    return
  fi

  local value
  value=$(python3 -c "
import json, sys
config = json.load(open('$CONFIG_FILE'))
keys = '$key'.split('.')
val = config
for k in keys:
    val = val.get(k, None)
    if val is None:
        break
if val is None:
    print('$default')
else:
    print(val)
" 2>/dev/null)

  echo "${value:-$default}"
}
