#!/bin/bash

# Function to replace placeholders in files
replace_placeholders() {
    local file="$1"
    local project_name="$2"
    sed -i "s/{{PROJECT_NAME}}/$project_name/g" "$file"
}

# Prompt for project name
echo "Please provide a project name:"
read -r PROJECT_NAME

# Prompt for directory choice using select
echo "Do you want to use the current directory?"
select USE_CURRENT_DIR in "Yes" "No"; do
    case $USE_CURRENT_DIR in
        Yes ) USE_CURRENT_DIR="y"; break;;
        No ) USE_CURRENT_DIR="n"; break;;
    esac
done

# Create project directory if not using current directory
if [[ "$USE_CURRENT_DIR" != "y" && "$USE_CURRENT_DIR" != "Y" ]]; then
    mkdir -p "$PROJECT_NAME"
    TARGET_DIR="$PROJECT_NAME"
else
    TARGET_DIR="."
fi

# List available template versions
echo "Available template versions:"
TEMPLATE_VERSIONS=($(ls /usr/local/share/project_templates))
select TEMPLATE_VERSION in "${TEMPLATE_VERSIONS[@]}"; do
    if [[ -n "$TEMPLATE_VERSION" ]]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Validate template version
TEMPLATE_DIR="/usr/local/share/project_templates/$TEMPLATE_VERSION"
if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "Invalid template version selected."
    exit 1
fi

# Copy template directory to target directory
cp -r "$TEMPLATE_DIR"/* "$TARGET_DIR"

# Replace placeholders in copied files
find "$TARGET_DIR" -type f -exec bash -c 'replace_placeholders "$0" "$1"' {} "$PROJECT_NAME" \;

echo "Project setup complete."
