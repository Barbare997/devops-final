#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

echo "Starting observability stack (app, Prometheus, Grafana, Loki, Promtail)..."
docker compose up -d --build
docker compose ps

echo ""
echo "App:        http://localhost:3000"
echo "Prometheus: http://localhost:9090"
echo "Grafana:    http://localhost:3001  (admin / admin)"
echo "Loki:       http://localhost:3100"
