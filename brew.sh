#!/usr/bin/env zsh

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    if [ $admin_response = 'Y' ]; then
        echo "Homebrew not installed. Installing Homebrew."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Attempt to set up Homebrew PATH automatically for this session
        if [ -x "/opt/homebrew/bin/brew" ]; then
            # For Apple Silicon Macs
            echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
            export PATH="/opt/homebrew/bin:$PATH"
        fi
    else
        print -P "Homebrew is not installed, and you indicated you %F{red}do not have administrator rights%f. Skipping brew installations..."
        echo
        exit
    fi
else
    echo "Homebrew is already installed."
fi

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Update Homebrew and Upgrade any already-installed formulae
brew update
brew upgrade
brew upgrade --cask
brew cleanup

# Define an array of packages to install using Homebrew.
# Note: awscli, fzf, go, and tree are managed by pixi global (see settings/pixi-global.toml)
# Python is kept in brew because some brew packages (like thefuck) depend on it
packages=(
    "bash"
    "duckdb"
    "git"
    "pixi"
    "powerlevel10k"
    "python"
    "terramate"
    "thefuck"
    "wget"
    "zsh"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
)

# Loop over the array to install each application.
for package in "${packages[@]}"; do
    if brew list --formula | grep -q "^$package\$"; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

# Get the path to Homebrew's zsh
BREW_ZSH="$(brew --prefix)/bin/zsh"
# Check if Homebrew's zsh is already the default shell
if [ "$SHELL" != "$BREW_ZSH" ]; then
    if [ $admin_response = 'Y' ]; then
        echo "Changing default shell to Homebrew zsh"
        # Check if Homebrew's zsh is already in allowed shells
        if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
            echo "Adding Homebrew zsh to allowed shells"
            echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
        fi
        # Set the Homebrew zsh as default shell
        chsh -s "$BREW_ZSH"
        echo "Default shell changed to Homebrew zsh."
    else
        echo
        print -P "%F{yellow}Without administrator rights, script cannot make the brew installed zsh as the default shell%f.
While this is not completely necessary, it is possible to default to this shell by changing the terminal settings via the UI.
To do this:
1. Open the Terminal
2. Open Settings > General
3. Enter the path $(brew --prefix)/bin/zsh in the 'Shells open with' option

Press ENTER to continue"
        read
    fi
else
    echo "Homebrew zsh is already the default shell. Skipping configuration."
fi

# Define an array of applications to install using Homebrew Cask.
apps=(
    "cheatsheet"
    "claude"
    "claude-code"
    "docker"
    "elgato-control-center"
    "firefox"
    "gimp"
    "google-chrome"
    "google-drive"
    "meetingbar"
    "moom"
    "obsidian"
    "raycast"
    "spotify"
    "steam"
    "visual-studio-code"
    "vlc"
)

# Loop over the array to install each application.
if [ $admin_response = 'Y' ]; then
    for app in "${apps[@]}"; do
        if brew list --cask | grep -q "^$app\$"; then
            echo "$app is already installed. Skipping..."
        else
            echo "Installing $app..."
            brew install --cask "$app"
        fi
    done
else
    print -P "%F{Yellow}Skipping application installations. Because no admin rights%f."
fi

# Moom settings
# Settings can be exported from a source machine by changing 'import' to 'export'
if [ -f "${HOME}/dotfiles/settings/Moom.plist" ]; then
    defaults import com.manytricks.Moom "${HOME}/dotfiles/settings/Moom.plist"
    echo "Moom settings imported successfully."
fi

# Install fonts
# Note: homebrew/cask-fonts tap is deprecated, fonts are now regular casks
fonts=(
    "font-awesome-terminal-fonts"
)

for font in "${fonts[@]}"; do
    # Check if the font is already installed
    if brew list --cask | grep -q "^$font\$"; then
        echo "$font is already installed. Skipping..."
    else
        echo "Installing $font..."
        brew install --cask "$font"
    fi
done

# Update and clean up again for safe measure
brew update
brew upgrade
brew upgrade --cask
brew cleanup
