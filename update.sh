#!/usr/bin/env bash
set -e

echo "=== Updating gitinspect ==="

echo "Updating dependencies..."
if command -v bun >/dev/null 2>&1; then
  bun install
else
  npm install
fi

echo "Rebuilding application packages..."
if command -v bun >/dev/null 2>&1; then
  bun run build
else
  npm run build
fi

echo "=== gitinspect updated successfully! ==="
