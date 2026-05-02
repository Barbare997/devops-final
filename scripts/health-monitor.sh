#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT/logs"
LOG_FILE="${LOG_FILE:-$LOG_DIR/health.log}"
URL="${HEALTH_URL:-http://127.0.0.1:8080/health}"
INTERVAL_SEC="${INTERVAL_SEC:-5}"

mkdir -p "$LOG_DIR"

echo "Logging health checks for ${URL} every ${INTERVAL_SEC}s to ${LOG_FILE}"
echo "Press Ctrl+C to stop."

while true; do
  ts="$(date -Iseconds)"
  if out="$(curl -fsS "$URL" 2>&1)"; then
    echo "${ts} OK ${out}" >>"$LOG_FILE"
  else
    echo "${ts} FAIL ${out}" >>"$LOG_FILE"
  fi
  sleep "$INTERVAL_SEC"
done
