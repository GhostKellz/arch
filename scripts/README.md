# Arch Linux Scripts

This directory is a collection of scripts used to manage and automate various aspects of my Arch Linux system. It includes everything from post-install setup to system maintenance, package management, NVIDIA support, backups, and more.

---

## 📜 Scripts Included

### `ckel.sh`
_Post-Install Script (WIP)_  
Automates installation of base packages, NVIDIA drivers, virtualization tools, Flatpak, KDE tweaks, and system settings. Still evolving based on real-world usage.

### `gpgsync.sh`
_Automatic GPG & Keyring Sync Script_  
Refreshes pacman keys and GPG trust database. Intended to run as a cronjob at 2AM. Logs to `~/.logs/ckel/gpgsync.log`.

### `ghostctl-kernel-install.sh`
_Failsafe Custom Kernel + NVIDIA Installer_  
Automates the full build and installation process for a custom `linux-tkg` kernel with NVIDIA 570 DKMS support. It includes:

- 🔐 Automatic `/boot`, `initramfs`, and `/lib/modules` backups to `/data/recovery`
- 🧷 Optional Snapper snapshot before install
- ⚙️ Systemd-boot loader entry creation
- 🎯 Optional default kernel selection

Designed to protect against failed boots and provide easy rollback capability.  
> ⚠️ Tested with **BTRFS root** and **systemd-boot** only.

#### 🧠 Configuration Overview

| Variable                  | Purpose                                          |
|---------------------------|--------------------------------------------------|
| `KERNEL_NAME`             | Systemd-boot kernel name (e.g., `linux-ck-615rc2`) |
| `LINUX_TKG_DIR`           | Path to your linux-tkg directory                |
| `NVIDIA_ALL_DIR`          | Path to your nvidia-all build directory         |
| `SNAPSHOT_BEFORE_INSTALL` | Create a Snapper snapshot before install        |
| `SET_AS_DEFAULT`          | Set this kernel as the default boot entry       |
| `BACKUP_DIR`              | Auto-created under `/data/recovery/<timestamp>` |

#### 🧼 Backup Contents
```
/boot/vmlinuz-*
/boot/initramfs-*
/lib/modules/<running-version>
~/ghostctl/linux-tkg/customization.cfg
~/ghostctl/linux-tkg/linux615rc2-tkg-userpatches/
```

#### 📍 Example Usage
```bash
cd ~/ghostctl
./ghostctl-kernel-install.sh
```

This is one of the most important scripts in the system — run it **before every kernel or NVIDIA upgrade** to ensure you can safely revert.

---

## 🧠 Purpose
This folder is intended as a flexible script hub to:
- Simplify my Arch post-install workflow
- Automate key maintenance tasks
- Keep all workstation setup scripts centralized and version-controlled

---

## ⏱️ Cron Example
To sync GPG keys nightly:

```bash
crontab -e
```
Add:
```cron
0 2 * * * /home/chris/arch/scripts/gpgsync.sh
```

---

## 🛠 Future Plans
- Dotfile sync and backup automation
- Kernel patch switching (BORE/EEVDF)
- Snapper snapshot management

---

> This folder is actively growing. Scripts may be WIP unless otherwise noted.
