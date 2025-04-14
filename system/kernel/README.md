# 🧬 Custom Kernel Configurations

This directory contains custom kernel builds, tuning configs, and boot parameter documentation for my Arch Linux setup. I'm experimenting with a hybrid kernel concept that blends:

- **linux-tkg** (flexible build system + performance tuning)
- **CachyOS**-level responsiveness (Bore scheduler, tick tweaks, etc.)
- Full **NVIDIA DKMS/Open** support with custom modprobe, hooks, and install scripts

This isn’t a full fork (yet), but `linux-ghost` is an evolving kernel project aimed at optimizing performance on high-end desktops — especially for AMD + NVIDIA hybrid setups.

---

## Included Kernels

| Kernel        | Version  | Scheduler | Notes                                                         |
| ------------- | -------- | --------- | ------------------------------------------------------------- |
| `linux-ghost` | 6.15-rc2 | BORE      | Custom-built with NVIDIA DKMS compatibility and snapper-ready |

> `linux-tkg` and `linux-zen` are archived for now as we consolidate around a more stable base.

---

## 🧠 Folder Structure

- `linux-ghost/` — Main custom kernel directory
  - `bootloader/` — systemd-boot entry
  - `customization.cfg` — TKG config
  - `README.md` — Kernel explanation
- `nvidia/` — NVIDIA DKMS build setup + system configs
- `kernel-params.md` — Centralized breakdown of kernel boot flags

---

## ⚙️ Why Custom Kernels?

- Better control over responsiveness (BORE, EEVDF, PDS)
- Remove bloat from stock kernel configs
- NVIDIA Open DKMS compatibility & boot flag enforcement
- Tweak swap/compression layers (zram vs zswap)
- Snapper-safe recovery support baked in

---

## 🚀 Installation

To install this kernel easily, use the companion script in:

```bash
~/arch/scripts/linux-ghost-installer.sh
```

It handles:

- Pre-install Snapper snapshot (optional)
- Kernel + NVIDIA DKMS build
- Bootloader entry generation
- Automatic backup to `/data/recovery/`

---

> This section is actively evolving — expect more schedulers, patches, and NVIDIA enhancements soon.

*Stay tuned. The ghost moves fast.* 👻


