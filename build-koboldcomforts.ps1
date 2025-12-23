$ErrorActionPreference = 'Stop'

$ROOT_DIR = Split-Path -Parent $PSCommandPath
$MOD_NAME = "koboldcomforts"
$MOD_DIR = Join-Path $ROOT_DIR $MOD_NAME

if (-not (Test-Path $MOD_DIR -PathType Container)) {
    Write-Error "Error: mod directory '$MOD_DIR' not found."
    exit 1
}

Push-Location $MOD_DIR

if (-not (Test-Path "modinfo.json" -PathType Leaf)) {
    Write-Error "Error: modinfo.json not found in '$MOD_DIR'."
    exit 1
}

if (-not (Test-Path "assets" -PathType Container)) {
    Write-Error "Error: assets directory not found in '$MOD_DIR'."
    exit 1
}

$modinfo = Get-Content "modinfo.json" -Raw | ConvertFrom-Json
$VERSION = $modinfo.version

if ([string]::IsNullOrEmpty($VERSION)) {
    Write-Error "Error: could not read 'version' from modinfo.json."
    exit 1
}

$OUTPUT_ZIP = Join-Path $ROOT_DIR "${MOD_NAME}_${VERSION}.zip"

if (Test-Path $OUTPUT_ZIP) {
    Remove-Item $OUTPUT_ZIP -Force
}

$filesToZip = @(
    "assets",
    "modicon.png",
    "modinfo.json"
)

Compress-Archive -Path $filesToZip -DestinationPath $OUTPUT_ZIP -CompressionLevel Optimal

Pop-Location

Write-Host "Created $OUTPUT_ZIP" -ForegroundColor Green

