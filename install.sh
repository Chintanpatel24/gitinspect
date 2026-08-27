#!/usr/bin/env bash
set -e

echo "=== Installing gitinspect locally ==="

if ! command -v bun >/dev/null 2>&1 && ! command -v node >/dev/null 2>&1; then
  echo "Error: Node.js or Bun is required to run gitinspect."
  exit 1
fi

echo "Installing dependencies..."
if command -v bun >/dev/null 2>&1; then
  bun install
else
  npm install
fi

echo "Building application packages..."
if command -v bun >/dev/null 2>&1; then
  bun run build
else
  npm run build
fi

echo ""
echo "=== gitinspect installed successfully! ==="
echo "To start the local web application, run:"
echo "  bun run dev   (or npm run dev)"
