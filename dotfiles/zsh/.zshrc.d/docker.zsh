# ~/.zshrc.d/docker.zsh
# Docker workflow helpers

alias d='docker'
alias dc='docker compose'

alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dv='docker volume ls'

alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'
alias dclean='docker system prune -af --volumes'

alias dlogs='docker logs -f'
alias dexec='docker exec -it'
alias denter='docker exec -it $1 bash'  # usage: denter container_id
