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

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::Open($OUTPUT_ZIP, [System.IO.Compression.ZipArchiveMode]::Create)

$filesToInclude = @("modinfo.json", "modicon.png")
foreach ($file in $filesToInclude) {
    if (Test-Path $file) {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, 
            (Resolve-Path $file).Path, 
            $file, 
            [System.IO.Compression.CompressionLevel]::Optimal
        ) | Out-Null
    }
}

Get-ChildItem -Path "assets" -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring((Get-Location).Path.Length + 1)
    $entryPath = $relativePath -replace '\\', '/'
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $zip, 
        $_.FullName, 
        $entryPath, 
        [System.IO.Compression.CompressionLevel]::Optimal
    ) | Out-Null
}

$zip.Dispose()

Pop-Location

Write-Host "Created $OUTPUT_ZIP" -ForegroundColor Green

