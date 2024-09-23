#!/usr/bin/env zsh

[ "${SHELL##/*/}" != "zsh" ] && echo "You might need to change default shell to zsh: `chsh -s /bin/zsh`"

function message() { 
  echo -e "\e[36m$1\e[m\n"
}

function clone_repository() {
  local repository_url="https://github.com/$1.git"
  git clone --depth 1 -q $repository_url
}

function add_symbolic_links() {
  cat .list_stow | xargs -L1 stow --adopt
  git restore .
}

function install_homebrew() {
  if ! command -v brew &>/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

function install_homebrew_formulae() {
  local formulae=$1
  local options=$2

  for formula in "${formulae[@]}"; do
    check_installed_formula "$formula" | xargs -L1 brew install $options
  done

}

function check_installed_formula() {
  local formula=$1
  comm -23 <(sort "$formula") <(brew list -1 | sort)
}

function install_rust() {
  if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"

    rustup self update
    rustup update
  fi
}

function uninstall_rust() {
  if ! command -v rustup >/dev/null 2>&1; then
    rustup self uninstall
  fi
}

function download_alacritty_theme() {
  local dest_file="$HOME/.config/alacritty/catppuccin-macchiato.toml"

  if [ ! -f "$dest_file" ]; then
    curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-macchiato.toml
  fi
}

function copy_gitconfig_local() {
  local dest_file="$HOME/.gitconfig.local"

  if [ ! -f "$dest_file" ]; then
    cp git/.gitconfig.local $dest_file
  fi
}

function main() {
  local dotfiles_dir=$HOME/dotfiles

  #
  clone_repository "jihnma/dotfiles"

  cd $dotfiles_dir
  
  #
  add_symbolic_links

  #
  install_homebrew

  #
  install_homebrew_formulae .list_brew
  install_homebrew_formulae .list_brewcask --cask

  #
  install_rust

  #
  download_alacritty_theme

  #
  copy_gitconfig_local
  
  # https://github.com/alacritty/alacritty/issues/4673#issuecomment-771291615
  xattr -rd com.apple.quarantine /Applications/Alacritty.app
}

main
