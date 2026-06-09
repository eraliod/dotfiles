#!/usr/bin/env bash
#
# Git configuration: identity, useful defaults, and pre-commit template
#
set -euo pipefail

if ! command -v git &>/dev/null; then
	echo "Git not found. Run scripts/setup/brew.sh first."
	exit 1
fi

GIT_CMD="$(brew --prefix)/bin/git"

current_name=$($GIT_CMD config --global --get user.name || true)
if [[ -z "$current_name" ]]; then
	read -r -p "Git user.name: " git_user_name
	$GIT_CMD config --global user.name "$git_user_name"
fi

current_email=$($GIT_CMD config --global --get user.email || true)
if [[ -z "$current_email" ]]; then
	read -r -p "Git user.email: " git_user_email
	$GIT_CMD config --global user.email "$git_user_email"
fi

$GIT_CMD config --global --replace-all core.pager "less -F -X"
$GIT_CMD config --global push.autoSetupRemote true
$GIT_CMD config --global init.defaultBranch main
$GIT_CMD config --global init.templateDir ~/.git-template

if command -v pre-commit &>/dev/null; then
	pre-commit init-templatedir ~/.git-template
fi

if command -v difft &>/dev/null; then
	$GIT_CMD config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'
	$GIT_CMD config --global difftool.prompt false
	$GIT_CMD config --global diff.tool difftastic
fi

echo "Git configuration complete."
