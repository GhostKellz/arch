# Arch Linux Scripts 👻🔥🌐

> **by GhostKellz**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Zsh Powered](https://img.shields.io/badge/Shell-Zsh-89e051?logo=gnu-bash&logoColor=white)](https://www.zsh.org)

---

## 🔍 About

This is a curated, professional-grade collection of ZSH-powered scripts for managing and optimizing my **personal Arch Linux workstation** setup. Focused on:

- Automating post-install tasks
- Bulletproof kernel upgrades and fallbacks
- Secure GPG key syncing
- Full system resilience and rollback ability

Every script here is designed for **speed**, **stability**, and **GhostKellz-level efficiency**.

---

## 🔧 Scripts Included

### `ckel.sh`
_Post-Install Setup (WIP)_
- Installs critical packages, NVIDIA drivers, Flatpak, virtualization tools, and applies KDE customizations.

### `gpgsync.sh`
_GPG + Keyring Auto-Sync_
- Refreshes pacman keys and GPG trust DB nightly.
- Cron-ready for background syncing.

### `ghost-kernel-install.sh`
_Custom Kernel Installer + Failsafe Backup_
- Builds custom `linux-tkg` kernels
- Fully backs up `/boot`, `initramfs`, `/lib/modules` into `/data/recovery/<timestamp>`
- Optionally Snapper snapshot before any kernel install
- Auto-updates systemd-boot entries
- Sets default kernel cleanly

### `ghostboot.zsh`
_Boot Image Cleaner_
- Smartly cleans old `/boot` kernels and initramfs files
- Prevents boot partition overflow
- Only keeps your active working kernels (safe and quick!)

---

## 🔍 Example Usage

```bash
cd ~/arch/scripts
./ghostboot.zsh
```
```bash
cd ~/ghostctl
./ghost-kernel-install.sh
```

---

## 🚀 Features

- 🌐 Full ZSH script style for speed and clarity
- 🔍 Minimal safe dependency footprint
- 🔧 Designed around **BTRFS root** + **systemd-boot** workflow
- 💀 Resilient against failed kernel upgrades or NVIDIA DKMS issues
- 🔔 Cron-ready tools for unattended maintenance
- 👻 Ghost-themed branding throughout

---

## 🧹 Future Plans

- Dotfile backup automation
- Automated Snapper pre/post snapshot scripts
- Faster Nvidia DKMS build detection hooks
- Full GitHub Actions template for GhostKellz Arch recovery system

---

> This repository is actively developed by **GhostKellz** under **CK Technology**. Scripts are version-controlled and battle-tested. Updates incoming!

