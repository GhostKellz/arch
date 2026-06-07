# Tiling Findings — Krohnkite / KDE Plasma 6 (Wayland)

Status: **Diagnostic only. No changes have been made to your system.**
Captured: investigation session, Plasma/KWin 6.6.5, Arch Linux.

---

## TL;DR (the corrected conclusion)

The most likely cause is **NOT a bug, NOT Polonium, NOT scaling, NOT a stale
`[Tiling]` block.** It is a **stuck Krohnkite layout cell**.

Krohnkite stores the active layout **independently for every
`(screen × virtual-desktop × activity)` combination** because your config has:

```
layoutPerDesktop  = true   (Krohnkite default)
layoutPerActivity = true   (Krohnkite default)
```

So **Desktop 1 + primary monitor** can be sitting on **Monocle** or **Floating**
layout while **Desktop 2** (and the right monitor) stay on **Tile**. That one
fact explains every symptom, including the ones the "it's a bug" theories could
not.

**This was triggered by a keybind, not a fault.** Most likely `Meta+M` (Monocle)
or a layout cycle via `Meta+|` while focused on Desktop 1 / primary monitor.

---

## Why this beats the earlier theories

The discriminating fact is **"a reboot fixes it."**

- `kwinrc` (the `[Tiling]` sections, electric-border settings, etc.) **survives
  reboots.** If stale saved config were the cause, a reboot would *reproduce*
  the bug, not fix it.
- Krohnkite's per-cell layout selection is **runtime state that resets on KWin
  restart.** A reboot wipes it back to the default Tile layout — which is
  exactly the behavior you see.

Therefore the cause must be **transient runtime state**, and the per-desktop /
per-screen independence is the only thing that explains "Desktop 2 perfect,
Desktop 1 broken" while Krohnkite is otherwise healthy.

### Symptom-by-symptom map

| Symptom | Cause under the "stuck layout cell" model |
|---|---|
| First window fills the whole monitor | Monocle layout maximizes (`monocleMaximize=true`) — looks fullscreen, is "by design" |
| Second terminal floats / won't tile beside it | Floating layout (or monocle stacking) — new window not placed in a tile |
| Desktop 2 flawless, Desktop 1 broken | Layout stored **per desktop** — only D1's cell is off Tile |
| Right monitor tiles, left does not | Layout stored **per screen** — independent cells |
| Moving a window to the other monitor "fixes" it | The other screen's cell is still Tile, so the window tiles there |
| **Reboot required to recover** | Layout selection is not persisted → resets to Tile on restart |
| `Meta+F` / `Meta+Shift+F` only partially help | Float toggle is a band-aid; it does not switch the layout back to Tile |

---

## What was RULED OUT (with evidence)

| Suspect | Verdict | Evidence captured |
|---|---|---|
| Polonium fighting Krohnkite | **Not the cause** | `poloniumEnabled` empty; no `EnabledByDefault`; no key in `kwinrc`. Installed but never loaded. |
| KZones | **Not the cause** | Not enabled; `EnabledByDefault=false`. |
| Monitor scaling mismatch | **Not the cause** | Both outputs `Scale: 1`. DP-2 (4K) at `0,0`, DP-3 (1440p) at `3840,0`. No fractional scaling. |
| Plasma version regression | **Not the cause** | Plasma/KWin **6.6.5** — past the 6.5.1 / 6.6.1 suspend & output fixes. |
| Wrong / unmaintained Krohnkite fork | **Not the cause** | On the maintained anametologin fork, **v0.9.9.2**. |
| Krohnkite crashing / errors | **Not the cause** | Journal shows it cleanly managing **both** DP-2 and DP-3 across desktops. No errors, no `output config failed`, no `unknown active output`. |
| Stale `[Tiling]` UUID blocks | **Clutter, not the trigger** | They persist across reboots; cannot explain "reboot fixes it." Worth cleaning for hygiene only. |

