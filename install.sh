#!/bin/bash

# Define the installation directory
INSTALL_DIR="/usr/local/bin"
SHARE_DIR="/usr/local/share/project_templates"
EXECUTABLE_NAME="pre"

# Ensure the installation directories exist
sudo mkdir -p "$INSTALL_DIR"
sudo mkdir -p "$SHARE_DIR"

# Copy the template directory to the shared location with versioning
VERSION="v1.0.0"  # Update this version as needed
sudo cp -r "templates/v1.0.0" "$SHARE_DIR/$VERSION"

# Copy the setup script to the installation directory
sudo cp "main.sh" "$INSTALL_DIR/$EXECUTABLE_NAME"

# Make the setup script executable
sudo chmod +x "$INSTALL_DIR/$EXECUTABLE_NAME"

echo "Installation complete. You can now run the application using the command: $EXECUTABLE_NAME"