source <(docker completion zsh)

alias dc='docker compose'
alias dsta='docker ps -q | xargs --no-run-if-empty docker stop'
alias dcsta="dc ps -q | xargs --no-run-if-empty docker stop"
alias -g ex="exec -it"
