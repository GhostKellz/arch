# Arch Linux Script Suite 🌍🌐✨

[![Built for Arch Linux](https://img.shields.io/badge/Built%20for-Arch%20Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org) 
[![Shell Powered](https://img.shields.io/badge/Powered%20By-Zsh-6A5ACD?logo=gnu-bash&logoColor=white)](https://zsh.org)
[![Maintenance](https://img.shields.io/badge/Status-Actively%20Maintained-brightgreen)]()

---

## 🔍 About

This directory houses professional-grade **Zsh** scripts tailored for managing, maintaining, and enhancing a custom Arch Linux system. Each script is built with clarity, rollback protection, and efficiency in mind, ideal for real-world workstation use.

Built by **CK Technology** and maintained by **GhostKellz**.

---

## 👨‍💻 Scripts Overview

### `ckel.sh`
_Initial Post-Install Script_
- Automates installation of critical packages.
- Handles NVIDIA driver setup, virtualization tools, Flatpak, KDE tweaks.
- Continually evolving based on workstation needs.

### `gpgsync.sh`
_GPG & Keyring Auto-Sync_
- Syncs GPG keys and Pacman trust database.
- Designed for cron-based execution (nightly).
- Logs activity to `~/.logs/ckel/gpgsync.log`.

### `ghost-kernel-install.sh`
_Atomic Custom Kernel Installer_
- Builds and installs a custom `linux-tkg` kernel with NVIDIA 570 DKMS.
- Automatic backup of `/boot`, `initramfs`, `/lib/modules`, and configs.
- Optional Snapper snapshot before operation.
- Systemd-boot integration and optional default kernel selection.
- **Essential for pre-NVIDIA upgrade rollbacks.**

##### 🧬 Kernel Installer Backup Includes
```
/boot/vmlinuz-*
/boot/initramfs-*
/lib/modules/<running-version>
~/ghostctl/linux-tkg/customization.cfg
~/ghostctl/linux-tkg/linux615rc2-tkg-userpatches/
```

##### 🔍 Example Kernel Install
```bash
cd ~/ghostctl
./ghostctl-kernel-install.sh
```

### `ghostboot.zsh`
_Dead Kernel / Boot Cleaner_
- Scans `/boot` for unused kernels and initramfs images.
- Safely deletes **only** files not associated with your running kernel.
- Helps maintain clean boot partitions post-upgrades.

##### 🧹 Example Boot Cleanup
```bash
cd ~/arch/scripts
./ghostboot.zsh
```

---

## 🤓 Philosophy
- **Zsh-native** and optimized for fast, local execution.
- **Fail-safe** by design (critical backups, rollback points).
- **Self-host friendly** for maximum control.
- **Actively updated** based on real workstation use.

---

## 🕒 Cron Example
Set up GPG syncing automatically:
```bash
crontab -e
```
Add:
```cron
0 2 * * * /home/chris/arch/scripts/gpgsync.sh
```

---

## 🛠️ Future Enhancements
- Dotfile sync & backup automation.
- Kernel patch toggling (BORE, EEVDF, future schedulers).
- Advanced Snapper snapshot management.
- Full multi-system recovery tooling.

---

> ✨ This directory is **actively growing**. Expect frequent updates, polish, and new utilities.

---

**Made with 💛 by CK Technology**

---
