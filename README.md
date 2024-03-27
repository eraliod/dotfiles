# Development Environment Setup

This repository contains scripts and configuration files to set up a development environment for macOS. It's tailored for software development, focusing on a clean, minimal, and efficient setup.
I forked this idea from Corey Schafer, who has a great instructional YouTube Channel. He originally took configurations from Mathias Bynens.

## Overview

The setup includes automated scripts for installing essential software, configuring Bash and Zsh shells, and setting up Visual Studio Code. This guide will help you replicate my development environment on your machine if you desire to do so.

The zsh shell is set up as the default shell in the machine. It is augmented with oh-my-zsh, powerlevel10k theme, and the autosuggestions and syntax-highlighting plugins. This also requires a custom font for icons which will be downloaded by the scripts [Font Awesome terminal fonts](https://github.com/Homebrew/homebrew-cask-fonts/blob/master/Casks/font-awesome-terminal-fonts.rb)

## Important Note Before Installation

**WARNING:** The configurations and scripts in this repository are **HIGHLY PERSONALIZED** to my own preferences and workflows. If you decide to use them, please be aware that they will **MODIFY** your current system, potentially making some changes that are **IRREVERSIBLE** without a fresh installation of your operating system.

Furthermore, while I strive to backup files wherever possible, I cannot guarantee that all files are backed up. The backup mechanism is designed to backup SOME files **ONCE**. If the script is run more than once, the initial backups will be **OVERWRITTEN**, potentially resulting in loss of data. While I could implement timestamped backups to preserve multiple versions, this setup is optimized for my personal use, and a single backup suffices for me.

If you would like a development environment similar to mine, I highly encourage you to fork this repository and make your own personalized changes to these scripts instead of running them exactly as I have them written for myself.

If you choose to run these scripts, please do so with **EXTREME CAUTION**. It's recommended to review the scripts and understand the changes they will make to your system before proceeding.

By using these scripts, you acknowledge and accept the risk of potential data loss or system alteration. Proceed at your own risk.

## Getting Started

### Prerequisites

-  macOS (The scripts are tailored for macOS)

### Installation

1. Clone the repository to your local machine:
   ```sh
   git clone https://github.com/eraliod/dotfiles.git ~/dotfiles
   ```
2. Navigate to the `dotfiles` directory:
   ```sh
   cd ~/dotfiles
   ```
3. Run the installation script:
   ```sh
   ./install.sh
   ```

This script will:

-  Create symlinks for dotfiles (`.bashrc`, `.zshrc`, etc.)
-  Run macOS-specific configurations
-  Install Homebrew packages and casks
-  Configure Visual Studio Code

## Configuration Files

-  `.bashrc` & `.zshrc`: Shell configuration files for Bash and Zsh.
-  `.shared_prompt`: Custom prompt setup used by `.bash_prompt`
-  `.bash_prompt`: Custom prompt setup for Bash.
-  `.bash_profile: Setting system-wide environment variables.
-  `.aliases`: Aliases for common commands.
-  `.private`: This is a file you'll create locally to hold private information and shouldn't be uploaded to version control
-  `settings/`: Directory containing settings for tools such as Visual Studio Code, Moom, etc.

### Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences. Here are some tips for customization:

-  **Dotfiles**: Edit `.shared_prompt`, `.bash_prompt` to add or modify shell configurations.
-  **VS Code**: Adjust settings in the `settings/` directory to change editor preferences and themes.

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome, but as said above, I likely won't accept pull requests that simply add additional brew installations or change some settings unless they align with my personal preferences.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

-  I forked this from [Corey Schafer's dotfiles](https://github.com/CoreyMSchafer/dotfiles), who originally forked this from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
-  Thanks to all the open-source projects used in this setup.
