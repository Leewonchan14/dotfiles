#!/bin/zsh

# 시간 측정 방법 (아래 사이에 두기)
# zmodload zsh/zprof
# zprof

# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# export PAGER='nvim -R'
export PAGER='less -R'
export MANPAGER='nvim +Man!'

ZSH_CONF_DIR="$HOME/.config/zsh"

ZSH_CONF_LIST=(
  brew.zsh
  oh-my-zsh.zsh
  conda.zsh
  libpq.zsh
  tmux.zsh
  fzf.zsh
  docker.zsh
  zoxide.zsh
  # ===
  alias.zsh
  mise.zsh
  ollama.zsh
  bun.zsh
)

for conf in $ZSH_CONF_LIST; do
  source "$ZSH_CONF_DIR/$conf"
done

export EDITOR="code --wait"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
