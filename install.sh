#!/usr/bin/env bash

CONFIG_FILE="$HOME/.pre_config"
DEFAULT_GITHUB_URL="https://github.com/shanberg/pre-templates"
DEFAULT_LOCAL_DIR="$HOME/.pre_project-templates"

# Function to prompt for GitHub repository setup
setup_github_repo() {
    read -p "Enter the GitHub repository URL for the templates [default: $DEFAULT_GITHUB_URL]: " github_url
    github_url=${github_url:-$DEFAULT_GITHUB_URL}

    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Please install Git and try again."
        exit 1
    fi

    git clone "$github_url" "$DEFAULT_LOCAL_DIR"
    if [[ $? -ne 0 ]]; then
        echo "Failed to clone repository. Please check the URL and try again."
        exit 1
    fi

    echo "TEMPLATE_FOLDER=\"$DEFAULT_LOCAL_DIR\"" > "$CONFIG_FILE"
    echo "Templates will be sourced from: $DEFAULT_LOCAL_DIR"
}

# Function to prompt for local directory setup
setup_local_dir() {
    read -p "Please enter the full path to your local templates directory [default: $DEFAULT_LOCAL_DIR]: " local_dir
    local_dir=${local_dir:-$DEFAULT_LOCAL_DIR}

    if [[ ! -d "$local_dir" ]]; then
        read -p "Directory does not exist. Create it? (y/n): " create_dir
        if [[ "$create_dir" == "y" ]]; then
            mkdir -p "$local_dir"
            if [[ $? -ne 0 ]]; then
                echo "Failed to create directory. Please check the path and try again."
                exit 1
            fi
        else
            echo "Directory setup aborted."
            exit 1
        fi
    fi

    echo "TEMPLATE_FOLDER=\"$local_dir\"" > "$CONFIG_FILE"
    echo "Templates will be sourced from: $local_dir"
}

# Main installer logic
echo "Welcome to the Project Templating System installer."
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

echo "Configuration complete!"
echo "You can change the template source later by editing $CONFIG_FILE"