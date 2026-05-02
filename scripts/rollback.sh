#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVE_FILE="$ROOT/data/active-target.json"
PREVIOUS_FILE="$ROOT/data/previous-target.json"

if [[ ! -f "$PREVIOUS_FILE" ]]; then
  echo "Nothing to roll back (missing $PREVIOUS_FILE)."
  exit 1
fi

cp "$PREVIOUS_FILE" "$ACTIVE_FILE"
echo "Restored routing from data/previous-target.json"
