#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.pre_config"
DEFAULT_GITHUB_URL="https://github.com/shanberg/pre-templates"
DEFAULT_LOCAL_DIR="$HOME/.pre_project-templates"
BIN_DIR="$HOME/bin"
SCRIPT_NAME="pre"
SCRIPT_PATH="$BIN_DIR/$SCRIPT_NAME"
BUNDLE_URL="https://raw.githubusercontent.com/shanberg/pre/main/dist/pre.tar.gz"

# Default values for non-interactive mode
NON_INTERACTIVE=false
TEMPLATE_SOURCE="github"
GITHUB_URL="$DEFAULT_GITHUB_URL"
LOCAL_DIR="$DEFAULT_LOCAL_DIR"

# Ensure common directories are in PATH
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/git/bin

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --non-interactive) NON_INTERACTIVE=true ;;
        --template-source) TEMPLATE_SOURCE="$2"; shift ;;
        --github-url) GITHUB_URL="$2"; shift ;;
        --local-dir) LOCAL_DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Associative array to store intermediate data
declare -A DATA

# Function to download and extract the bundle
download_and_extract_bundle() {
    TEMP_DIR=$(mktemp -d)
    BUNDLE_PATH="$TEMP_DIR/pre.tar.gz"

    curl -L "$BUNDLE_URL" -o "$BUNDLE_PATH"
    if [[ $? -ne 0 ]]; then
        echo "Failed to download the bundle. Please check the URL and try again."
        exit 1
    fi

    tar -xzvf "$BUNDLE_PATH" -C "$TEMP_DIR"
    if [[ $? -ne 0 ]]; then
        echo "Failed to extract the bundle."
        exit 1
    fi

    DATA[BUNDLE_DIR]="$TEMP_DIR"
}

# Function to setup GitHub repository
setup_github_repo() {
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Please install Git and try again."
        exit 1
    fi

    if [[ -d "$DEFAULT_LOCAL_DIR" && "$(ls -A $DEFAULT_LOCAL_DIR)" ]]; then
        if $NON_INTERACTIVE; then
            rm -rf "$DEFAULT_LOCAL_DIR"
            if [[ $? -ne 0 ]]; then
                echo "Failed to remove existing directory: $DEFAULT_LOCAL_DIR"
                exit 1
            fi
        else
            read -p "Directory $DEFAULT_LOCAL_DIR already exists and is not empty. Remove it and continue? (y/n): " remove_dir
            if [[ "$remove_dir" == "y" ]]; then
                rm -rf "$DEFAULT_LOCAL_DIR"
                if [[ $? -ne 0 ]]; then
                    echo "Failed to remove existing directory: $DEFAULT_LOCAL_DIR"
                    exit 1
                fi
            else
                echo "Aborting installation."
                exit 1
            fi
        fi
    fi

    git clone "$GITHUB_URL" "$DEFAULT_LOCAL_DIR"
    if [[ $? -ne 0 ]]; then
        echo "Failed to clone repository. Please check the URL and try again."
        exit 1
    fi

    echo "Cloning completed. Contents of $DEFAULT_LOCAL_DIR:"
    ls -la "$DEFAULT_LOCAL_DIR"

    echo "TEMPLATE_FOLDER=\"$DEFAULT_LOCAL_DIR\"" > "$CONFIG_FILE"
    echo "Templates will be sourced from: $DEFAULT_LOCAL_DIR"
}

# Function to setup local directory
setup_local_dir() {
    if [[ ! -d "$LOCAL_DIR" ]]; then
        if $NON_INTERACTIVE; then
            mkdir -p "$LOCAL_DIR"
            if [[ $? -ne 0 ]]; then
                echo "Failed to create directory. Please check the path and try again."
                exit 1
            fi
        else
            read -p "Directory does not exist. Create it? (y/n): " create_dir
            if [[ "$create_dir" == "y" ]]; then
                mkdir -p "$LOCAL_DIR"
                if [[ $? -ne 0 ]]; then
                    echo "Failed to create directory. Please check the path and try again."
                    exit 1
                fi
            else
                echo "Directory setup aborted."
                exit 1
            fi
        fi
    fi

    echo "TEMPLATE_FOLDER=\"$LOCAL_DIR\"" > "$CONFIG_FILE"
    echo "Templates will be sourced from: $LOCAL_DIR"
}

# Function to install the main script
install_main_script() {
    if [[ ! -d "$BIN_DIR" ]]; then
        mkdir -p "$BIN_DIR"
    fi

    local bundle_dir="${DATA[BUNDLE_DIR]}"
    echo "Looking for pre.sh in $bundle_dir/bin"
    if [[ ! -f "$bundle_dir/bin/pre.sh" ]]; then
        echo "pre.sh script not found in the bundle. Please ensure it is included in the bundle."
        echo "Contents of $bundle_dir/bin:"
        ls -la "$bundle_dir/bin"
        exit 1
    fi

    cp "$bundle_dir/bin/pre.sh" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    echo "Main script installed to: $SCRIPT_PATH"

    # Add BIN_DIR to PATH if not already present
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
        echo "Added $BIN_DIR to PATH"

        # Source the relevant shell configuration file
        if [[ "$SHELL" == *"zsh"* ]]; then
            source "$HOME/.zshrc"
        elif [[ "$SHELL" == *"bash"* ]]; then
            source "$HOME/.bashrc"
        fi
    fi
}

# Main installer logic
echo "Downloading and preparing the bundle..."
download_and_extract_bundle

# Ensure BUNDLE_DIR is correctly set
echo "BUNDLE_DIR is set to: ${DATA[BUNDLE_DIR]}"

if $NON_INTERACTIVE; then
    if [[ "$TEMPLATE_SOURCE" == "github" ]]; then
        setup_github_repo
    elif [[ "$TEMPLATE_SOURCE" == "local" ]]; then
        setup_local_dir
    else
        echo "Invalid template source specified. Use 'github' or 'local'."
        exit 1
    fi
else
    echo "How would you like to manage your templates?"
    echo "1) Use templates from a GitHub repository (recommended)"
    echo "2) Use a local directory for templates"
    read -p "Enter your choice (1/2): " choice

    case $choice in
        1)
            setup_github_repo
            ;;
        2)
            setup_local_dir
            ;;
        *)
            echo "Invalid choice. Please run the installer again and select a valid option."
            exit 1
            ;;
    esac
fi

install_main_script

echo "Configuration complete!"
echo "You can change the template source later by editing $CONFIG_FILE"
