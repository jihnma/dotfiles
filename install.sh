#!/usr/bin/env zsh

if [ "${SHELL##/*/}" != "zsh" ]; then
  echo "Error: You might need to change default shell to zsh: chsh -s /bin/zsh"
  exit 1
fi

function install_homebrew() {
  if ! command -v brew &>/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

function add_symbolic_links() {
  cat .list_stow | xargs -L1 stow --adopt
  # git restore .
}

function install_homebrew_formulae() {
  local brew_file=$1
  local cask_file=$2

  # Get list of installed packages in advance
  local installed_formulae=($(brew list --formula))
  local installed_casks=($(brew list --cask))

  # Install regular packages
  while IFS= read -r formula; do
    if [[ ! " ${installed_formulae[@]} " =~ " ${formula} " ]]; then
      brew install "$formula"
    fi
  done < "$brew_file"

  # Install cask packages
  while IFS= read -r formula; do
    if [[ ! " ${installed_casks[@]} " =~ " ${formula} " ]]; then
      brew install --cask "$formula"
    fi
  done < "$cask_file"
}

function install_rust() {
  if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"

    rustup self update
    rustup update
  fi
}

# Define constants at the beginning of the script
readonly SPINNER=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

# Initialize screen buffer
setup_screen() {
    printf "\033[2J\033[H"  # Clear screen and move cursor home
    printf "╭──────────────────────────────────╮\n"
    printf "│                                  │\n"
    printf "│  ○ Dotfiles installation         │\n"
    printf "│                                  │\n"
    printf "│                                  │\n"
    printf "╰──────────────────────────────────╯\n"
}

cleanup() {
    # Clear current line
    printf "\033[2K"
    
    # Show cursor
    printf "\033[?25h"
    
    # Display final state cleanly
    printf "\033[4;1H│  ■ Installation interrupted!     │"
    printf "\033[7;1H"  # Move below the box
    printf "Installation was interrupted.\n"
    exit 1
}

update_status() {
    local message=$1
    local command=$2
    local args=("${@:3}")
    local i=0

    # Hide cursor
    printf "\033[?25l"

    # Execute command in background
    $command "${args[@]}" &
    local pid=$!

    while kill -0 $pid 2>/dev/null; do
        # Update spinner and message at once
        printf "\033[4;1H│  %s %s%-$((26-${#message}))s " "${SPINNER[$i]}" "$message" " "
        
        (( i = (i + 1) % 8 ))
        sleep 0.1
    done

    wait $pid

    # Final display
    printf "\033[4;1H│   %-28s" "$message"

    # Show cursor again
    printf "\033[?25h"
}

main() {
  local dotfiles_dir=$HOME/dotfiles
  cd $dotfiles_dir

  # Suppress output during interruption
  stty -echoctl
  
  setup_screen

  # Check if running in terminal
  if [ -t 1 ] && [ -t 2 ]; then
    # Only handle stty and cursor settings in terminal
    stty -echoctl
    trap cleanup INT
    trap 'stty echoctl 2>/dev/null; printf "\033[?25h" 2>/dev/null' EXIT
  else
    # Use simplified output for pipes or redirections
    trap cleanup INT
    setup_screen() { :; }  # Ignore screen setup
    update_status() {
      local message=$1
      local command=$2
      local args=("${@:3}")
      echo "Installing: $message"
      $command "${args[@]}"
    }
  fi

  # Installation steps
  update_status "Initializing..." sleep 1
  update_status "Checking for conflicts..." sleep 1
  update_status "Homebrew..." install_homebrew
  update_status "Homebrew formulae..." install_homebrew_formulae ".list_brew" ".list_brewcask"
  update_status "Installing Rust..." install_rust
  update_status "Creating symlinks..." add_symbolic_links

  update_status "Installing dotfiles..." sleep 1

  # Simplify completion message
  if [ -t 1 ] && [ -t 2 ]; then
    printf "\033[4;1H│  ● Installation completed!"
    printf "\033[7;1H"
  fi
  echo "Dotfiles have been successfully installed."
}

main
