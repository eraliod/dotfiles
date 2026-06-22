#!/usr/bin/env bash
#
# Install VS Code extensions
# (VS Code user settings are stowed by `stow vscode`, not copied here)
#
set -euo pipefail

extensions=(
	# Python
	ms-python.python
	ms-python.pylint
	ms-python.vscode-pylance
	ms-python.debugpy
	charliermarsh.ruff

	# Formatting & Language Support
	esbenp.prettier-vscode
	foxundermoon.shell-format
	tamasfe.even-better-toml
	hashicorp.terraform
	redhat.vscode-yaml

	# Utilities
	usernamehw.errorlens
	vscodevim.vim
	wayou.vscode-todo-highlight
	oderwat.indent-rainbow

	# Git & AI Tools
	eamodio.gitlens
	github.copilot

	# Theme
	zhuangtongfa.material-theme
)

if ! command -v code &>/dev/null; then
	echo "VS Code CLI not found. Install VS Code (brew bundle handles the cask), then re-run."
	exit 0
fi

installed_extensions=$(code --list-extensions)

for extension in "${extensions[@]}"; do
	if echo "$installed_extensions" | grep -qi "^$extension$"; then
		echo "$extension already installed. Skipping..."
	else
		echo "Installing $extension..."
		code --install-extension "$extension"
	fi
done

echo "VS Code extensions installed."
