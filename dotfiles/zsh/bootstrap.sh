#!/bin/bash

echo "[+] Installing essential packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm zsh starship zoxide fzf ripgrep fd bat exa wl-clipboard copyq neovim git unzip curl

echo "[+] Installing Nerd Fonts..."
yay -S --noconfirm nerd-fonts-jetbrains-mono nerd-fonts-fira-code

echo "[+] Setting Zsh as default shell..."
chsh -s /bin/zsh

echo "[+] Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

echo "[+] Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM}/plugins/zsh-history-substring-search

echo "[+] Writing .zshrc..."
cat > ~/.zshrc <<EOF
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
)
source \$ZSH/oh-my-zsh.sh
eval "\$(starship init zsh)"
eval "\$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
alias copy='wl-copy'
alias paste='wl-paste'
export EDITOR="nvim"
alias ls='exa --icons --group-directories-first'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias update="sudo pacman -Syu && yay -Syu"
EOF

echo "[+] Writing wezterm config..."
mkdir -p ~/.config/wezterm
cat > ~/.config/wezterm/wezterm.lua <<EOF
local wezterm = require 'wezterm'
return {
  color_scheme = "Catppuccin Mocha",
  enable_wayland = true,
  front_end = "WebGpu",
  font = wezterm.font_with_fallback {
    "JetBrainsMono Nerd Font",
    "FiraCode Nerd Font",
  },
  font_size = 13.0,
  default_prog = { "/bin/zsh" },
  window_background_opacity = 0.95,
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  keys = {
    { key = "v", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "s", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
  },
  window_padding = {
    left = 4,
    right = 4,
    top = 2,
    bottom = 2,
  },
}
EOF

echo "[+] Done! Reload your terminal or run: zsh"
