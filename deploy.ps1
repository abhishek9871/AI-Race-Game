# AI Race Bike Game - Cloudflare Pages Deployment Script
# This script exports the Godot project and deploys to Cloudflare Pages

$ErrorActionPreference = "Stop"

# Configuration
$GODOT_PATH = "C:\Users\VASU\Downloads\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe"
$PROJECT_PATH = "C:\Users\VASU\Desktop\build"
$BUILD_DIR = "web-build"
$PROJECT_NAME = "ai-race-bike-game"

Write-Host "===========================================
" -ForegroundColor Cyan
Write-Host "  AI Race Bike Game - Deployment Script  " -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Export Godot Project
Write-Host "[1/4] Exporting Godot project to Web..." -ForegroundColor Yellow
Set-Location $PROJECT_PATH

& $GODOT_PATH --headless --export-release "Web" "$BUILD_DIR/index.html"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Godot export failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Export completed successfully!" -ForegroundColor Green
Write-Host ""

# Step 2: Compress WASM file for Cloudflare Pages 25MB limit
Write-Host "[2/4] Compressing WASM file..." -ForegroundColor Yellow

$wasmFiles = Get-ChildItem -Path "$BUILD_DIR" -Filter "*.wasm"

foreach ($wasmFile in $wasmFiles) {
    $inputFile = $wasmFile.FullName
    $outputFile = "$inputFile.gz"
    
    Write-Host "  Compressing: $($wasmFile.Name)" -ForegroundColor Gray
    
    # Use .NET compression
    $input = [System.IO.File]::ReadAllBytes($inputFile)
    $output = [System.IO.File]::Create($outputFile)
    $gzipStream = New-Object System.IO.Compression.GzipStream $output, ([System.IO.Compression.CompressionMode]::Compress)
    $gzipStream.Write($input, 0, $input.Length)
    $gzipStream.Close()
    $output.Close()
    
    $originalSize = [math]::Round($wasmFile.Length / 1MB, 2)
    $compressedSize = [math]::Round((Get-Item $outputFile).Length / 1MB, 2)
    $savings = [math]::Round(($wasmFile.Length - (Get-Item $outputFile).Length) / $wasmFile.Length * 100, 1)
    
    Write-Host "  Original: $originalSize MB → Compressed: $compressedSize MB (${savings}% reduction)" -ForegroundColor Green
    
    # Rename compressed file to replace original if under 25MB
    if ((Get-Item $outputFile).Length -lt 25MB) {
        Remove-Item $inputFile
        Rename-Item $outputFile $wasmFile.Name
        Write-Host "  ✓ WASM file optimized for Cloudflare Pages!" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Warning: Compressed file still exceeds 25MB!" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 3: Verify build files
Write-Host "[3/4] Verifying build files..." -ForegroundColor Yellow

$requiredFiles = @("index.html", "*.js", "*.wasm", "*.pck")
$allFilesPresent = $true

foreach ($pattern in $requiredFiles) {
    $files = Get-ChildItem -Path "$BUILD_DIR" -Filter $pattern
    if ($files.Count -eq 0) {
        Write-Host "  ✗ Missing: $pattern" -ForegroundColor Red
        $allFilesPresent = $false
    } else {
        Write-Host "  ✓ Found: $pattern ($($files.Count) file(s))" -ForegroundColor Green
    }
}

if (-not $allFilesPresent) {
    Write-Host "Error: Build verification failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 4: Deploy to Cloudflare Pages
Write-Host "[4/4] Deploying to Cloudflare Pages..." -ForegroundColor Yellow
Write-Host "  Project Name: $PROJECT_NAME" -ForegroundColor Cyan
Write-Host "  Branch: main (production)" -ForegroundColor Cyan
Write-Host ""

wrangler pages deploy $BUILD_DIR --project-name=$PROJECT_NAME --branch=main

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Cloudflare Pages deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  🎉 Deployment Completed Successfully!  " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your game will be available at:" -ForegroundColor Cyan
Write-Host "  https://$PROJECT_NAME.pages.dev" -ForegroundColor White
Write-Host ""
