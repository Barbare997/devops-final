$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$activeFile = Join-Path $root "data\active-target.json"
$previousFile = Join-Path $root "data\previous-target.json"

$bluePort = if ($env:BLUE_PORT) { [int]$env:BLUE_PORT } else { 3001 }
$greenPort = if ($env:GREEN_PORT) { [int]$env:GREEN_PORT } else { 3002 }

if (-not (Test-Path $activeFile)) {
  throw "Missing $activeFile"
}

$current = Get-Content $activeFile -Raw | ConvertFrom-Json
$currentPort = [int]$current.port

if ($currentPort -eq $bluePort) {
  $nextPort = $greenPort
  $nextLabel = "green"
}
elseif ($currentPort -eq $greenPort) {
  $nextPort = $bluePort
  $nextLabel = "blue"
}
else {
  throw "active-target.json port must be $bluePort (blue) or $greenPort (green). Got: $currentPort"
}

$healthUrl = "http://127.0.0.1:$nextPort/health"
Write-Host "Checking inactive slot health on $healthUrl ..."

try {
  Invoke-RestMethod -Uri $healthUrl -Method Get | Out-Null
}
catch {
  Write-Host "Inactive slot failed health check. Start it first, e.g.:"
  Write-Host "  `$env:PORT='$nextPort'; `$env:DEPLOY_SLOT='$nextLabel'; `$env:APP_VERSION='2'; npm start"
  throw
}

Copy-Item -Force $activeFile $previousFile

$next = [ordered]@{ port = $nextPort; label = $nextLabel }
$json = ($next | ConvertTo-Json -Depth 5) + "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($activeFile, $json, $utf8NoBom)

Write-Host "Switched active traffic to $nextLabel (port $nextPort)."
Write-Host "Previous routing saved to data\previous-target.json"
