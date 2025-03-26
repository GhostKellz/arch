# Arch Linux Cheatsheet

### Snapper 
### 1. Commands list
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
