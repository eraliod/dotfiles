#!/usr/bin/env bash
#
# Install Oh My Zsh and set Homebrew zsh as default shell
#
set -euo pipefail

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	echo "Installing Oh My Zsh..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

BREW_ZSH="$(brew --prefix)/bin/zsh"
if [[ "$SHELL" != "$BREW_ZSH" ]]; then
	echo "Setting Homebrew zsh as default shell..."
	if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
		echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
	fi
	chsh -s "$BREW_ZSH"
fi

echo "Oh My Zsh setup complete."
