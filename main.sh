#!/usr/bin/env bash

# Load configuration
CONFIG_FILE="$HOME/.pre_config"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Check if template folder exists
if [[ ! -d "$TEMPLATE_FOLDER" ]]; then
    echo "Template folder not found at $TEMPLATE_FOLDER"
    exit 1
fi

# List available templates
list_templates() {
    echo "Available templates:"
    local index=1
    for template in "$TEMPLATE_FOLDER"/*; 
    do
        if [[ -d "$template" ]]; then
            echo "$index) $(basename "$template")"
            index=$((index + 1))
        fi
    done
}

# Select template interactively
select_template() {
    list_templates
    echo -n "Select a template: "
    read -r template_index
    local selected_template=$(ls -d "$TEMPLATE_FOLDER"/* | sed -n "${template_index}p")
    if [[ -z "$selected_template" ]]; then
        echo "Invalid selection"
        exit 1
    fi
    echo "$selected_template"
}

# Initialize project
initialize_project() {
    local template_path="$1"
    echo -n "Enter project name: "
    read -r project_name
    local project_path="$PWD/$project_name"
    if [[ -d "$project_path" ]]; then
        echo "Project directory already exists"
        exit 1
    fi
    cp -r "$template_path" "$project_path"
    echo "Creating project '$project_name' using '$(basename "$template_path")' template..."
    echo "Done!"
}

# Update template folder location
update_template_folder() {
    echo -n "Enter new template folder path: "
    read -r new_template_folder
    if [[ ! -d "$new_template_folder" ]]; then
        echo "Directory does not exist: $new_template_folder"
        exit 1
    fi
    echo "TEMPLATE_FOLDER=\"$new_template_folder\"" > "$CONFIG_FILE"
    echo "Template folder location updated to $new_template_folder"
}

# Main script logic
main() {
    if [[ "$1" == "--update-template-folder" ]]; then
        update_template_folder
    else
        local template_path=$(select_template)
        initialize_project "$template_path"
    fi
}

main "$@"