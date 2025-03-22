# CK Arch Linux Repository

This repository is a structured collection of configuration files, reference guides, and scripts used to set up and maintain Arch Linux.

---

## 📂 Repository Structure

```
arch/
├── cheatsheet.md           # General-purpose command and fix reference
├── ckpostinstall.sh        # Post-install script for configuring system packages and services
├── btrfs/                  # Snapper and backup strategies using BTRFS
├── dotfiles/               # Minimal shell and config file references
├── nvidia/                 # NVIDIA-specific Wayland, OBS, gaming, and fixes
├── networking/             # Network-related configs (NFS, Tailscale, etc.)
├── virtualization/         # KVM/libvirt and VM management references
```

---

## ✅ Key Components

- **ckpostinstall.sh** – Automates base configuration (Zen kernel, NVIDIA open drivers, PipeWire, Flatpak, ZRAM, SDDM + Nordic, etc.)
- **cheatsheet.md** – Central markdown file for commands, aliases, tweaks, and troubleshooting
- **btrfs-snapshots/** – Snapper setup and Synology backup integration
- **dotfiles/** – Reference `.bashrc`, `.zshrc`, and other environment customizations
- **nvidia/** – Wayland, OBS, NVENC, gaming flags, and performance tips
- **networking/** – Tailscale, NFS mounts, and related tools
- **virtualization/** – QEMU/KVM setup, VM backups, and performance tuning

