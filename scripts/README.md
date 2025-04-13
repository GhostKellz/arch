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

---

## 🧰 Purpose
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
- LXC + Proxmox tooling
- Snapper snapshot management

---

> This folder is actively growing. Scripts may be WIP unless otherwise noted.```
