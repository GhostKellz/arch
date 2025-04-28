# 👻 GhostKellz Terminal 2.0

This directory contains the full configuration for WezTerm, featuring a custom hacker-blue inspired theme, modernized for clarity, style, and performance.  
It blends precision and speed for a clean, powerful terminal experience.

---

## 🎨 Theme Overview

- **Color Scheme**: `GhostKellz` (custom hackerblue TokyoNight variant)
- **Foreground**: Light hacker blue (`#57c7ff`)
- **Background**: Deep navy blue (`#0d1117`)
- **Cursor/Selection**: Contrasting blues for precision and visibility

The theme is tuned for visual sharpness while maintaining a low-glare, low-distraction environment ideal for long coding sessions.

---

## 🧐 Features

- Custom ANSI and Bright color palettes
- WebGPU backend (with HighPerformance preference)
- Fallbacks: OpenGL and Software rendering if needed
- JetBrainsMono + FiraCode Nerd Fonts with emoji fallback
- Minimal UI: no tab clutter, subtle transparent background
- Full Zsh (`oh-my-zsh`) + `starship.toml` prompt compatibility
- Keybindings for fast split panes, clipboard access, debug overlay
- Cursor customization: Solid blinking block for visibility

---

## 🗂️ Directory Structure

```
dotfiles/wezterm/
├── assets/
│   └── ghostkellz-preview.png      # Preview image of the terminal setup
├── colors/
│   └── ghostkellz.toml              # Full GhostKellz custom color scheme
└── wezterm.lua                     # Main configuration file
```

---

## 💬 Notes

This configuration is optimized for Wayland (NVIDIA open driver supported) and integrates seamlessly with `zsh`, `starship`, and a customized Arch-based environment.

Built for performance, style, and minimalism.

```

