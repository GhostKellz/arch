# 🔋 Power Management

This file outlines power management configurations for systems where **performance** is prioritized over power savings—ideal for desktops, gaming rigs, and high-performance workstations.

---

## ⚙️ CPU Frequency Scaling

All CPU cores are configured to use the `performance` governor to ensure maximum clock speed and minimal frequency scaling delays.

### Check current scaling governor:
```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```
Expected output:
```
performance
performance
...
```

### Optional: Set persistently via cpupower
```bash
sudo cpupower frequency-set -g performance
```

### Or persist with systemd:
```ini
# /etc/systemd/system/cpufreq-performance.service
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g performance

[Install]
WantedBy=multi-user.target
```
Enable the service:
```bash
sudo systemctl enable --now cpufreq-performance.service
```

---

## 🛎️ Suspend and Hibernate

Systemd sleep config is lightly customized to reduce latency and keep the system responsive during suspend/resume cycles.

### Config: `/etc/systemd/sleep.conf`
```ini
[Sleep]
SuspendState=mem standby freeze
HibernateOnACPower=yes
SuspendEstimationSec=60min
```
Most other options are commented out, allowing defaults or DE policies (e.g., KDE PowerDevil) to manage transitions.

---

## 🧷 Inhibitor Tracking

Use `systemd-inhibit --list` to check what services or apps block sleep:

Examples:
- `PowerDevil` (KDE) — manages power events like lid close or sleep key
- `UPower` — manages device polling
- `Discord` — adds an inhibitor for cleanup before suspend

If you want full control, some DE components can be disabled or overridden.

---

## 🔋 Optional Tuning

- On desktops, disable unused power services like `power-profiles-daemon`.
- Adjust suspend targets for more aggressive or conservative behavior:
  ```bash
  sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
  ```
- Combine with disk writeback tuning (see `io.md`) and swap/memory tuning (`memory.md`) for a more responsive setup.

---

> This configuration aims for responsiveness and speed. If you're building a laptop config, consider a hybrid profile with better balance.

> For broader systemd tweaks and logging performance, see `systemd.md`. For persistent backup and snapshot management, see `restic/` and `snapper/`.

