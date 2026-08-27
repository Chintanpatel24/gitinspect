#!/usr/bin/env bash
set -e

echo "=== Updating gitinspect ==="

get_bun() {
  if command -v bun >/dev/null 2>&1; then
    echo "bun"
  elif command -v npx >/dev/null 2>&1; then
    echo "npx -y bun"
  else
    echo "Error: Node/npx or Bun is required to run gitinspect." >&2
    exit 1
  fi
}

BUN_CMD=$(get_bun)

echo "Updating dependencies using Bun ($BUN_CMD)..."
$BUN_CMD install

echo "Rebuilding application packages..."
$BUN_CMD run build

echo "=== gitinspect updated successfully! ==="
