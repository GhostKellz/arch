# NVIDIA + Wayland Sync Issues

This document addresses issues related to screen tearing, stuttering, and frame synchronization when using NVIDIA GPUs under Wayland compositors.

---

## Common Issues

- Tearing or stuttering in full-screen applications
- Improper vsync/frame pacing
- One monitor freezing or lagging randomly
- Compositor not honoring frame callback timing (especially on multi-monitor setups)

---

## Fixes & Workarounds

### 1. Enable Explicit Sync (If supported by your compositor)

Some compositors (e.g., GNOME, KDE Plasma, and recent versions of Hyprland) have started implementing explicit synchronization.

Check session type:

```bash
echo $XDG_SESSION_TYPE
```

If it returns `wayland`, ensure:

- You are using NVIDIA driver version 525 or later
- Kernel version is 6.1 or later
- Add this to your environment (e.g., in `/etc/environment`):

```bash
__GLX_VENDOR_LIBRARY_NAME=nvidia
```

You may also try adding:

```bash
WLR_NO_HARDWARE_CURSORS=1
```

---

### 2. Enable DRM Modeset

Required for proper Wayland support:

```bash
sudo mkdir -p /etc/modprobe.d
echo "options nvidia-drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf
sudo mkinitcpio -P
```

Then reboot your system.

---

### 3. Compositor-Specific Flags

For **Hyprland** users, you can try:

```ini
# ~/.config/hypr/hyprland.conf
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```

You may also want to experiment with these launch options:

```bash
__GL_GSYNC_ALLOWED=1 __GL_VRR_ALLOWED=1 __GL_YIELD="USLEEP"
```

---

## Notes

- Monitor freezing may be due to one display being set to a mismatched refresh rate. Try aligning them.
- Explicit sync and DRM modesetting are both required for Wayland + NVIDIA to function well.
- Currently using NVIDIA open drivers (v590+) with KDE Plasma as primary DE.
- Hyprland will be tested and used more extensively in future workflows.
 may be due to one display being set to a mismatched refresh rate. Try aligning them.
- Explicit sync and DRM modesetting are both required for Wayland + NVIDIA to function well.

---

## Contribution

Please update this file as new NVIDIA drivers and Wayland compositor features are released. Every minor version can drastically change behavior.

