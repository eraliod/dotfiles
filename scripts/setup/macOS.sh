#!/usr/bin/env bash
#
# macOS-specific setup: Xcode CLI tools, Moom import, optional Dock cleanup
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if ! xcode-select -p &>/dev/null; then
	echo "Installing Xcode Command Line Tools..."
	xcode-select --install
	echo "Press enter after Xcode CLI tools installation completes..."
	read -r
fi

# Moom window manager settings
# Re-export from a source machine by changing 'import' to 'export' below.
if [[ -f "${DOTFILES_DIR}/settings/Moom.plist" ]]; then
	defaults import com.manytricks.Moom "${DOTFILES_DIR}/settings/Moom.plist"
	echo "Moom settings imported."
fi

# Optional: clear the Dock of default icons
read -r -p "Clear default icons from the macOS Dock? (y/N) " kill_dock
if [[ "${kill_dock:-N}" =~ ^[Yy]$ ]]; then
	defaults write com.apple.dock persistent-apps -array ""
	killall Dock
	echo "Dock cleared."
fi

echo "macOS setup complete."
