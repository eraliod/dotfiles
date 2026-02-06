#!/usr/bin/env zsh

# Configure Pixi global environment
# Note: Pixi is installed via Homebrew (see brew.sh)
# This script configures the global environment by symlinking the config file

echo "Configuring Pixi global environment..."

# Define the target directory for pixi global toml on macOS
PIXI_GLOBAL_TOML_DIR="${HOME}/.pixi/manifests"

# Check if pixi global toml directory exists
if [ -d "$PIXI_GLOBAL_TOML_DIR" ]; then
    # Copy your custom global toml to the pixi global toml directory
    ln -sf "${HOME}/dotfiles/settings/pixi-global.toml" "${PIXI_GLOBAL_TOML_DIR}/pixi-global.toml"

    pixi global sync

    echo "pixi global toml has been installed."
else
    echo "pixi global toml directory does not exist. Please ensure pixi is installed."
fi
