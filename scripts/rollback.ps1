$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$activeFile = Join-Path $root "data\active-target.json"
$previousFile = Join-Path $root "data\previous-target.json"

if (-not (Test-Path $previousFile)) {
  throw "Nothing to roll back (missing $previousFile)."
}

Copy-Item -Force $previousFile $activeFile
Write-Host "Restored routing from data\previous-target.json"
