#!/bin/bash
# Build script for Love2D Starter Kit
# Creates a .love file by zipping the project contents

# Create build directory if it doesn't exist
BUILD_DIR="$(pwd)/build"
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
fi

# Set the output filename in the build directory
OUTPUT_FILE="$BUILD_DIR/love-2d-starter-kit.love"

# Get the current directory
PROJECT_DIR="$(pwd)"

# Remove existing .love file if it exists
if [ -f "$OUTPUT_FILE" ]; then
    echo "Removing existing $OUTPUT_FILE..."
    rm -f "$OUTPUT_FILE"
fi

# Files and directories to exclude from the build
EXCLUDE_PATTERNS=(
    "*.love"
    "*.ps1"
    "*.sh"
    "build-love.ps1"
    "build-love.sh"
    "build/*"
    "build"
    "utils/*"
    "utils"
    ".git*"
    ".github*"
    "*.md"
    "INSTALL.md"
    "README.md"
    "FONT_SUPPORT.md"
)

echo "Building $OUTPUT_FILE..."

# Create a temporary directory for staging files
TEMP_DIR="/tmp/love2d-build-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$TEMP_DIR"

# Function to check if a file/directory should be excluded
should_exclude() {
    local item="$1"
    local basename_item="$(basename "$item")"
    
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        # Check against full relative path
        if [[ "$item" == $pattern ]]; then
            return 0
        fi
        # Check against basename
        if [[ "$basename_item" == $pattern ]]; then
            return 0
        fi
        # Handle wildcard patterns
        if [[ "$item" == $pattern || "$basename_item" == $pattern ]]; then
            return 0
        fi
    done
    return 1
}

cleanup() {
    # Clean up temporary directory
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Set up cleanup on script exit
trap cleanup EXIT

# Copy all files except excluded ones
echo "Copying project files..."

# Use find to get all files and directories, excluding the temp directory
find "$PROJECT_DIR" -type f -o -type d | while read -r item; do
    # Skip if it's the temp directory itself
    if [[ "$item" == "$TEMP_DIR"* ]]; then
        continue
    fi
    
    # Get relative path
    RELATIVE_PATH="${item#$PROJECT_DIR/}"
    
    # Skip the project directory itself
    if [ "$item" = "$PROJECT_DIR" ]; then
        continue
    fi
    
    # Check if this item should be excluded
    if should_exclude "$RELATIVE_PATH"; then
        continue
    fi
    
    DEST_PATH="$TEMP_DIR/$RELATIVE_PATH"
    
    if [ -d "$item" ]; then
        # Create directory
        mkdir -p "$DEST_PATH"
    else
        # Copy file
        DEST_DIR="$(dirname "$DEST_PATH")"
        mkdir -p "$DEST_DIR"
        cp "$item" "$DEST_PATH"
    fi
done

# Create the .love file (which is just a ZIP file)
echo "Creating ZIP archive..."

# Check if we're in the temp directory and have files
if [ "$(find "$TEMP_DIR" -type f | wc -l)" -eq 0 ]; then
    echo "Error: No files found to archive" >&2
    exit 1
fi

# Use zip to create the archive
if command -v zip >/dev/null 2>&1; then
    cd "$TEMP_DIR" && zip -r "$OUTPUT_FILE" . >/dev/null
else
    echo "Error: zip command not found. Please install zip." >&2
    exit 1
fi

if [ $? -eq 0 ]; then
    echo -e "\033[32mSuccessfully created $OUTPUT_FILE\033[0m"
    
    # Show file size
    if command -v stat >/dev/null 2>&1; then
        # Linux/GNU stat
        FILE_SIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null)
        if [ -n "$FILE_SIZE" ]; then
            FILE_SIZE_KB=$((FILE_SIZE / 1024))
            echo -e "\033[36mFile size: $FILE_SIZE_KB KB\033[0m"
        fi
    fi
else
    echo "Error: Failed to create ZIP archive" >&2
    exit 1
fi

echo -e "\n\033[33mBuild complete! You can now run the game with:\033[0m"
echo -e "\033[37mlove \"$OUTPUT_FILE\"\033[0m"
