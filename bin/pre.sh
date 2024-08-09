#!/usr/bin/env bash

set -euo pipefail  # Exit immediately if a command exits with a non-zero status.

# Load configuration
CONFIG_FILE="$HOME/.pre_config"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Configuration file not found at $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

# Check if template folder exists
if [[ ! -d "$TEMPLATE_FOLDER" ]]; then
    echo "Template folder not found at $TEMPLATE_FOLDER"
    exit 1
fi

# Function to check for updates
check_for_updates() {
    cd "$TEMPLATE_FOLDER" || exit 1
    git fetch origin
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/main)
    if [[ "$local_commit" != "$remote_commit" ]]; then
        echo "Updates are available for the templates."
        read -r -p "Would you like to update now? (y/n): " update_choice
        if [[ "$update_choice" == "y" ]]; then
            git pull origin main
            if [[ $? -ne 0 ]]; then
                echo "Failed to update templates from GitHub."
                exit 1
            fi
            echo "Templates updated successfully."
        fi
    fi
}

# List available templates
list_templates() {
    local templates=()
    for template in "$TEMPLATE_FOLDER"/*; do
        if [[ -d "$template" && ! "$(basename "$template")" =~ ^\..* ]]; then
            templates+=("$template")
        fi
    done
    printf "%s\n" "${templates[@]}"
}

# Display template options
display_templates() {
    local templates=("$@")
    echo "Available templates:"
    for ((i=0; i<${#templates[@]}; i++)); do
        echo "$((i+1))) $(basename "${templates[i]}")"
    done
}

# Select template interactively
select_template() {
    local templates=("$@")
    local selected_index=""
    while true; do
        read -r -p "Select a template (1-${#templates[@]}): " selected_index
        if [[ -z "$selected_index" ]]; then
            echo "Input cannot be empty. Please try again."
        elif [[ "$selected_index" =~ ^[0-9]+$ ]] && ((selected_index >= 1 && selected_index <= ${#templates[@]})); then
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done

    echo "$selected_index"
}

# Initialize project
initialize_project() {
    local template_path="$1"
    local project_name
    read -r -p "Enter project name: " project_name
    local project_path="$PWD/$project_name"
    mkdir -p "$project_path"
    cp -r "$template_path"/* "$project_path"
    echo "Project initialized at $project_path"

    # Replace {{PROJECT_NAME}} in folder and file names
    find "$project_path" -depth -name '*{{PROJECT_NAME}}*' | while IFS= read -r path; do
        # Ensure the path starts with the project_path
        if [[ "$path" == "$project_path"* ]]; then
            new_path=$(echo "$path" | sed "s/{{PROJECT_NAME}}/$project_name/g")
            mv "$path" "$new_path"
        fi
    done

    # Replace {{PROJECT_NAME}} in file contents
    find "$project_path" -type f -exec sed -i "s/{{PROJECT_NAME}}/$project_name/g" {} +
}

# Main script logic
main() {
    check_for_updates
    local templates=()
    readarray -t templates < <(list_templates)
    display_templates "${templates[@]}"
    local selected_index
    selected_index=$(select_template "${templates[@]}")
    local template_path="${templates[$((selected_index - 1))]}"
    initialize_project "$template_path"
}

main
