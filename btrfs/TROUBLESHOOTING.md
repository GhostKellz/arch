# BTRFS/Snapper Troubleshooting

Common issues and fixes.

---

## Snapper Issues

### "Cannot delete snapshot X since it is the next to be mounted snapshot"

The btrfs default subvolume points to that snapshot.

**Fix:**
```bash
# Check current default
sudo btrfs subvolume get-default /

# Get @ subvolume ID
sudo btrfs subvolume list / | grep "path @$"

# Set default to @
sudo btrfs subvolume set-default <ID-of-@> /

# Now delete works
sudo snapper delete <X>
```

### Snapshots Not Auto-Cleaning

Check if cleanup timer is running:
```bash
systemctl status snapper-cleanup.timer
```

Manually trigger cleanup:
```bash
sudo snapper cleanup number
sudo snapper cleanup timeline
```

Check config limits in `/etc/snapper/configs/root`.

### "snapper list" Shows Nothing

Config might be broken:
```bash
# Verify config exists
ls /etc/snapper/configs/

# Check .snapshots is mounted
findmnt /.snapshots

# If not mounted
sudo mount -a
```

---

## BTRFS Issues

### Filesystem Read-Only / Errors

```bash
# Check for errors
sudo btrfs device stats /

# Scrub to check integrity
sudo btrfs scrub start /
sudo btrfs scrub status /
```

### "No space left" But Disk Shows Free

BTRFS metadata might be full:
```bash
# Check actual usage
sudo btrfs filesystem usage /

# If metadata is full, rebalance
sudo btrfs balance start -dusage=50 /
```

### Subvolume Shows Wrong Size

BTRFS shares data via CoW. Use `compsize` for accurate measurement:
```bash
sudo pacman -S compsize
sudo compsize /@
```

---

## Boot Issues

### System Boots to Wrong Snapshot

Check boot entry has explicit subvol:
```bash
cat /boot/loader/entries/linux-cachyos-lto.conf
# Should have: rootflags=subvol=@
```

Check btrfs default:
```bash
sudo btrfs subvolume get-default /
# Should point to @, not a snapshot
```

### Boot Fails After Restore

From live USB:
```bash
# Mount and check
mount -o subvolid=5 /dev/nvme0n1p2 /mnt
ls /mnt/@  # Verify @ exists

# Check fstab has correct UUIDs
cat /mnt/@/etc/fstab
blkid /dev/nvme0n1p2  # Compare UUID
```

### initramfs Missing After Restore

Snapshots don't include /boot (separate partition). Regenerate:
```bash
# Mount properly
mount /dev/nvme0n1p2 /mnt -o subvol=@
mount /dev/nvme0n1p1 /mnt/boot
arch-chroot /mnt

# Regenerate
mkinitcpio -P
exit
```

---

## Disk Space Issues

### Find What's Using Space

```bash
# Overall usage
sudo btrfs filesystem usage /

# Per-subvolume (rough)
sudo btrfs subvolume list / | while read line; do
  path=$(echo $line | awk '{print $NF}')
  echo "$path"
done
```

### Delete Old Snapshots

```bash
# List all
snapper list

# Delete specific
sudo snapper delete <number>

# Delete range
sudo snapper delete <start>-<end>
```

### Reclaim Space After Deletion

BTRFS doesn't immediately free space. Force with:
```bash
sudo btrfs filesystem sync /
sudo fstrim -v /  # If SSD
```

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `snapper list` | List snapshots |
| `sudo btrfs subvolume list /` | List all subvolumes |
| `sudo btrfs filesystem usage /` | Disk usage breakdown |
| `sudo btrfs subvolume get-default /` | Check default subvol |
| `findmnt -no SOURCE /` | Check what's mounted as root |
| `sudo btrfs scrub start /` | Check filesystem integrity |
