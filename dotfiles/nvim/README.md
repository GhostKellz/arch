# 👻 GhostKellz Neovim Theme

![Neovim](https://img.shields.io/badge/Neovim-0.9%2B-brightgreen?style=for-the-badge\&logo=neovim\&logoColor=white)
![GPU Accelerated (NVIDIA)](https://img.shields.io/badge/GPU_Accelerated-NVIDIA-76b900?style=for-the-badge\&logo=nvidia\&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-Powered-1793D1?style=for-the-badge\&logo=arch-linux\&logoColor=white)

A clean, GPU-accelerated, Wayland-optimized Neovim setup built for speed, precision, and style.
Designed around a heavily enhanced **TokyoNight** theme with custom tweaks for an improved developer experience. The Termius SSH "Hacker Blue" palette gets a ghost-themed twist.

---

## 🌈 Theme Overview

* **Base Theme**: `tokyonight` (custom variant: `ghostkellz`)
* **Foreground**: `#57c7ff` (light hacker blue)
* **Background**: `#0d1117` (deep navy)
* **Highlights**:

  * Cyan for functions + cursorline
  * Hacker blue for comments, diagnostics, and borders
  * Green/mint accents for UI widgets
  * Smooth contrast for floating windows and popups

---

## 🧪 Features

* 🚀 Fully GPU-accelerated (Wayland + NVIDIA)
* 🧠 Lazy.nvim managed plugin system
* 🌌 Built-in LSP with customized lsconfig support
* 🧪 Rust and Go support (with Clippy, RustFmt, etc.)
* 🧲 Telescope + Treesitter enabled
* 🧭 `tmux-navigator` for seamless tmux/Vim movement
* ⌨️ Custom keybinds for 60% keyboards (Wooting60HE friendly)
* ⚖️ Formatting: Prettier, stylua, shfmt, rustfmt, gofmt auto-detect
* 🌟 Ghost-powered Starship + Powerlevel10k prompt integration

---

## 📂 Directory Structure

```bash
dotfiles/nvim/
├── README.md                # This file
├── init.lua                 # Bootstrap entry point
├── lazy-lock.json           # Plugin lockfile
├── lua/
│   ├── config/
│   │   ├── formatting.lua       # Formatter config (stylua, shfmt, etc.)
│   │   ├── lazy.lua             # Lazy.nvim setup
│   │   ├── lsp.lua              # LSP definitions + handlers
│   │   ├── navigation.lua       # Movement + 60% keyboard logic
│   │   ├── options.lua          # Global vim options
│   │   ├── ... (other configs)
│   ├── plugins/
│   │   ├── ai.lua               # AI helpers
│   │   ├── copilot.lua          # GitHub Copilot
│   │   ├── telescope.lua        # Telescope setup
│   │   ├── treesitter.lua       # Treesitter setup
│   │   ├── tmux-navigator.lua   # Tmux keybindings
│   │   ├── ... (other plugin configs)
├── assets/
│   ├── nvim-ghostblue.png       # New theme preview
│   ├── nvim-preview.png         # Neovim inside WezTerm
│   └── Neovim-theme.png         # Highlight scheme visual
```

---

## 📷 Previews

### Live Session (2026)

![Neovim Session 2026](https://raw.githubusercontent.com/GhostKellz/arch/main/assets/nvim-session-2026.png)

### Ghostkellz Custom Theme

![Ghostkellz Neovim Theme](https://raw.githubusercontent.com/GhostKellz/arch/main/assets/nvim-ghostblue.png)

### Neovim in WezTerm

![Neovim in WezTerm](https://raw.githubusercontent.com/GhostKellz/arch/main/assets/nvim-preview.png)

### Highlight Visuals

![Neovim Highlight Theme](https://raw.githubusercontent.com/GhostKellz/arch/main/assets/Neovim-theme.png)

---

## 💬 Notes

This setup is fine-tuned for performance, aesthetic cohesion, and speed:

* Built on Lazy.nvim with modular Lua components
* Tailored for daily driver hardware: NVIDIA, Wayland, and 60% boards
* Excellent for TypeScript, Go, Rust, Shell, Markdown, YAML
* Works beautifully with tmux, Starship, and vivid themes

---

🌟 Maintained by [GhostKellz](https://github.com/GhostKellz)

