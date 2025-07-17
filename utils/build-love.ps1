# Build script for Love2D Starter Kit
# Creates a .love file by zipping the project contents

# Create build directory if it doesn't exist
$buildDir = Join-Path (Get-Location) "build"
if (!(Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
}

# Set the output filename in the build directory
$outputFile = Join-Path $buildDir "love-2d-starter-kit.love"

# Get the current directory
$projectDir = Get-Location

# Remove existing .love file if it exists
if (Test-Path $outputFile) {
    Write-Host "Removing existing $outputFile..."
    Remove-Item $outputFile -Force
}

# Files and directories to exclude from the build
$excludePatterns = @(
    "*.love",
    "*.ps1",
    "build-love.ps1",
    "build/*",
    "build",
    "utils/*",
    "utils",
    ".git*",
    ".github*",
    "*.md",
    "INSTALL.md",
    "README.md",
    "FONT_SUPPORT.md"
)

Write-Host "Building $outputFile..."

# Create a temporary directory for staging files
$tempDir = Join-Path $env:TEMP "love2d-build-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    # Copy all files except excluded ones
    Write-Host "Copying project files..."
    
    # Get all items in the project directory
    $allItems = Get-ChildItem -Path $projectDir -Recurse
    
    foreach ($item in $allItems) {
        $relativePath = $item.FullName.Substring($projectDir.Path.Length + 1)
        
        # Check if this item should be excluded
        $shouldExclude = $false
        foreach ($pattern in $excludePatterns) {
            if ($relativePath -like $pattern -or $item.Name -like $pattern) {
                $shouldExclude = $true
                break
            }
        }
        
        # Skip if excluded or if it's the temp directory itself
        if ($shouldExclude -or $item.FullName.StartsWith($tempDir)) {
            continue
        }
        
        $destPath = Join-Path $tempDir $relativePath
        
        if ($item.PSIsContainer) {
            # Create directory
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        } else {
            # Copy file
            $destDir = Split-Path $destPath -Parent
            if (!(Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item $item.FullName $destPath
        }
    }
    
    # Create the .love file (which is just a ZIP file)
    Write-Host "Creating ZIP archive..."
    
    # Use .NET compression to create the ZIP file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $outputFile)
    
    Write-Host "Successfully created $outputFile" -ForegroundColor Green
    
    # Show file size
    $fileSize = (Get-Item $outputFile).Length
    $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
    Write-Host "File size: $fileSizeKB KB" -ForegroundColor Cyan
    
} catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
} finally {
    # Clean up temporary directory
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
}

Write-Host "`nBuild complete! You can now run the game with:" -ForegroundColor Yellow
Write-Host "love `"$outputFile`"" -ForegroundColor White
