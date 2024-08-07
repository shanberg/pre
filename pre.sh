#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status.

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

# List available templates
list_templates() {
    echo "Available templates:"
    local index=1
    for template in "$TEMPLATE_FOLDER"/*; do
        if [[ -d "$template" && ! "$(basename "$template")" =~ ^\..* ]]; then
            echo "$index) $(basename "$template")"
            ((index++))
        fi
    done
}

# Select template interactively
select_template() {
    list_templates
    local templates=()
    while IFS= read -r -d '' dir; do
        if [[ ! "$(basename "$dir")" =~ ^\..* ]]; then
            templates+=("$dir")
        fi
    done < <(find "$TEMPLATE_FOLDER" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

    while true; do
        echo -n "Select a template (1-${#templates[@]}): "
        read -r template_index
        if [[ "$template_index" =~ ^[0-9]+$ ]] && ((template_index >= 1 && template_index <= ${#templates[@]})); then
            selected_template="${templates[template_index-1]}"
            echo "Selected template path: $selected_template"
            echo "$selected_template"
            return
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Initialize project
initialize_project() {
    local template_path="$1"
    local project_name
    while true; do
        echo -n "Enter project name: "
        read -r project_name
        if [[ -n "$project_name" ]]; then
            break
        else
            echo "Project name cannot be empty. Please try again."
        fi
    done

    local project_path="$PWD/$project_name"
    if [[ -d "$project_path" ]]; then
        echo "Project directory already exists"
        exit 1
    fi

    echo "Creating project '$project_name' using '$(basename "$template_path")' template..."
    mkdir -p "$project_path"
    echo "Debug: Copying from $template_path to $project_path"
    if ! cp -r "$template_path"/* "$project_path" 2>/dev/null; then
        echo "Error: Failed to copy template files. Please check permissions and try again."
        ls -la "$template_path"
        ls -la "$project_path"
        rm -rf "$project_path"
        exit 1
    fi
    echo "Done!"
}

# Main script logic
main() {
    local template_path
    template_path=$(select_template)
    echo "Debug: Selected template path is $template_path"
    initialize_project "$template_path"
}

main