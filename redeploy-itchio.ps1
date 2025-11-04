# AI Race Bike Game - itch.io Re-deployment Script
# Double-click this file to re-export and package your game for itch.io

$ErrorActionPreference = "Stop"

# Configuration
$GODOT_PATH = "C:\Users\VASU\Downloads\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe"
$PROJECT_PATH = "C:\Users\VASU\Desktop\build"
$BUILD_DIR = "web-build"
$ZIP_NAME = "ai-race-bike-game-itchio.zip"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  AI Race Bike Game - itch.io Update  " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Export Godot Project
Write-Host "[1/3] Exporting Godot project..." -ForegroundColor Yellow
Set-Location $PROJECT_PATH

& $GODOT_PATH --headless --export-release "Web" "$BUILD_DIR/index.html"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ Error: Godot export failed!" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "  ✓ Export completed!" -ForegroundColor Green
Write-Host ""

# Step 2: Remove old zip
Write-Host "[2/3] Removing old zip file..." -ForegroundColor Yellow

if (Test-Path $ZIP_NAME) {
    Remove-Item $ZIP_NAME -Force
    Write-Host "  ✓ Old zip removed!" -ForegroundColor Green
} else {
    Write-Host "  • No old zip found (first build)" -ForegroundColor Gray
}

Write-Host ""

# Step 3: Create new zip
Write-Host "[3/3] Creating new zip file..." -ForegroundColor Yellow

Compress-Archive -Path "$BUILD_DIR\*" -DestinationPath $ZIP_NAME -Force

$zipSize = [math]::Round((Get-Item $ZIP_NAME).Length / 1MB, 2)
Write-Host "  ✓ Created: $ZIP_NAME ($zipSize MB)" -ForegroundColor Green
Write-Host ""

# Success message
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  🎉 Build Ready for itch.io Upload!  " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Go to: https://itch.io/dashboard" -ForegroundColor White
Write-Host "  2. Open your game project" -ForegroundColor White
Write-Host "  3. Delete the old upload" -ForegroundColor White
Write-Host "  4. Upload: $ZIP_NAME" -ForegroundColor White
Write-Host "  5. Check: 'This file will be played in the browser'" -ForegroundColor White
Write-Host "  6. Click: Save" -ForegroundColor White
Write-Host ""

# Ask if user wants to open the folder
Write-Host "Open build folder? (Y/N): " -ForegroundColor Yellow -NoNewline
$response = Read-Host

if ($response -eq "Y" -or $response -eq "y") {
    Start-Process explorer.exe -ArgumentList $PROJECT_PATH
    Write-Host "  ✓ Folder opened!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done! 🚀" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
