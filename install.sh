#!/usr/bin/env bash
set -e

echo "=== Installing gitinspect locally ==="

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

echo "Installing dependencies using Bun ($BUN_CMD)..."
$BUN_CMD install

echo "Building application packages..."
$BUN_CMD run build

echo ""
echo "=== gitinspect installed successfully! ==="
echo "To start the local web application, run:"
echo "  $BUN_CMD run dev"
