# CK Arch Linux Repository

This repository is a structured collection of configuration files, reference guides, and scripts used to set up and maintain Arch Linux across various use cases, including backup automation, NVIDIA performance tweaks, and personalized dotfiles.

---

## 📂 Repository Structure

```
arch/
├── cheatsheet.md              # General-purpose command and fix reference
├── git-cheatsheet.md          # Basic Git usage tips
├── nvim-cheatsheet.md         # Neovim configuration and plugin commands
├── zsh-cheatsheet.md          # Zsh basics, plugins, and shortcuts

├── scripts/                   # Modular post-install script for configuring system packages

├── btrfs/                     # Snapper and backup strategies using BTRFS
│   └── snapper/               # Root snapper config and layout

├── dotfiles/                  # Shell and app config files
│   ├── nvim/                  # LazyVim setup with Lua config
│   ├── wezterm/               # WezTerm themes, colors, and config
│   ├── zsh/                   # Modular Zsh configuration
│   │   ├── .zshrc             # Main Zsh config (Starship + NVIDIA + loader)
│   │   ├── starship.toml      # Starship prompt theming
│   │   ├── bootstrap.sh       # Zsh bootstrap script (symlinks, plugin setup, etc.)
│   │   ├── .zshrc.d/          # Modular aliases and functions
│   │   │   ├── docker.zsh
│   │   │   ├── git-aliases.zsh
│   │   │   ├── restic.zsh
│   │   │   ├── snapper.zsh
│   │   │   ├── system.zsh
│   │   │   └── wezterm.zsh
│   └── oh-my-zsh/             # Custom plugins/themes (not full Oh My Zsh install)
│       └── custom/
│           ├── plugins/
│           │   ├── zsh-autosuggestions/
│           │   └── zsh-syntax-highlighting/
│           └── themes/
│               └── your-theme.zsh-theme
├── .bashrc                    # Bash configuration (fallback)

├── restic/                    # Restic systemd service/timer and env vars
├── nvidia/                    # NVIDIA-specific tweaks and fixes
├── networking/                # Network configs (Headscale, Tailnet, NGINX, etc.)
├── system/                    # System-wide tuning (ZRAM, systemd, memory, kernel)
│   ├── kernel/                # Kernel tweaks and boot configuration
│   │   ├── tkg/               # Custom bootloader entry and customization.cfg
│   │   └── kernel-params.md   # Boot parameter summary
│   ├── io.md                  # I/O scheduler tweaks and disk settings
│   ├── memory.md              # ZRAM, swappiness, and caching behavior
│   ├── power.md               # Power profiles, suspend tuning
│   └── systemd.md             # Systemd timers, journal, and overrides

├── virtualization/            # QEMU, passthrough, and Libvirt tuning
│   ├── kvm.md
│   ├── libvirt.md
│   ├── passthrough.md
│   └── tweaks.md

├── kde/                       # KDE-specific quirks, bugs, and tuning (Wayland-specific)
│   ├── README.md              # KDE + Wayland + NVIDIA freeze fix (pageflip)
│   └── known_issues.md        # Known issues tracking (Wayland pageflip bug, etc.)

├── wayland/                   # Wayland (non-DE specific) tweaks and guides
│   ├── tweaks.md              # Global Wayland environment variables
│   ├── compatibility.md       # App compatibility: Discord, OBS, Firefox, etc.
│   ├── input.md               # libinput, gestures, touchpads
│   ├── fractional-scaling.md  # Multi-monitor DPI, scaling fixes
│   └── nvidia.md              # NVIDIA + Wayland driver and rendering tweaks

└── assets/                    # Shared images and screenshots for documentation
```

---
## ✅ Key Components

- **cheatsheet.md** – Central markdown file for commands, aliases, tweaks, and troubleshooting
- **git-cheatsheet.md** – A quick reference guide for basic Git usage
- **nvim-cheatsheet.md** – A quick guide for working with Neovim and its plugins
- **zsh-cheatsheet.md** – A quick guide to using Zsh, its plugins, and configuration tips
- **btrfs/** – Snapper setup, GRUB/systemd-boot integration, permissions, and subvol layout
- **restic/** – Systemd backup service/timer units and sensitive `.env` config (excluded from sync) along with MinIO/S3-compatible remote backup
- **dotfiles/** – Centralized system configuration and customization files, used for managing shell settings, terminal appearance, development tools, and environment setup across machines. Including:
  - LazyVim + Lua config
  - Modular Zsh config (`.zshrc`, `.zshrc.d/`, `starship.toml`, `bootstrap.sh`)
  - Oh My Zsh with custom plugins/themes (stored in `zsh/oh-my-zsh/`)
  - WezTerm colors, font tweaks, and hot-reload alias
- **nvidia/** – Tweaks, fixes, OBS/NVENC configs, kernel params, and performance enhancements specific to NVIDIA + Wayland setups
- **networking/** – WireGuard, NFS mounts, Tailscale settings, and LAN/cloud mesh configuration
- **performance/** – ZRAM tuning, swappiness, systemd optimizations, I/O scheduling, and system responsiveness tweaks
- **virtualization/** – QEMU/libvirt configs, host tuning, and Proxmox integration for remote VM backups
- **wayland/** – Wayland-specific fixes and tweaks:
  - Fractional scaling
  - Multi-monitor and DPI fixes
  - Input tweaks (gestures, polling)
  - App compatibility (Electron, OBS, Discord, etc.)
  - NVIDIA Wayland-specific setup and env vars
- **scripts/** – Modular post-install automation scripts for Arch Linux provisioning:
  - `ckel.sh`: main setup tool for installing system packages, Flatpak, Docker, virtualization, and performance tuning
  - Automatically pulls personal GitHub repos (`arch`, `docker`, `proxmox`)
  - Includes backup setup with Snapper + Restic
  - Preps KDE theming, modular Zsh, and Tailscale for zero-config networking

---

### 🔍 Maintained by [Christopher Kelley](https://github.com/Christopherkelley89)  
Feel free to fork or submit pull requests!
---


