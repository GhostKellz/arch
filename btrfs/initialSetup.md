# Replace /dev/nvme0n1 with your drive
cfdisk /dev/nvme0n1

# Format partitions
mkfs.btrfs -f /dev/nvme0n1p1
mount /dev/nvme0n1p1 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

# Mount subvolumes
umount /mnt
mount -o noatime,compress=zstd,subvol=@ /dev/nvme0n1p1 /mnt
mkdir -p /mnt/{boot,home,.snapshots}
mount -o noatime,compress=zstd,subvol=@home /dev/nvme0n1p1 /mnt/home
mount -o noatime,compress=zstd,subvol=@snapshots /dev/nvme0n1p1 /mnt/.snapshots
