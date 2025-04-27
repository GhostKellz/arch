# 🛠 CKTech Linux Optimizations

[![Kernel Customization](https://img.shields.io/badge/Kernel-Custom_Tuning-blue)](https://www.kernel.org/) [![System Performance](https://img.shields.io/badge/System-Optimized-brightgreen)](https://archlinux.org) [![ZRAM](https://img.shields.io/badge/ZRAM-Enabled-5C6BC0)](https://wiki.archlinux.org/title/Zram) [![Restic Backups](https://img.shields.io/badge/Backups-Restic-orange)](https://restic.net) [![GhostCache](https://img.shields.io/badge/CachyOS-GhostCache-ff69b4)](https://cachyos.org/) [![AMD Ryzen](https://img.shields.io/badge/Ryzen-7950X3D-ED1C24)](https://www.amd.com/en/processors/ryzen)

---

## Overview

This directory contains system-wide configuration files and tuning tips to improve **performance**, **responsiveness**, and **reliability** across Arch-based Linux setups. Targeted for custom desktop environments, gaming rigs, dev workstations, and high-efficiency systemd infrastructures.

Ghost-tuned for speed, resilience, and clean rollback paths.

---

## 🧬 Memory and Swap

Focus on virtual memory optimizations:

- **ZRAM Setup** using `zram-generator` (compression: `zstd`)
- Smart `vm.swappiness` tuning
- Hybrid swap strategies
- OOM killer behaviors tweaked for system stability

> See `memory.md` for full parameter examples and notes.

---

## 🧬 Kernel Configuration

Updated kernel stack focused on peak performance:

- **Primary Kernel:** Custom **CachyOS GhostCache** variant (EEVDF scheduler)
- **Fallback Kernel:** **Custom linux-tkg 6.15 EEVDF** for testing/experimentation
- Optimized for NVIDIA Open 575 DKMS and AMD 7950X3D
- Boot entries organized under `systemd-boot`

Boot parameters fine-tuned for:
- NVIDIA DRM modeset
- Microcode loading
- Reduced boot/init delays

> See `kernel/` for full parameter tuning and systemd-boot configs.

---

## ⚙️ systemd and Services

Custom systemd improvements:

- Unit file overrides for better startup reliability
- Journal compression & persistent logging
- System-wide timers for backups, maintenance, health checks
- Prioritized service launches

> See `systemd.md` for examples and reference materials.

---

## 💽 Disk I/O and Filesystem Tuning

Optimized throughput and latency:

- I/O Scheduler tuning (`none`, `mq-deadline`, or `bfq`) based on drive
- Read-ahead buffer size adjustments
- Smart `fstab` mount options: `noatime`, `commit=60`, etc.
- `udev` rules for persistent disk tuning

> See `io.md` for deep dive examples.

---

## 🔋 Power Management

Energy efficiency options:

- CPU Frequency scaling (schedutil/performance)
- Smart suspend & wake behaviors
- Power-saving policies for low-load situations

> See `power.md` for tunable values and power scripts.

---

## 📘 File Index

| File/Folder        | Purpose                                                             |
|--------------------|---------------------------------------------------------------------|
| `kernel/`          | Kernel tuning: parameters, systemd-boot configs, fallback options  |
| `memory.md`        | ZRAM configs, hybrid swap strategies, OOM tweaks                   |
| `io.md`            | I/O scheduler tuning, disk optimizations                           |
| `power.md`         | CPU scaling, suspend, power-saving tricks                          |
| `systemd.md`       | Systemd unit overrides, journald tuning, timer setups              |

> 📂 Additional boot settings and fallback kernels in `kernel/tkg/` and `kernel/cachy/`.

---

> 🛡️ This directory embodies a Ghost-optimized system: fast, efficient, and prepared for anything.

