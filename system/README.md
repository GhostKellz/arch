# CKTech Linux System Configuration

System-wide configuration and tuning for Arch Linux workstation.

---

## Hardware

- **CPU:** AMD Ryzen 9950X3D (Zen 5, 16c/32t)
- **RAM:** 64GB DDR5
- **GPU:** NVIDIA RTX 5090 (Blackwell)
- **Storage:** NVMe

---

## Memory and Swap

- ZRAM with zstd compression
- systemd-oomd for early OOM killing
- Tuned dirty ratios for responsive I/O

See `memory.md` for full configuration.

---

## Kernel Configuration

**Primary Kernel:** CachyOS GhostCache (BORE scheduler, Full LTO, znver5)
- Package: `linux-cachyos-lto`
- Version: 7.0.x

**Fallback Kernel:** linux-tkg (BORE scheduler, Full LTO, znver5)
- Package: `linux-tkg-bore-znver5`
- Version: 7.0.x

**Driver:** NVIDIA Open 595.x DKMS (required for Blackwell/RTX 5090)

Both kernels include:
- Full netfilter stack for Docker/Tailscale (CONNMARK, nftables compat)
- VFIO/KVM passthrough support
- Container namespaces and cgroups
- BBR3 TCP congestion control
- Performance governor default

See `kernel/` for myfrag configs and PKGBUILD settings.

---

## systemd

- Journal compression and persistent logging
- Timers for backups and maintenance
- Service overrides for reliability

See `systemd.md` for details.

---

## Disk I/O

- I/O scheduler tuning per drive type
- fstab mount options: noatime, commit=60
- udev rules for persistent tuning

See `io.md` for details.

---

## File Index

| Path | Description |
|------|-------------|
| `kernel/` | Kernel configs, myfrag files, PKGBUILD settings |
| `kernel/linux-tkg/` | TKG kernel customization |
| `kernel/linux-cachyos/` | CachyOS kernel customization |
| `kernel/nvidia/` | NVIDIA DKMS patches |
| `memory.md` | ZRAM, swap, OOM configuration |
| `docker.md` | Docker kernel requirements, GPU support |
| `makepkg.conf` | Compiler flags for znver5 |
| `io.md` | I/O scheduler and disk tuning |
| `power.md` | CPU governor, suspend/hibernate |
| `systemd.md` | systemd unit overrides and timers |
| `sysctl/` | Sysctl configs (gaming, memory) |
| `pacman.conf` | Pacman configuration |

