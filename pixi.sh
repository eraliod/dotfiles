#!/usr/bin/env zsh

# Install and configure Pixi
# Installed via pixi.sh installer (not Homebrew) to allow version pinning matching CI

PIXI_VERSION="v0.55.0"

# Install pixi if not already installed, or if version doesn't match
install_pixi=false
if ! command -v pixi &>/dev/null; then
    install_pixi=true
elif [[ "$(pixi --version)" != "pixi ${PIXI_VERSION#v}" ]]; then
    echo "Pixi version mismatch: found $(pixi --version), want pixi ${PIXI_VERSION#v}"
    install_pixi=true
fi

if $install_pixi; then
    echo "Installing pixi ${PIXI_VERSION}..."
    curl -fsSL https://pixi.sh/install.sh | PIXI_VERSION="${PIXI_VERSION}" bash
    export PATH="$HOME/.pixi/bin:$PATH"
else
    echo "pixi ${PIXI_VERSION#v} is already installed. Skipping..."
fi

# Configure Pixi global environment
echo "Configuring Pixi global environment..."

PIXI_GLOBAL_TOML_DIR="${HOME}/.pixi/manifests"

# Create the manifests directory if it doesn't exist yet
mkdir -p "$PIXI_GLOBAL_TOML_DIR"

ln -sf "${HOME}/dotfiles/settings/pixi-global.toml" "${PIXI_GLOBAL_TOML_DIR}/pixi-global.toml"
pixi global sync

echo "Pixi global environment configured."
