# Linux-TKG Configuration

Fallback kernel built via [linux-tkg](https://github.com/Frogging-Family/linux-tkg).

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
_version="6.18-latest"
_cpusched="bore"              # BORE scheduler
_compiler="llvm"              # Clang/LLVM
_lto_mode="full"              # Full LTO
_processor_opt="znver4"       # Zen 4 optimizations
_timer_freq="1000"            # 1000Hz tick
_default_cpu_gov="performance"
_tcp_cong_alg="bbr"           # BBR TCP
_modprobeddb="true"           # Use modprobed-db for faster builds
_custom_pkgbase="linux-ghost" # Package name
```

---

## Config Fragment (ghostkellz.myfrag)

Enables:
- Elgato/UVC webcam support
- CIFS/SMB network shares
- FUSE3 filesystem
- Docker/container support (namespaces, cgroups, overlayfs)
- nftables/netfilter for networking
- VirtIO for VMs

---

## Build

```bash
cd /data/repo/linux-tkg
./install.sh
```

The built package installs as `linux-ghost`.
