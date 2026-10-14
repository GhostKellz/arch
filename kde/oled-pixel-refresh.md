# 🖥️ OLED Pixel Refresh on KDE Wayland

[![KDE Plasma](https://img.shields.io/badge/KDE-Plasma-1D99F3?style=for-the-badge&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/) [![Wayland](https://img.shields.io/badge/Wayland-Protocol-5C6BC0?style=for-the-badge&logo=wayland&logoColor=white)](https://wayland.freedesktop.org/) [![PowerDevil](https://img.shields.io/badge/PowerDevil-Idle_DPMS-3DAEE9?style=for-the-badge&logo=kde&logoColor=white)](https://invent.kde.org/plasma/powerdevil) [![NVIDIA Open Kernel](https://img.shields.io/badge/NVIDIA-Open_DKMS-76B900?style=for-the-badge&logo=nvidia&logoColor=white)](https://github.com/NVIDIA/open-gpu-kernel-modules)

How QD-OLED panel maintenance is handled on this workstation under KDE Wayland.

---

## 🧩 Panels

Model strings come from EDID
(`strings /sys/class/drm/card1-DP-*/edid`), all on `card1` (`0000:01:00.0`,
RTX 5090, NVIDIA open DKMS module).

| Output | Model | Panel | Mode |
|--------|-------|-------|------|
| `DP-2` | ASUS ROG Swift **PG32UCDM** | 32" QD-OLED (gen3) | 3840x2160 @ 240 Hz, HDR |
| `DP-3` | Alienware **AW2725DF** | 27" QD-OLED | 2560x1440 @ 360 Hz, HDR |
| *(incoming)* | ASUS **PG32UCDM3** | 32" QD-OLED (gen4) | 3840x2160 @ 240 Hz, DP 2.1 |

Capture the gen4 panel's model string from EDID once attached and correct the
table.

---

## ⚙️ What the panels need

A QD-OLED runs its compensation cycle when it **enters standby** — when the GPU
stops scanning out to it. It can't be triggered from the OS directly and won't
run while a signal is present. OLED Care on the PG32UCDM offers Screen Dimming
(Global / Outer), Adjust Logo Brightness, Screen Move, manual Pixel Cleaning,
and Pixel Cleaning Reminder — no toggle for the automatic cycle itself.

What ASUS actually documents for automatic Pixel Cleaning:

- It starts **~5 minutes after the panel enters standby** and the cycle takes
  ~5–6 minutes, with **AC power present** throughout.
- It runs in **Standard Mode only** — it does **not** commence in Power Saving
  Mode. Check the OSD power-saving setting on any panel that never seems to
  clean.
- The oft-quoted "~4 hours of panel-on time" is the **Pixel Cleaning
  *Reminder*** default, not a documented prerequisite for the automatic
  cycle. Do not assume a 4-hour gate; it is unverified.

Behaviour is firmware-dependent: the PG32UCDM MCM111 release notes cite an
"Enhanced Pixel Cleaning Mechanism" and changed indicator-light behaviour, so
record the exact firmware revision before characterizing a panel, and
re-characterize after flashing. Each panel tracks its own state — treat the
PG32UCDM, AW2725DF, and PG32UCDM3 as three independent devices; never carry a
measurement from one over to another.

The monitor's power button is a poor way to supply the window — switching back
on a few minutes later aborts the cycle. And a completed standby window is not
proof a clean ran: the only observable evidence is the panel itself (e.g. the
OSD pixel-clean counter advancing, or LED behaviour during the window). Log
"standby window completed", verify the clean separately.

So the host's job is simple: give the panels regular, unattended standby
windows. That's what the config below does.

---

## 🔧 Configuration

Idle DPMS in `~/.config/powerdevilrc` is what supplies those windows:

```ini
[AC][Display]
TurnOffDisplayWhenIdle=true
TurnOffDisplayIdleTimeoutSec=600
TurnOffDisplayIdleTimeoutWhenLockedSec=900
```

Set it via System Settings → Power Management, or:

```sh
kwriteconfig6 --file powerdevilrc --group AC --group Display \
  --key TurnOffDisplayWhenIdle true
kwriteconfig6 --file powerdevilrc --group AC --group Display \
  --key TurnOffDisplayIdleTimeoutSec 600
qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement \
  reparseConfiguration
```

`reparseConfiguration` applies it live — no session or service restart needed.

Ten idle minutes is short enough to catch normal breaks and long enough not to
blank mid-read. Nothing else idle-related is enabled: there is no suspend action
on AC, so idling never interrupts running work.

---

## 🎛️ Blanking on demand

```sh
kscreen-doctor --dpms off
```

This is the correct call on Wayland. `xset dpms force off` does nothing here —
it only reaches XWayland. Any input wakes the panels again; the session,
windows, and running processes are untouched throughout.

Bound to a shortcut, add a delay so the key release doesn't immediately wake the
displays:

```sh
sh -c 'sleep 1; kscreen-doctor --dpms off'
```

Lock and blank together when leaving the desk:

```sh
loginctl lock-session; sleep 2; kscreen-doctor --dpms off
```

`kscreen-doctor --dpms off` is all-or-nothing: there is no working per-output
exclusion in current Plasma (`--dpms-excluded` is not supported).

> Use DPMS off, not `kscreen-doctor output.DP-2.disable`. Disabling an output is
> a hotplug event and reshuffles windows onto the remaining screens. DPMS off
> keeps the output object intact.

---

## ✅ Checking it

```sh
sleep 3; kscreen-doctor --dpms off
```

Hands off the mouse and keyboard. Power LEDs should go amber/off within a second
or two, and stay there until you move the mouse.

A display that wakes on its own means something is generating input events —
sensor drift on a high-polling mouse is the usual cause, and it defeats the idle
timer as well.

If the panels don't blank while idle, check for idle inhibitors:

```sh
systemd-inhibit --list
```

Discord in a call, browser video, and Steam Big Picture all take real idle
inhibits. `delay`-mode inhibitors on `sleep` (NetworkManager, rtkit, UPower,
libvirt) are unrelated and harmless.

---

## ⚠️ Notes

- Running **manual** Pixel Cleaning from the OSD resets that panel's usage
  counter (and the reminder). Quiet immediately after a manual clean is
  expected.
- To verify a clean actually ran, use the OSD: OLED Panel Care shows a
  pixel-clean count. Note it before an unattended standby window and check it
  after — that's the only ground truth.
- Never cut AC to a panel that may be mid-cycle — no switched strips, no smart
  plugs on a timer.
- Leave Pixel Cleaning Reminder enabled so the monitor prompts at its threshold.
- PowerDevil drives the panels over DDC/CI (`/dev/i2c-5`, `/dev/i2c-6`) via
  libddcutil and logs noisy unsupported-feature probes. Harmless, though DDC
  transactions against a monitor in standby can be flaky.

---

## 🔌 Gen4 panel / DP 2.1

When the third panel lands, confirm it enters standby cleanly on
`kscreen-doctor --dpms off` while running its native DP 2.1 UHBR20 mode.
Link-training behaviour at UHBR20 on NVIDIA is the thing to watch; if it won't
blank, drop to DP 1.4 + DSC in the OSD and retest before suspecting KWin.

Re-check per-output DPMS behaviour once three outputs are live — the idle logic
is session-wide, but the panels each track their own hours.
