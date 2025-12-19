# Custom Kernel Configurations

Kernel build configs, boot parameters, and documentation for my Arch Linux setup.

---

## Current Kernel Setup

| Priority | Kernel | Scheduler | Build Location |
|----------|--------|-----------|----------------|
| **Primary** | `linux-cachyos-lto` | EEVDF + BORE | `/data/repo/linux-cachyos/linux-cachyos/` |
| **Fallback** | `linux-ghost` (TKG) | BORE | `/data/repo/linux-tkg/` |
| **Backup** | `linux-zen` | EEVDF | Arch repos |

---

## Directory Structure

```
kernel/
├── linux-cachyos/           # CachyOS-LTO config (primary)
│   ├── config-overrides.cfg
│   ├── ghostkellz.myfrag
│   ├── linux-cachyos-lto.conf
│   └── README.md
├── linux-tkg/               # TKG config (fallback)
│   ├── customization.cfg
│   ├── ghostkellz.myfrag
│   ├── linux-ghost.conf
│   └── README.md
├── linux-ghost/             # Experimental kernel project (WIP)
│   ├── bootloader/
│   ├── customization.cfg
│   └── README.md
├── nvidia/                  # NVIDIA DKMS configs
├── kernel-params.md         # Boot parameter documentation
└── README.md
```

---

## Common Boot Parameters

All kernels use these flags (see `/boot/loader/entries/`):

```bash
zswap.enabled=0                                # Using zram instead
nvidia_drm.modeset=1                           # Required for Wayland
nvidia.NVreg_PreserveVideoMemoryAllocations=1  # Suspend/resume
usbcore.autosuspend=-1                         # Disable USB autosuspend
```

---

## Hardware

- **CPU**: AMD Ryzen 9 9950X3D (Zen 5)
- **GPU**: NVIDIA RTX 5090 (nvidia-open 570.x+)
- **RAM**: 64GB DDR5
- **Storage**: NVMe

---

## Quick Commands

```bash
# Current kernel
uname -r

# Build CachyOS
cd /data/repo/linux-cachyos/linux-cachyos && makepkg -si

# Build TKG
cd /data/repo/linux-tkg && ./install.sh

# Boot menu
# Hold Space during boot for systemd-boot menu
```
