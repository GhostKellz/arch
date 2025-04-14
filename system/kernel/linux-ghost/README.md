# 🌧️ Custom `linux-tkg` Kernel Setup (Ryzen + EEVDF + NVIDIA Open DKMS)

This directory contains the files and documentation for my custom `linux-tkg` kernel configuration. It’s optimized for:

- 🧠 **Ryzen 9 X3D** CPU (AM5 platform)
- 🎮 **NVIDIA RTX 4090** with Open 570 DKMS drivers
- ⚙️ **Linux 6.1.4**
- 🧵 **EEVDF scheduler** (a modern fair queuing CPU scheduler)
- 🧬 **AMD microcode** applied at boot

---

## 💠 What’s this kernel setup for?

The `linux-tkg` kernel gives me full control over kernel options like:
- The CPU scheduler (e.g., EEVDF, BMQ, PDS)
- Tick rate and latency profiles
- NVIDIA compatibility at the kernel level
- General performance tuning and debugging

I use this kernel daily on my Arch Linux workstation running Wayland (Plasma 6), where I need high performance, low input latency, and full NVIDIA driver support — especially for gaming, development, and desktop use.

---

## 📦 What’s included in this directory?

| File                          | Description |
|------------------------------|-------------|
| `customization.cfg`          | The file I used to build my TKG kernel — it defines all my choices during the build (like EEVDF, tickrate, scheduler, etc.) |
| `bootloader/boot-entry.conf` | The systemd-boot entry used to boot into this kernel. It also contains boot flags for NVIDIA and memory tuning. |
| `README.md`                  | This file — documentation for my setup and rationale behind choices |

---

## ⚙️ Key Boot Parameters (from `boot-entry.conf`)

### 💡 Current flags:
```bash
zswap.enabled=0
nvidia_drm.modeset=1
nvidia.NVreg_EnableGpuFirmware=0
```

---

## 🔍 What these do (explained)

### 🧠 `zswap.enabled=0`

By default, Linux uses **zswap** — a memory compression feature that stores swapped memory pages in compressed form in RAM before sending them to disk.

I'm **disabling it** because I'm using **ZRAM instead** — which is an alternative that creates compressed RAM disks used *entirely in memory*. It's faster and more modern for high-memory systems like mine (64GB+), and avoids unnecessary overlap with zswap.

If you're not using ZRAM, you might want to leave `zswap.enabled=1` instead.

---

### 📂 `nvidia_drm.modeset=1`

This flag enables DRM (Direct Rendering Manager) mode setting early in the boot process. It is **required** for NVIDIA to work correctly with **Wayland compositors** like KDE Plasma and GNOME.

Without this, your displays might not be recognized properly or Wayland might not start at all.

---

### 🚀 `nvidia.NVreg_EnableGpuFirmware=0`

This flag disables **GSP (GPU System Processor) firmware**, which NVIDIA is pushing as a newer way to offload GPU tasks to firmware.

I originally had this setting in `/etc/modprobe.d/nvidia.conf`, but noticed it wasn't always applying at the right time. I moved it to the **boot parameters** so it's picked up early, before the module loads.

Some users report better stability or compatibility (especially with **NVIDIA Open 570 DKMS** on Wayland) when GSP is **disabled**, especially in multi-monitor setups or when experiencing graphical bugs.

I'm still experimenting between `0` and `1`, but keeping it here gives me control.

---

## 💡 Where did these files come from?

- `customization.cfg`: From the `~/linux-tkg/` directory after choosing options during kernel build.
- `boot-entry.conf`: From `/boot/loader/entries/` after installing the TKG kernel (renamed for clarity).

---

## 🚀 Future Ideas

I plan to add:
- `zram-generator.conf` to track my ZRAM setup
- `mkinitcpio.conf` to track any custom hooks or compression options
- Benchmarks and metrics comparing `linux-tkg` to `linux-zen` or mainline
- Module config for NVIDIA, VFIO, and gaming

---

