zstyle ':completion:*:git-checkout:*' sort false
# # set descriptions format to enable group support
# # NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# # set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# # preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

FD_EXCLUDE_FILES=(
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
  Library
)

# 2. 제외 목록을 바탕으로 fd 인자 배열 생성
FD_DEFAULT_ARGS=(--hidden --follow)
for item in $FD_EXCLUDE_FILES; do
  FD_DEFAULT_ARGS+=(--exclude "$item")
done

# export FZF_DEFAULT_OPTS='--wrap --preview "fzf-preview.sh {}" --bind "focus:transform-header:file --brief {}" --bind "ctrl-x:reload(fd --type f . $FD_DEFAULT_ARGS --exclude {q} && echo {q})+clear-query"'
export FZF_DEFAULT_OPTS='--ignore-case --wrap --preview "fzf-preview.sh {}" --bind "focus:transform-header:file --brief {}" --bind "ctrl-x:reload(fd --type f . $FD_DEFAULT_ARGS --exclude {q} && echo {q} >> .fzf_exclude)+clear-query"'

alias fdd='fd --type d ".*" $(pwd) $FD_DEFAULT_ARGS | fzf'
alias cdf='z $(fdd)'
# alias fdf='fd --type f ".*" $(pwd) $FD_DEFAULT_ARGS | fzf'
fdf() {
  fd --type f ".*" $(pwd) "${FD_DEFAULT_ARGS[@]}" | fzf
}

alias vif='vi $(fdf)'
alias hisf='print -z $(history | awk '\''{$1=""; sub(/^ /, ""); if (!seen[$0]++) print $0}'\'' | tail -r | fzf)'
alias psf='ps -eo pid,lstart,etime,command | awk '\''NR==1; NR>1 {print | "sort -k5M -k6 -k7"}'\'' | fzf | awk '\''{print $1}'\'''

fzf-history-selection() {
  local selected=$(history -E 1 | sed 's/^[ ]*[0-9]*[ ]*//' | sed 's/^.*[0-9]\{2\}:[0-9]\{2\}  //' |
    awk '!seen[$0]++' |
    fzf --query="$LBUFFER" \
      --layout=reverse \
      --ignore-case \
      --border)

  if [ -n "$selected" ]; then
    LBUFFER="$selected" # 선택한 명령어로 현재 줄을 교체
  fi
  zle reset-prompt
}

# 위젯 등록 및 단축키 바인딩 (예: CTRL-H)
zle -N fzf-history-selection
bindkey '^H' fzf-history-selection
