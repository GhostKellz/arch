# Linux-CachyOS-LTO Configuration

Primary kernel - [CachyOS kernel](https://github.com/CachyOS/linux-cachyos) with full LTO.

**Build location**: `/data/repo/linux-cachyos/linux-cachyos/`

---

## Files

| File | Description |
|------|-------------|
| `config-overrides.cfg` | CachyOS PKGBUILD variable overrides |
| `ghostkellz.myfrag` | Custom kernel config fragment |

---

## Key Settings

From CachyOS PKGBUILD defaults + overrides:

```bash
_cpusched="cachyos"           # EEVDF + BORE patches
_use_llvm_lto="full"          # Full LTO with Clang
_processor_opt="zen4"         # Zen 4 optimizations
_HZ_ticks="1000"              # 1000Hz tick
_tickrate="full"              # Full tickless
_preempt="full"               # Low-latency preemption
_hugepage="always"            # THP always enabled
_tcp_bbr3="yes"               # BBR3 TCP
_cc_harder="yes"              # -O3 optimizations
_per_gov="yes"                # Performance governor default
```

Override settings (`config-overrides.cfg`):
```bash
_compress_modules="zstd"
_compiler="llvm"
_use_mold="true"              # Mold linker
_use_kcfi="true"              # Kernel CFI
_lto_mode="full"
```

---

## Config Fragment (ghostkellz.myfrag)

Same as TKG - enables webcam, CIFS, containers, nftables, etc.

---

## Build

```bash
cd /data/repo/linux-cachyos/linux-cachyos
makepkg -si
```

The built package installs as `linux-cachyos-lto`.
