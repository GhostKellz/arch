# CK Arch Linux Repository

This repository is a structured collection of configuration files, reference guides, and scripts used to set up and maintain Arch Linux across various use cases, including backup automation, NVIDIA performance tweaks, and personalized dotfiles.

---

## 📂 Repository Structure

```
arch/
├── cheatsheet.md           # General-purpose command and fix reference
├── git-cheatsheet.md       # Basic Git usage tips
├── nvim-cheatsheet.md      # Neovim configuration and plugin commands
├── zsh-cheatsheet.md       # Zsh basics, plugins, and shortcuts
├── scripts/       	    # Modular post-install script for configuring system packages, services, and pulling dotfile configs
├── btrfs/                  # Snapper and backup strategies using BTRFS
│   └── snapper/            # Root snapper config and layout
├── dotfiles/               # Shell and app config files
│   ├── nvim/               # LazyVim setup with Lua config
│   ├── oh-my-zsh/          # Zsh plugin manager and custom setup
│   ├── wezterm/            # WezTerm themes, colors, and config
│   ├── .bashrc             # Bash configuration
│   ├── .zshrc              # Zsh configuration
│   ├── starship.toml       # Prompt theming (Starship)
│   └── bootstrap.sh        # Local environment bootstrap script
├── restic/                 # Restic systemd service/timer and env vars
├── nvidia/                 # NVIDIA-specific tweaks and fixes
├── networking/             # Network configs (Tailscale, NFS, etc.)
├── performance/            # General system performance and stability tweaks (ZRAM, systemd, I/O, etc.)
├── virtualization/         # Libvirt/QEMU tools and backup notes
├── wayland/                # Wayland-specific tweaks, environment variables, app fixes, and scaling issues
│   ├── tweaks.md              # General Wayland vars & settings
│   ├── compatibility.md       # OBS, Discord, Electron, etc.
│   ├── input.md               # libinput, gestures, polling
│   ├── fractional-scaling.md  # DPI, HiDPI, multi-monitor
│   └── nvidia.md              # NVIDIA-specific Wayland quirks (XWayland, env vars, EGLStream notes)
```

---

## ✅ Key Components

- **cheatsheet.md** – Central markdown file for commands, aliases, tweaks, and troubleshooting
- **git-cheatsheet.md** – A quick reference guide for basic Git usage
- **nvim-cheatsheet.md** – A quick guide for working with Neovim and its plugins
- **zsh-cheatsheet.md** – A quick guide to using Zsh, its plugins, and configuration tips
- **btrfs/** – Snapper setup, GRUB integration, permissions, and subvol layout
- **restic/** – Systemd backup service/timer units and sensitive `.env` config (excluded from sync) along with minio S3 compatible backup
- **dotfiles/** – Centralized system configuration and customization files, used for managing shell settings, terminal appearance, development tools, and environment setup across machines. including:
  - LazyVim + Lua
  - Starship prompt
  - Oh My Zsh + plugins
  - WezTerm colors & font tweaks
  - Bootstrap shell script
- **nvidia/** – tweaks, fixes, OBS/NVENC configs, kernel params, and performance enhancements
- **networking/** – WireGuard, NFS mounts, and Tailscale settings
- **performance/** – ZRAM tuning, swappiness, systemd, I/O scheduling, and overall resource optimization
- **virtualization/** – VM management with libvirt, remote backups, and host tuning
- **wayland/** – Standalone Wayland-specific fixes: fractional scaling, app compatibility, gestures, and environment tweaks, nvidia tweaks
- **scripts/** – Modular post-install automation scripts for Arch Linux provisioning:
  - `ckel.sh`: main setup tool for installing system packages, configuring services, enabling Flatpak, Docker, virtualization, and performance tweaks
  - Automatically pulls personal GitHub repos (arch, docker, proxmox)
  - Includes backup setup with Snapper and Restic
  - Preps KDE theming, Zsh shell, and Tailscale for zero-config networking
---
### 🔍 Maintained by [Christopher Kelley](https://github.com/Christopherkelley89)  
Feel free to fork or submit pull requests!
---

