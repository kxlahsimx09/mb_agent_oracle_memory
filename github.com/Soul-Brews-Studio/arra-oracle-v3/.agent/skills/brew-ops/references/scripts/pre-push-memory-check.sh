#!/usr/bin/env bash
# Pre-push / pre-commit memory hygiene check.
# Delegates to the python checker alongside this file.
# See workflow-6-pre-push-memory-check.md for the spec.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_CHECK="$SCRIPT_DIR/pre-push-memory-check.py"

if [ ! -f "$PYTHON_CHECK" ]; then
  echo "Error: checker script not found at $PYTHON_CHECK" >&2
  exit 3
fi

exec python3 "$PYTHON_CHECK" "$@"
