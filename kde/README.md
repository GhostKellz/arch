# KDE + Wayland Quirks (NVIDIA)

## ❄️ Frozen Screen Bug (Pageflip Timeout)
- **Symptom:** One monitor freezes or entire desktop becomes unresponsive under KDE Wayland.
- **Cause:** `Pageflip timed out! This is a bug in the nvidia-drm kernel driver` (see journal logs).
- **Temporary Fix:**
  - Switch to a TTY: `Ctrl + Alt + F3` (or F2/F4)
  - Return to graphical session: `Ctrl + Alt + F1`
  - This refreshes the compositor without rebooting or killing session. Or also logging off and logging back in

## 🪛 System Info
- **GPU:** NVIDIA (check `nvidia-smi`)
- **Kernel:** TKG / Zen tested
- **Display Server:** Wayland (KWin)
- **Compositor:** KWin (KDE)

## 🛠️ Workarounds
- Tested with TKG kernel (reduced occurrence)
- Alternative: Use GNOME (issue does not occur)
- May require kernel parameter or env var tweaks

## 📂 Assets
- `assets/kde-wayland-nvidia-kwin-pageflip-timedout-error.png`: Screenshot of journal log with `pageflip timeout` errors

## 📎 Notes
- Session is not killed—refresh only.
- Logout or reboot will also resolve temporarily.
- Might be tied to power management or multi-monitor on NVIDIA.

---
