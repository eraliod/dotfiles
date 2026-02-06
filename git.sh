#!/usr/bin/env zsh

# Git Configuration Script
echo "Configuring Git..."

# Ensure git is available (should be installed via brew.sh)
if ! command -v git &>/dev/null; then
    echo "Git not found. Please run brew.sh first."
    exit 1
fi

# Get the path to Homebrew's git for consistent configuration
GIT_CMD="$(brew --prefix)/bin/git"

# Git config name
current_name=$($GIT_CMD config --global --get user.name)
if [ -z "$current_name" ]; then
    echo "Please enter your FULL NAME for Git configuration:"
    read git_user_name
    $GIT_CMD config --global user.name "$git_user_name"
    echo "Git user.name has been set to $git_user_name"
else
    echo "Git user.name is already set to '$current_name'. Skipping configuration."
fi

# Git config email
current_email=$($GIT_CMD config --global --get user.email)
if [ -z "$current_email" ]; then
    echo "Please enter your EMAIL for Git configuration:"
    read git_user_email
    $GIT_CMD config --global user.email "$git_user_email"
    echo "Git user.email has been set to $git_user_email"
else
    echo "Git user.email is already set to '$current_email'. Skipping configuration."
fi

# Set my git global preferences
$GIT_CMD config --global --replace-all core.pager "less -F -X"
$GIT_CMD config --global push.autoSetupRemote true
$GIT_CMD config --global init.defaultBranch main

# Automatically enable pre-commit on cloned repos
$GIT_CMD config --global init.templateDir ~/.git-template
if command -v pre-commit &>/dev/null; then
    pre-commit init-templatedir ~/.git-template
    echo "Pre-commit template directory configured."
else
    echo "Pre-commit not found. Skipping template directory setup."
fi

# Configure difftastic for enhanced diffs (only if difft is available)
if command -v difft &>/dev/null; then
    echo "Configuring git with difftastic for enhanced diffs..."
    $GIT_CMD config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'
    $GIT_CMD config --global difftool.prompt false
    $GIT_CMD config --global diff.tool difftastic
    echo "Git difftastic configuration complete."
else
    echo "Difftastic not found in PATH. Skipping enhanced diff configuration."
    echo "Make sure pixi.sh has been run and pixi bin directory is in PATH."
fi

echo "Git configuration complete!"
