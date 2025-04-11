# 🧾 Kernel Boot Parameters

This document explains various boot flags used across my custom kernels. These are passed to the kernel via systemd-boot entries or GRUB.

## 🔧 Memory & Swap

- `zswap.enabled=0`: Disable zswap (I use zram instead).
- `nowatchdog`: Disables the software watchdog timer to reduce latency.
- `quiet loglevel=3`: Reduce boot spam, cleaner logs.

## 🎮 NVIDIA-Specific

- `nvidia_drm.modeset=1`: Enables DRM KMS — required for Wayland.
- `nvidia.NVreg_EnableGpuFirmware=0`: Disables GSP firmware for stability (still testing).
- `nvidia.NVreg_UsePageAttributeTable=1`: Enables PAT (better throughput).
- `nvidia.NVreg_OpenRmEnableUnsupportedGpus=1`: Allows unsupported GPUs if needed.

## 🧬 CPU & Power

- `amd_pstate=passive`: Use AMD's passive power scaling (when enabled).
- `processor.max_cstate=5`: Limits deep CPU sleep states (can reduce latency).
