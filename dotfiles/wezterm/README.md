# WezTerm

This directory contains the full configuration for WezTerm, featuring a custom hackerblue-inspired theme loosely based on Termius. It blends style and clarity for a modern terminal experience with vibrant colors and smooth contrasts.

---

## 🎨 Theme Overview

- **Color Scheme**: Catppuccin Mocha (customized)
- **Foreground**: Light hacker blue (`#57c7ff`)
- **Background**: Deep navy blue (`#0d1117`)
- **Cursor/Selection**: Contrasting blue highlights

The theme is tuned for visual clarity and comfort, using softened contrast while maintaining vibrant syntax highlighting.

---

## 🧠 Features

- Custom ANSI/bright color palette
- WezTerm GPU backend (WebGPU enabled)
- JetBrainsMono + FiraCode Nerd Fonts with fallback
- Minimal padding and blur
- Starship.toml prompt integration
- Zsh (Oh My Zsh) with autosuggestions and plugins
- Keybindings for split panes and clipboard actions

---

## 🗂 Directory Structure

```
dotfiles/wezterm/
├── assets/
│   └── wezterm-PreviewPic.png  # Preview image of terminal setup
├── colors/
│   └── ckterm.toml             # Custom Catppuccin-Mocha theme variant
├── wezterm.lua                # Main configuration file
```

---

## 💬 Notes

This configuration is designed for use on Wayland (NVIDIA supported) and integrates seamlessly with `zsh`, `starship`, and a full custom Arch-based environment.

Feel free to fork and adapt to your own setup!
