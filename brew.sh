#!/usr/bin/env zsh

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    if [ $admin_response = 'Y' ]; then
        echo "Homebrew not installed. Installing Homebrew."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        print -P "Homebrew is not installed, and you indicated you %F{red}do not have administrator rights%f. Skipping brew installations..."
        echo
        exit
    fi
    # Attempt to set up Homebrew PATH automatically for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # For Apple Silicon Macs
        echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
        export PATH="/opt/homebrew/bin:$PATH"
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
packages=(
    "git"
    "bash"
    "zsh"
    "fzf"
    "tree"
    "python"
    "awscli"
    "fzf"
    "go"
    "powerlevel10k"
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

# Add the Homebrew zsh to allowed shells
if [ $admin_response = 'Y' ]; then
    echo
    echo "Attempting to change the default shell to Homebrew zsh"
    echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells >/dev/null
    # Set the Homebrew zsh as default shell
    chsh -s "$(brew --prefix)/bin/zsh"
    echo "Successfully changed default shell to the homebrew zsh installation"
    echo
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

# Git config name
echo "Please enter your FULL NAME for Git configuration:"
read git_user_name

# Git config email
echo "Please enter your EMAIL for Git configuration:"
read git_user_email

# Set my git credentials
$(brew --prefix)/bin/git config --global user.name "$git_user_name"
$(brew --prefix)/bin/git config --global user.email "$git_user_email"

# Set my git global preferences
$(brew --prefix)/bin/git config --global --replace-all core.pager "less -F -X"  

# install the powerlevel10k theme for zsh
directory=~/.oh-my-zsh
if [ -d "$directory" ] && [ "$(ls -A $directory)" ]; then
    echo "oh-my-zsh already installed in the default installation directory ~/.oh-my-zsh"
else
    echo "Installing oh-my-zsh"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; exit
    # Because oh-my-zsh installation creates a new .zshrc file, must re-point .zshrc symlink
    ln -sf "${dotfiledir}/.zshrc" "${HOME}/.zshrc"
fi

# Define an array of applications to install using Homebrew Cask.
apps=(
    "google-chrome"
    "firefox"
    "visual-studio-code"
    "moom"
    "cheatsheet"
    "docker"
    "raycast"
    "google-drive"
    "dropzone"
    "gimp"
    "zoom"
    "vlc"
    "steam"
    "discord"
    "spotify"
    "elgato-control-center"
    "meetingbar"
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
defaults import com.manytricks.Moom ${HOME}/dotfiles/settings/Moom.plist

# Install Source Code Pro Font
# Tap the Homebrew font cask repository if not already tapped
brew tap | grep -q "^homebrew/cask-fonts$" || brew tap homebrew/cask-fonts

# Define the font name
font_name="font-awesome-terminal-fonts"

# Check if the font is already installed
if brew list --cask | grep -q "^$font_name\$"; then
    echo "$font_name is already installed. Skipping..."
else
    echo "Installing $font_name..."
    brew install --cask "$font_name"
fi

# Once font is installed, Import your Terminal Profile
echo
print -P "%F{green}Import your terminal settings...%f"
echo "Terminal -> Settings -> Profiles -> Import..."
echo "Import from ${HOME}/dotfiles/settings/DEC.terminal"
echo "Press enter to continue..."
read

# Update and clean up again for safe measure
brew update
brew upgrade
brew upgrade --cask
brew cleanup

if [ $admin_response = 'Y' ]; then
    echo "Use Spotlight ⌘Space, type 'Keyboard Shortcuts', go to Spotlight. Change shortcut to ⌥Space"
    echo "Grab the Raycast Export from a private share (contains private keys, cannot be committed to repo)"
    echo "Import Raycast Settings under Advanced Options"

    echo "Sign in to Google Chrome. Press enter to continue..."
    read

    echo "Sign in to Spotify. Press enter to continue..."
    read

    echo "Sign in to Discord. Press enter to continue..."
    read
fi
