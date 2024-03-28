#!/usr/bin/env zsh

# Check if Homebrew's bin exists and if it's not already in the PATH
if [ -x "/opt/homebrew/bin/brew" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Install VS Code Extensions
extensions=(
    ms-python.python
    ms-python.pylint
    ms-python.vscode-pylance
    ms-python.debugpy
    znck.grammarly
    usernamehw.errorlens
    vscodevim.vim
    wayou.vscode-todo-highlight
    zhuangtongfa.material-theme
    oderwat.indent-rainbow
)

# The installation of extensions via script is predicated on the code cli being present
if command -v code &>/dev/null; then
    # Get a list of all currently installed extensions.
    installed_extensions=$(code --list-extensions)

    for extension in "${extensions[@]}"; do
        if echo "$installed_extensions" | grep -qi "^$extension$"; then
            echo "$extension is already installed. Skipping..."
        else
            echo "Installing $extension..."
            code --install-extension "$extension"
        fi
    done

    echo "VS Code extensions have been installed."
else
    print -P "%F{yellow}VS Code CLI is not installed, extensions must be installed manually%f."
    for extension in "${extensions[@]}"; do
    echo "$extension"
    done
fi
read

# Define the target directory for VS Code user settings on macOS
VSCODE_USER_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"

# Check if VS Code settings directory exists
if [ -d "$VSCODE_USER_SETTINGS_DIR" ]; then
    # Backup existing settings.json and keybindings.json, if they exist
    cp "${VSCODE_USER_SETTINGS_DIR}/settings.json" "${VSCODE_USER_SETTINGS_DIR}/settings.json.backup"

    # Copy your custom settings.json and keybindings.json to the VS Code settings directory
    cp "settings/VSCode-Settings.json" "${VSCODE_USER_SETTINGS_DIR}/settings.json"

    echo "VS Code settings have been updated."
else
    print -P "%F{yellow}VS Code user settings directory does not exist%f. Please ensure VS Code is installed. Or open manually if it has never been opened."
fi

# Open VS Code to sign-in to extensions
code . &>/dev/null
echo "Login to extensions within VS Code."
echo
echo "use Option + Cmd + D to hide the dock"
echo
echo "Press enter to continue..."
read
