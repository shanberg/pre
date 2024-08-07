#!/usr/bin/env bash

CONFIG_FILE="$HOME/.pre_config"
DEFAULT_LOCAL_DIR="$HOME/.pre_project"

# Function to remove the configuration file
remove_config_file() {
    if [[ -f "$CONFIG_FILE" ]]; then
        rm "$CONFIG_FILE"
        if [[ $? -ne 0 ]]; then
            echo "Failed to remove configuration file: $CONFIG_FILE"
            exit 1
        fi
        echo "Configuration file removed: $CONFIG_FILE"
    else
        echo "Configuration file not found: $CONFIG_FILE"
    fi
}

# Function to remove the template directory
remove_template_directory() {
    if [[ -d "$DEFAULT_LOCAL_DIR" ]]; then
        read -p "Do you want to remove the template directory and its contents? (y/n): " remove_dir
        if [[ "$remove_dir" == "y" ]]; then
            rm -rf "$DEFAULT_LOCAL_DIR"
            if [[ $? -ne 0 ]]; then
                echo "Failed to remove template directory: $DEFAULT_LOCAL_DIR"
                exit 1
            fi
            echo "Template directory removed: $DEFAULT_LOCAL_DIR"
        else
            echo "Template directory not removed: $DEFAULT_LOCAL_DIR"
        fi
    else
        echo "Template directory not found: $DEFAULT_LOCAL_DIR"
    fi
}

# Function to remove the main script from PATH
remove_main_script() {
    MAIN_SCRIPT="$HOME/bin/pre"
    if [[ -f "$MAIN_SCRIPT" ]]; then
        rm "$MAIN_SCRIPT"
        if [[ $? -ne 0 ]]; then
            echo "Failed to remove main script: $MAIN_SCRIPT"
            exit 1
        fi
        echo "Main script removed: $MAIN_SCRIPT"
    else
        echo "Main script not found: $MAIN_SCRIPT"
    fi
}

# Main uninstaller logic
echo "Uninstalling the pre..."

remove_config_file
remove_template_directory
remove_main_script

echo "Uninstallation complete"