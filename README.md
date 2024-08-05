# `pre`

`pre` slaps some files and folders together to 

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/shanberg/pre/main/install.sh | bash
```

## Usage

After installation, you can run the `pre` from anywhere on your machine.

You'll be asked for a project name, and whether to use the current folder or create a new one.

`pre` will copy the selected template to the target directory and replace placeholders with the provided project name.

`pre` will replace the string {{PROJECT_NAME}} anywhere in the files in the template with the project name provided.

## Templates

The templates are stored in versioned directories under `/templates`.

Example:

```md
/templates/
├── v1.0.0/
│   ├── .gitignore
│   ├── .structure_version
│   ├── .vscode/
│   │   ├── extensions.json
│   │   ├── project.code-workspace
│   │   ├── settings.json
│   │   └── tasks.json
│   ├── README.md
│   ├── docs/ 
│   │   ├── notes.md
│   │   └── progress.md
│   ├── links.md
```

## Updating Templates

1. **Create a New Template Directory**: Create a new directory for the template version under `templates/`.

    ```bash
    mkdir -p templates/v1.1.0
    ```

2. **Add Template Files**: Add the necessary files and directories to the new template version.

3. **Update the Installation Script**: Update the `VERSION` variable in the `install.sh` script to the new version and run the installation script again.

```bash
VERSION="v1.1.0"  # Update this version as needed
sudo ./install.sh
```

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.
