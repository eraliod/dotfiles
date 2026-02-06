#!/usr/bin/env zsh

if [ $admin_response = 'Y' ]; then
    xcode-select --install

    echo "Complete the installation of Xcode Command Line Tools before proceeding."
    echo "Press enter to continue..."
    read
else
    echo "Skipping Xcode Command Line Tools installation (requires admin rights)."
    echo "Please ensure Xcode Command Line Tools are already installed."
    echo "Press enter to continue..."
    read
fi

# Configure macOS Dock
if [ $admin_response = 'Y' ]; then
    print -P "%F{yellow}Would you like to remove all default icons from the macOS dock? (y/n)%f "
    read kill_dock
    if [ ${kill_dock:u} = 'Y' ]; then
        defaults write com.apple.dock persistent-apps -array ""
        killall Dock
        echo "Dock cleared successfully."
    fi
fi
