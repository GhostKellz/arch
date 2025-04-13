
# ── Oh My Zsh ───────────────────────────────────────────────
# ~/.zshrc - GhostKellz Edition

# ── Oh My Zsh ───────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

# ── Plugins ─────────────────────────────────────────────────
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

# ── CLI Tools ────────────────────────────────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ── Terminal Appearance ─────────────────────────────────────
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='di=38;5;33:fi=38;5;39:ln=38;5;37'
export LESS='-R'

# ── History ─────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# ── Editor ──────────────────────────────────────────────────
export EDITOR="nvim"

# ── Aliases ─────────────────────────────────────────────────
alias vi='nvim'
alias vim='nvim'
alias reload='exec zsh'
alias sudo='sudo -E'
alias copy='wl-copy'
alias paste='wl-paste'
alias ls='exa --icons --group-directories-first'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias dotls='exa -a --icons --group-directories-first | grep "^\\."'
alias dotfiles='exa -a --icons --group-directories-first | grep "^\\."'
alias update='sudo pacman -Syu && yay -Syu'
alias ffx='MOZ_ENABLE_WAYLAND=1 firefox --profile ~/.mozilla/firefox/b2s53f9w.default-release'

# ── Git Aliases ─────────────────────────────────────────────
alias gcm='git commit -m'
alias gaa='git add .'
alias gps='git push origin main'

# ── GPG Aliases ─────────────────────────────────────────────
alias gpgchk='gpg --locate-keys ckelley@ghostkellz.sh'

# ── Completion System ───────────────────────────────────────
autoload -Uz compinit
compinit

# ── Modular Zsh Config Loader ───────────────────────────────
for config in ~/.zshrc.d/*.zsh(N); do
  source "$config"
done

# ── NVIDIA Environment Variables ────────────────────────────
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

# ── GTK / Cursor Theme ──────────────────────────────────────
export GTK_THEME=Sweet-Amber
export XCURSOR_THEME=Tela

# ── Paths ───────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── GPG / SSH ───────────────────────────────────────────────
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh
export GPG_AGENT_INFO=