---

## Leading explanation (detail)

Krohnkite keeps a separate layout engine per `(output, desktop, activity)`.
Relevant defaults confirmed in
`~/.local/share/kwin/scripts/krohnkite/contents/config/main.xml`:

```
layoutPerActivity = true
layoutPerDesktop  = true
monocleMaximize   = true     # Monocle maximizes the focused window
soleWindowWidth   = 100      # a single tiled window fills the screen (normal!)
soleWindowHeight  = 100
screenDefaultLayout = (empty)
```

Note: `soleWindowWidth/Height = 100` means **one** tiled window correctly fills
the monitor. That is normal and is NOT the bug — the bug is the **second**
window not joining, which is what Monocle/Floating produces.

### Your layout shortcuts (from `kglobalshortcutsrc`)

```
Meta+M   = Monocle Layout        # maximizes -> looks fullscreen
Meta+|   = Previous Layout       # cycles layouts (can land on Floating, idx 8)
Meta+\   = (Next Layout is UNBOUND in your config)
Meta+F       = Toggle Float       (single window band-aid)
Meta+Shift+F = Toggle Float All   (band-aid)
KrohnkiteTileLayout = none        # <-- no dedicated "force Tile" key bound!
```

The absence of a bound **Tile Layout** key is why recovery is awkward: when a
cell is stuck on Monocle/Floating, you have no single press to force it back to
Tile, so you reach for float-toggle (which doesn't fix the layout) or reboot.

---

## HOW TO CONFIRM IT LIVE (definitive test — do this when it next breaks)

Non-destructive. Proves the theory in seconds.

1. When Desktop 1 / primary monitor is misbehaving, click a window on that
   monitor so it has focus.
2. Press **`Meta+M`** (toggle Monocle). Watch the windows.
   - If they snap into a side-by-side tiled layout → **confirmed: it was a
     stuck Monocle layout cell.**
3. If `Meta+M` doesn't do it, press **`Meta+|`** a few times to cycle layouts
   and stop on the standard Tile layout.
   - If tiling returns → **confirmed: it was a stuck layout (Floating/other)**,
     not a bug.
4. Note which desktop and which monitor you were on. If only Desktop 1 / primary
   needed it, that nails the per-cell explanation.

If neither restores tiling, capture logs while broken (see below) before
rebooting.

---

## NON-DESTRUCTIVE RECOVERY (no reboot needed)

In order of preference:

1. **Switch the layout back to Tile** on the affected desktop/monitor:
   `Meta+M` (toggle off Monocle) or `Meta+|` to cycle to Tile.
2. **Reload Krohnkite without a full reboot** (re-registers all windows):
   ```bash
   # Reload KWin config/scripts on Wayland (safe, no logout):
   qdbus org.kde.KWin /KWin reconfigure
   ```
   If that isn't enough, restarting the compositor on Wayland:
   ```bash
   # Wayland-safe KWin restart (your session stays up):
   kwin_wayland --replace &
   ```
   Caution: do NOT repeatedly toggle the script in System Settings as a habit —
   toggling can spawn duplicate Krohnkite instances. Prefer `reconfigure` or a
   single clean restart.

---

## RECOMMENDED PREVENTION (decide later — not applied)

These target the actual cause and make it self-correcting. **None are
applied yet.**

1. **Bind a dedicated "Tile Layout" panic key** so you always have a one-press
   escape back to tiling (currently unbound):
   - System Settings → Shortcuts → KWin → "Krohnkite: Tile Layout" → set e.g.
     `Meta+Ctrl+T`.
   - This is the single highest-value change. It turns a reboot into one keypress.

2. **Consider disabling per-desktop / per-activity layouts** if you want every
   desktop/monitor to always behave identically (removes the stuck-cell class of
   problem entirely):
   - Krohnkite settings → uncheck "Use separate layouts per desktop" and
     "per activity."
   - Trade-off: you lose the ability to have different layouts per desktop.

3. **Re-examine `Meta+M`** — it's very easy to fat-finger and silently flips the
   focused cell into maximizing Monocle. Consider remapping it to something less
   accidental, or leave it but rely on the panic key in #1.

### Secondary hygiene (NOT the cause — optional cleanup)

Only if you want a tidy config; these will not fix the layout-cell issue:

- Disable native edge tiling/maximize so KDE quick-tile never competes:
  `ElectricBorderMaximize=false`, `ElectricBorderTiling=false` (`[Windows]`).
- Add multi-monitor keys the fork suggests:
  `SeparateScreenFocus=true`, `ActiveMouseScreen=false` (`[Windows]`).
- Strip the 15 `[Tiling]` sections in `kwinrc` (4 active + ~9 stale orphan
  UUIDs from past monitor reconnects). Back up `kwinrc` first.
- Remove the inert Polonium install (user copy + `/usr/share/kwin/scripts/polonium`).

Apply config changes via `kwriteconfig6` + `qdbus org.kde.KWin /KWin reconfigure`
(a running KWin can overwrite manual `kwinrc` edits on exit).

---

## Manual verification you can do now

Open **System Settings → Window Management → Window Tiling** and look at the
**left/primary** monitor. If KDE shows a custom native tile layout there, note it
— but remember native custom tiling only grabs windows you *drag* into it; it
does not auto-tile new windows, so it is not the primary cause of this issue.

The more telling check is **live**: next time it breaks, do the `Meta+M` /
`Meta+|` test above.

---

## Logs to capture WHEN IT IS BROKEN (not now — it's healthy now)

The system is currently working, so the failing state isn't visible. Next time
Desktop 1 misbehaves, run these before rebooting and save the output:

```bash
# What Krohnkite is doing / any late-session messages:
journalctl --user -b 0 --no-pager | grep -i krohnkite

# Live-tail while you open a new terminal on the broken monitor:
journalctl --user -f | grep -i krohnkite

# Current outputs (confirm both still present & scale 1):
kscreen-doctor -o

# Confirm only Krohnkite is enabled:
grep -iE 'krohn|polonium|kzone' ~/.config/kwinrc | grep -i enabled
```

---

## Raw data captured this session

- Plasma / KWin: **6.6.5**
- Enabled tilers: **krohnkite only** (`krohnkiteEnabled=true`); polonium/kzones not enabled
- Krohnkite: anametologin fork **v0.9.9.2**, `~/.local/share/kwin/scripts/krohnkite/`
- Outputs:
  - **DP-2** (primary/left): `3840x2160@240`, geometry `0,0`, **Scale 1**, UUID `fdd0bb77-…`
  - **DP-3** (right): `2560x1440@360`, geometry `3840,0`, **Scale 1**, UUID `e9795afc-…`
- `[Windows]` group keys all UNSET (KWin defaults apply):
  `ElectricBorderMaximize`, `ElectricBorderTiling`, `SeparateScreenFocus`, `ActiveMouseScreen`
- `[Tiling]` sections: **15 total** (4 match current monitors; ~9 stale orphan UUIDs)
- Active desktop UUIDs: `d858c542-…` (Desktop 1), `1eeb31e9-…` (Desktop 2)
- Journal: no KWin/Krohnkite errors, no `output config failed`, no `unknown active output`
- An Activity UUID (`2fde5ea8-…`) appears for Desktop 2 in logs — relevant because
  `layoutPerActivity=true` adds Activity as another dimension to the layout-cell key.

---

## One-line summary

Desktop 1 / primary monitor is parked on a non-Tile Krohnkite layout
(Monocle or Floating) in its own per-desktop/per-screen layout cell; Desktop 2
is on Tile. Switch that cell back to Tile (`Meta+M` / `Meta+|`) — and bind a
dedicated Tile-Layout key so you never need to reboot for this again.
