#!/usr/bin/env bash
# Installs the memory hygiene check as a git pre-push hook.
# Run from inside any git repo where you want the hook active.
#
# Usage:
#   bash .../scripts/install-pre-push-hook.sh           # install pre-push
#   bash .../scripts/install-pre-push-hook.sh --commit  # install pre-commit instead
#   bash .../scripts/install-pre-push-hook.sh --remove  # remove whichever is installed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKER="$SCRIPT_DIR/pre-push-memory-check.sh"

if [ ! -f "$CHECKER" ]; then
  echo "Error: checker not found at $CHECKER" >&2
  exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: not in a git repository. cd into the repo first." >&2
  exit 1
fi

HOOK_DIR="$(git rev-parse --git-path hooks)"
TARGET="$HOOK_DIR/pre-push"
REMOVE=0

for arg in "$@"; do
  case "$arg" in
    --commit) TARGET="$HOOK_DIR/pre-commit" ;;
    --remove) REMOVE=1 ;;
    --help)
      sed -n '1,10p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown flag: $arg" >&2
      exit 1
      ;;
  esac
done

if [ "$REMOVE" = "1" ]; then
  removed=0
  for hook in "$HOOK_DIR/pre-push" "$HOOK_DIR/pre-commit"; do
    if [ -L "$hook" ] && [ "$(readlink "$hook")" = "$CHECKER" ]; then
      rm "$hook"
      echo "removed: $hook"
      removed=1
    fi
  done
  [ "$removed" = "0" ] && echo "No managed hook found to remove."
  exit 0
fi

# Safety: don't overwrite an existing unrelated hook
if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  echo "Error: $TARGET exists and is not a symlink." >&2
  echo "Refusing to overwrite — back it up or remove it manually first." >&2
  exit 1
fi

if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$CHECKER" ]; then
  echo "✅ already installed at $TARGET"
  exit 0
fi

# Install
chmod +x "$CHECKER"
chmod +x "$SCRIPT_DIR/pre-push-memory-check.py"
ln -s "$CHECKER" "$TARGET"
echo "🔗 installed: $TARGET → $CHECKER"
echo ""
echo "Test it: bash $CHECKER"
echo "Remove:  bash $(basename "$0") --remove"
