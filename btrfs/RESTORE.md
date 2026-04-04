# BTRFS Restore Guide

Restoring from snapshots on this system (systemd-boot, NVMe).

---

## Prerequisites

- Live USB (Arch ISO or CachyOS ISO)
- Know your root partition: `/dev/nvme0n1p2`
- Know your target snapshot number (from `snapper list`)

---

## Method 1: Restore from Snapper Snapshot (Recommended)

### 1. Boot Live USB

### 2. Mount BTRFS Toplevel
```bash
mount -o subvolid=5 /dev/nvme0n1p2 /mnt
```

### 3. Check Available Snapshots
```bash
ls /mnt/@snapshots/
```

### 4. Backup Current Root (Optional)
```bash
mv /mnt/@ /mnt/@.broken
```

### 5. Create New Root from Snapshot
```bash
btrfs subvolume snapshot /mnt/@snapshots/<NUMBER>/snapshot /mnt/@
```

### 6. Cleanup (After Confirming System Works)
```bash
btrfs subvolume delete /mnt/@.broken
```

### 7. Unmount and Reboot
```bash
umount /mnt
reboot
```

---

## Method 2: Rollback Using Snapper (If System Boots)

If the system still boots but is broken:

```bash
# List snapshots
snapper list

# Rollback to snapshot (creates a new snapshot of current state first)
sudo snapper rollback <NUMBER>

# Reboot
sudo reboot
```

---

## Verify After Restore

```bash
# Check you're on @ subvolume
findmnt -no SOURCE /

# Should show: /dev/nvme0n1p2[/@]

# Verify btrfs default points to @
sudo btrfs subvolume get-default /

# Should show: ID XXXX ... path @
```

---

## Partition Layout Reference

| Partition | Mount | Subvolume |
|-----------|-------|-----------|
| nvme0n1p1 | /boot | (vfat EFI) |
| nvme0n1p2 | / | @ |
| nvme0n1p2 | /home | @home |
| nvme0n1p2 | /.snapshots | @snapshots |
| nvme0n1p2 | /var/cache/pacman/pkg | @pkg |
| nvme0n1p2 | /var/log | @log |

---

## Boot Entry Reference

Located at `/boot/loader/entries/linux-cachyos-lto.conf`:

```
title   linux-cachyos
linux   /vmlinuz-linux-cachyos-lto
initrd  /amd-ucode.img
initrd  /initramfs-linux-cachyos-lto.img
options root=UUID=cd054ef0-41f2-4df5-ba65-2b1d8dd50021 rw rootflags=subvol=@ ...
```

The `rootflags=subvol=@` ensures boot always uses @ regardless of btrfs default.

---

## Emergency: If @ Is Completely Gone

```bash
# Mount toplevel
mount -o subvolid=5 /dev/nvme0n1p2 /mnt

# List what exists
btrfs subvolume list /mnt

# Pick a snapshot and restore
btrfs subvolume snapshot /mnt/@snapshots/<NUMBER>/snapshot /mnt/@

# Ensure default is set to new @
btrfs subvolume show /mnt/@  # Note the subvolume ID
btrfs subvolume set-default <ID> /mnt

# Unmount and reboot
umount /mnt
reboot
```
