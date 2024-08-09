#!/usr/bin/env bash

# Define the name of the bundled archive
BUNDLE_NAME="pre.tar.gz"

# Define the directories and files to include in the bundle
INCLUDE_DIRS=("bin" "lib")
INCLUDE_FILES=("install.sh" "uninstall.sh" "LICENSE" "README.md" ".gitattributes" ".pre.now.md")

# Create a temporary directory for bundling
TEMP_DIR=$(mktemp -d)

# Copy the necessary directories and files to the temporary directory
for dir in "${INCLUDE_DIRS[@]}"; do
    cp -r "$dir" "$TEMP_DIR/"
done

for file in "${INCLUDE_FILES[@]}"; do
    cp "$file" "$TEMP_DIR/"
done

# Create the dist directory if it doesn't exist
DIST_DIR="dist"
mkdir -p "$DIST_DIR"

# Create the bundled archive in the dist directory
tar -czvf "$DIST_DIR/$BUNDLE_NAME" -C "$TEMP_DIR" .

# Clean up the temporary directory
rm -rf "$TEMP_DIR"

echo "Bundling complete. Created archive: $DIST_DIR/$BUNDLE_NAME"
