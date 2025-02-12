# dotfiles

My macOS setup for a fast and productive development environment.

> [!WARNING]
> Feel free to use these files, but do so at your own risk.

## Quick Start

### 1. Install Homebrew [^1]

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, configure your shell environment for Homebrew:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

[^1]: https://brew.sh/

### 2. Clone This Repo

```sh
git clone https://github.com/jihnma/dotfiles.git && cd dotfiles  
```

### 3. Install brew packages

Install packages:

```sh
sort brew | xargs brew install
```

Install GUI apps:

```sh
sort brewcask | xargs brew install --cask
```

### 4. Install tmux plugins

Set up the tmux plugin manager for plugin management:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

After installing TPM, open your tmux session, then press `prefix` + <kbd> I </kbd> (capital 'i') to install plugins defined in the `tmux.conf` file.

### 5. Link Dotfiles

```sh
cd ~/dotfiles && stow .
```

### 6. Config git config

TODO

## Optional Steps

### Install Rust [^2]

If you need Rust for your projects, install it using the following command:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

[^2]: https://rustup.rs/

## Remove Dotfiles

To remove the dotfiles, follow these steps:  

```sh
cd ~/dotfiles && stow -D .
```
