# 🧬 Custom Kernel Configurations

This directory contains custom kernel builds, tuning configs, and boot parameter documentation for my Arch Linux setup.

## Included Kernels

| Kernel       | Version  | Scheduler | Notes                              |
|--------------|----------|-----------|------------------------------------|
| `linux-tkg`  | 6.1.4    | EEVDF     | Ryzen-optimized, custom flags      |
| `linux-zen`  | (archived) | CFS      | Previously used; now replaced with TKG |

## 🧠 Folder Structure

- `kernel-params.md`: Centralized breakdown of kernel boot flags used across custom builds.
- `tkg/`: My active kernel, built with TKG using custom configs and performance flags.
- `bootloader/`: systemd-boot entries specific to each kernel build.

## ⚙️ Why Custom Kernels?

- Better control over responsiveness (EEVDF, BMQ, PDS)
- Remove bloat from stock kernel configs
- NVIDIA Open DKMS compatibility & boot flag enforcement
- Tweak swap/compression layers (zram vs zswap)
