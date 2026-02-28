bindkey "^a" vi-beginning-of-line
bindkey "^e" vi-end-of-line
set -sg escape-time 10

# alias tm="tmux"
tm() {
  tmux new -s ${PWD##*/}
}
alias tma="tmux attach"
