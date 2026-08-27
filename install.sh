#!/usr/bin/env bash
set -e

echo "=== Installing gitinspect locally ==="

# Check for git
if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required to run gitinspect. Please install git and try again." >&2
  exit 1
fi

# Ensure standard Bun path is in PATH if present
if [ -d "$HOME/.bun/bin" ]; then
  export PATH="$HOME/.bun/bin:$PATH"
fi

# Ensure Bun is installed
ensure_bun() {
  if command -v bun >/dev/null 2>&1; then
    return 0
  fi

  echo "Bun is required to run gitinspect, but it is not installed."

  AUTO_INSTALL=false
  if [ "$1" = "-y" ] || [ "$CI" = "true" ]; then
    AUTO_INSTALL=true
  elif [ -t 0 ] || [ -c /dev/tty ]; then
    exec < /dev/tty 2>/dev/null || true
    read -rp "Would you like to install Bun now? [Y/n] " response
    case "$response" in
      [yY][eE][sS]|[yY]|"")
        AUTO_INSTALL=true
        ;;
      *)
        AUTO_INSTALL=false
        ;;
    esac
  fi

  if [ "$AUTO_INSTALL" = "true" ]; then
    echo "Installing Bun..."
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL https://bun.sh/install | bash
    elif command -v npm >/dev/null 2>&1; then
      npm install -g bun
    else
      echo "Error: Neither curl nor npm is available to install Bun automatically." >&2
      echo "Please install Bun manually from https://bun.sh" >&2
      exit 1
    fi

    if [ -d "$HOME/.bun/bin" ]; then
      export PATH="$HOME/.bun/bin:$PATH"
    fi

    if ! command -v bun >/dev/null 2>&1; then
      echo "Error: Bun installation finished, but 'bun' command was not found in PATH." >&2
      echo "Please add Bun to your PATH (e.g. export PATH=\"\$HOME/.bun/bin:\$PATH\") and re-run." >&2
      exit 1
    fi
  else
    echo "Please install Bun from https://bun.sh or using 'npm install -g bun', then re-run this script." >&2
    exit 1
  fi
}

ensure_bun "$@"

echo "Installing dependencies using Bun..."
bun install

echo "Building application packages..."
bun run build

echo ""
echo "=== gitinspect installed successfully! ==="
echo "To start the local web application, run:"
echo "  bun run dev"
