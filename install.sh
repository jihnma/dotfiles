#!/usr/bin/env zsh

if [ "${SHELL##/*/}" != "zsh" ]; then
    echo "Error: You might need to change default shell to zsh: chsh -s /bin/zsh"
    exit 1
fi

REPO="git@github.com:jihnma/dotfiles.git"
DOTFILES="$HOME/dotfiles"

install_kitty() {    
    if command kitty > /dev/null 2>&1; then 
        return 0 
    fi
    curl -L https://sw.kovidgoya.net/kitty/installer.sh | sh /dev/stdin
}

install_homebrew() {
    if command -v brew > /dev/null 2>&1; then 
        return 0 
    fi
    
    if ! sudo -v > /dev/null 2>&1; then
        echo "Error: Administrator privileges required for Homebrew installation"
        return 1
    fi
    
    export NONINTERACTIVE=1
    if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash -; then
        echo "Error: Homebrew installation failed"
        return 1
    fi
    
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        return 1
    fi
}

initialize_repository() {
    if [ ! -d "$DOTFILES/.git" ]; then
        git clone --depth 1 "$REPO" "$DOTFILES" > /dev/null 2>&1 || return 1
        cd "$DOTFILES" || return 1
        return 0
    fi

    cd "$DOTFILES" || return 1
    if [ "$(git remote get-url origin 2>/dev/null)" != "$REPO" ]; then
        echo "Error: Repository mismatch at $DOTFILES"
        return 1
    fi

    git pull --ff-only > /dev/null 2>&1
}

install_homebrew_packages() {
    cd "$DOTFILES" || return 1

    comm -23 <(sort .list_brew) <(brew list --formula | sort) | xargs brew install
    comm -23 <(sort .list_brewcask) <(brew list --cask | sort) | xargs brew install --cask
}

create_symlinks() {
    xargs -L1 stow --adopt < .list_stow
    git restore .
}

setup_mise() {
    command -v mise > /dev/null 2>&1 && mise trust ~/.config/mise/config.toml -q
    mise install
}

setup_rust() {
    command -v rustup > /dev/null 2>&1 && return 0
    
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y > /dev/null 2>&1
    source "$HOME/.cargo/env"
    rustup self update > /dev/null 2>&1
    rustup update > /dev/null 2>&1
}

main() {
    echo "Starting installation..."

    install_homebrew
    initialize_repository 
    install_homebrew_packages
    install_kitty
    create_symlinks
    setup_rust
    setup_mise
    source "$HOME/.zshrc"

    echo "Installation completed successfully!"
}

main
