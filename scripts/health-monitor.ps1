$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path $root "logs"

if (-not (Test-Path $logDir)) {
  New-Item -ItemType Directory -Path $logDir | Out-Null
}

$logFile = if ($env:LOG_FILE) { $env:LOG_FILE } else { Join-Path $logDir "health.log" }
$url = if ($env:HEALTH_URL) { $env:HEALTH_URL } else { "http://127.0.0.1:8080/health" }
$intervalSec = if ($env:INTERVAL_SEC) { [int]$env:INTERVAL_SEC } else { 5 }

Write-Host "Logging health checks for $url every ${intervalSec}s to $logFile"
Write-Host "Press Ctrl+C to stop."

while ($true) {
  $ts = (Get-Date).ToString("o")
  try {
    $resp = Invoke-RestMethod -Uri $url -Method Get
    $line = "{0} OK {1}" -f $ts, ($resp | ConvertTo-Json -Compress)
    Add-Content -Path $logFile -Value $line
  }
  catch {
    $line = "{0} FAIL {1}" -f $ts, $_.Exception.Message
    Add-Content -Path $logFile -Value $line
  }

  Start-Sleep -Seconds $intervalSec
}
