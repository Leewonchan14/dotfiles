# zmodload zsh/zprof

autoload -Uz compinit
compinit -C

bindkey "^a" vi-beginning-of-line
bindkey "^e" vi-end-of-line

# HISTTIMEFORMAT
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S |"

# export PAGER='nvim -R'
export PAGER='less -R'
export MANPAGER='nvim +Man!'

# === Amazon Q pre block. Keep at the top of this file. ===
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# === Amazon Q pre block. Keep at the top of this file. end ===

# If you come from bash you might have to change your $PATH.
export PATH=/opt/homebrew/bin:$PATH
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="robbyrussell"

plugins=(
  git
  alias-finder
  aliases
  copypath
  copyfile
  colored-man-pages
  # zsh-vi-mode
  # globalias
  # dotenv
  docker
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-better-npm-completion
)
source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

ZSH_THEME="powerlevel10k/powerlevel10k"
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
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

# === Amazon Q post block. Keep at the bottom of this file. ===
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
alias claude="~/.claude/local/claude"
# === Amazon Q post block. Keep at the bottom of this file. end ===

# >>> conda initialize (Lazy Loading) >>>
__conda_lazy_load() {
  unset -f conda
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
}

conda() {
  __conda_lazy_load
  conda "$@"
}
# <<< conda initialize <

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

zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes   # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes    # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes  # disabled by default

eval "$(zoxide init zsh)"

# zprof

export FZF_DEFAULT_COMMAND='fd ".*" ~ --hidden --follow --exclude .git'
export FZF_CURRENT_COMMAND='fd ".*" . --hidden --follow --exclude .git'

alias vi=nvim
alias cdd=z # Space tab for search
alias cdf='z $(fd '\''.*'\'' ~ --type d --hidden --follow --exclude .git | fzf)'
# alias hisf='eval "$(history | tail -r | fzf | xargs | awk '\''{$1=""; print $0}'\'')"'
alias hisf='print -z $(history | tail -r | fzf | xargs | awk '\''{$1=""; print $0}'\'' | cat)'
alias his='print -z $(history | tail -r | fzf | xargs | awk '\''{$1=""; print $0}'\'' | cat)'
alias psf='ps -eo pid,lstart,etime,command | awk '\''NR==1; NR>1 {print | "sort -k5M -k6 -k7"}'\'' | fzf | awk '\''{print $1}'\'''
alias cursorf='cursor $(eval $FZF_DEFAULT_COMMAND | fzf)'
alias codef='code $(eval $FZF_DEFAULT_COMMAND | fzf)'
alias dc='docker compose'
alias dsta='docker ps -q | xargs --no-run-if-empty docker stop'
alias dcsta="dc ps -q | xargs --no-run-if-empty docker stop"
alias -g ex="exec -it"
alias slp='sleep'
alias vif='vi $(eval $FZF_DEFAULT_COMMAND | fzf)'
alias vifc='vi $(eval $FZF_CURRENT_COMMAND| fzf)'
alias copy='pbcopy'
alias lzd='lazydocker'
alias vim='vi'

eval $(thefuck --alias fk)

eval $(thefuck --alias)

