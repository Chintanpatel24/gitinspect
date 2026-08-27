#!/usr/bin/env bash
set -e

echo "=== Uninstalling gitinspect local build artifacts ==="

echo "Cleaning node_modules and build outputs..."
rm -rf node_modules
rm -rf apps/web/dist apps/web/.vite
rm -rf apps/cli/dist
rm -rf apps/extension/dist
rm -rf packages/*/dist

echo "=== Cleaned up gitinspect build artifacts and dependencies. ==="
