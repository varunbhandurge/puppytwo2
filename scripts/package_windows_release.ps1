<#
.SYNOPSIS
    Two Puppies: The Great Adventure — Master Windows PC Release Packaging Automation
.DESCRIPTION
    Runs the automated 57+ QA test verification suite, exports the standalone Windows x86_64
    release build, packages release documentation and Steam metadata, generates SHA256
    checksums, and produces the final distributable release ZIP archive.
#>

param(
    [switch]$SkipTests = $false,
    [string]$Version = "1.0.0"
)

$ErrorActionPreference = "Stop"

Write-Host ("=" * 75) -ForegroundColor Cyan
Write-Host "   TWO PUPPIES: THE GREAT ADVENTURE — WINDOWS PC RELEASE PACKAGER" -ForegroundColor Cyan
Write-Host ("=" * 75) -ForegroundColor Cyan
Write-Host "Target Version : v$Version"
Write-Host "Platform       : Windows Desktop (x86_64, Vulkan Forward+)"

# 1. Verification of Prerequisites
Write-Host "`n[1/5] Verifying toolchain and prerequisites..." -ForegroundColor Yellow
$godotCmd = Get-Command "godot" -ErrorAction SilentlyContinue
if (-not $godotCmd) {
    Write-Error "Godot executable not found on PATH. Please ensure ~/.local/bin/godot.cmd is configured."
    exit 1
}
Write-Host "  Found Godot CLI: $($godotCmd.Source)" -ForegroundColor Green

# 2. Automated QA Verification
if (-not $SkipTests) {
    Write-Host "`n[2/5] Executing Master QA Automated Test Suite..." -ForegroundColor Yellow
    & godot --headless res://tests/test_runner_scene.tscn
    if ($LASTEXITCODE -ne 0) {
        Write-Error "QA Test Suite FAILED with exit code $LASTEXITCODE. Packaging aborted to prevent defective release."
        exit 1
    }
    Write-Host "  QA Verification: 100% PASS RATE CONFIRMED." -ForegroundColor Green
} else {
    Write-Host "`n[2/5] Skipping QA tests (-SkipTests specified)." -ForegroundColor Magenta
}

# 3. Directory Layout Preparation
Write-Host "`n[3/5] Preparing release staging directory..." -ForegroundColor Yellow
$projectRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $projectRoot "dist"
$targetDir = Join-Path $distDir "TwoPuppies_Windows_x64"

if (Test-Path $targetDir) {
    Remove-Item -Path $targetDir -Recurse -Force
}
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
Write-Host "  Staging directory created: $targetDir" -ForegroundColor Green

# 4. Export or Stage Game Binary & Package
Write-Host "`n[4/5] Exporting game binary & assets..." -ForegroundColor Yellow
$exeTarget = Join-Path $targetDir "TwoPuppiesTheGreatAdventure.exe"
$pckTarget = Join-Path $targetDir "TwoPuppiesTheGreatAdventure.pck"

# Export the game package first
Write-Host "  Exporting game resource package (.pck)..." -ForegroundColor Yellow
& godot --headless --export-pack "Windows Desktop" $pckTarget
if (-not (Test-Path $pckTarget)) {
    Write-Error "Failed to generate game package ($pckTarget)."
    exit 1
}
Write-Host "  Asset package generated: $pckTarget" -ForegroundColor Green

# Attempt full binary export or fallback to bundled runner
$oldEAP = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
& godot --headless --export-release "Windows Desktop" $exeTarget 2>&1 | Out-Null
$ErrorActionPreference = $oldEAP

if (-not (Test-Path $exeTarget)) {
    Write-Host "  Export template not present locally; packaging with standalone Godot runtime executable." -ForegroundColor Yellow
    $godotCmdFile = "$HOME\.local\bin\godot.cmd"
    if (Test-Path $godotCmdFile) {
        $content = Get-Content $godotCmdFile
        if ($content -match '([A-Za-z]:\\[^"]+\.exe)') {
            $rawExe = $matches[1]
            if ($rawExe -match '_console\.exe$') {
                $realExe = $rawExe -replace '_console\.exe$', '.exe'
                if (Test-Path $realExe) {
                    $rawExe = $realExe
                }
            }
            Copy-Item -Path $rawExe -Destination $exeTarget -Force
        }
    }
}

if (-not (Test-Path $exeTarget)) {
    Write-Error "Could not stage target executable ($exeTarget)."
    exit 1
}
Write-Host "  Release executable prepared: $exeTarget" -ForegroundColor Green

# Bundle metadata and documentation files
$readmePath = Join-Path $targetDir "README.txt"
@"
================================================================================
                    TWO PUPPIES: THE GREAT ADVENTURE
                    Official Windows PC Release v$Version
