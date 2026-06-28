$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "Starting observability stack (app, Prometheus, Grafana, Loki, Promtail)..."
docker compose up -d --build
docker compose ps

Write-Host ""
Write-Host "App:        http://localhost:3000"
Write-Host "Prometheus: http://localhost:9090"
Write-Host "Grafana:    http://localhost:3001  (admin / admin)"
Write-Host "Loki:       http://localhost:3100"
