#!/usr/bin/env zsh

if ! command -v xcode-select &> /dev/null; then
    echo "Command Line Tools not installed. Installing..."
    xcode-select --install
else
    echo "Command Line Tools already installed."
fi

echo "Complete the installation of Xcode Command Line Tools before proceeding."
echo "Press enter to continue..."
read
