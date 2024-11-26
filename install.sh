#!/usr/bin/env zsh

if [ "${SHELL##/*/}" != "zsh" ]; then
  echo "Error: You might need to change default shell to zsh: chsh -s /bin/zsh"
  exit 1
fi

REPO="https://github.com/jihnma/dotfiles.git"
DOTFILES="$HOME/dotfiles"
SPINNER=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

install_homebrew() {
    if ! command -v brew &>/dev/null; then
        export NONINTERACTIVE=1
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sh || {
            echo "Error: Homebrew installation failed"
            return 1
        }
        
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo "Error: brew command not found after installation"
            return 1
        fi
    fi
}

generate_barcode_pattern() {
    local chars=("▌" "│" "█" "║")
    local pattern=""
    local width=30
    
    for ((i=0; i<width; i++)); do
        pattern+="${chars[$RANDOM % 4]}"
    done
    echo "$pattern"
}

setup_screen() {
    printf "\033[2J\033[H"
    printf "\033[?25l"
    
    local barcode=$(generate_barcode_pattern)
    
    printf "╭──────────────────────────────────╮\n"
    printf "│  %s  │\n" "$barcode"
    printf "│  %s  │\n" "$barcode"
    printf "│  %s  │\n" "$barcode"
    printf "╰──────────────────────────────────╯\n\n"
    
    local steps=(
        "Initialize repository"
        "Install Homebrew" 
        "Install Homebrew packages"
        "Setup Rust"
        "Create symlinks"
        "Setup mise"
    )
    local line=6
    for step in "${steps[@]}"; do
        printf "\033[%d;3H○  %s\n" "$line" "$step"
        ((line++))
    done
}

update_status() {
    local line=$1
    local message=$2
    local command=$3
    shift 3

    if [ -t 1 ] && [ -t 2 ]; then
        # 메시지 왼쪽 정렬을 위해 공백 추가
        printf "\033[%d;3H${SPINNER[0]}  %s" "$line" "$message"
        
        local temp_file=$(mktemp)
        $command "$@" > "$temp_file" 2>&1 &
        local pid=$!
        
        local i=0
        while kill -0 $pid 2>/dev/null; do
            printf "\033[%d;3H${SPINNER[i]}  %s" "$line" "$message"
            i=$(( (i + 1) % 8 ))
            sleep 0.1
        done
        
        wait $pid
        local result=$?
        
        if [ $result -eq 0 ]; then
            printf "\033[%d;3H●  %s" "$line" "$message"
            rm "$temp_file"
            return 0
        else
            printf "\033[%d;3H\033[31m■  %s\033[0m" "$line" "$message"
            printf "\033[11;1H\033[31mError: %s failed\033[0m" "$message"
            printf "\033[12;1H\033[31m%s\033[0m" "$(cat "$temp_file")"
            rm "$temp_file"
            return 1
        fi
    else
        echo "Installing: $message"
        $command "$@"
    fi
}

initialize_repository() {
    if [ ! -d "$DOTFILES" ] || [ ! -d "$DOTFILES/.git" ]; then
        git clone --depth 1 "$REPO" "$DOTFILES" >/dev/null 2>&1 || exit 1
        cd "$DOTFILES" || exit 1
        return 0
    fi

    cd "$DOTFILES" || exit 1
    local current_remote
    current_remote=$(git remote get-url origin 2>/dev/null)
    
    if [ "$current_remote" != "$REPO" ]; then
        echo "Error: Different repository exists at $DOTFILES"
        echo "Expected: $REPO" 
        echo "Found: $current_remote"
        exit 1
    fi

    git pull --ff-only >/dev/null 2>&1
    return 0
}

install_packages() {
    local installed_formulae=($(brew list --formula))
    local installed_casks=($(brew list --cask))

    while read -r formula; do
        if [[ ! " ${installed_formulae[@]} " =~ " ${formula} " ]]; then
            brew install $formula >/dev/null 2>&1
        fi
    done < .list_brew

    while read -r formula; do
        if [[ ! " ${installed_casks[@]} " =~ " ${formula} " ]]; then
            brew install --cask $formula >/dev/null 2>&1
        fi
    done < .list_brewcask
}

setup_rust() {
    if ! command -v rustup >/dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1
        source $HOME/.cargo/env
        rustup self update >/dev/null 2>&1
        rustup update >/dev/null 2>&1
    fi
}

create_symlinks() {
    xargs -L1 stow --adopt < .list_stow
    git restore .
}

setup_mise() {
    mise trust ~/.config/mise/config.toml -q
}

main() {
    if [ -t 1 ] && [ -t 2 ]; then
        setup_screen
        trap 'printf "\033[11;1H\033[31mInstallation cancelled\033[0m\n\033[?25h"; exit 1' INT
        trap 'printf "\033[?25h"' EXIT
    fi

    update_status 6 "Initialize repository" initialize_repository || exit 1
    update_status 7 "Install Homebrew" install_homebrew || exit 1
    update_status 8 "Install Homebrew packages" install_packages || exit 1
    update_status 9 "Setup Rust" setup_rust || exit 1
    update_status 10 "Create symlinks" create_symlinks || exit 1
    update_status 11 "Setup mise" setup_mise || exit 1

    if [ -t 1 ] && [ -t 2 ]; then
        printf "\033[13;1HInstallation completed!\n"
    fi
}

main
