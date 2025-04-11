# ⚙️ systemd.md

This file outlines customizations, logging tweaks, service enhancements, and general tips for using `systemd` effectively on an Arch-based system.

While most service-specific timers and overrides are stored within their respective tool directories (see below), this file acts as the central hub for systemd-level notes and tuning.

---

## 🔧 Overview

`systemd` is the init system and service manager used on most modern Linux distributions. It handles service lifecycles, journaling, timers, and boot processes.

This file includes:
- Journaling and logging optimizations
- Timer and persistent service notes
- Startup and boot performance tweaks
- Links to other tool-specific systemd units

---

## 🗂️ Service References

Some systemd units are managed directly within tool-specific directories:

| Tool      | Path          | Description                                      |
|-----------|---------------|--------------------------------------------------|
| **Restic**  | `/restic/`     | Backup service + timer with `.env` configs       |
| **Snapper** | `/snapper/`    | Snapper cleanup service + timer                 |
| **Btrfs**   | `/btrfs/`      | Snapshot maintenance units + tuning notes       |

---

## 🧾 Journald Configuration

Logging can be tuned by editing `/etc/systemd/journald.conf`. Some useful options:

```ini
[Journal]
Storage=persistent
Compress=yes
SystemMaxUse=500M
RuntimeMaxUse=100M
MaxRetentionSec=30day
```

Apply changes:
```bash
sudo systemctl restart systemd-journald
```

---

## ⏱️ Timer Behavior

- **Persistent timers** (e.g., restic, snapper) continue across reboots.
- Use `OnCalendar=` or `OnBootSec=` in custom timers.
- Check timer status:
  ```bash
  systemctl list-timers
  ```

---

## 🚀 Boot Optimization Tips

```bash
systemd-analyze blame       # Show slow boot services
systemd-analyze             # Total boot + kernel time
```

Use overrides to delay or disable slow or unnecessary services.

Create an override:
```bash
sudo systemctl edit NAME.service
```

---

Feel free to add more general-purpose overrides, timers, or logging tricks here!

