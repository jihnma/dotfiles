# dotfiles

This repository is primarily for macOS systems and contains my personal dotfiles, designed to create an efficient development environment.

Feel free to use anything from these dotfiles, but do so at your own risk.

## Installation  

To apply the dotfiles to your system, follow these steps:  

### Install Homebrew

First, ensure that Homebrew is installed on your system. If it's not installed, run the following command:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, configure your shell environment for Homebrew:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Clone the repository

```sh
git clone https://github.com/jihnma/dotfiles.git
```

### Install brew packages

The `brew` and `brewcask` files in the dotfiles directory contain lists of Homebrew formulae and casks that are essential for the development environment. To install these packages, use the following commands:

```sh
sort ~/dotfiles/brew | xargs brew install
sort ~/dotfiles/brewcask | xargs brew install --cask
```

### Link using Stow  

```sh
cd ~/dotfiles
stow .
```

### Install rust (Optional)

If you need Rust for your projects, install it using the following command:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y > /dev/null 2>&1
```

## Uninstallation  

To remove the dotfiles, follow these steps:  

### Unlink using Stow  

```sh
cd ~/dotfiles
stow -D .
```
