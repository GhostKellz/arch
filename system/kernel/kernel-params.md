# 🧾 Kernel Boot Parameters

This document explains various boot flags used across my custom kernels. These are passed to the kernel via systemd-boot entries or GRUB.

## 🔧 Memory & Swap

- `zswap.enabled=0`: Disable zswap (I use zram instead).
- `quiet loglevel=3`: Reduce boot spam, cleaner logs.

## 🎮 NVIDIA-Specific

- `nvidia_drm.modeset=1`: Enables DRM KMS — required for Wayland.
- `nvidia.NVreg_PreserveVideoMemoryAllocations=1`: Preserves VRAM across
  suspend when the NVIDIA systemd sleep units are enabled.

Module configuration in `../../nvidia/nvidia.conf` explicitly enables supported
firmware and Resizable BAR behavior and stores suspend VRAM under disk-backed
`/var/tmp`. Rejected, undocumented, and unsupported-GPU overrides are omitted.

Keep the NMI watchdog enabled on this workstation so a future hard lockup can
produce diagnostic evidence.

## 🧬 CPU & Power

- `amd_pstate=passive`: Use AMD's passive power scaling (when enabled).
- `processor.max_cstate=5`: Limits deep CPU sleep states (can reduce latency).