================================================================================

A premium 3D cooperative adventure game following Bruno and Milo on their epic
journey to the legendary Aura Bone.

FEATURES:
- Full 8-Chapter Narrative Campaign with 64 Collectible Golden Bones.
- Asymmetric Co-op Gameplay:
    * Bruno: Heavy pushing, deep digging, vocal bark deflection, snout boost.
    * Milo: Scent-o-Vision tracking, small burrow crawl, mechanism activation.
- Two-Player Split-Screen with dynamic orientation and single-viewport convergence.
- Rich 3D Visuals powered by Godot 4.7 Forward+ Vulkan pipeline.
- Full Controller Support (Xbox, PlayStation DualSense, Nintendo Switch Pro).

CONTROLS:
Player 1 (Bruno):
  - Move: W, A, S, D / Left Stick
  - Jump: Space / Button A (Xbox) / Cross (PlayStation)
  - Interact / Push: E / Button X (Xbox) / Square (PlayStation)
  - Bark: F / Button B (Xbox) / Circle (PlayStation)
  - Special (Dig): Q / Button Y (Xbox) / Triangle (PlayStation)
  - Sprint: Left Shift / Right Trigger (RT / R2)

Player 2 (Milo):
  - Move: Arrow Keys / Left Stick
  - Jump: Up Arrow / Button A (Xbox) / Cross (PlayStation)
  - Interact / Switch: K / Button X (Xbox) / Square (PlayStation)
  - Bark: L / Button B (Xbox) / Circle (PlayStation)
  - Special (Scent-o-Vision / Crawl): J / Button Y (Xbox) / Triangle (PlayStation)
  - Sprint: Right Ctrl / Right Trigger (RT / R2)

SYSTEM REQUIREMENTS:
  Minimum:
    - OS: Windows 10/11 64-bit
    - CPU: Quad-core Intel / AMD 2.5 GHz
    - RAM: 8 GB
    - GPU: NVIDIA GTX 1060 / AMD RX 580 (Vulkan 1.2+ compatible)
    - Storage: 10 GB available space

  Recommended:
    - CPU: 6-Core AMD Ryzen 5 5600X / Intel Core i5-12400
    - RAM: 16 GB
    - GPU: NVIDIA RTX 3060 / AMD RX 6700 XT
    - Storage: High-speed NVMe SSD

(c) 2026 Two Puppies Studio. All Rights Reserved.
================================================================================
"@ | Set-Content -Path $readmePath -Encoding UTF8

$licensePath = Join-Path $targetDir "LICENSE.txt"
@"
TWO PUPPIES: THE GREAT ADVENTURE
End User License Agreement (EULA)

Copyright (c) 2026 Two Puppies Studio. All rights reserved.

Permission is hereby granted to the purchaser to install and execute this software
for personal, non-commercial entertainment purposes. Reverse engineering,
unauthorized duplication, redistribution, or modification of the software assets
is strictly prohibited without express written consent.
"@ | Set-Content -Path $licensePath -Encoding UTF8

$appIdPath = Join-Path $targetDir "steam_appid.txt"
"2854000" | Set-Content -Path $appIdPath -Encoding ASCII

# 5. Checksum Generation & Compression
Write-Host "`n[5/5] Generating cryptographic hashes and release archive..." -ForegroundColor Yellow
$checksumsPath = Join-Path $targetDir "SHA256SUMS.txt"
$hashes = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne "SHA256SUMS.txt" } | ForEach-Object {
    $hash = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash
    "$hash  $($_.Name)"
}
$hashes | Set-Content -Path $checksumsPath -Encoding UTF8
Write-Host "  SHA256 Checksums computed for $(($hashes | Measure-Object).Count) files." -ForegroundColor Green

$zipTarget = Join-Path $distDir "TwoPuppies_Windows_x64_v$Version.zip"
if (Test-Path $zipTarget) {
    Remove-Item -Path $zipTarget -Force
}
Compress-Archive -Path "$targetDir\*" -DestinationPath $zipTarget -CompressionLevel Optimal
Write-Host "  Release Archive Created: $zipTarget" -ForegroundColor Green

Write-Host "`n" + ("=" * 75) -ForegroundColor Cyan
Write-Host "   WINDOWS PC RELEASE PACKAGE COMPLETED SUCCESSFULLY!" -ForegroundColor Cyan
Write-Host ("=" * 75) -ForegroundColor Cyan
Write-Host "Package Output: $zipTarget"
Write-Host "Staging Folder: $targetDir"
Write-Host "Release Ready for Distribution and Steamworks Depot Ingestion.`n"
