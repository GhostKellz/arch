# Linux-TKG Configuration

Secondary kernel built via [linux-tkg](https://github.com/Frogging-Family/linux-tkg).

**Version**: 7.0.x
**Build location**: `/data/repo/linux-tkg/`

---

## Files

| File | Description |
|------|-------------|
| `customization.cfg` | TKG build configuration |
| `ghostkellz.myfrag` | Custom kernel config fragment |

---

## Key Settings

From `customization.cfg`:

```bash
_version="7.0-latest"
_cpusched="bore"              # BORE scheduler
_compiler="llvm"              # Clang/LLVM
_lto_mode="full"              # Full LTO
_processor_opt="znver5"       # Zen 5 optimizations (Ryzen 9000/9950X3D)
_timer_freq="1000"            # 1000Hz tick
_tickless="1"                 # Full tickless (CattaRappa)
_default_cpu_gov="performance"
_tcp_cong_alg="bbr"           # BBR TCP
_compileroptlevel="2"         # -O3 optimizations
_modprobeddb="true"           # Use modprobed-db for faster builds
_zenify="true"                # Zen/Liquorix patches
_glitched_base="true"         # Community patches
_custom_pkgbase="linux-ghost" # Package name
```

---

## ZEN5 Support

TKG handles znver5 directly via `_processor_opt="znver5"` which passes `-march=znver5` to the compiler. No Kconfig patch needed.

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
cd /data/repo/linux-tkg
makepkg -si
```

Or use the install script:
```bash
./install.sh
```

The built package installs as `linux-ghost`.
