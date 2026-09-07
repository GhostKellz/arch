# 👻  KDE + Wayland GhostKellz Setup

[![KDE Plasma](https://img.shields.io/badge/KDE-Plasma-1D99F3?style=for-the-badge&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/) [![Wayland](https://img.shields.io/badge/Wayland-Protocol-5C6BC0?style=for-the-badge&logo=wayland&logoColor=white)](https://wayland.freedesktop.org/) [![NVIDIA Open Kernel](https://img.shields.io/badge/NVIDIA-Open_DKMS-76B900?style=for-the-badge&logo=nvidia&logoColor=white)](https://github.com/NVIDIA/open-gpu-kernel-modules) [![AMD Ryzen](https://img.shields.io/badge/Ryzen-9950X3D-ED1C24?style=for-the-badge&logo=amd&logoColor=white)](https://www.amd.com/en/processors/ryzen)

---

## ❄️ Frozen Screen Bug (Pageflip Timeout)

- **Symptom:** One monitor freezes or entire desktop becomes unresponsive under KDE Wayland.
- **Cause:** `Pageflip timed out! This is a bug in the nvidia-drm kernel driver` (see journal logs).
- **Temporary Fix:**
  - Switch to a TTY: `Ctrl + Alt + F3` (or F2/F4)
  - Return to graphical session: `Ctrl + Alt + F1`
  - This refreshes the compositor without rebooting or killing session. Or also logging off and logging back in.

**Current status:** this has not reproduced under standard usage with the
current NVIDIA Open source-DKMS module and CachyOS-LTO kernel. Treat any future
recurrence as a new incident and capture the exact kernel, driver, KWin, and
connector state rather than assuming the historical cause.

## 🪛 System Info

![System Info](../assets/CK-Arch-System.png)

## 🎮 Current NVIDIA RTX 5090 Config

[![NVIDIA RTX 5090](https://img.shields.io/badge/NVIDIA-RTX_5090_Config-76B900?style=for-the-badge&logo=nvidia&logoColor=white)](../nvidia/nvidia.conf)

## 🛠️ Workarounds (historical)
- Previously tested with TKG kernel (reduced occurrence)
- Alternative: Use GNOME (issue did not occur)
- Required kernel parameter or env var tweaks before fixes arrived.

## 📎 Notes
- Session was not killed—refresh only.
- Logout or reboot also resolved temporarily.
- Originally tied to power management or multi-monitor setups on NVIDIA.

---

Current hardware is a Ryzen 9 9950X3D and RTX 5090. Live driver and kernel
versions come from `dkms status` and `uname -r`.
