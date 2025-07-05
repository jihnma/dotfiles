# dotfiles

My macOS setup for a fast and productive development environment.

> [!WARNING]
> Feel free to use these files, but do so at your own risk.

## Quick Start

### 1. Install Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Install 1Password if you need it:

```sh
brew install --cask 1password
```

### 2. Clone this repo

```sh
git clone https://github.com/jihnma/dotfiles.git && cd dotfiles
```

### 3. Install packages

```sh
sort brew | xargs brew install
sort brewcask | xargs brew install --cask
```

### 4. Link dotfiles

```sh
stow .
```

To unlink:

```sh
stow -D .
```

### 5. Setup your Git local config

Edit the file as needed to match your own project folder paths and user settings.

```sh
cp ~/dotfiles/dot-gitconfig.local ~/.gitconfig.local
```

## Next Steps: Git & 1Password SSH Multi-Account

Set up **multiple Git user profiles with 1Password SSH signing**
by following this guide:

> [!NOTE]
> [Git Multi-User + 1Password SSH Signing Setup](https://gist.github.com/jihnma/0ddc2a81bbe6cb10e2708693c21e7c8d)

**What to do:**

* Edit your `.gitconfig*` and `.ssh/config` as shown in the gist.
* Use 1Password for SSH key management.
* All required configs and copy-paste instructions are in the guide.


That’s it!
To remove your dotfiles, run `stow -D .` again.
