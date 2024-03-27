#!/usr/bin/env zsh
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up VS Code
############################

# dotfiles directory
dotfiledir="${HOME}/dotfiles"

# list of files/folders to symlink in ${homedir}
files=(zshrc zprofile bashrc bash_profile bash_prompt aliases private p10k.zsh)

# backup the files into a dotfiles_backup directory if they exist
mkdir ~/dotfiles_backup
for file in "${files[@]}"; do
    if [ -f "${HOME}/.${file}" ]; then
        echo "Backing up ${file}"
        mv "${HOME}/.${file}" "${HOME}/dotfiles_backup/.${file}" 
    fi
done

# change to the dotfiles directory
echo "Changing to the ${dotfiledir} directory"
cd "${dotfiledir}" || exit

# create symlinks (will overwrite old dotfiles)
for file in "${files[@]}"; do
    echo "Creating symlink to $file in home directory."
    ln -sf "${dotfiledir}/.${file}" "${HOME}/.${file}"
done

# Run the MacOS Script
./macOS.sh

# Run the Homebrew Script
./brew.sh

# Run VS Code Script
./vscode.sh

echo "Installation Complete!"
