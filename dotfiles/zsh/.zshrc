export ZSH="/home/chris/.oh-my-zsh"
ZSH_THEME=""

# Plugins
plugins=(
  git
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
  colored-man-pages
)
source $ZSH/oh-my-zsh.sh

# Optional CLI tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Prompt styling
#autoload -U colors && colors
#PS1="%{$fg[lightblue]%}%n@%m %{$fg[lightblue]%}%~ %{$reset_color%}$ "

# Terminal colors
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='di=38;5;33:fi=38;5;39:ln=38;5;37'
export LESS='-R'

# History size
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Editor
export EDITOR="nvim"

# Aliases
alias vi='nvim'
alias vim='nvim'
alias reload='exec zsh'
alias sudo="sudo -E"
alias copy='wl-copy'
alias paste='wl-paste'
alias ls='exa --icons --group-directories-first'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias update="sudo pacman -Syu && yay -Syu"
alias ffx='MOZ_ENABLE_WAYLAND=1 firefox --profile ~/.mozilla/firefox/b2s53f9w.default-release'

# Completion system
autoload -Uz compinit
compinit

# Load all modular Zsh config files from ~/.zshrc.d/
for config in ~/.zshrc.d/*.zsh(N); do
  source "$config"
done

### NVIDIA ENVIRONMENT VARIABLES ###

export KDE_NO_GALLIUM=1
export KWIN_DRM_NO_VAAPI=1
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export VDPAU_DRIVER=nvidia
export LIBVA_DRIVER_NAME=nvidia
export DRI_PRIME=1
export __NV_PRIME_RENDER_OFFLOAD=1
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
export __GL_YIELD="USLEEP"
export __GL_SYNC_TO_VBLANK="1"
export GTK_THEME=Sweet-Amber
export XCURSOR_THEME=Tela
export PATH="$HOME/.local/bin:$PATH"
