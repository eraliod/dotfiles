#!/usr/bin/env bash
#
# Install Homebrew and packages from Brewfile
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if ! command -v brew &>/dev/null; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Installing Homebrew packages from Brewfile..."
if ! brew bundle --file="${DOTFILES_DIR}/packages/Brewfile"; then
	echo "Warning: some Brewfile dependencies failed to install (see above)"
fi

echo "Homebrew setup complete."
