# Dotfiles

macOS configs, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```sh
brew install stow fzf gh helix mise zsh-abbr
brew install --cask aerospace ghostty

cd ~/dotfiles
stow .
```

`.zshrc` sources zsh-abbr, fzf and mise directly, so it fails on every shell start until those exist.

## Git identity

Kept out of this repo on purpose. `user.useConfigOnly = true` makes git refuse to commit until you supply one, so create `~/.config/git/config.local`:

```ini
[user]
	name = Your Name
	email = you@example.com
	signingkey = ~/.ssh/id_ed25519
[gpg]
	format = ssh
[gpg "ssh"]
	allowedSignersFile = ~/.config/git/allowed_signers
[commit]
	gpgsign = true
```

Commits are signed with a plain SSH key, no agent. `allowed_signers` holds one `email ssh-ed25519 AAAA…` line per signer and stays local as well.
