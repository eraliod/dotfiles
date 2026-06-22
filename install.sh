#!/usr/bin/env bash
#
# Dotfiles installer
#
# Usage:
#   ./install.sh              # Full setup (fails on conflicts)
#   ./install.sh --stow-only  # Just stow, skip package installs
#   ./install.sh --adopt      # Migration: pull existing files into repo
#   ./install.sh --force      # Reset: backup & replace existing files
#
# Scenarios:
#   Fresh machine:  ./install.sh
#   Migration:      ./install.sh --adopt  (then review & commit)
#   Reset env:      ./install.sh --force
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="${DOTFILES_DIR}/stow"
BACKUP_DIR="${DOTFILES_DIR}/.backup/$(date +%Y%m%d-%H%M%S)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [[ "$OSTYPE" != "darwin"* ]]; then
	error "This script is designed for macOS only."
	exit 1
fi

###############################################################################
# Parse arguments
###############################################################################
STOW_ONLY=false
ADOPT_MODE=false
FORCE_MODE=false

for arg in "$@"; do
	case $arg in
	--stow-only)
		STOW_ONLY=true
		;;
	--adopt)
		ADOPT_MODE=true
		;;
	--force)
		FORCE_MODE=true
		;;
	--help | -h)
		echo "Usage: $0 [OPTIONS]"
		echo ""
		echo "Options:"
		echo "  --stow-only  Skip package installation, just stow dotfiles"
		echo "  --adopt      Migration mode: pull existing files into repo"
		echo "  --force      Reset mode: backup existing files, use repo as truth"
		echo "  --help       Show this help"
		exit 0
		;;
	esac
done

if [[ "$ADOPT_MODE" == true && "$FORCE_MODE" == true ]]; then
	error "Cannot use --adopt and --force together"
	exit 1
fi

###############################################################################
# Install tools (skip if --stow-only)
###############################################################################
if [[ "$STOW_ONLY" == false ]]; then
	"${DOTFILES_DIR}/scripts/setup/macOS.sh"
	"${DOTFILES_DIR}/scripts/setup/brew.sh"

	eval "$(/opt/homebrew/bin/brew shellenv)"

	"${DOTFILES_DIR}/scripts/setup/ohmyzsh.sh"
fi

###############################################################################
# Stow dotfiles (always runs)
###############################################################################

if [[ -x /opt/homebrew/bin/brew ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

info "Stowing dotfiles..."

mkdir -p "$HOME/.pixi/manifests"
mkdir -p "$HOME/.claude"

# Seed .private for untracked secrets (stow will symlink to ~, sourced by .zshrc)
if [[ ! -f "$STOW_DIR/shell/.private" ]]; then
	cat >"$STOW_DIR/shell/.private" <<'PRIVATE'
# ~/.private — sourced by .zshrc
# Put sensitive exports here (API keys, tokens, etc.)
# This file is gitignored and NOT tracked.
PRIVATE
	info "Created stow/shell/.private for sensitive environment variables"
fi

if ! command -v stow &>/dev/null; then
	error "stow not found on PATH. Brew bundle likely failed earlier — fix the Brewfile and re-run."
	exit 1
fi

cd "$STOW_DIR"

STOW_FLAGS=(-t "$HOME" -R)
if [[ "$ADOPT_MODE" == true ]]; then
	STOW_FLAGS=(-t "$HOME" --adopt)
	warn "ADOPT MODE: Existing files will be pulled into the repo"
	warn "Review changes with 'git diff' after completion"
fi

for package in */; do
	package_name="${package%/}"

	if [[ "$FORCE_MODE" == true ]]; then
		while IFS= read -r conflict_file; do
			if [[ -n "$conflict_file" && -L "$HOME/$conflict_file" ]]; then
				info "Removing old symlink: $conflict_file"
				rm "$HOME/$conflict_file"
			elif [[ -n "$conflict_file" && -e "$HOME/$conflict_file" ]]; then
				mkdir -p "$BACKUP_DIR/$(dirname "$conflict_file")"
				info "Backing up: $conflict_file"
				mv "$HOME/$conflict_file" "$BACKUP_DIR/$conflict_file"
			fi
		done < <(cd "$STOW_DIR/$package_name" && find . -type f | sed 's|^\./||')
	fi

	info "Stowing ${package_name}..."
	if ! stow "${STOW_FLAGS[@]}" "$package_name" 2>&1; then
		if [[ "$ADOPT_MODE" == false && "$FORCE_MODE" == false ]]; then
			error "Stow failed for ${package_name}. Use --adopt (migration) or --force (reset)."
			exit 1
		fi
	fi
done

if [[ "$FORCE_MODE" == true && -d "$BACKUP_DIR" ]]; then
	info "Backups saved to: $BACKUP_DIR"
fi

if [[ "$ADOPT_MODE" == true ]]; then
	warn "ADOPT MODE complete. Review pulled files:"
	warn "  cd $DOTFILES_DIR && git status"
	warn "  git diff"
	warn "Then commit if satisfied."
fi

###############################################################################
# Post-stow setup (skip if --stow-only)
###############################################################################
if [[ "$STOW_ONLY" == false ]]; then
	"${DOTFILES_DIR}/scripts/setup/pixi.sh"
	"${DOTFILES_DIR}/scripts/setup/git.sh"
	"${DOTFILES_DIR}/scripts/setup/vscode.sh"
	"${DOTFILES_DIR}/scripts/setup/claude.sh"
fi

###############################################################################
# Done
###############################################################################
echo ""
info "Install complete!"
echo ""
echo "Stowed packages:"
ls -1 "$STOW_DIR"
echo ""
if [[ "$STOW_ONLY" == false ]]; then
	echo "Post-installation manual steps:"
	echo "  1. Restart your terminal (or run: source ~/.zshrc)"
	echo "  2. Set Terminal default profile (settings/DEC.terminal)"
	echo "  3. Configure Raycast keyboard shortcut (⌘Space)"
	echo "  4. Sign in to VS Code extensions (Copilot, GitLens, etc.)"
	echo "  5. (Optional) Adopt ~/.aws/config and ~/.databrickscfg into stow:"
	echo "       mkdir -p stow/aws/.aws stow/databricks"
	echo "       ./install.sh --adopt"
fi
