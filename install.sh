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

check_uninstalled_packages() {
  local list_file=$1

  comm -23 <(sort "$list_file") <(brew list -1 | sort)
}

install_homebrew_packages() {
  cd "$dotfiles_dir"

  packages=(
    "brew/brewlist brew install"
    "brew/brewcasklist brew install -q --cask"
  )

  for package in "${packages[@]}"; do
    read -r list_file install_cmd <<< "$package"
    check_uninstalled_packages "$list_file" | xargs -L1 $install_cmd
  done
}

link_stow() {
  cd "$dotfiles_dir"

  cat stowlist | xargs -L1 stow --adopt
  git restore .
}

copy_gitconfig_local() {
  cd "$dotfiles_dir"

  local target_file="$HOME/.gitconfig.local"
  
  if [ ! -f "$target_file" ]; then
    cp git.local/.gitconfig.local "$target_file"
  fi
}

echo ""
echo "Starting Dotfiles Installation"

install_homebrew
clone_repository
install_homebrew_packages
link_stow
copy_gitconfig_local

echo "Dotfiles Installation Complete"
echo ""
