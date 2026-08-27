#!/usr/bin/env bash
set -e

# Increase Node heap space to prevent OOM during heavy Vite/Nitro builds
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=4096}"

echo "=== Installing gitinspect locally ==="

# Check for git
if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required to run gitinspect. Please install git and try again." >&2
  exit 1
fi

# Handle remote execution (e.g. curl | bash) outside of a cloned repo
REPO_URL="https://github.com/gitinspect/gitinspect.git"
TARGET_DIR="gitinspect"

if [ ! -f "package.json" ] || ! grep -q '"name": "gitinspect"' package.json 2>/dev/null; then
  if [ -d "$TARGET_DIR" ] && [ -f "$TARGET_DIR/package.json" ]; then
    echo "Existing '$TARGET_DIR' folder found. Navigating into '$TARGET_DIR'..."
    cd "$TARGET_DIR"
  else
    echo "Cloning gitinspect repository..."
    git clone "$REPO_URL" "$TARGET_DIR"
    cd "$TARGET_DIR"
  fi
fi

# Ensure standard Bun path is in PATH if present
if [ -d "$HOME/.bun/bin" ]; then
  export PATH="$HOME/.bun/bin:$PATH"
fi

# Prompt user for package manager preference if both or none are active
select_package_manager() {
  # If explicitly passed via argument or environment variable
  if [ -n "$USE_PKG_MGR" ]; then
    PKG_MGR="$USE_PKG_MGR"
    return
  fi

  HAS_BUN=false
  HAS_NPM=false
  command -v bun >/dev/null 2>&1 && HAS_BUN=true
  command -v npm >/dev/null 2>&1 && HAS_NPM=true

  if [ "$1" = "-y" ] || [ "$CI" = "true" ]; then
    if [ "$HAS_BUN" = "true" ]; then
      PKG_MGR="bun"
    elif [ "$HAS_NPM" = "true" ]; then
      PKG_MGR="npm"
    else
      PKG_MGR="bun"
    fi
    return
  fi

  if [ -t 0 ] || [ -c /dev/tty ]; then
    exec < /dev/tty 2>/dev/null || true
    echo ""
    echo "Select package manager / runtime to use:"
    echo "1) Bun (Recommended)"
    echo "2) Node.js / npm"
    read -rp "Enter choice [1/2, default: 1]: " choice
    case "$choice" in
      2|[nN][oO][dD][eE]|[nN][pP][mM])
        PKG_MGR="npm"
        ;;
      *)
        PKG_MGR="bun"
        ;;
    esac
  else
    PKG_MGR="bun"
  fi
}

select_package_manager "$@"

ensure_runtime() {
  if [ "$PKG_MGR" = "npm" ]; then
    if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
      echo "Error: Node.js and npm are required when using npm manager." >&2
      exit 1
    fi
  else
    if ! command -v bun >/dev/null 2>&1; then
      echo "Bun is required, but it is not installed."
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
        echo "Please install Bun from https://bun.sh or choose Node.js option." >&2
        exit 1
      fi
    fi
  fi
}

ensure_runtime "$@"

echo "Installing dependencies using $PKG_MGR..."
if [ "$PKG_MGR" = "npm" ]; then
  npm install
  echo "Building application packages..."
  npm run build
else
  bun install
  echo "Building application packages..."
  bun run build
fi

echo ""
echo "=== gitinspect installed successfully! ==="
echo "To start the local web application, navigate into the repo directory (if not already there) and run:"
if [ "$PKG_MGR" = "npm" ]; then
  echo "  cd $(pwd) && npm run dev"
else
  echo "  cd $(pwd) && bun run dev"
fi
