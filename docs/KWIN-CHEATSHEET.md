# KWin + Krohnkite Tiling WM Cheatsheet (Wayland, Arch, 60% Keyboard)

This is a minimal tiling window manager configuration using **KDE Plasma + Krohnkite** with a 60% keyboard in mind. All shortcuts are `Meta`-based (Windows key), inspired by Vim (`HJKL`) and designed for speed.

---

## 🔁 Restart KWin (Wayland)

```bash
krestart
```

Defined as a ZSH function:

```zsh
krestart() {
  echo "[KWin] Reloading config and restarting Wayland compositor..."
  qdbus org.kde.KWin /KWin org.kde.KWin.reloadConfig
  kwin_wayland --replace & disown
}
```

---

## 🧠 Navigation

| Action      | Shortcut   |
| ----------- | ---------- |
| Focus Left  | `Meta + H` |
| Focus Down  | `Meta + J` |
| Focus Up    | `Meta + K` |
| Focus Right | `Meta + L` |

## 🔀 Move Windows

| Action     | Shortcut           |
| ---------- | ------------------ |
| Move Left  | `Meta + Shift + H` |
| Move Down  | `Meta + Shift + J` |
| Move Up    | `Meta + Shift + K` |
| Move Right | `Meta + Shift + L` |

## ↔ Resize Tiles

| Action        | Shortcut          |
| ------------- | ----------------- |
| Grow Width    | `Meta + Ctrl + L` |
| Shrink Width  | `Meta + Ctrl + H` |
| Grow Height   | `Meta + Ctrl + J` |
| Shrink Height | `Meta + Ctrl + K` |

## 🧱 Layout Control

| Action            | Shortcut           |
| ----------------- | ------------------ |
| Next Layout       | `Meta + \`         |
| Monocle Layout    | `Meta + M`         |
| Toggle Float      | `Meta + F`         |
| Toggle Float All  | `Meta + Shift + F` |
| Set Master Window | `Meta + Return`    |

## 🧼 System / Misc

| Action                     | Shortcut                |
| -------------------------- | ----------------------- |
| Kill Window                | `Meta + Ctrl + Esc`     |
| Close Window               | `Alt + F4`              |
| Overview / Present Windows | `Meta + W` / `Meta + T` |
| Show Desktop               | `Meta + D`              |

## ❌ Disabled Zoom

Zoom is permanently disabled:

```ini
[Plugins]
zoomEnabled=false
```

All zoom keybindings removed from `kglobalshortcutsrc`.

---

## 📝 Files to Watch

* `~/.config/kwinrc` → Plugin and effect toggles
* `~/.config/kglobalshortcutsrc` → Keybinding definitions

---

## 💡 Tips

* Use `krestart` after editing either file.
* Keybindings are optimized for 60% keyboards: no F-keys required.
* Customize layouts further using Krohnkite layout cycle (`Meta + \`).

---

Arch Linux + KDE + Wayland + Krohnkite FTW ✨

