# Battle.net / WoW Classic Anniversary - Linux Troubleshooting Reference

> System: Arch (CachyOS) | Wayland (KDE/KWin) | NVIDIA RTX 5090 (open 590.48) | Proton-GE | Steam (native)
> CPU: AMD Ryzen 9 9950X3D (+ RADV Raphael Mendocino iGPU) | RAM: 60.5 GB | Storage: btrfs on NVMe
> Kernel: 6.18.7-273-tkg-linux-ghost
> Battle.net AppID: 3090424623 | Proton: GE-Proton10-29 (system pkg `/usr/share/steam/compatibilitytools.d/proton-ge-custom/`)
> Monitors: DP-2 3840x2160@240Hz (primary) + DP-3 2560x1440@360Hz (secondary)
> Wine prefix: `~/.local/share/Steam/steamapps/compatdata/3090424623/pfx/`
> WoW Classic Anniversary: `pfx/drive_c/Program Files (x86)/World of Warcraft/_anniversary_/`

---

## Session 2 (2026-01-30): WoW Classic Anniversary 5-15 Minute Launch Hang — FIXED

### Problem

WoW Classic Anniversary Edition would hang for 5-15 minutes after launching before showing a window. The process would start, open data files (300+ FDs), write `cpu.log`, then sit in a polling loop doing nothing. Eventually it would break out and initialize graphics. WoW Retail worked fine. All Proton versions (GE, Experimental, 10.0) were affected. The issue was intermittent — it was working earlier the same day.

### Root Cause

**Stale/corrupt `Config.wtf` causing a startup polling loop.**

Classic's main thread entered a 50ms `pselect(0, NULL, NULL, NULL, {0, 50ms})` polling loop — a timed sleep with zero file descriptors. Between each sleep, it would:
1. `recvmsg(fd 15)` → EAGAIN (socket never had data)
2. Check wineserver (fd 5) → working fine
3. Make wineserver requests (fd 7/8) → working fine
4. `futex_wake` multiple threads
5. Repeat

This loop ran for 5-15 minutes until an internal timeout expired, at which point Classic proceeded to initialize graphics normally. The polling was triggered by mismatched state in `Config.wtf` — specifically `currentGameMode "12"` conflicting with the launch parameter `-initialgamemode=standard`.

### Fix

The game itself fixed its config when it finally ran and saved properly. The rewritten `Config.wtf` changed `currentGameMode` from `"12"` to `"8"` (matching the `standard` launch mode) and cleaned up stale entries. After this, Classic launched instantly on every subsequent attempt.

**If it happens again**, delete and let the game regenerate:
```bash
rm "/home/chris/.local/share/Steam/steamapps/compatdata/3090424623/pfx/drive_c/Program Files (x86)/World of Warcraft/_anniversary_/WTF/Config.wtf"
```

> **Note:** Battle.net will delete any manually-created Config.wtf during its launch sequence. The game regenerates its own on first run. Manual edits must be made after the game has created the file and before the next launch.

### Additional Config.wtf fixes applied

```
SET gxWindow "1"           # Fullscreen windowed (borderless) mode
SET GxMaximize "1"         # Maximize window
SET GxMonitor "0"          # Force primary monitor (DP-2 3840x2160)
SET GxAdapter "NVIDIA GeForce RTX 5090"
SET GxFullscreenResolution "3840x2160"
SET gxApi "d3d12"
SET targetFPS "200"
SET LowLatencyMode "2"    # NVIDIA Reflex
```

### Investigation timeline

