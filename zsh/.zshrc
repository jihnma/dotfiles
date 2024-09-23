# export LANG=en_US.UTF-8
# export EDITOR=hx

# # If you're using macOS
# if [[ -f "/opt/homebrew/bin/brew" ]] then
#   eval "$(/opt/homebrew/bin/brew shellenv)"
#   eval "$(/opt/homebrew/bin/mise activate zsh)"
# fi

# # Set the directory we want to store zinit and plugins
# ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# # Download Zinit, if it's not there yet
# if [ ! -d "$ZINIT_HOME" ]; then
#    mkdir -p "$(dirname $ZINIT_HOME)"
#    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
# fi

# # Source/Load zinit
# source "${ZINIT_HOME}/zinit.zsh"

# # Add in zsh plugins
# zinit light zsh-users/zsh-syntax-highlighting

# # Load completions
# autoload -Uz compinit && compinit

# Prompt
prompt_mark="%{%(?.%F{yellow}.%F{red})%}%f"
PROMPT="$prompt_mark "
RPROMPT="%F{green}x %f"

# Aliases
alias ls='ls -l --color'
alias cat='bat'
alias clr='clear'
alias tx='tmux attach || tmux new'

# # Integrations
# eval "$(fzf --zsh)"
