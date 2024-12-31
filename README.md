# dotfiles

This repository is primarily for macOS systems and contains my personal dotfiles, designed to create an efficient development environment.

Feel free to use anything from these dotfiles, but do so at your own risk.

## Installation  

To apply the dotfiles to your system, follow these steps:  

### Clone the repository  

```sh
git clone git@github.com:jihnma/dotfiles.git
cd ~/dotfiles
```  

### Link using Stow  

```sh
stow .
```  

## Uninstallation  

To remove the dotfiles, follow these steps:  

### Unlink using Stow  

```sh
cd ~/dotfiles
stow -D .
```