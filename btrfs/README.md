# Backup Strategy for Arch with BTRFS and Synology NAS

This guide outlines a hybrid local + remote backup strategy using BTRFS snapshots and syncing them to a Synology NAS.

---

## 📸 Step 1: Take Snapshots with Snapper
Use Snapper to automate snapshot creation on your BTRFS system.

### Enable Snapshot Timers
```bash
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

### Optional: Auto-snapshot on `pacman` changes
```bash
yay -S snap-pac
```

---

## 🗃️ Step 2: Mount Synology NAS Share (Preferred via NFS)

### On Synology:
1. Enable NFS on the NAS.
2. Create a shared folder (e.g., `linux-backups`).
3. Allow access to your Arch machine's IP address in NFS permissions.

### On Arch:
```bash
sudo pacman -S nfs-utils
sudo mkdir -p /mnt/nas
sudo mount -t nfs 192.168.x.x:/volume1/linux-backups /mnt/nas
```

Optional: Add to `/etc/fstab`:
```bash
192.168.x.x:/volume1/linux-backups /mnt/nas nfs defaults,noatime,x-systemd.automount 0 0
```

---

## 🔄 Step 3: Sync Snapshots to NAS

### Option 1: `btrfs send` + `btrfs receive`
```bash
sudo btrfs send //.snapshots/XX/snapshot | ssh user@nas 'btrfs receive /volume1/linux-backups/snapshots'
```
- Efficient and fast
- Requires NAS to support BTRFS (only possible with Synology EXT4-to-BTRFS setup)

### Option 2: `rsync` (Simpler & Reliable)
```bash
sudo rsync -aAXv /.snapshots /mnt/nas/arch-snapshots --delete
```
- Works with any NAS filesystem (EXT4, BTRFS, etc.)
- Use cron or a systemd timer for automation

---

## 🔐 Option 3: Use `restic` for Encrypted Deduplicated Backups
### Install Restic
```bash
sudo pacman -S restic
```

### Initialize Backup Repo on NAS
```bash
restic init --repo /mnt/nas/restic-arch
```

### Backup a Folder (e.g., `/home`, `/etc`, `/var`) with Snapshots
```bash
restic -r /mnt/nas/restic-arch backup / --exclude={"/mnt","/proc","/sys","/dev","/run"}
```

Add password in `/etc/restic/restic.env` or use environment variable securely.

---

## 🧠 Best Practice
- Use **Snapper** for rollback and versioning
- Use **rsync or restic** to back up snapshots and important data to Synology
- Schedule with **systemd timers** or `cron`

---

**See also:** `snapper.md` for snapshot setup and usage.
