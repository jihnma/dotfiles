#!/bin/bash

dotfiles_dir="$HOME/.files"
dotfiles_repository="https://github.com/jihnma/dotfiles.git"

echo ""
echo "Starting Dotfiles Uninstallation"

# Uninstall each package listed in the 'stowlist' file using GNU Stow
# The '-D' flag tells Stow to remove the symlinks for each package
cat stowlist | xargs -L1 stow -D

echo "Dotfiles Uninstallation Complete"
echo ""
