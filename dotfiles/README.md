# Dotfiles Reference

This folder is a placeholder for quick notes and links to essential config files. Helpful for locating where certain tools keep their settings on a typical Linux system.

### System Config Paths:

- **Zsh config**: `~/.zshrc`
- **Bash config**: `~/.bashrc`
- **Starship prompt**: `~/.config/starship.toml`
- **WezTerm config**: `~/.config/wezterm/wezterm.lua`
  - WezTerm colors: `~/.config/wezterm/colors/*.toml`
- **Neovim config**: `~/.config/nvim/`
  - Main config file: `~/.config/nvim/init.lua`
  - Lazy.nvim plugin manager: `~/.config/nvim/lazy/lazy.nvim/`
  - Lockfile: `~/.config/nvim/lazy-lock.json`
- **Oh My Zsh** (plugin framework): `~/.oh-my-zsh/`
- **KDE global theme**: `~/.config/kdeglobals`
- **VSCode settings**: `~/.config/Code/User/settings.json`
- **SDDM themes**: `~/.local/share/sddm/themes/`

---

## Contents

- `.bashrc` — Aliases, environment variables, and quality-of-life improvements for Bash users.
- `.zshrc` — Zsh-specific enhancements, prompt setup, and plugin definitions.
- `wezterm/` — Config directory for WezTerm terminal emulator.
- `starship.toml` — Prompt theming for Starship across shells.
- `nvim/` — Full Neovim config with Lazy.nvim-based plugin management.

---

## Purpose

This directory is meant to:

- Store frequently reused shell and tool config files
- Serve as a quick reference for rebuilding environments
- Act as a placeholder for future expansion (e.g., `~/.config` items, VSCode, KDE tweaks)

---
