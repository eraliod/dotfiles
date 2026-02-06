#!/usr/bin/env zsh

# dotfiles directory
dotfiledir="${HOME}/dotfiles"

# Install oh-my-zsh if it isn't already installed
directory=~/.oh-my-zsh
if [ -d "$directory" ] && [ "$(ls -A $directory)" ]; then
    echo "oh-my-zsh already installed in the default installation directory ~/.oh-my-zsh"
else
    echo "Installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Because oh-my-zsh installation creates a new .zshrc file, must re-point .zshrc symlink
    ln -sf "${dotfiledir}/.zshrc" "${HOME}/.zshrc"
fi
