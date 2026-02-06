# Development Environment Setup

This repository contains scripts and configuration files to set up a development environment for macOS. It's tailored for software development, focusing on a clean, minimal, and efficient setup.
I forked this idea from Corey Schafer, who has a great instructional YouTube Channel. He originally took configurations from Mathias Bynens.

## Overview

The setup includes automated scripts for installing essential software, configuring the Zsh shell, setting up Visual Studio Code, Claude Desktop & Claude Code CLI, and configuring a comprehensive development environment with pixi global tools. This guide will help you replicate my development environment on your machine if you desire to do so.

The zsh shell is set up as the default shell in the machine. It is augmented with oh-my-zsh, powerlevel10k theme, and the autosuggestions and syntax-highlighting plugins. This also requires a custom font for icons which will be downloaded by the scripts [Font Awesome terminal fonts](https://github.com/Homebrew/homebrew-cask-fonts/blob/master/Casks/font-awesome-terminal-fonts.rb)

## Important Note Before Installation

**WARNING:** The configurations and scripts in this repository are **HIGHLY PERSONALIZED** to my own preferences and workflows. If you decide to use them, please be aware that they will **MODIFY** your current system, potentially making some changes that are **IRREVERSIBLE** without a fresh installation of your operating system.

Furthermore, while I strive to backup files wherever possible, I cannot guarantee that all files are backed up. The backup mechanism is designed to backup SOME files **ONCE**. If the script is run more than once, the initial backups will be **OVERWRITTEN**, potentially resulting in loss of data. While I could implement timestamped backups to preserve multiple versions, this setup is optimized for my personal use, and a single backup suffices for me.

If you would like a development environment similar to mine, I highly encourage you to fork this repository and make your own personalized changes to these scripts instead of running them exactly as I have them written for myself.

If you choose to run these scripts, please do so with **EXTREME CAUTION**. It's recommended to review the scripts and understand the changes they will make to your system before proceeding.

By using these scripts, you acknowledge and accept the risk of potential data loss or system alteration. Proceed at your own risk.

## Getting Started

### Prerequisites

- macOS (The scripts are tailored for macOS)
- Administrator rights (optional, but required for full installation)

### Installation

1. Clone the repository to your local machine:
   ```sh
   git clone https://github.com/eraliod/dotfiles.git ~/dotfiles
   ```
2. Navigate to the `dotfiles` directory:
   ```sh
   cd ~/dotfiles
   ```
3. Here you should definitely take the time to comment out any of the applications inside brew.sh that you do not want
4. Run the installation script:
   ```sh
   ./install.sh
   ```

The installation script will guide you through the process, asking about administrator rights and running the following scripts in sequence:

### Installation Scripts

The installation is broken down into modular scripts that run in the following order:

1. **macOS.sh**: Installs Xcode Command Line Tools and configures macOS settings (dock, etc.)
2. **brew.sh**: Installs Homebrew, packages (formulae), applications (casks), and fonts. Also configures the default shell to Homebrew's zsh and imports application settings (Moom, Terminal profile)
3. **pixi.sh**: Configures pixi global environment by symlinking `pixi-global.toml` and running `pixi global sync`
4. **git.sh**: Configures git with user credentials, enhanced diff tools (difftastic), and pre-commit hooks
5. **ohmyzsh.sh**: Installs Oh-My-Zsh if not already present
6. **vscode.sh**: Installs VS Code extensions and imports settings
7. **claude.sh**: Configures Claude Desktop, Claude Code CLI, and VSCode Copilot instructions
8. **Symlink creation**: Creates symlinks for dotfiles (`.zshrc`, `.zprofile`, `.aliases`, `.private`, `.p10k.zsh`)

### Pixi Global Environment

A comprehensive set of development tools installed via pixi (see `settings/pixi-global.toml`):

### Git Enhancements

- **difftastic**: Enhanced diff tool with syntax-aware diffs
- **pre-commit**: Automatically enabled on cloned repos via git template directory
- **autoSetupRemote**: Automatically sets up remote tracking branches

### Claude Configuration

- Claude Desktop configuration synced from `settings/claude/`
- Claude Code CLI settings synced from `settings/claude/`
- VSCode Copilot instructions

## Configuration Files

- `.zshrc`: Zsh shell configuration with oh-my-zsh, plugins, PATH updates, completions, and custom functions
- `.zprofile`: Initializes Homebrew shell environment
- `.aliases`: Aliases for common commands
- `.private`: Local file for private information (not tracked in git)
- `.p10k.zsh`: Powerlevel10k theme configuration
- `settings/`: Directory containing settings for VS Code, Moom, Terminal, Claude, pixi global environment, etc.

## Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences. Here are some tips for customization:

### Key Files to Customize

- **brew.sh**: Edit the `packages` and `apps` arrays to add/remove formulae and casks
- **settings/pixi-global.toml**: Add or remove global development tools managed by pixi
- **settings/VSCode-Settings.json**: Customize VS Code editor preferences
- **settings/claude/**: Customize Claude Desktop, Claude Code, and Copilot configurations
- **.zshrc**: Add custom shell configurations, functions, or aliases
- **.aliases**: Add your own command aliases

## Features

### Admin Rights Handling

The installation script detects whether you have administrator rights and adapts accordingly:

- With admin rights: Full installation including apps and system modifications
- Without admin rights: Configuration-only mode (requires pre-installed tools)

### Idempotent Scripts

Most scripts are designed to be run multiple times safely:

- Checks for existing installations before installing
- Preserves existing git configuration (name/email)
- Creates backups before overwriting files

## Post-Installation Manual Steps

After running `install.sh`, complete these manual configuration steps:

### 1. Terminal Profile

- Open Terminal.app
- Go to Terminal → Settings → Profiles
- Import the profile: `~/dotfiles/settings/DEC.terminal`
- Set it as the default profile

### 2. Raycast Configuration

- Open System Settings → Keyboard → Keyboard Shortcuts → Spotlight
- Change Spotlight shortcut from `⌘Space` to `⌥Space`
- Launch Raycast and set its shortcut to `⌘Space`
- Import Raycast settings from your private backup (contains API keys)
  - Raycast → Settings → Advanced → Import Settings

### 3. VS Code Extensions Login

- Open VS Code (should auto-launch from `vscode.sh`)
- Sign in to extensions that require authentication:
  - GitHub Copilot
  - GitLens (optional)
  - Grammarly (optional)

### 4. Restart Claude Desktop

After the installation completes, **restart Claude Desktop** for the MCP servers to be recognized. The MCP servers are installed automatically by `claude.sh`, but Claude Desktop needs to be restarted to detect them.

You can verify MCP servers are connected by opening Claude Desktop → Settings → MCP Servers.

### 5. Verify Installation

Run these commands to verify everything is set up correctly:

```bash
# Check shell
echo $SHELL  # Should be /opt/homebrew/bin/zsh

# Check git config
git config --global --get push.autoSetupRemote  # Should be "true"
git config --global --get init.defaultBranch     # Should be "main"

# Check pixi global tools
pixi global list

# Check Claude settings
cat ~/.claude/settings.json | jq '.model'  # Should be "opus"

# Check Claude Desktop MCP servers (after restart)
# Open Claude Desktop and verify MCP servers are connected in settings
```

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome, but as said above, I likely won't accept pull requests that simply add additional brew installations or change some settings unless they align with my personal preferences.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- I forked this from [Corey Schafer's dotfiles](https://github.com/CoreyMSchafer/dotfiles), who originally forked this from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles). And I recently added recommendations from [Jacob Hurlburt's dotfiles](https://github.com/jthurlburt/dotfiles)
- Thanks to all the open-source projects used in this setup.
