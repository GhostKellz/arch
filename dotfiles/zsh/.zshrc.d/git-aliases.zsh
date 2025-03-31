# ~/.zshrc.d/git-aliases.zsh
# Git workflow aliases for quick commits, pushes, branching, and stash handling

# Add & commit
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit -am'

# Push / Pull
alias gp='git push'
alias gpl='git pull'

# Status & log
alias gs='git status'
alias gl='git log --oneline --graph --decorate'

# Branching
alias gco='git checkout'
alias gcb='git checkout -b'

# Stash
alias gst='git stash'
alias gsta='git stash apply'

# Cloning
alias gcl='git clone'
alias clone='git clone'  # shorthand version

# One-liner: Add, Commit, Push with message
alias gcp='f() { git add . && git commit -m "$1" && git push; }; f'

# Interactive Commit Message → Add, Commit, Push
alias gpush='f() { git add . && read -p "Commit message: " msg && git commit -m "$msg" && git push; }; f'

# Dotfile project shortcuts
alias dotpush='cd ~/dotfiles && git add . && read -p "Commit msg: " msg && git commit -m "$msg" && git push'
alias archpush='cd ~/arch && git add . && read -p "Commit msg: " msg && git commit -m "$msg" && git push'
