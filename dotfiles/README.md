# 👻 Dotfiles

[![Zsh](https://img.shields.io/badge/Zsh-Shell-689E6E)](https://www.zsh.org/) 
[![Neovim](https://img.shields.io/badge/Neovim-Config-57A143)](https://neovim.io/) 
[![Starship](https://img.shields.io/badge/Starship-Prompt-DD00FF)](https://starship.rs/) 
[![Oh My Zsh](https://img.shields.io/badge/Oh_My_Zsh-Framework-3C3C3C)](https://ohmyz.sh/) 
[![WezTerm](https://img.shields.io/badge/WezTerm-Terminal-5E81AC)](https://wezfurlong.org/wezterm/) 
[![Ghostty](https://img.shields.io/badge/Ghostty-Terminal-7B68EE)](https://github.com/ghostty-org/ghostty) 
[![vivid](https://img.shields.io/badge/Vivid-Colors-F2B134)](https://github.com/sharkdp/vivid) 
[![tmux](https://img.shields.io/badge/tmux-Terminal_Muxer-33CC99)](https://github.com/tmux/tmux) 
[![GPG](https://img.shields.io/badge/GPG-Keys-4E5D94)](https://gnupg.org/) 
[![Termius](https://img.shields.io/badge/Termius-SSH_Manager-00BFFF)](https://termius.com)

---

# 📚 Overview

This folder contains essential configuration files, notes, and quick references for setting up a full Ghost-powered Linux environment.

Optimized for:

* 🎯 Rapid rebuilding
* 🛡️ Secure SSH and GPG key management
* 🧠 Clean modular configs for terminal, editor, and shell

---

# 🔧 System Config Paths

* **Zsh config**: `~/.zshrc`
* **Zsh Alis files** `~/.zshrc.d/`
* **Ghostty Shell** 👻: `~/.config/ghostty/ghostty.toml`
* **Starship prompt**: `~/.config/starship.toml`
* **WezTerm config**: `~/.config/wezterm/wezterm.lua`
  * WezTerm colors: `~/.config/wezterm/colors/*.toml`
* **Neovim config**: `~/.config/nvim/`
  * Main config: `~/.config/nvim/init.lua`
  * Plugins: `~/.config/nvim/lazy/lazy.nvim/`
  * Config: `~/.config/nvim/lua/config/*.lua`
  * Plugin modules: `~/.config/nvim/lua/plugins/*.lua`
  * Lockfile: `~/.config/nvim/lazy-lock.json`
* **Oh My Zsh**: `~/.oh-my-zsh/`
* **KDE global theme**: `~/.config/kdeglobals`
* **Powerlevel10k theme**: `~/.p10k.zsh`
* **VSCode settings**: `~/.config/Code/User/settings.json`
* **SDDM themes**: `~/.local/share/sddm/themes/`
* **vivid themes**: `~/.config/vivid/`
* **tmux config**: `~/.config/tmux/tmux.conf`
* **Termius SSH Manager** (Flatpak install): Key vault, SSH server profiles, and GPG key handling.

---

# 📦 Contents

* `.zshrc` — Zsh shell enhancements and plugins.
* `wezterm/` — WezTerm terminal emulator configuration.
* `ghostty/` — Ghostty configuration and ghost-themed terminal setup.
* `vivid/` — Theme overrides for ls and terminal color schemes.
* `starship.toml` — Cross-shell Starship prompt theming.
* `nvim/` — Full Neovim IDE setup using Lazy.nvim.
* `tmux/` — Terminal multiplexer configuration.

---

# 🎯 Purpose

* Centralize dotfiles for shells, editors, terminals.
* Manage SSH keys and GPG operations cleanly (via Termius + GPG).
* Rebuild Arch environments with minimal downtime.
* Maintain flexibility across laptops, desktops, and cloud workstations.

> 🌀 Ghost-Touched. Minimalist, modular, and always future-ready.

---

