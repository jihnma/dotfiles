# Dotfiles

macOS configs, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Files are named `dot-zshrc`, `dot-config/…` and land as `~/.zshrc`, `~/.config/…`. That is stow's [`--dotfiles`](https://www.gnu.org/software/stow/manual/html_node/Invoking-Stow.html) mode, set in `.stowrc` together with `--no-folding`.

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
