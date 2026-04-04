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
