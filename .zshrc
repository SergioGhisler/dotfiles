# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

export PATH=~/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git vi-mode)
plugins=(git)
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
source $ZSH/oh-my-zsh.sh

eval "$(oh-my-posh init zsh --config ~/.oh-my-posh/catppuccin.omp.json)"

# source ~/.config/tmux/tmux_auto.sh
# alias tmux="tmux_auto"
fzf_projects() {
  zle -I
  zle reset-prompt
  ~/.config/scripts/tmux-fzf-project.sh
}

zle -N fzf_projects
bindkey -r '^F'
bindkey '^F' fzf_projects

# Path to my stubs (Python stubs)
export VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
export VI_MODE_SET_CURSOR=true
export KEYTIMEOUT=1

export PATH="$HOME/Documents/projects/texpresso/build:$PATH"

export PYTHONPATH="$PYTHONPATH:/Users/sergioghislergomez/.config/nvim/stubs"
export PYTHONPATH="$PYTHONPATH:/Users/sergioghislergomez/.config/nvim/stubs/pandas"
export PYTHONPATH="$PYTHONPATH:/Users/sergioghislergomez/.config/nvim/stubs/django"
export EDITOR="nvim"
export VISUAL="nvim"

port-info() {
  if [ -z "$1" ]; then
    echo "Usage: port-info <port>"
    return 1
  fi
  lsof -i :"$1"
}

port-kill() {
  if [ -z "$1" ]; then
    echo "Usage: kill-port <port>"
    return 1
  fi
  local pid
  pid=$(lsof -ti :"$1")
  if [ -n "$pid" ]; then
    echo "Killing process $pid on port $1"
    kill -9 $pid
  else
    echo "No process found on port $1"
  fi
}

alias oo='cd $HOME/library/Mobile\ Documents/iCloud~md~obsidian/Documents/Gigi'



export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

. "$HOME/.local/bin/env"

