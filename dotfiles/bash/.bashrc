# ~/.bashrc - GhostKellz Edition

# ── Prompt ─────────────────────────────────────────────────────────────
# Initialize Starship if available
if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi

# ── Terminal Prompt Colors ─────────────────────────────────────────────
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='di=38;5;33:fi=38;5;39:ln=38;5;37'

# ── Editor ─────────────────────────────────────────────────────────────
export EDITOR="nvim"

# ── History ────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
PROMPT_COMMAND="history -a"

# ── Aliases ────────────────────────────────────────────────────────────
alias vi='nvim'
alias vim='nvim'
alias ls='exa --icons --group-directories-first'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias reload='exec bash'
alias sudo='sudo -E'
alias copy='wl-copy'
alias paste='wl-paste'
alias update='sudo pacman -Syu && yay -Syu'
alias ffx='MOZ_ENABLE_WAYLAND=1 firefox --profile ~/.mozilla/firefox/b2s53f9w.default-release'
# New: Show hidden dotfiles quickly
alias dotls='exa -a --icons --group-directories-first'
alias dotfiles='exa -d .[^.]*'

# ── Optional Tools ─────────────────────────────────────────────────────
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init bash)"
fi

if [ -f ~/.fzf.bash ]; then
  source ~/.fzf.bash
fi

# ── NVIDIA Environment Variables ───────────────────────────────────────
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

# ── GTK / Theme Tweaks ─────────────────────────────────────────────────
export GTK_THEME=Sweet-Amber
export XCURSOR_THEME=Tela

# ── GPG / SSH ──────────────────────────────────────────────────────────
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh

# ── Path ───────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

