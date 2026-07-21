# Arch Linux Scripts 👻🔥🌐

> **by GhostKellz**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Zsh Powered](https://img.shields.io/badge/Shell-Zsh-89e051?logo=gnu-bash&logoColor=white)](https://www.zsh.org)

---

## 🔍 About

This is a curated, professional-grade collection of ZSH-powered scripts for managing and optimizing my **personal Arch Linux workstation** setup. Focused on:

- Automating post-install tasks
- Bulletproof kernel upgrades and fallbacks
- Secure GPG key syncing
- Full system resilience and rollback ability

Every script here is designed for **speed**, **stability**, and **GhostKellz-level efficiency**.

---

## 🔧 Scripts Included

### `weeklyMain.sh`
_Weekly Maintenance for Arch Systems_

- Reports filesystem capacity, Btrfs allocation/error counters, scrub status,
  Snapper cleanup status, memory/zram/PSI state, OOM services, journal usage,
  and failed units.
- Bounds potentially slow inspection commands with `timeout`; one failed check
  does not strand the rest of the weekly report.
- Cleans only the pacman cache, retaining two package versions.
- Runs at idle CPU/I/O priority from `weekMain.timer`.
- Does **not** perform unattended package/AUR upgrades, remove packages, balance
  Btrfs, rebuild DKMS modules, or modify user development environments.
- `weeklyMain.sh` never launches scrub or balance.
- `--check` verifies dependencies and PSI interfaces without performing cache
  cleanup or Btrfs inspection.

### `btrfs-scrub-safe.sh`

- Verifies `/` and `/data` sequentially and read-only.
- Limits each device to 64 MiB/s and uses idle systemd CPU/I/O priority.
- Uses an exclusive lock and refuses to overlap another run.
- Skips when boot age, load, or I/O pressure indicates an interactive or busy
  workstation.
- It is called monthly by `btrfs-scrub-safe.timer`, following upstream Btrfs
  guidance.
- The timer is non-persistent and does not catch up at boot.
- `--check` validates gates and mounts while guaranteeing that no scrub starts.

Install the tracked script and units:

```bash
sudo install -Dm755 weeklyMain.sh /usr/local/bin/weekly-maintenance
sudo install -Dm644 ../system/systemd/weekMain.service /etc/systemd/system/weekMain.service
sudo install -Dm644 ../system/systemd/weekMain.timer /etc/systemd/system/weekMain.timer
sudo install -Dm755 btrfs-scrub-safe.sh /usr/local/bin/btrfs-scrub-safe
sudo install -Dm644 ../system/systemd/btrfs-scrub-safe.service /etc/systemd/system/btrfs-scrub-safe.service
sudo install -Dm644 ../system/systemd/btrfs-scrub-safe.timer /etc/systemd/system/btrfs-scrub-safe.timer
sudo systemctl daemon-reload
sudo systemctl disable --now btrfs-scrub@-.timer btrfs-scrub@data.timer
sudo systemctl enable --now weekMain.timer btrfs-scrub-safe.timer
sudo /usr/local/bin/weekly-maintenance --check
sudo /usr/local/bin/btrfs-scrub-safe --check
```

The final two commands are preflight-only. Never test the service by manually
launching a production scrub.

### `agent-scope.sh`

Runs an agent, compiler, analyzer, or test command inside the aggregate
`agent-workload.slice` memory boundary:

```bash
agent-scope.sh codex
agent-scope.sh cargo test --workspace
```

Install it as `~/.local/bin/agent-scope` after installing
`../system/systemd/user/agent-workload.slice` in the user systemd directory.
The tracked zsh configuration resolves the real executables through `PATH`, then
wraps ordinary `codex`, `claude`, and `gemini` commands with `agent-scope`.
Explicit `codex-unscoped`, `claude-unscoped`, and `gemini-unscoped` escape
commands bypass the slice for exceptional monitored work. Non-zsh launchers
must invoke `agent-scope` explicitly.


### `bootstrap.sh`
_Experimental Fresh Arch Workstation Bootstrap_

> **Prototype:** this is intentionally dry-run-first and has not yet been
> validated on a clean installation. Review its complete output before using
> `--apply`. It is not a recovery script and does not replace tested backups.

The repository checkout is the source of truth. On a fresh machine, clone it as
the target user rather than installing it under root-owned `/opt`:

```bash
git clone https://github.com/GhostKellz/arch.git "$HOME/arch" && \
  "$HOME/arch/scripts/bootstrap.sh"
```

That command performs a dry run. After reviewing the plan:

```bash
"$HOME/arch/scripts/bootstrap.sh" --apply
```

The baseline installs curated official Arch packages for Plasma/Wayland,
PipeWire, OBS/content creation, development, virtualization, containers, and
the workstation shell;
deploys the tracked Zsh,
Powerlevel10k, Oh My Zsh plugin, Neovim, Ghostty, tmux, and vivid configuration;
installs the workstation memory, journald, NVIDIA, and agent workload policies;
enables NetworkManager, libvirt, Docker, Tailscale, and cron; and adds a weekly
user cron entry for `update-rust.zsh`. Pacman remains interactive, existing user
configuration is backed up under `~/.local/state/ghostkellz-bootstrap/`, and the
Rust job never deletes pinned toolchains. Replaced system files are backed up
under `/var/lib/ghostkellz-bootstrap/backups/`.

Riskier or machine-specific stages require explicit flags:

```bash
# Install CLIs under ~/.local; login remains manual.
./scripts/bootstrap.sh --apply --with-agent-clis

# Configure Snapper only after checking the Btrfs layout.
./scripts/bootstrap.sh --apply --with-snapper

# Install the bounded timers; their preflights do not start a scrub.
./scripts/bootstrap.sh --apply --with-maintenance

# Create disabled NetworkManager profiles without activating or cutting over.
./scripts/bootstrap.sh --apply --bridge-parent enp1s0 --bridge-name br0

# Explicitly rebuild all installed mkinitcpio presets after policy deployment.
./scripts/bootstrap.sh --apply --rebuild-initramfs

# Add OBS virtual-camera support (builds a DKMS module).
./scripts/bootstrap.sh --apply --with-obs-virtual-camera
```

OBS Studio itself includes PipeWire screen capture, NVENC, and WebSocket
support. The baseline adds KDE and GTK portal backends, GStreamer and background
removal plugins, and deploys a sanitized 1080p60 NVENC/MKV profile. It never
copies scenes, streaming services or keys, WebSocket credentials, browser
sources, cookies, logs, or profiler captures into the public repository. Select
the `GhostKellz` profile after first launch and configure devices and accounts
locally.

The agent packages follow their official npm installation paths:
`@openai/codex`, `@anthropic-ai/claude-code`, and
`@google/gemini-cli`. They are installed with a user prefix and the bootstrap
never starts an authentication flow or handles credentials.

Current exclusions are deliberate: it does not install or build the custom
CachyOS-LTO kernel, enable AUR helpers, modify systemd-boot entries, activate a
bridge, run a Btrfs scrub or balance, repartition disks, rewrite fstab, configure
Tailscale authentication, or reboot. Snapper refuses automatic creation when an
existing `/.snapshots` mount needs topology review.

The NVIDIA driver is also deliberately excluded from the generic pacman set.
This workstation uses `~/open-gpu-kernel-modules` registered as
`nvidia-open/<version>` in DKMS plus the exactly matching `nvidia-utils-beta`
and `lib32-nvidia-utils-beta` userland packages. The bootstrap checks version
consistency when that source tree exists, but it does not replace the source
tree, install the stable Arch driver over it, fetch unreviewed AUR packaging, or
perform a heavy DKMS build. The driver/userland update must be designed as a
separate atomic, version-locked stage before it becomes bootstrap automation.

### `gpgsync.sh`
_GPG + Keyring Auto-Sync_
- Refreshes pacman keys and GPG trust DB nightly.
- Cron-ready for background syncing.

### `ghost-kernel-install.sh`
_Custom Kernel Installer + Failsafe Backup_
- Builds custom `linux-tkg` kernels
- Fully backs up `/boot`, `initramfs`, `/lib/modules` into `/data/recovery/<timestamp>`
- Optionally Snapper snapshot before any kernel install
- Auto-updates systemd-boot entries
- Sets default kernel cleanly

### `ghostboot.zsh`
_Boot Image Cleaner_
- Smartly cleans old `/boot` kernels and initramfs files
- Prevents boot partition overflow
- Only keeps your active working kernels (safe and quick!)

### 🌐 `update-root-hints.zsh`
_Weekly Root DNS Hints Refresher._

This script automates downloading the latest `root.hints` file from [Internic](https://www.internic.net/domain/named.root).  
Keeping your root servers up-to-date ensures maximum resolver reliability, DNSSEC validation, and minimal lookup errors.

It automatically:
- Downloads the newest root hints to `/var/lib/unbound/root.hints`
- Restarts Unbound cleanly to apply updates
- Is scheduled via `systemd` to run once a week without any user action required
- No manual steps are needed under normal conditions — the systemd timer handles everything.


_Example usage (manual):_
```bash
sudo /usr/local/bin/update-root-hints.zsh
```

### `autozig.zsh`
_Automated Zig Dev Build Updater_

Keeps your Zig 0.16.0-dev installation up-to-date with the latest master builds from [ziglang.org](https://ziglang.org/download/).

- Fetches build info from Zig's official JSON API
- Downloads the latest `x86_64-linux` tarball
- Verifies SHA256 checksum before installing
- Installs to `/opt/zig-0.16.0-dev` with clean overwrites
- Tracks installed version to skip redundant downloads
- Cron-ready: runs daily at 4am via root crontab

_Example usage (manual):_
```bash
~/arch/scripts/autozig.zsh
```

_Cron log location:_ `/var/log/autozig.log`

---

## 🔍 Example Usage

```bash
cd ~/arch/scripts
./ghostboot.zsh
```
```bash
cd ~/ghostctl
./ghost-kernel-install.sh
```

---

## 🚀 Features

- 🌐 Full ZSH script style for speed and clarity
- 🔍 Minimal safe dependency footprint
- 🔧 Designed around **BTRFS root** + **systemd-boot** workflow
- 💀 Resilient against failed kernel upgrades or NVIDIA DKMS issues
- 🔔 Cron-ready tools for unattended maintenance
- 👻 Ghost-themed branding throughout

---

## 🧹 Future Plans

- Dotfile backup automation
- Automated Snapper pre/post snapshot scripts
- Faster Nvidia DKMS build detection hooks
- Full GitHub Actions template for GhostKellz Arch recovery system

---

> This repository is actively developed by **GhostKellz** under **CK Technology**. Scripts are version-controlled and battle-tested. Updates incoming!
