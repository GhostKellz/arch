# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ── Oh My Zsh ───────────────────────────────────────────────
# ~/.zshrc - GhostKellz Edition

# ── Oh My Zsh ───────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# ── Plugins ─────────────────────────────────────────────────
plugins=(
  git
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
  colored-man-pages
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# ── CLI Tools ────────────────────────────────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(direnv hook zsh)"

# ── Terminal Appearance ─────────────────────────────────────
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='di=38;5;33:fi=38;5;39:ln=38;5;37'
export LESS='-R'
#ZSH_HIGHLIGHT_STYLES[command]='fg=#98ff98'
ZSH_HIGHLIGHT_STYLES[command]='fg=#7FFFD4'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#98ff98'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#98ff98'
ZSH_HIGHLIGHT_STYLES[function]='fg=#98ff98'

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
#alias update='sudo pacman -Syu && yay -Syu'
#alias update='sudo pacman -Syu --noconfirm && yay -Qua --devel --quiet'
alias update='sudo pacman -Syu --noconfirm && yay -Qua --quiet | grep -v "ignoring package upgrade"'
alias ffx='MOZ_ENABLE_WAYLAND=1 firefox --profile ~/.mozilla/firefox/b2s53f9w.default-release'

# Battle.net
alias bnet='WINEPREFIX=~/.wine-bnet64 wine64 ~/.wine-bnet64/drive_c/Program\ Files\ \(x86\)/Battle.net/Battle.net.exe'


# ⚙️ Rebuild DKMS and Initramfs (ernel)manually
alias rebuild='echo "[+] Rebuilding DKMS modules..." && sudo dkms autoinstall && echo "[+] Regenerating initramfs..." && sudo mkinitcpio -P && echo "[+] Done ✅"'
alias rebuild-test='echo "[TEST] Rebuilding DKMS modules..." && sudo dkms autoinstall && echo "[TEST] Regenerating initramfs..." && sudo mkinitcpio -P && echo "[TEST] Finished ✅"'

# ── Git Aliases ─────────────────────────────────────────────
alias gcm='git commit -m'
alias gaa='git add .'
alias gps='git push origin main'
alias ghostinit="~/scripts/bootstrap-repo.zsh"
# ── GPG  ─────────────────────────────────────────────
alias gpgchk='gpg --locate-keys ckelley@ghostkellz.sh'

[[ -z "$GPG_AGENT_INFO" ]] && export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket)"

# ── Network Aliases ───────────────────────────────────────
alias pgd='ping google.com'
alias p8='ping 8.8.8.8'
alias p1='ping 1.1.1.1'
alias digg='dig +nocmd +nocomments +noquestion +noauthority +noadditional'

alias dnscheck='dig +dnssec +multi'
alias dnstest='dig @1.1.1.1 google.com'
alias dnshit='dig @127.0.0.1 -p 53 example.com ANY'

alias dnsflush='sudo resolvectl flush-caches'
alias ns='nslookup'
alias tracer='traceroute'

alias myip='curl ifconfig.me'
alias localip="ip a | grep inet"
alias publicip='dig @resolver4.opendns.com myip.opendns.com +short'

alias portscan='nmap -Pn -p-'
alias sniff='sudo tcpdump -i any -n'

# ── Devtool Aliases ───────────────────────────────────────
alias actl='source $HOME/.venvs/lsp/bin/activate'
alias ra='rust-analyzer'
alias zigv='zig version'
alias godoc='go doc'
alias pyver='python --version'
alias activate-lsp='source ~/.venvs/lsp/bin/activate'
alias lspenvrc='echo "source ~/.venvs/lsp/bin/activate" > .envrc && direnv allow'

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

# ── NVIDIA Digital Vibrance  ────────────────────────────
echo "alias vibe60='~/.local/bin/vibrance-low.sh'" >> ~/.zshrc
echo "alias vibe100='~/.local/bin/vibrance-high.sh'" >> ~/.zshrc


# ── NVIDIA Vulkan Environment Variables ────────────────────────────
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d

# ── GTK / Cursor Theme ──────────────────────────────────────
export GTK_THEME=Sweet-Amber
export XCURSOR_THEME=Tela

# ── Gaming Environment ──────────────────────────────────────
export DXVK_ASYNC=1
export WINE_FULLSCREEN_FSR=1
export WINE_FULLSCREEN_FSR_STRENGTH=5
export __GL_GSYNC_ALLOWED=1
export __GL_VRR_ALLOWED=1
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_PATH="$HOME/.nv_shader_cache"
export STEAM_FORCE_DESKTOPUI_SCALING=1
export VKD3D_CONFIG=dxr11
export MANGOHUD=1

# ── Paths ───────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── GPG / SSH ───────────────────────────────────────────────
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh
export GPG_AGENT_INFO=

# ── Zsh Autocomplete ────────────────────────────────────────
if [[ -r /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]]; then
  source /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
  echo "%F{green}[zsh-autocomplete] loaded ✅%f"
fi

# ─── Go Dev Environment  ────────────────────────────────────────────────
# Go environment Variables
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
export PATH="$HOME/go/bin:$PATH"

# ─── Python Dev Environment  ────────────────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
unset VIRTUAL_ENV

# Silence direnv during prompt preload
if [[ -n "${POWERLEVEL9K_INSTANT_PROMPT}" ]]; then
  export DIRENV_LOG_FORMAT=
fi
# ─── Rust Dev Environment  ────────────────────────────────────────────────
export PATH="$HOME/.cargo/bin:$PATH"
export RUSTUP_HOME="$HOME/.rustup"
export CARGO_HOME="$HOME/.cargo"
export RUSTFLAGS="-C target-cpu=native"
[[ -r "${CARGO_HOME:-$HOME/.cargo}/env" ]] && source "${CARGO_HOME:-$HOME/.cargo}/env"

# ─── Zig Dev Environment  ────────────────────────────────────────────────
export PATH="$HOME/zls/zig-out/bin:$PATH"

# ─── Javascript Dev Environment  ────────────────────────────────────────────────
export PATH="$HOME/.npm-global/bin:$PATH"
export NODE_PATH="$HOME/.npm-global/lib/node_modules"

# ─── ccache  ────────────────────────────────────────────────
export PATH="/usr/lib/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"

# ─── ghostty  ────────────────────────────────────────────────
alias ghostty="ghostty --config ~/.config/ghostty/config.toml"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─── ghost Tech  ────────────────────────────────────────────────
alias forge="ghostforge"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
alias vibe60='~/.local/bin/vibrance-low.sh'
alias vibe100='~/.local/bin/vibrance-high.sh'