| Time | Finding |
|------|---------|
| Started | IPv6 already disabled (session 1), same 15-min hang persists |
| | DNS changed from 10.0.0.2 (local) to 1.1.1.1 — `telemetry-in.battle.net` was failing to resolve. Did not fix hang. |
| | Found Classic process (PID 35008) with 30 threads. Main thread in `do_select`/pselect6. All game logs empty. |
| | Two SYN_SENT connections to 34.36.57.103:443 found — confirmed NOT from Classic (socket inodes not in /proc/PID/fd) |
| | nftables checked: all chains `policy accept`, no blocking rules. Docker/libvirt tables only. Not the issue. |
| | Classic's gx.log: 5 min 35 sec gap between cpu.log (00:36:49) and graphics init (00:42:24). Battle.net Agent and app logs show nothing during the gap. |
| | Battle.net Agent log: `authorization` token changed during the gap (re-auth happened), but Agent was idle. Delay is inside WoWClassic.exe. |
| | Reduced `tcp_syn_retries` from 6→2 — no effect. Confirmed via strace that Classic makes NO outbound TCP during the hang. |
| | **strace captured polling loop**: `pselect6(0, NULL, NULL, NULL, {50ms})` + `recvmsg(fd 15) → EAGAIN` repeating. Classic is busy-waiting, not doing I/O. |
| | Launched Classic directly without `-launcherlogin` — **same hang**. Credential handoff is not the cause. |
| | Config.wtf was rewritten by the game after a successful run — `currentGameMode` changed from 12→8. **Subsequent launches were instant.** |
| | Added `gxWindow "1"` and `GxMonitor "0"` to fix fullscreen windowed mode on primary monitor. |

### What was ruled out

| Suspect | Why it's not the cause |
|---------|----------------------|
| nftables/firewall | All chains `policy accept`, no blocking rules |
| TCP connection timeouts | strace shows zero outbound TCP during hang; `tcp_syn_retries=2` had no effect |
| DNS resolution | Changed to 1.1.1.1, all hostnames resolve; hang is not network-related |
| IPv6 | Already disabled in session 1; no IPv6 sockets from Classic |
| `-launcherlogin` credential handoff | Same hang without the flag |
| Custom vkd3d-proton build | SHA256 confirmed stock Proton-GE DLLs everywhere (prefix, Proton-GE, Proton Experimental) |
| Battle.net Agent | Registered game session in <1 second, idle during hang |
| Battle.net app | Completed auth in <5 seconds, idle during hang |
| Proton version | All versions (GE, Experimental, 10.0) had the same behavior |
| NVIDIA driver | No dmesg errors; gx.log shows correct GPU detection and D3D12 device creation when Classic finally starts |
| AMD iGPU interference | Classic correctly selects NVIDIA RTX 5090 via `GxAdapter` config |
| Shader cache corruption | Hang occurs before graphics initialization (before gx.log) |
| Wine prefix corruption | Prefix DLLs match stock; registry intact |

---

## Session 1 (2026-01-29): Battle.net Launch Issues — Summary

### Fixed in session 1
- **IPv6 disabled** (`/etc/sysctl.d/99-sysctl.conf`) — Wine timing out on AAAA records
- **compatdata/0/ deleted** — stuck in prefix upgrade loop
- **~/.config/protonfixes/ created** — was missing, caused warnings
- **bnet-fix function** added to `~/.zshrc` for killing orphaned Wine processes

### Key discovery from session 1
Battle.net IS launching but Steam loses PID tracking. Battle.net forks via Agent.exe, parent exits, Steam marks game as stopped. The game continues running invisibly.

---

## System Configuration

### Launch options (Steam)
```
QTWEBENGINE_DISABLE_SANDBOX=1 %command%
```
No other environment variables needed. Do NOT add `DXVK_FILTER_DEVICE_NAME` or `gamemoderun`.

### DNS
```
# /etc/resolv.conf
nameserver 1.1.1.1
```
Changed from local 10.0.0.2 (was failing to resolve `telemetry-in.battle.net`).

