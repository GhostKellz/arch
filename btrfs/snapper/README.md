# Snapper

## Snapper Setup

### 1. Install Required Packages
```bash
sudo pacman -S snapper snap-pac btrfs-progs
```

### 2. Create Snapper Config for Root
```bash
sudo snapper -c root create-config /
```
This creates `/etc/snapper/configs/root`

### 3. Set Proper Permissions
```bash
sudo chmod a+rx /.snapshots
sudo chown :wheel /.snapshots
```

### 4. Enable Snapper Timers
```bash
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

The vendor timeline timer runs hourly. This workstation retains daily snapshots,
so install `../../system/systemd/snapper-timeline.timer.d/schedule.conf` under
`/etc/systemd/system/snapper-timeline.timer.d/` to avoid creating and deleting
hourly snapshots unnecessarily.

---

## Retention Policy

Current config keeps max ~17 snapshots:

| Type | Limit | Purpose |
|------|-------|---------|
| NUMBER_LIMIT | 10 | Pacman pre/post snapshots (~5 days of updates) |
| TIMELINE_LIMIT_DAILY | 7 | Daily safety net for non-pacman changes |
| TIMELINE_LIMIT_HOURLY | 0 | Disabled |
| TIMELINE_LIMIT_MONTHLY | 0 | Disabled |
| TIMELINE_LIMIT_YEARLY | 0 | Disabled |

Qgroups are intentionally disabled for workstation performance. Retention is
count-based; `SPACE_LIMIT` and `FREE_LIMIT` do not enforce space limits without
qgroups. Disk space is checked by the weekly maintenance job.

## Btrfs Scrub

Do not enable or launch the packaged per-filesystem scrub units on this
workstation. Starting the `/` and `/data` units together caused a hard desktop
lockup on 2026-07-21.

Use the tracked bounded service instead:

```bash
sudo install -Dm755 ../../scripts/btrfs-scrub-safe.sh /usr/local/bin/btrfs-scrub-safe
sudo install -Dm644 ../../system/systemd/btrfs-scrub-safe.service /etc/systemd/system/btrfs-scrub-safe.service
sudo install -Dm644 ../../system/systemd/btrfs-scrub-safe.timer /etc/systemd/system/btrfs-scrub-safe.timer
sudo install -Dm755 ../../scripts/weeklyMain.sh /usr/local/bin/weekly-maintenance
sudo install -Dm644 ../../system/systemd/weekMain.service /etc/systemd/system/weekMain.service
sudo install -Dm644 ../../system/systemd/weekMain.timer /etc/systemd/system/weekMain.timer
sudo systemctl daemon-reload
sudo systemctl enable --now weekMain.timer
sudo systemctl enable --now btrfs-scrub-safe.timer
```

It verifies `/` and `/data` sequentially, never concurrently; runs read-only;
caps each device at 64 MiB/s through both Btrfs and systemd cgroup controls;
refuses overlap; and skips when recent I/O pressure, load, or boot age makes
maintenance unsafe. It runs monthly, following upstream Btrfs guidance. The
timer is not persistent, so a missed run never catches up during boot.

Validate preflight logic without starting a scrub:

```bash
sudo /usr/local/bin/btrfs-scrub-safe --check
```

Do not put scrub or balance inside the general weekly maintenance script. Never
schedule balance routinely; inspect allocation first and run a filtered balance
only with explicit approval.

---

## Suggested Subvolume Layout
```
@          -> /
@home      -> /home
@snapshots -> /.snapshots
@pkg       -> /var/cache/pacman/pkg
@log       -> /var/log
```

Mount separately in `/etc/fstab`:
```bash
UUID=xxx  /               btrfs subvol=@,compress=zstd:3,ssd,discard=async,space_cache=v2  0 0
UUID=xxx  /home           btrfs subvol=@home,compress=zstd:3,ssd,discard=async,space_cache=v2  0 0
UUID=xxx  /.snapshots     btrfs subvol=@snapshots,compress=zstd:3,ssd,discard=async,space_cache=v2  0 0
UUID=xxx  /var/cache/pacman/pkg  btrfs subvol=@pkg,compress=zstd:3,ssd,discard=async,space_cache=v2  0 0
UUID=xxx  /var/log        btrfs subvol=@log,compress=zstd:3,ssd,discard=async,space_cache=v2  0 0
```

---

## Snapshot Management

### List Snapshots
```bash
snapper list
```

### Create Manual Snapshot
```bash
sudo snapper create -d "Before major update"
```

### Compare Snapshots
```bash
snapper diff 1..2
```

### Rollback to Snapshot (Manual)
Use a live ISO or recovery method to:
1. Mount btrfs toplevel: `mount -o subvolid=5 /dev/nvme0n1p2 /mnt`
2. Delete or rename current `@`
3. Snapshot the target: `btrfs subvolume snapshot /mnt/@snapshots/XX/snapshot /mnt/@`
4. Reboot

---

## Important: BTRFS Default Subvolume

Ensure the btrfs default subvolume points to `@`, not a snapshot:
```bash
# Check current default
sudo btrfs subvolume get-default /

# Set default to @ (get subvolid from: btrfs subvolume list /)
sudo btrfs subvolume set-default <subvolid-of-@> /
```

Boot entries should always specify `rootflags=subvol=@` explicitly.

---

## Notes
- `snap-pac` auto-creates pre/post snapshots for every pacman transaction
- Snapper won't snapshot `/home` by default unless you create a config for it
- Use `snapper -c root cleanup number` to manually trigger cleanup
