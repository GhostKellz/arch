# Linux-CachyOS-LTO Configuration

Primary kernel - [CachyOS kernel](https://github.com/CachyOS/linux-cachyos) with full LTO.

**Version**: 7.0.x
**Build location**: `/data/repo/linux-cachyos/linux-cachyos/`

---

## Files

| File | Description |
|------|-------------|
| `PKGBUILD` | Modified PKGBUILD with ZEN5 support |
| `ghostzen5.patch` | Adds CONFIG_MZEN5 for Ryzen 9000 series |
| `ghostkellz.myfrag` | Custom kernel config fragment |
| `config-overrides.cfg` | CachyOS PKGBUILD variable overrides |

---

## Key Settings

```bash
_cpusched="cachyos"           # EEVDF + BORE patches
_use_llvm_lto="full"          # Full LTO with Clang
_processor_opt="zen5"         # Zen 5 optimizations (Ryzen 9000/9950X3D)
_HZ_ticks="1000"              # 1000Hz tick
_tickrate="full"              # Full tickless
_preempt="full"               # Low-latency preemption
_hugepage="always"            # THP always enabled
_cc_harder="yes"              # -O3 optimizations
```

---

## ZEN5 Support

The PKGBUILD includes explicit ZEN5 support via:

1. **ghostzen5.patch** - Adds `CONFIG_MZEN5` to kernel Kconfig
2. **PKGBUILD modification** - `ZEN5` case in CPU optimization switch
3. **Default** - `_processor_opt=zen5`

This matches CachyOS pre-built znver5 repository binaries.

---

## Config Fragment (ghostkellz.myfrag)

Enables:
- Elgato/UVC webcam support
- CIFS/SMB, FUSE3
- Docker/container support (namespaces, cgroups, overlayfs)
- nftables + iptables compat
- KVM/QEMU, VFIO passthrough
- WireGuard, Tailscale
- NVIDIA container toolkit support
- AMD Zen5 optimizations

---

## Build

```bash
cd /data/repo/linux-cachyos/linux-cachyos
makepkg -si
```

The built package installs as `linux-cachyos-lto`.
