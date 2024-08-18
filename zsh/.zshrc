export LANG=en_US.UTF-8
export EDITOR=hx

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(/opt/homebrew/bin/mise activate zsh)"

# Custom prompt
prompt_mark="%{%(?.%F{blue}.%F{red})%}ᘜ%F{red}ᘝ%f"

PROMPT="$prompt_mark "

# Alias
alias ls='ls -lrta --color=auto'
alias tx='tmux attach || tmux new'