### IPv6
```
# /etc/sysctl.d/99-sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

### Network (verified good)
| Setting | Value |
|---------|-------|
| TCP congestion | BBR + fq |
| tcp_keepalive_time | 120s |
| tcp_syn_retries | 6 (default, was temporarily set to 2 during testing) |
| nftables | accept-all on inet filter; Docker/libvirt tables only |
| MTU | 1500, no fragmentation |

### Proton versions available
| Version | Path | Notes |
|---------|------|-------|
| Proton-GE 10-29 | `/usr/share/steam/compatibilitytools.d/proton-ge-custom/` | System package (AUR), current default |
| Proton Experimental | `~/.local/share/Steam/steamapps/common/Proton - Experimental/` | 10.0-20260127 |
| Proton 10.0 | `~/.local/share/Steam/steamapps/common/Proton 10.0/` | 10.0-4 |

All share the same Wine prefix at `compatdata/3090424623/pfx/`.

### Custom vkd3d-proton (~/vkd3d-proton/)
Experimental build with "DO NOT MERGE" commits on branch. **Confirmed NOT installed** — SHA256 of built DLLs does not match any prefix or Proton installation. Safe to ignore.

### NVIDIA open-gpu-kernel-modules (~/open-gpu-kernel-modules/)
Has PR #28 for experimental Vulkan/DX12 fix. Not directly related to the Classic launch hang.

---

## Orphaned Process Cleanup

```bash
# In ~/.zshrc
bnet-fix() {
  pkill -9 -f 'Battle.net.exe'      2>/dev/null
  pkill -9 -f 'Agent.exe'           2>/dev/null
  pkill -9 -f 'BlizzardBrowser'     2>/dev/null
  pkill -9 -f 'WoWClassic.exe'      2>/dev/null
  pkill -9 -f 'xalia.exe'           2>/dev/null
  pkill -9 -f 'wineserver'          2>/dev/null
  pkill -9 -f 'wine-preloader'      2>/dev/null
}
```

---

## Quick Reference

```bash
# Check if Battle.net is running (even if Steam says Play)
ps aux | grep -E 'Battle|Agent|WoW' | grep -v grep

# Fix stuck processes
bnet-fix

# Find Battle.net window (KDE Wayland)
kdotool search --name "Battle.net"

# Delete Classic config to fix startup hang
rm "$HOME/.local/share/Steam/steamapps/compatdata/3090424623/pfx/drive_c/Program Files (x86)/World of Warcraft/_anniversary_/WTF/Config.wtf"

# Full nuclear reset
bnet-fix && steam -shutdown
# wait 10s, then: steam

# Verify IPv6 is disabled (should return 1)
sysctl net.ipv6.conf.all.disable_ipv6

# Check for orphaned processes
ps aux | grep -E 'wine|Battle|Blizzard|xalia|WoW' | grep -v grep

# Monitor for failing TCP connections during launch
ss -tnp state syn-sent

# Trace Classic's main thread during hang (needs strace installed)
sudo strace -p $(pgrep -f WoWClassic) -e trace=all -t -T 2>&1 | head -100
```

---

## Package Changes (2026-01-29) That May Be Relevant

| Time | Package | Change |
|------|---------|--------|
| 08:45 | lib32-glibc | 2.42+r51-1 → 2.42+r51-2 |
| 08:45 | kwin | 6.5.5-1 → 6.5.5-2 |
| 08:45 | kwin-polonium | 1.0rc-1.13 → 1.0rc-1.14 |
| 08:45 | lib32-openssl | 3.6.0-1 → 3.6.1-1 |
| 08:45 | lib32-curl | 8.18.0-3 → 8.18.0-4 |
| 15:38 | proton-ge-custom-bin | GE_Proton10_29-1 → GE_Proton10_29-2 |
| 15:38 | libva-nvidia-driver | 0.0.14-1 → 0.0.15-1 |

Old proton-ge package still in pacman cache: `/var/cache/pacman/pkg/proton-ge-custom-bin-1:GE_Proton10_29-1-x86_64.pkg.tar.zst`

---

## Known Wine/Proton Issues Relevant to This Setup

1. **Wine `INTERNET_OPTION_CONNECT_TIMEOUT` is a STUB** — Wine's wininet.dll ignores application-requested connection timeouts. If a game makes HTTP connections via wininet, failed connections fall back to kernel TCP SYN retry timeout (~127s with `tcp_syn_retries=6`). Not the direct cause of the Classic hang, but relevant for other timeout-related issues.

2. **Dual GPU (NVIDIA + AMD iGPU)** — `VK_ICD_FILENAMES` inside the pressure-vessel container includes both NVIDIA and Radeon ICDs. Games must explicitly select the NVIDIA adapter. Classic does this via `SET GxAdapter "NVIDIA GeForce RTX 5090"` in Config.wtf.

3. **Battle.net deletes Config.wtf during launch** — Observed in Agent logs: `Deleting File: C:/Program Files (x86)/World of Warcraft/_anniversary_/WTF/Config.wtf`. Manual config edits may be overwritten. The game regenerates the file on startup.
