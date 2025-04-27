# NVIDIA Performance & Tweaks 🔥🌐🛠️

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![NVIDIA](https://img.shields.io/badge/NVIDIA-76B900?style=for-the-badge&logo=nvidia&logoColor=white)
![Wayland](https://img.shields.io/badge/Wayland-00AEEF?style=for-the-badge&logo=wayland&logoColor=white)

---

## 🔍 About

This section provides custom **Wayland** fixes, gaming optimizations, NVENC improvements, and overall performance tuning focused on **NVIDIA RTX 4090** systems.

Built for **Arch Linux** users who demand top-tier performance and maximum stability.

GhostKellz Certified. 👻✅

### Topics Covered:
- 🛠️ Compatibility fixes for Wayland and NVIDIA 570 drivers
- 🎮 Gaming optimization and OBS streaming tweaks
- 🎥 NVENC encoding improvements
- 🖥️ Monitor/refresh rate fixes under Wayland

---

## ⚙️ Structure Overview

| Folder / File               | Purpose                                    |
|------------------------------|--------------------------------------------|
| `gamescope/`                 | Tweaks for Gamescope environments         |
| `wayland/`                   | Specific Wayland fixes for NVIDIA drivers |
| `fixes.md`                   | General fixes and workaround notes        |
| `gaming.md`                  | OBS/Game-focused performance tips         |
| `modprobe-nvidia.conf`        | Kernel module options (disable GSP)       |
| `nvenc.md`                   | NVENC performance tuning                  |
| `nvidia.conf`                 | Xorg/NVIDIA config overrides              |

---

## 🚀 Quick Highlights

- 🔥 **Disables unstable GSP firmware** on Open drivers
- 🎯 **Fixes monitor freezes** common with 570+ series drivers
- 📈 **Unlocks maximum gaming performance** on Wayland
- 🎥 **Optimizes NVENC** for high-quality OBS recording
- 🧹 **Cleans up environment variables** for Gamescope/Wayland

---

## 📍 Usage Example

Most configs are meant to be copied into your local `/etc/modprobe.d/`, `/etc/X11/xorg.conf.d/`, or sourced manually in gaming sessions (e.g., environment tweaks).

Example:
```bash
sudo cp modprobe-nvidia.conf /etc/modprobe.d/nvidia.conf
sudo cp nvidia.conf /etc/X11/xorg.conf.d/20-nvidia.conf
```

For Wayland environment variables, you can source them via your session launcher or `.zshrc`.

---

## 🚧 Warnings
- **Built for modern RTX cards (40-series).**
- **Assumes kernel 6.14+ and open-source NVIDIA drivers.**
- **Wayland performance may vary based on compositor (KDE/Hyprland/Gamescope).**

> Use at your own risk — but tested extensively on CKTech/GhostKellz setups.

---

## 📈 Future Work
- Vulkan layer performance enhancements
- Full Hyprland-specific profiles
- DLSS + OBS workflows

---

> This project is actively evolving alongside my personal system upgrades. 
> Expect rapid improvements, better automation, and even deeper tuning scripts. 👻🚀
