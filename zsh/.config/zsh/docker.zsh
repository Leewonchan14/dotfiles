source <(docker completion zsh)

alias dc='docker compose'
alias dcl='docker compose logs -f --tail 100'
alias dcu='docker compose up -d'
alias dcr='docker compose restart'
alias dce='docker compose exec -it'
alias dsta='docker ps -q | xargs --no-run-if-empty docker stop'
alias dcsta="dc ps -q | xargs --no-run-if-empty docker stop"
