#
# ~/.bashrc
#
# If not running interactively, don't do anything
#[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
#alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '

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
alias vi='nvim'
alias vim='nvim'




### NVIDIA ENVIRONMENT VARIABLES ###

# Disable fallback drivers that conflict with NVIDIA (Wayland + KDE-specific)
export KDE_NO_GALLIUM=1
export KWIN_DRM_NO_VAAPI=1

# Force NVIDIA as the Wayland renderer
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# Hardware acceleration for media
export VDPAU_DRIVER=nvidia
export LIBVA_DRIVER_NAME=nvidia

# PRIME offloading (for hybrid GPU setups — optional if desktop with single GPU)
export DRI_PRIME=1
export __NV_PRIME_RENDER_OFFLOAD=1
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0  # Only if you're sure this is the correct provider

# NVIDIA GL rendering behavior
export __GL_YIELD="USLEEP"             # Lower latency
export __GL_SYNC_TO_VBLANK="1"         # Sync to monitor refresh rate

# GTK + QT Theming Harmony
export GTK_THEME=Sweet-Amber
export XCURSOR_THEME=Tela
