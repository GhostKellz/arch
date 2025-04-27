# 👻 Dotfiles

[![Zsh](https://img.shields.io/badge/Zsh-Shell-689E6E)](https://www.zsh.org/) [![Neovim](https://img.shields.io/badge/Neovim-Config-57A143)](https://neovim.io/) [![VSCode](https://img.shields.io/badge/VSCode-Editor-007ACC)](https://code.visualstudio.com/) [![WezTerm](https://img.shields.io/badge/WezTerm-Terminal-5E81AC)](https://wezfurlong.org/wezterm/) [![GPG](https://img.shields.io/badge/GPG-Keys-4E5D94)](https://gnupg.org/) [![Termius](https://img.shields.io/badge/Termius-SSH_Manager-00BFFF)](https://termius.com)

---

# 📚 Overview

This folder contains essential configuration files, notes, and quick references for setting up a full Ghost-powered Linux environment.

Optimized for:
- 🎯 Rapid rebuilding
- 🛡️ Secure SSH and GPG key management
- 🧠 Clean modular configs for terminal, editor, and shell

---

# 🔧 System Config Paths

- **Zsh config**: `~/.zshrc`
- **Bash config**: `~/.bashrc`
- **Starship prompt**: `~/.config/starship.toml`
- **WezTerm config**: `~/.config/wezterm/wezterm.lua`
  - WezTerm colors: `~/.config/wezterm/colors/*.toml`
- **Neovim config**: `~/.config/nvim/`
  - Main config: `~/.config/nvim/init.lua`
  - Plugins: `~/.config/nvim/lazy/lazy.nvim/`
  - Lockfile: `~/.config/nvim/lazy-lock.json`
- **Oh My Zsh**: `~/.oh-my-zsh/`
- **KDE global theme**: `~/.config/kdeglobals`
- **VSCode settings**: `~/.config/Code/User/settings.json`
- **SDDM themes**: `~/.local/share/sddm/themes/`
- **Termius SSH Manager** (Flatpak install): Key vault, SSH server profiles, and GPG key handling.

---

# 📦 Contents

- `.bashrc` — Bash aliases, environment tweaks.
- `.zshrc` — Zsh shell enhancements and plugins.
- `wezterm/` — WezTerm terminal emulator configuration.
- `starship.toml` — Cross-shell Starship prompt theming.
- `nvim/` — Full Neovim IDE setup using Lazy.nvim.

---

# 🎯 Purpose

- Centralize dotfiles for shells, editors, terminals.
- Manage SSH keys and GPG operations cleanly (via Termius + GPG).
- Rebuild Arch environments with minimal downtime.
- Maintain flexibility across laptops, desktops, and cloud workstations.

> 🌀 Ghost-Touched. Minimalist, modular, and always future-ready.

---
