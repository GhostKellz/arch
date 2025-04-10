# Arch Linux Cheatsheet

## BTRFS Commands
- List subvolumes: `btrfs subvolume list /`
- Create snapshot: `btrfs subvolume snapshot /mnt/data /mnt/data_snap`
- Delete snapshot: `btrfs subvolume delete /mnt/data_snap`
- Check filesystem status: `btrfs device stats /mnt/data`
- Repair filesystem: `btrfs check --repair /dev/sda`


### Snapper 
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
### Restic
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
### regenerates the initramfs
sudo mkinitcpio -P
