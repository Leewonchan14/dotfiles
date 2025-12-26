if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export UPDATE_ZSH_DAYS=13 # 13일마다 한 번만 확인

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet


autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
  compinit
else
  compinit -C
fi


plugins=(
  git
  # alias-finder
  # aliases
  # copypath
  # copyfile
  # colored-man-pages
  # zsh-vi-mode
  # globalias
  # dotenv
  # docker
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#663399,standout"

ZSH_THEME="powerlevel10k/powerlevel10k"

[[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]] && source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

source $ZSH/oh-my-zsh.sh

