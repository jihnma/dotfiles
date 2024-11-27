#!/usr/bin/env zsh

if [ "${SHELL##/*/}" != "zsh" ]; then
    echo "Error: You might need to change default shell to zsh: chsh -s /bin/zsh"
    exit 1
fi

REPO="https://github.com/jihnma/dotfiles.git"
DOTFILES="$HOME/dotfiles"

install_homebrew() {
    command -v brew &>/dev/null && return 0
    
    export NONINTERACTIVE=1
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sh || return 1
    
    [ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)" || return 1
    return 0
}

initialize_repository() {
    if [ ! -d "$DOTFILES/.git" ]; then
        git clone --depth 1 "$REPO" "$DOTFILES" >/dev/null 2>&1 || return 1
        cd "$DOTFILES" || return 1
        return 0
    fi

    cd "$DOTFILES" || return 1
    [ "$(git remote get-url origin 2>/dev/null)" != "$REPO" ] && {
        echo "Error: Repository mismatch at $DOTFILES"
        return 1
    }

    git pull --ff-only >/dev/null 2>&1
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

setup_alacritty_theme() {
    [ -f ~/.config/alacritty/catppuccin-macchiato.toml ] && return 0
    curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-macchiato.toml
}

setup_mise() {
    command -v mise >/dev/null 2>&1 && mise trust ~/.config/mise/config.toml -q
}

setup_rust() {
    command -v rustup >/dev/null 2>&1 && return 0
    
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1
    source $HOME/.cargo/env
    rustup self update >/dev/null 2>&1
    rustup update >/dev/null 2>&1
}

main() {
    echo "Starting installation..."

    install_homebrew
    initialize_repository 
    install_homebrew_packages
    setup_alacritty_theme
    setup_rust
    setup_mise
    create_symlinks

    echo "Installation completed successfully!"
}

main
