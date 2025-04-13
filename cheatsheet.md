# 🐉 🐧 Arch Linux Cheatsheet 

### 📸 BTRFS Commands
- List subvolumes: `btrfs subvolume list /`
- Create snapshot: `btrfs subvolume snapshot /mnt/data /mnt/data_snap`
- Delete snapshot: `btrfs subvolume delete /mnt/data_snap`
- Check filesystem status: `btrfs device stats /mnt/data`
- Repair filesystem: `btrfs check --repair /dev/sda`


### 📸Snapper 
- Commands list for setup
```bash
sudo pacman -S snapper snap-pac
sudo btrfs subvolume create /.snapshots
sudo chmod 750 /.snapshots
sudo chown :wheel /.snapshots
sudo blkid | grep nvme0n1p2
UUID=your-root-uuid  /.snapshots  btrfs  subvol=@.snapshots,noatime,compress=zstd:3  0 0
sudo mount /.snapshots
sudo snapper -c root create --description "Initial root snapshot"
sudo snapper -c root list
sudo snapper -c home create-config /home
sudo chmod 750 /home/.snapshots
sudo chown :wheel /home/.snapshots
sudo snapper -c home create --description "initial home snapshot"
sudo snapper -c home list
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```
### 💾 Restic
- Encrypted, deduplicated backups from /home to a MinIO S3 bucket (e.g. on Synology)
- Uses /etc/restic.env to store S3 credentials and repo info
```bash
# Install restic
sudo pacman -S restic

# Create and edit environment file
sudo nano /etc/restic.env
```
- paste in the .env
```bash
RESTIC_REPOSITORY="s3:http://10.0.0.10:9000/restic-arch"
AWS_ACCESS_KEY_ID="your-access-key"
AWS_SECRET_ACCESS_KEY="your-secret-key"
RESTIC_PASSWORD="your-encryption-password"
```
- One by one
```bash
# Make env file readable by systemd
sudo chmod 644 /etc/restic.env

# Initialize restic repo (run once)
source /etc/restic.env
restic init

# Run first backup manually
restic backup /home

# List snapshots
restic snapshots

# Optional: remove old backups with retention policy
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
```
- Creates daily backups and prunes old ones
```bash
[Unit]
Description=Restic Backup to MinIO (restic-arch bucket)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
EnvironmentFile=/etc/restic.env
ExecStart=/usr/bin/restic backup /home
ExecStartPost=/usr/bin/restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
Nice=19
IOSchedulingClass=2
IOSchedulingPriority=7
StandardOutput=append:/var/log/restic.log
StandardError=append:/var/log/restic.log
```
- Create the Restic Backup timer 
```bash
# Create restic-backup.timer
sudo nano /etc/systemd/system/restic-backup.timer
```
- Paste this in for backup.timer
```bash
[Unit]
Description=Daily Restic Backup to MinIO

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```
- Then run the following to enable etc. 
```bash
# Enable and start the timer
sudo systemctl daemon-reexec
sudo systemctl enable --now restic-backup.timer

# Run manually to test
sudo systemctl start restic-backup.service

# View backup logs
sudo tail -f /var/log/restic.log
```
---
### 🧬 Regenerate Initramfs
- Rebuilds the initial ramdisk image for kernel boot. Run this after kernel or hook changes.
```bash
sudo mkinitcpio -P
```
---
## KDE / Wayland Frozen Monitor Workaround Nvidia

- Switch to TTY with `Ctrl + Alt + F3` (or F2/F4/etc.)
- Return to graphical session with `Ctrl + Alt + F1`
- Works around frozen monitor bug on KDE + Wayland with NVIDIA GPU
- Session is not killed — just refreshed
- Faster than rebooting or logging out
- Issue appears reduced when using TKG kernel (lower GSP frequency)
---
### 🧠 Memory & Swap 
# Check swap devices (zram, regular swap)
```bash
swapon --show --bytes
```
# Check current zram config (if using zram-generator)
```bash
cat /etc/systemd/zram-generator.conf
```
# Show current vm tunables
```bash
sysctl vm.swappiness
sysctl vm.vfs_cache_pressure
sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio
```
# Show if zswap is enabled
```bash
cat /sys/module/zswap/parameters/enabled
```
# Early OOM killer or custom OOM settings
```bash
cat /etc/sysctl.d/* | grep -i oom || echo "No custom OOM killer settings"
```
---
## 🔋Power Management  
# Show CPU frequency governor settings (per core)
```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```
# Show active power profiles (req. power-profiles-daemon)
'''bash
powerprofilesctl list
```
# Check if TLP is installed and active
```bash
systemctl status tlp.service
```
# Check your current sleep/hibernate settings
```bash
cat /etc/systemd/sleep.conf
```
# See what services are inhibiting suspend/sleep
```bash
systemd-inhibit --list
```
# See any tuned profiles
```bash
tuned-adm active
```
---
## 🔧 Fix Chaotic AUR Mirror Errors

```bash
# Re-sync the Chaotic AUR mirror list
sudo pacman -Sy chaotic-mirrorlist

# Then force-refresh all package databases and upgrade
sudo pacman -Syyu
```
---
## 🔐 Verify Keystone Pro 3 Firmware Checksum

```bash
# Check the SHA-256 checksum of the firmware .bin file
sha256sum keystone3.bin
```

# Match the result with the official hash (v2.0.4) MultiCoin: 
# dccbb843b33f26cdb11093e9c5a38d32cedc05b95593a4ada2eb82c4a08db0eb
```
---
