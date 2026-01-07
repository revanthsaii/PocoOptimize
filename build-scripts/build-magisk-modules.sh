#!/bin/bash
# PocoOptimize - Magisk Module Builder
# Author: Revanth Sai
# Description: Automatically builds all Magisk modules as flashable ZIP files

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODULES_DIR="$PROJECT_ROOT/magisk-modules"
OUTPUT_DIR="$PROJECT_ROOT/releases"
BUILD_DATE=$(date '+%Y%m%d')

echo "========================================"
echo "PocoOptimize Magisk Module Builder"
echo "========================================"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to build a single module
build_module() {
    local module_name="$1"
    local module_path="$MODULES_DIR/$module_name"
    
    if [ ! -d "$module_path" ]; then
        echo "ERROR: Module directory not found: $module_path"
        return 1
    fi
    
    echo ""
    echo "Building module: $module_name"
    echo "----------------------------------------"
    
    # Read version from module.prop
    if [ -f "$module_path/module.prop" ]; then
        VERSION=$(grep "^version=" "$module_path/module.prop" | cut -d'=' -f2)
        echo "Version: $VERSION"
    else
        echo "WARNING: module.prop not found"
        VERSION="unknown"
    fi
    
    # Create ZIP filename
    ZIP_NAME="${module_name}-${VERSION}-${BUILD_DATE}.zip"
    ZIP_PATH="$OUTPUT_DIR/$ZIP_NAME"
    
    # Create temporary build directory
    TEMP_DIR=$(mktemp -d)
    echo "Using temp directory: $TEMP_DIR"
    
    # Copy module files to temp directory
    cp -r "$module_path/"* "$TEMP_DIR/"
    
    # Ensure proper permissions for scripts
    find "$TEMP_DIR" -type f -name "*.sh" -exec chmod 755 {} \;
    if [ -d "$TEMP_DIR/META-INF" ]; then
        find "$TEMP_DIR/META-INF" -type f -exec chmod 755 {} \;
    fi
    
    # Create the ZIP file
    cd "$TEMP_DIR"
    zip -r9 "$ZIP_PATH" ./* -x "*.git*" -x "*.md"
    cd - > /dev/null
    
    # Cleanup temp directory
    rm -rf "$TEMP_DIR"
    
    # Calculate file size and SHA256
    FILE_SIZE=$(du -h "$ZIP_PATH" | cut -f1)
    SHA256=$(sha256sum "$ZIP_PATH" | cut -d' ' -f1)
    
    echo "✓ Built: $ZIP_NAME"
    echo "  Size: $FILE_SIZE"
    echo "  SHA256: $SHA256"
    
    # Create SHA256 checksum file
    echo "$SHA256  $ZIP_NAME" > "$ZIP_PATH.sha256"
    echo "  Checksum file created"
    
    return 0
}

# Build all modules
MODULES=(
    "PocoOptimize-Performance"
    "PocoOptimize-Battery"
    "PocoOptimize-Thermal"
)

SUCCESS_COUNT=0
FAIL_COUNT=0

for module in "${MODULES[@]}"; do
    if build_module "$module"; then
        ((SUCCESS_COUNT++))
    else
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "========================================"
echo "Build Summary"
echo "========================================"
echo "Total modules: ${#MODULES[@]}"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✓ All modules built successfully!"
    ls -lh "$OUTPUT_DIR"
    exit 0
else
    echo "✗ Some modules failed to build"
    exit 1
fi
