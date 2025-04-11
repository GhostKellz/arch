# 🛠️ system/

This directory contains system-wide configuration files and tuning tips to help improve performance, responsiveness, and reliability across Arch-based Linux systems. These optimizations are particularly helpful for custom desktop setups, gaming workstations, development environments, and advanced systemd configurations.

---

## 🧠 Memory and Swap

This section focuses on virtual memory tuning, swap behavior, and low-memory edge cases:

- **ZRAM Setup** using `zram-generator` with `zstd` compression for faster and more efficient compressed swap
- Tuning `vm.swappiness` to influence swap tendency
- Hybrid swap strategies using multiple swap devices
- Notes on configuring OOM killer behavior to reduce the chance of lockups

> See `memory.md` for full configuration examples and parameter references.

---

## 🧬 Kernel Configuration

Custom kernel and bootloader options for performance tuning and hardware compatibility:

- **Custom Kernel (TKG)** entries for EEVDF scheduler with AMD microcode
- Bootloader entries using `systemd-boot`
- `nvidia_drm.modeset=1` and GSP-related NVIDIA toggles
- `zswap.enabled=0` and `zram` interaction
- Organize per-kernel boot entries in `kernel/tkg/` or other subfolders

> See `kernel/` for parameter files and boot configuration examples.

---

## ⚙️ systemd and Services

Tuning and customizing `systemd` units and logging behavior:

- Override unit files to improve startup times or behavior
- Journal optimizations (persistent logs, compression)
- User timers and system-wide timers
- Startup reliability and service prioritization
- Restic backup services live under `/restic` for systemd-based backup jobs

> See `systemd.md` for system-level overrides and logging tweaks.

---

## 💽 Disk I/O and Filesystem Tuning

Optimize disk throughput, latency, and responsiveness:

- I/O scheduler tuning (`none`, `mq-deadline`, `bfq`) based on device type
- Disk readahead size tuning
- Filesystem mount options for performance (e.g., `noatime`, `commit=60`)
- `udev` rules for persistent block device settings

> See `io.md` for detailed scheduler configurations and notes.

---

## 🔋 Power Management

Energy efficiency and power-saving tips for desktop and mobile use:

- CPU frequency scaling (schedutil, performance, powersave)
- Power-saving options for idle systems
- Suspend/hibernate configuration and wake-up behavior

> See `power.md` for power-related sysfs toggles and policies.

---

## 📚 File Index

| File               | Description                                                             |
|--------------------|-------------------------------------------------------------------------|
| `kernel/`          | Kernel tuning: parameters, custom bootloader entries, and TKG configs   |
| `memory.md`        | ZRAM, swap strategies, and OOM tuning                                   |
| `io.md`            | Disk scheduler tweaks, disk caching, and readahead settings              |
| `power.md`         | Desktop and laptop power-saving options                                 |
| `systemd.md`       | systemd unit overrides, journald configuration, and timers              |

> 🗃️ Additional kernel boot settings (e.g. for NVIDIA/AMD) can be found in `kernel/tkg/` and `nvidia/`.

Feel free to contribute your own system tuning tips or open issues for deeper topics!
