# linux-ghost Kernel Project (WIP)

Experimental custom kernel project - a spinoff combining elements from CachyOS and linux-tkg.

**Status**: Under development, not currently in use.

---

## Project Goals

- Merge the best of CachyOS patches with TKG flexibility
- Optimized for AMD Zen 4/5 + NVIDIA Blackwell
- Custom scheduler tuning (BORE/EEVDF hybrid)
- NVIDIA DKMS compatibility baked in

---

## Current Files

| File | Description |
|------|-------------|
| `customization.cfg` | TKG-style configuration template |
| `bootloader/linux-ghost.conf` | systemd-boot entry template |

---

## Hardware Target

- **CPU**: AMD Ryzen 9 9950X3D (Zen 5)
- **GPU**: NVIDIA RTX 5090 (Blackwell)
- **Platform**: AM5, DDR5, NVMe

---

## Note

This is separate from the TKG-built `linux-ghost` package (built from `/data/repo/linux-tkg/`) which serves as the current fallback kernel. This directory is for the standalone linux-ghost kernel project.
