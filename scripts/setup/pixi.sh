#!/usr/bin/env bash
#
# Install pixi and sync the global environment
# (pixi-global.toml is stowed to ~/.pixi/manifests/ by stow)
#
set -euo pipefail

PIXI_VERSION="v0.55.0"

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

echo "Syncing pixi global environment..."
pixi global sync

echo "Pixi setup complete."
