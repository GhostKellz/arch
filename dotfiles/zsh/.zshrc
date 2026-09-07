# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Keep inherited and tool-managed PATH entries unique across nested shells/tmux.
typeset -U path PATH

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
  zsh-completions
  zsh-history-substring-search
  colored-man-pages
)
source $ZSH/oh-my-zsh.sh

# ── CLI Tools ────────────────────────────────────────────────
eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(direnv hook zsh)"

# -- Claude 
# export PATH="$HOME/.nvm/versions/node/v20.19.2/bin:$PATH"
# --- Claude BashTool: run bash as NON-login shell (skip .bash_profile) ---
export CLAUDE_BASH_NO_LOGIN=1    # or "true"

# --- Bedrock / Vertex toggles: must be real booleans, not any string ---
# Use your tool’s actual var names; common patterns shown below.
# Set to exactly "true"/"false" (or 1/0). Anything else will be treated as false now.

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ── Terminal Appearance ─────────────────────────────────────
#export CLICOLOR=1
#export LSCOLORS="Gxfxcxdxbxegedabagacad"
#export LS_COLORS="$(vivid generate tokyonight-moon)"
export LS_COLORS="$(vivid generate ghost-hacker-blue)"
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
alias copy='wl-copy'
alias paste='wl-paste'
alias ls='eza --icons --group-directories-first'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias dotls='eza -a --icons --group-directories-first | grep "^\\."'
alias dotfiles='eza -a --icons --group-directories-first | grep "^\\."'
alias update='sudo pacman -Syu && yay -Sua'
alias ffx='MOZ_ENABLE_WAYLAND=1 firefox --profile ~/.mozilla/firefox/b2s53f9w.default-release'

# Battle.net
alias bnet='WINEPREFIX=~/.wine-bnet64 wine64 ~/.wine-bnet64/drive_c/Program\ Files\ \(x86\)/Battle.net/Battle.net.exe'


# ⚙️ Rebuild DKMS and initramfs manually
alias rebuild='echo "[+] Rebuilding DKMS modules..." && sudo dkms autoinstall && echo "[+] Regenerating initramfs..." && sudo mkinitcpio -P && echo "[+] Done ✅"'

# Fast restart of KWin (Wayland-safe)
krestart() {
  echo "[KWin] Reloading config and restarting Wayland compositor..."
  qdbus org.kde.KWin /KWin org.kde.KWin.reloadConfig
  kwin_wayland --replace & disown
}

# --- Update Mirrorlist with Reflector ---
alias mirrorlist="sudo reflector --country US --age 6 --protocol https --sort score --latest 20 --save /etc/pacman.d/mirrorlist && echo '✅ US mirrorlist updated (East Coast bias)'"
alias mirrorshow="sudo reflector --country US --age 6 --protocol https --sort score --latest 20 --save /etc/pacman.d/mirrorlist && echo '✅ Mirrors updated:' && head -n 12 /etc/pacman.d/mirrorlist"



# ── Git Aliases ─────────────────────────────────────────────
alias gcm='git commit -m'
alias gaa='git add .'
alias gps='git push origin main'
alias ghostinit="~/scripts/bootstrap-repo.zsh"
# ── GPG  ─────────────────────────────────────────────
alias gpgchk='gpg --locate-keys ckelley@ghostkellz.sh'

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

# ── Modular Zsh Config Loader ───────────────────────────────
for config in ~/.zshrc.d/*.zsh(N); do
  source "$config"
done

# NVIDIA session selection lives in /etc/environment. Keep app/game overrides
# scoped to their launchers so Vulkan and GLVND can discover every installed GPU.

# ── NVIDIA Digital Vibrance  ────────────────────────────
# nvctl vibrance takes 0-200 (100 = driver default / no boost).
# Replaced the old nvibrant wrapper scripts, which used a different 0-1023
# scale -- the numbers do not map 1:1, so tune these to taste.
alias vibe='nvctl vibrance'
alias vibe100='nvctl vibrance 100'
alias vibe150='nvctl vibrance 150'
alias vibe200='nvctl vibrance 200'


# ── GTK / Cursor Theme ──────────────────────────────────────
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

# ── Zsh Autocomplete ────────────────────────────────────────
if [[ -r /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]]; then
  source /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

# ─── Go Dev Environment  ────────────────────────────────────────────────
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH="$GOBIN:$PATH"

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
#export PATH="$HOME/.npm-global/bin:$PATH"
#export NODE_PATH="$HOME/.npm-global/lib/node_modules"

# --- Cuda Dev Environment -----------------------------------
# The Arch CUDA package supplies PATH and linker discovery through profile.d
# and ld.so.conf.d. CUDA_HOME remains for build systems that expect it.
export CUDA_HOME="${CUDA_PATH:-/opt/cuda}"

# ─── ccache  ────────────────────────────────────────────────
#export PATH="/usr/lib/ccache/bin:$PATH"
#export CC="ccache gcc"
#export CXX="ccache g++"

# ─── ghostty  ────────────────────────────────────────────────
# alias removed - Ghostty auto-reads from ~/.config/ghostty/config

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─── ghost Tech  ────────────────────────────────────────────────
alias forge="ghostforge"

# Resolve the external executable through PATH even when a same-named wrapper
# function exists. This supports pacman, npm --prefix ~/.local, and nvm installs
# without hardcoding one machine-specific path.
_agent_binary() {
  local binary
  binary="$(whence -p "$1")" || {
    print -u2 -- "$1 executable not found in PATH"
    return 127
  }
  print -r -- "$binary"
}

_agent_scoped() {
  local command_name="$1"
  local binary
  shift
  binary="$(_agent_binary "$command_name")" || return
  agent-scope "$binary" "$@"
}

_agent_unscoped() {
  local command_name="$1"
  local binary
  shift
  binary="$(_agent_binary "$command_name")" || return
  "$binary" "$@"
}

# Keep agentic workloads inside the aggregate memory boundary by default.
codex() { _agent_scoped codex "$@"; }
claude() { _agent_scoped claude "$@"; }
gemini() { _agent_scoped gemini "$@"; }

# Deliberate escape hatches for exceptional, actively monitored work.
codex-unscoped() { _agent_unscoped codex "$@"; }
claude-unscoped() { _agent_unscoped claude "$@"; }
gemini-unscoped() { _agent_unscoped gemini "$@"; }

# Fix stuck Battle.net / Proton-GE sessions (Wayland-safe)
bnet-fix() {
  echo "🔧 Fixing stuck Battle.net / Proton processes..."

  pkill -9 -f 'Battle.net.exe'      2>/dev/null
  pkill -9 -f 'Agent.exe'           2>/dev/null
  pkill -9 -f 'BlizzardBrowser'     2>/dev/null
  pkill -9 -f 'WoWClassic.exe'      2>/dev/null
  pkill -9 -f 'xalia.exe'           2>/dev/null
  pkill -9 -f 'wineserver'          2>/dev/null
  pkill -9 -f 'wine-preloader'      2>/dev/null

  echo "✅ Proton/Wine cleanup complete."
  echo "👉 Relaunch Battle.net from Steam."
}

# Must load after compinit and every plugin/widget that can modify the ZLE buffer.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[command]='fg=#7FFFD4'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#98ff98'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#98ff98'
ZSH_HIGHLIGHT_STYLES[function]='fg=#98ff98'
