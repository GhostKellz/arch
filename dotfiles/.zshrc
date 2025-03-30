export ZSH="/home/chris/.oh-my-zsh"
ZSH_THEME="jonathan"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
)
source $ZSH/oh-my-zsh.sh
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
alias copy='wl-copy'
alias paste='wl-paste'
export EDITOR="nvim"
alias ls='exa --icons --group-directories-first'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias update="sudo pacman -Syu && yay -Syu"
eval "$(starship init zsh)"

#enable colors in the terminal 
autoload -U colors && colors

# Set the prompt to use light blue
PS1="%{$fg[lightblue]%}%n@%m %{$fg[lightblue]%}%~ %{$reset_color%}$ "  # Customize prompt

# Set the terminal's LS_COLORS for directories and files
export LS_COLORS='di=38;5;33:fi=38;5;39:ln=38;5;37'

# Set the color for the prompt, making everything more "light blue"
autoload -U colors && colors

PS1="%{$fg[lightblue]%}%n@%m %{$fg[lightblue]%}%~ %{$reset_color%}$ "  # Set prompt colors

# Change the color for other outputs (like pacman and versioning)
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"

#Enable completion for zsh
autoload -Uz compinit
compinit

# Set correct path for sudo and allow commands without needing the full sudo password
alias sudo="sudo -E"

### NVIDIA SETTINGS #####
## Test Running a file: 
# mpv --vo=vappi --hwdec=vdpau  /home/chris/Videos/TestVid.mp4

# Disable Gallium driver for NVIDIA on Wayland
export KDE_NO_GALLIUM=1
export KWIN_DRM_NO_VAAPI=1

# Enable NVIDIA rendering via PRIME offloading (for multi-GPU setups)
export DRI_PRIME=1
export __NV_PRIME_RENDER_OFFLOAD=1

# VA-API & VDPAU (for hardware acceleration)
export VDPAU_DRIVER=nvidia
export LIBVA_DRIVER_NAME=nvidia

