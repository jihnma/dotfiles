#!/bin/bash

dotfiles_dir="$HOME/.files"
dotfiles_repository="https://github.com/jihnma/dotfiles.git"

clone_repository() {
  if [ ! -d "$dotfiles_dir" ]; then
    git clone --depth 1 -q "$dotfiles_repository" "$dotfiles_dir"
  else
    git -C "$dotfiles_dir" pull --quiet --rebase origin main || exit 1
  fi
}

install_homebrew() {
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

install_homebrew_packages() {
  cd "$dotfiles_dir"

  local list_file=$1
  local install_cmd=$2

  comm -23 <(sort "$list_file") <(brew list -1 | sort) | xargs -L1 $install_cmd
}

link_stow() {
  cd "$dotfiles_dir"

  cat stowlist | xargs -L1 stow --adopt
  git restore .
}

echo ""
echo "Starting Dotfiles Installation"

install_homebrew
clone_repository
install_homebrew_packages "brew/brewlist" "brew install"
install_homebrew_packages "brew/brewcasklist" "brew install -q --cask"

link_stow

echo "Dotfiles Installation Complete"
echo ""
