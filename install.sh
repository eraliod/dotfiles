#!/usr/bin/env zsh
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up VS Code
############################

# The first step is to check if the user has admin rights.
# Often with work computers one may not have sudo rights and parts of this script will fail
# If the user answers no, applications cannot be installed through the script and they will
# have to be installed manually or through whatever MDM system (ex. Kandji) or process IT makes available
while true; do
    print -P "%F{yellow}Do you have sudo rights on this machine / are you an administrator? (y/n)%f "
    read admin_response
    admin_response=${admin_response:u}
    if [ ${admin_response} = 'Y' ]; then
        break
    elif [ ${admin_response} = 'N' ]; then
        print -P "Without administrator rights, this script can still be used to configure settings.
But user must first install applications. At minimum %F{green}xcode command line tools%f, %F{green}visual studio code%f, and %F{green}homebrew%f
Please install those applications and re-run the script.
%F{red}!!!%f%F{yellow}On the next run, use the hidden option 'c' to continue installation without admin rights%f%F{red}!!!%f

Press ENTER to exit"
        read
        exit
    elif [ ${admin_response} = 'Q' ]; then
        exit
    elif [ ${admin_response} = 'C' ]; then
        echo "Continuing without admin rights"
        break
    else
        echo "Please write 'y' or 'n'. Or 'q' to quit"
    fi
done

export admin_response

# Run the MacOS Script
./macOS.sh

# Run the Homebrew Script
./brew.sh

# Run the pixi Script
./pixi.sh

# Run the Git configuration Script
./git.sh

# Run the ohmyzsh Script
./ohmyzsh.sh

# Run VS Code Script
./vscode.sh

# Run Claude configuration Script
./claude.sh

# dotfiles directory
dotfiledir="${HOME}/dotfiles"

# list of files/folders to symlink in ${homedir}
files=(zshrc zprofile aliases private p10k.zsh)

# change to the dotfiles directory
echo "Changing to the ${dotfiledir} directory"
cd "${dotfiledir}" || exit

# backup the files into a dotfiles_backup directory if they exist
mkdir -p ~/dotfiles_backup
for file in "${files[@]}"; do
    if [ -f "${HOME}/.${file}" ]; then
        echo "Backing up ${file}"
        mv "${HOME}/.${file}" "${HOME}/dotfiles_backup/.${file}"
    fi
done

# create symlinks (will overwrite old dotfiles)
for file in "${files[@]}"; do
    echo "Creating symlink to $file in home directory."
    ln -sf "${dotfiledir}/.${file}" "${HOME}/.${file}"
done

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "📋 POST-INSTALLATION MANUAL STEPS:"
echo ""
echo "Please complete the following manual configuration steps:"
echo "  1. Set Terminal default profile (DEC.terminal)"
echo "  2. Configure Raycast keyboard shortcut (⌘Space)"
echo "  3. Sign in to VS Code extensions (Copilot, GitLens, etc.)"
echo ""
echo "For detailed instructions, see the 'Post-Installation Manual Steps'"
echo "section in the README: ${dotfiledir}/README.md"
echo ""
