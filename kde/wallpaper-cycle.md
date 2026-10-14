# 🖼️ Synced Wallpaper Cycling on KDE Plasma

[![KDE Plasma](https://img.shields.io/badge/KDE-Plasma-1D99F3?style=for-the-badge&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/) [![Wayland](https://img.shields.io/badge/Wayland-Protocol-5C6BC0?style=for-the-badge&logo=wayland&logoColor=white)](https://wayland.freedesktop.org/) [![systemd](https://img.shields.io/badge/systemd-user_timer-30D475?style=for-the-badge&logo=linux&logoColor=white)](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html)

Rotate through a curated wallpaper pool every 10 minutes with **every monitor
showing the same image**.

---

## 🧩 Why not Plasma's Slideshow plugin

Plasma's built-in Slideshow wallpaper (`org.kde.slideshow`) runs a separate
timer and random pick **per screen**, so two monitors drift apart within one
cycle. There is no sync option. The fix is to pick one image outside Plasma
and push it to all desktops at once with `plasma-apply-wallpaperimage`, which
always targets every containment.

---

## 📁 Wallpaper pool

Two folders feed the rotation. The script scans both, top level only, for
`jpg` / `jpeg` / `png` / `webp` / `avif`.

| Folder | Contents |
|--------|----------|
| `~/Pictures/wallpapers/cycle/` | Symlinks to the hand-picked subset of `~/Pictures/wallpapers/` |
| `/data/projects/ghost/wallpapers/collection/` | Ghost project wallpaper set |

Add an image to the rotation by symlinking it into `cycle/`:

```bash
ln -s ~/Pictures/wallpapers/moonlit-desert.jpg ~/Pictures/wallpapers/cycle/
```

Remove one by deleting the symlink. The originals are never touched.

---

## 🔧 Script: [`scripts/wallpaper-cycle.sh`](../scripts/wallpaper-cycle.sh)

Installed to `~/.local/bin/wallpaper-cycle.sh`. Picks a random file from the
pool, skips the image shown last time, applies it to all screens, and records
the pick in `~/.local/state/wallpaper-cycle.last`.

Run it by hand any time to jump to the next wallpaper:

```bash
wallpaper-cycle.sh
```

---

## ⏱️ systemd user units

Tracked in [`system/systemd/user/`](../system/systemd/user/):

- `wallpaper-cycle.service` is a oneshot that runs the script after
  plasmashell is up.
- `wallpaper-cycle.timer` fires 30 s after the user session starts and every
  10 minutes after that.

Install both to `~/.config/systemd/user/` and enable once:

```bash
install -Dm755 scripts/wallpaper-cycle.sh ~/.local/bin/wallpaper-cycle.sh
install -Dm644 system/systemd/user/wallpaper-cycle.service ~/.config/systemd/user/wallpaper-cycle.service
install -Dm644 system/systemd/user/wallpaper-cycle.timer ~/.config/systemd/user/wallpaper-cycle.timer
systemctl --user daemon-reload
systemctl --user enable --now wallpaper-cycle.timer
```

Check it:

```bash
systemctl --user list-timers wallpaper-cycle.timer
journalctl --user -u wallpaper-cycle.service -n 5
```

---

## 🎛️ Tuning

- **Interval:** change `OnUnitActiveSec` in the timer, then
  `systemctl --user daemon-reload && systemctl --user restart wallpaper-cycle.timer`.
- **Fill mode:** `plasma-apply-wallpaperimage` keeps whatever the Image
  plugin already has. Set it once in *Configure Desktop and Wallpaper*
  (Scaled and Cropped is the default) and it sticks.
- **Pause:** `systemctl --user stop wallpaper-cycle.timer`; the current image
  stays until you start it again.

---

## 📎 Notes

- `plasma-apply-wallpaperimage` switches the desktops to the Image plugin
  (`org.kde.image`). Opening the Slideshow plugin again in settings will
  re-enable per-screen drift.
- A stale containment for a disconnected screen may still list
  `org.kde.slideshow` in `plasma-org.kde.plasma.desktop-appletsrc`. Harmless.
- `find` is run with `-maxdepth 1`, so nested folders in the pool are ignored.
