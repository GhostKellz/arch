# BTRFS Snapper 

## Snapper Setup 

### 1. Install Required Packages
```bash
sudo pacman -S snapper btrfs-progs grub grub-btrfs
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

### 5. Add Grub Hook (Optional for boot snapshot recovery)
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

> Tip: You can use tools like `btrfs-assistant` (AUR) for GUI management.

---

## Suggested Subvolume Layout
```
@       -> /
@home   -> /home
@snapshots -> /.snapshots
```

Make sure each subvolume is mounted separately in `/etc/fstab`:
```bash
UUID=xxxxxx /               btrfs subvol=@       defaults,noatime,compress=zstd 0 1
UUID=xxxxxx /home           btrfs subvol=@home   defaults,noatime,compress=zstd 0 2
UUID=xxxxxx /.snapshots     btrfs subvol=@snapshots defaults,noatime,compress=zstd 0 2
```

---

## Snapshot Management

### List Snapshots
```bash
sudo snapper -c root list
```

### Create Manual Snapshot
```bash
sudo snapper -c root create --description "Before major update"
```

### Rollback to Snapshot (Manual)
Use a live ISO or recovery method to:
- Mount your root partition
- Delete current `@`
- Rename snapshot to `@`
- Reboot

---

## Optional GUI
- `btrfs-assistant` (AUR)
- `snapper-gui` (older, less maintained)

---

## Notes
- Snapper won’t snapshot `/home` by default unless you create a config for it
- Use `snap-pac` (AUR) to auto-create snapshots with `pacman`

---

**Next:** See `backup-strategy.md` for syncing snapshots to Synology or another external location.

