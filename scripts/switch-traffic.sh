#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVE_FILE="$ROOT/data/active-target.json"
PREVIOUS_FILE="$ROOT/data/previous-target.json"

BLUE_PORT="${BLUE_PORT:-3001}"
GREEN_PORT="${GREEN_PORT:-3002}"

if [[ ! -f "$ACTIVE_FILE" ]]; then
  echo "Missing $ACTIVE_FILE"
  exit 1
fi

current_port="$(node -e "console.log(JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')).port)" "$ACTIVE_FILE")"

if [[ "$current_port" == "$BLUE_PORT" ]]; then
  next_port="$GREEN_PORT"
  next_label="green"
elif [[ "$current_port" == "$GREEN_PORT" ]]; then
  next_port="$BLUE_PORT"
  next_label="blue"
else
  echo "active-target.json port must be $BLUE_PORT (blue) or $GREEN_PORT (green). Got: $current_port"
  exit 1
fi

echo "Checking inactive slot health on 127.0.0.1:${next_port}/health ..."
if ! curl -fsS "http://127.0.0.1:${next_port}/health" >/dev/null; then
  echo "Inactive slot failed health check. Start it first, e.g.:"
  echo "  PORT=${next_port} DEPLOY_SLOT=${next_label} APP_VERSION=2 npm start"
  exit 1
fi

cp "$ACTIVE_FILE" "$PREVIOUS_FILE"
node -e "const fs=require('fs'); const p=process.argv[1]; const port=Number(process.argv[2]); const label=process.argv[3]; fs.writeFileSync(p, JSON.stringify({port, label}, null, 2) + '\\n');" "$ACTIVE_FILE" "$next_port" "$next_label"

echo "Switched active traffic to ${next_label} (port ${next_port})."
echo "Previous routing saved to data/previous-target.json"
