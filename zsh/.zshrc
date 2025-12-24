#!/bin/zsh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# zmodload zsh/zprof

# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
# === Kiro CLI pre block. Keep at the top of this file. end ===

autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
  compinit
else
  compinit -C
fi

bindkey "^a" vi-beginning-of-line
bindkey "^e" vi-end-of-line

# HISTTIMEFORMAT
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S |"

# export PAGER='nvim -R'
export PAGER='less -R'
export MANPAGER='nvim +Man!'

export PATH=/opt/homebrew/bin:$PATH

# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export UPDATE_ZSH_DAYS=13 # 13일마다 한 번만 확인

# ZSH_THEME="robbyrussell"

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

source <(docker completion zsh)
source $ZSH/oh-my-zsh.sh

# === nvm (Lazy Loading) ===

FIRST_LOAD=true
nvm_load() {
  unset -f nvm node npm npx
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

  if [[ $FIRST_LOAD == true ]]; then
    if [[ -f ".nvmrc" ]]; then
      # .nvmrc 파일의 내용을 읽어 버전 확인
      NVM_VERSION=$(cat .nvmrc)

      # nvm이 설치되어 있고, 해당 버전이 유효한지 확인
      if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        #echo
        echo $NVM_VERSION

        # 'nvm use' 명령어를 실행
        nvm use
      fi
      FIRST_LOAD=false
    fi
  fi
}

nvm() {
  nvm_load && nvm "$@"
}

node() {
  nvm_load && node "$@"
}

npm() {
  nvm_load && npm "$@"
}

npx() {
  nvm_load && npx "$@"
}

# === nvm end ===

# === bun ===
[ -s "/Users/twoone14/.bun/_bun" ] && source "/Users/twoone14/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# === bun end ===

# === libpq (postgres) ===
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
# export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"
# === libpq (postgres) end ===

tmn() {
  ~/.tmux.new.sh
}
tma() {
  ~/.tmux.attach.sh
}

chain() {
  pid=$(psf)
  # 만약 아무것도 없다면 에러와 함께 종료
  if [ -z "$pid" ]; then
    echo "No process found"
    return 1
  fi
  while ps -p $pid >/dev/null; do
    sleep 1
  done
}

alias tm=tmux
alias tmksv="tm kill-server"
alias tmkss="tm kill-session"

eval "$(zoxide init zsh)"

FZF_EXCLUDE_FILES=(
  .git
  node_modules
  __pycache__
  venv\*
  .venv\*
  .vscode
  .cursor
  dist
  build
  .DS_Store
  .vim
  \*.hpp
  \*test\*
)

# 2. 제외 목록을 바탕으로 fd 인자 배열 생성
FZF_DEFAULT_ARGS=(--hidden --follow)
for item in $FZF_EXCLUDE_FILES; do
  FZF_DEFAULT_ARGS+=(--exclude "$item")
done
export XDG_CONFIG_HOME="$HOME/.config"

alias vi=nvim
alias claude="~/.claude/local/claude"
# zoxide edit
alias cdd=z # Space tab for search
alias fdd='fd --type d ".*" $(pwd) $FZF_DEFAULT_ARGS | fzf'
alias cdf='z $(fdd)'
alias fdf='fd --type f ".*" $(pwd) $FZF_DEFAULT_ARGS | fzf'
# alias hisf='eval "$(history | tail -r | fzf | xargs | awk '\''{$1=""; print $0}'\'')"'
alias hisf='print -z $(history | awk '\''{$1=""; sub(/^ /, ""); if (!seen[$0]++) print $0}'\'' | tail -r | fzf)'
alias his="hisf"
alias psf='ps -eo pid,lstart,etime,command | awk '\''NR==1; NR>1 {print | "sort -k5M -k6 -k7"}'\'' | fzf | awk '\''{print $1}'\'''
alias cursorf='cursor $(fdd)'
alias codef='code $(fdd)'
alias dc='docker compose'
alias dsta='docker ps -q | xargs --no-run-if-empty docker stop'
alias dcsta="dc ps -q | xargs --no-run-if-empty docker stop"
alias -g ex="exec -it"
alias slp='sleep'
alias vif='vi $(fdf)'
alias copy='pbcopy'
alias vim='vi'
alias anti='/Users/twoone14/.antigravity/antigravity/bin/antigravity'
qa() {
  pueue add "$@"
}
alias qs='pueue status'
alias ql='pueue log'

fk() {
  unset -f fk
  eval $(thefuck --alias fk)
  fk "$@"
}

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
# Kiro CLI post block. Keep at the bottom of this file.

setopt HIST_FIND_NO_DUPS

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
    . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
  else
    export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<

# zprof

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet


eval "$(mise activate zsh)"
