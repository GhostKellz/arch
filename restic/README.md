# 👻 Restic Backup Automation 

[![Restic](https://img.shields.io/badge/Restic-Backup-34A853)](https://restic.net/) [![Systemd](https://img.shields.io/badge/Systemd-Timers-0078D4)](https://freedesktop.org/wiki/Software/systemd/) [![MinIO](https://img.shields.io/badge/MinIO-Storage-F43F5E)](https://min.io/) [![Synology](https://img.shields.io/badge/Synology-NAS-003057)](https://www.synology.com/) [![GhostSecured](https://img.shields.io/badge/Ghost-Secured-6B21A8)](#)

---

## 📖 Overview

This directory manages fully automated backup strategies using **Restic** with:

- ✨ Backups to **MinIO** (self-hosted S3)
- ✨ Backups to **Synology NAS**
- ⏳ Scheduled **systemd timers**
- ✨ **Environment variable** based encryption and authentication
- ✨ **Pruning** old snapshots automatically

Optimized for secure, encrypted, and deduplicated backups with minimal manual intervention.

---

## 🌐 Key Files

| File | Purpose |
|:----|:--------|
| `restic-backup.service` | One-shot systemd service that performs backup and snapshot pruning |
| `restic-backup.timer` | Systemd timer that schedules the backup service |
| `restic.env` | Environment variables for Restic repo, password, and MinIO/S3 credentials |

---

## 📚 Basic Setup

### Enable & Start the Timer
```bash
sudo systemctl enable --now restic-backup.timer
```
This ensures your backups are triggered automatically based on the timer schedule.

### Manual Run (Optional)
```bash
sudo systemctl start restic-backup.service
```
Use this to trigger an immediate backup outside the normal schedule.

---

## 🛡️ Security Notes
- Backup repos are encrypted by Restic natively.
- Environment variables securely store credentials outside the script.
- SSH and MinIO use secured access policies.

---

## 🌟 Highlights
- **Encrypted** ✔️
- **Deduplicated** ✔️
- **Pruned** (7 daily, 4 weekly, 6 monthly snapshots)
- **Ghost-tested** — zero-trust mindset

> 🌟 Built for reliability. Optimized for flexibility. Minimal human error.

---

## 🔗 Related
- [Restic Official Docs](https://restic.net/)
- [Systemd Timers Guide](https://wiki.archlinux.org/title/Systemd/Timers)
- [MinIO Object Storage](https://min.io/)
- [Synology NAS Systems](https://www.synology.com/en-global)

---

_"Backups are your last line of defense. Encrypt them. Automate them. Validate them."_

👻 Stay Ghosted, Stay Protected.
