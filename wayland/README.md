# Wayland Optimization and Fixes

This section contains tweaks, compatibility notes, and configuration tips for users running Wayland-based compositors. Designed for users on NVIDIA GPUs as well as general Wayland setups, this directory aims to help improve stability, reduce tearing, fix rendering bugs, and tune experience across common window managers and desktop environments.

---

## 🔧 Directory Purpose

Wayland is still evolving across distributions, and running it with proprietary GPU drivers (such as NVIDIA) introduces challenges. This folder is where all Wayland-specific solutions are collected.

We cover topics like:
- Screen tearing and refresh issues
- Hybrid GPU (iGPU/dGPU) behavior
- HDR and color space support
- PipeWire and screenshot compatibility (e.g., Spectacle crashes)
- Environment variables and session overrides
- Compositor-specific behavior (e.g., Hyprland, Sway, GNOME Wayland)

---

## 📁 Directory Structure

```
wayland/
├── README.md                # Overview and structure
├── nvidia/                  # NVIDIA-specific Wayland issues
│   └── sync-issues.md       # Placeholder for future issues syncing, tweaks, etc.
├── kde.md                   # KDE-specific tweaks and quirks
├── hyprland.md              # Hyprland-specific tweaks and quirks
├── screenshot.md            # Fixes for Spectacle and screenshot tools
├── tearing.md               # General screen tearing fixes
├── sessions.md              # Env variables, XDG and session configs
├── wayland-general.md       # Misc Wayland bugs and general solutions
```

---

Feel free to contribute new files and notes as you encounter quirks in Wayland usage!

