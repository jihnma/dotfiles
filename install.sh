#!/usr/bin/env zsh

if [ "${SHELL##/*/}" != "zsh" ]; then
  echo "Error: You might need to change default shell to zsh: chsh -s /bin/zsh"
  exit 1
fi

function clone_repository() {
  local repo_url="https://github.com/jihnma/dotfiles.git"
  local target_dir="$HOME/dotfiles"

  if [ -d "$target_dir" ]; then
    if [ -d "$target_dir/.git" ]; then
      local current_remote
      current_remote=$(cd "$target_dir" && git remote get-url origin 2>/dev/null)
      
      if [ "$current_remote" = "$repo_url" ]; then
        return 0
      else
        cleanup
        printf "Error: Different repository exists at $target_dir\n"
        printf "Expected: $repo_url\n"
        printf "Found: $current_remote\n"
        exit 1
      fi
    fi
  fi

  git clone "$repo_url" "$target_dir" >/dev/null 2>&1
}

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
      brew install "$formula" >/dev/null 2>&1
    fi
  done < "$brew_file"

  # Install cask packages
  while IFS= read -r formula; do
    if [[ ! " ${installed_casks[@]} " =~ " ${formula} " ]]; then
      brew install --cask "$formula" >/dev/null 2>&1
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

# Define spinner animation characters
readonly SPINNER=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

# Initialize screen buffer with installation UI
setup_screen() {
    printf "\033[2J\033[H"  # Clear screen and move cursor home
    printf "╭──────────────────────────────────╮\n"
    printf "│                                  │\n"
    printf "│  ○ Dotfiles installation         │\n"
    printf "│                                  │\n"
    printf "│                                  │\n"
    printf "╰──────────────────────────────────╯\n"
}

function cleanup() {
    # Clear current line
    printf "\033[2K"
    
    # Show cursor
    printf "\033[?25h"
    
    # Display final state cleanly
    printf "\033[4;1H│  ■ Installation interrupted!     │"
    printf "\033[5;1H│                                  │"
    printf "\033[6;1H╰──────────────────────────────────╯"
    printf "\033[7;1H"
}

update_status() {
    local message=$1
    local command=$2
    local args=("${@:3}")

    if [ -t 1 ] && [ -t 2 ]; then
        # Hide cursor
        printf "\033[?25l"
        printf "\033[4;1H│  ⋯ %-28s" "$message"
        
        # Execute in background
        $command "${args[@]}" &
        local pid=$!
        
        # Save original INT handler
        trap 'kill $pid 2>/dev/null; cleanup; printf "Installation was interrupted.\n"; exit 1' INT
        
        # Spinner animation
        local i=0
        while kill -0 $pid 2>/dev/null; do
            printf "\033[4;1H│  ${SPINNER[i]} %-28s" "$message"
            i=$(( (i + 1) % 8 ))
            sleep 0.1
        done
        
        # Restore original INT handler
        trap cleanup INT
        
        # Check result
        wait $pid
        local result=$?
        
        # Show cursor
        printf "\033[?25h"
        
        if [ $result -eq 0 ]; then
            printf "\033[4;1H│  ✓ %-28s" "$message"
        else
            # Execute original process on error (cleanup is called by caller)
            return $result
        fi
    else
        $command "${args[@]}" || {
            echo "Installation was interrupted."
            exit 1
        }
    fi
}

main() {
  # if [ -t 0 ]; then
  #   stty -echoctl
  # fi
  
  setup_screen

  # Check if running in terminal
  if [ -t 1 ] && [ -t 2 ]; then
    # Only handle stty and cursor settings in terminal
    # stty -echoctl
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
  update_status "Initializing..." clone_repository || exit 1  # Exit on error

  local dotfiles_dir=$HOME/dotfiles
  cd $dotfiles_dir || exit 1

  update_status "Checking for conflicts..." sleep 1 || exit 1
  update_status "Homebrew..." install_homebrew || exit 1
  update_status "Homebrew formulae..." install_homebrew_formulae ".list_brew" ".list_brewcask" || exit 1
  update_status "Installing Rust..." install_rust || exit 1
  update_status "Creating symlinks..." add_symbolic_links || exit 1

  mise trust ~/.config/mise/config.toml -q

  update_status "Installing dotfiles..." sleep 1 || exit 1

  # Display completion message
  if [ -t 1 ] && [ -t 2 ]; then
    printf "\033[4;1H│  ● Installation completed!"
    printf "\033[7;1H"
  fi
  echo "Dotfiles have been successfully installed."
}

main
