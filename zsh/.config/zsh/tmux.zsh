bindkey "^a" vi-beginning-of-line
bindkey "^e" vi-end-of-line
# tmux escape-time: Escape 수신 후 시퀀스 완료를 기다리는 시간 (ms)
# 기본값 500ms. 10ms로 설정하면 Vim 등에서 ESC 입력 딜레이가 줄지만,
# macOS 한글(두벌식) IME 조합 중 방향키를 누를 때 IME가 preedit을
# commit할 시간이 부족해 조합 중인 글이 사라지거나 튀는 버그 발생.
# 500ms로 복원하여 IME가 안정적으로 동작하도록 함.
# 참고: https://github.com/tmux/tmux/issues/4543 (한글 Jamo 처리)
set -sg escape-time 500

# alias tm="tmux"
tm() {
  tmux new -s ${PWD##*/}
}
alias tma="tmux attach"
