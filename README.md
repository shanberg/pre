# `pre`

`pre` is a simmple project templating program. Run `pre` to

## Installing

Clone and run `install.sh`. You'll be asked to choose between using templates from a GitHub repository or a local folder.

```bash
chmod +x install.sh
./install.sh
```

The installation script will also add the `pre` script to your `PATH` by modifying your `.bashrc` and `.zshrc` files.

## Configuration

The configuration file is located at `$HOME/.pre_config`. It contains the path to the templates directory:
bash
TEMPLATE_FOLDER="/path/to/your/templates"
You can edit this file to change the source of your templates.

## Usage

To initialize a new project, run the `pre` script:

```bash
pre
```

### Steps:

1. **List available templates**:

   - The script will list all available templates in the configured template directory.

2. **Select a template**:

   - You will be prompted to select a template by entering its corresponding number.

3. **Enter project name**:
   - You will be prompted to enter a name for your new project.

The script will create a new directory with the project name in the current working directory, copy the selected template's contents into it, and replace instances of `{{PROJECT_NAME}}` with the project name in both file names and file contents.

## Uninstallation

To uninstall the Project Templating System, run the `uninstall.sh` script:
bash
./uninstall.sh

### Uninstallation Steps:

1. **Remove the configuration file**:

   - The script will remove the configuration file located at `$HOME/.pre_config`.

2. **Remove the template directory**:

   - You will be prompted to confirm whether you want to remove the template directory and its contents.

3. **Remove the main script from PATH**:
   - The script will remove the `pre` script from the `BIN_DIR` (`$HOME/bin`).

## Example

To create a new project using a template:

1. Run the `pre` script:

bash
pre

2. Select a template from the list of available templates.
3. Enter a name for your new project.

The new project will be initialized in the current directory.

## License

This project is licensed under the MIT License.
`
