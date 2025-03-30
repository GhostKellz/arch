# performance/

This directory contains system-wide performance tuning notes, fixes, and references. It is designed to help improve general responsiveness, resource efficiency, and stability of your Linux system, particularly on Arch-based setups.

---

## 📌 Overview

Here you'll find tweaks and settings related to:

- ZRAM and swap optimization
- I/O scheduler tuning
- `systemd` service improvements
- Kernel parameter adjustments
- Filesystem performance tuning (non-BTRFS-specific)
- Power management for desktop systems
- Handling OOM (Out of Memory) edge cases

These tips are aimed at ensuring performance without sacrificing stability, especially on modern hardware.

---

## 📁 File Index

- `zram.md` – Configure compressed RAM swap with `zstd`
- `systemd.md` – Boot optimizations, journal, and unit tweaks
- `memory.md` – Swappiness, caching behavior, and OOM handling
- `io.md` – Filesystem and disk I/O scheduler adjustments
- `kernel.md` – Useful kernel boot params and sysctl tweaks
- `power.md` – Desktop-friendly power-saving tips

---

Feel free to contribute your own performance-related tips, benchmarks, or optimizations.

