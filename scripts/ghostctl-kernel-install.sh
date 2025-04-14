#!/bin/bash
# ghostctl-build.sh - Safe Kernel + NVIDIA DKMS Build w/ Recovery + Bootloader
# Author: GhostKellz

set -euo pipefail

### === CONFIGURATION ===
KERNEL_NAME="linux-ck-615rc2"
KERNEL_ENTRY="/boot/loader/entries/${KERNEL_NAME}.conf"
LINUX_TKG_DIR="$HOME/ghostctl/linux-tkg"
NVIDIA_ALL_DIR="$HOME/ghostctl/nvidia-all"
SNAPSHOT_BEFORE_INSTALL=true
SET_AS_DEFAULT=true
DATE=$(date +%F-%H%M)
BACKUP_DIR="/data/recovery/$DATE"

### === STEP 0: Safety Backup + Snapshot ===

if [ "$SNAPSHOT_BEFORE_INSTALL" = true ]; then
    echo "> 🧷 Creating Snapper pre-install snapshot..."
    sudo snapper create --description "Pre-GhostCTL Kernel + NVIDIA Install" || echo "Snapper failed (non-fatal)."
fi

echo "> 🔐 Backing up kernel: $KERNEL_NAME to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
sudo cp -v /boot/vmlinuz-* "$BACKUP_DIR" || echo "⚠️ Failed to backup vmlinuz"
sudo cp -v /boot/initramfs-* "$BACKUP_DIR" || echo "⚠️ Failed to backup initramfs"
sudo cp -a /lib/modules/"$(uname -r)" "$BACKUP_DIR/modules-$(uname -r)" || echo "⚠️ Failed to backup modules"
cp "$LINUX_TKG_DIR/customization.cfg" "$BACKUP_DIR/" || echo "⚠️ customization.cfg not found"
cp -r "$LINUX_TKG_DIR/linux615rc2-tkg-userpatches" "$BACKUP_DIR/userpatches" || echo "⚠️ No userpatches found"

### === STEP 1: Build Custom Kernel ===
echo "> 🛠️ Building kernel from $LINUX_TKG_DIR..."
cd "$LINUX_TKG_DIR"
makepkg -si --noconfirm

### === STEP 2: Build & Install NVIDIA DKMS ===
echo "> 🧠 Installing NVIDIA Open DKMS from $NVIDIA_ALL_DIR..."
cd "$NVIDIA_ALL_DIR"
makepkg -si --noconfirm

### === STEP 3: Create systemd-boot Loader Entry ===
echo "> 🧱 Creating systemd-boot entry at $KERNEL_ENTRY..."

PARTUUID=$(lsblk -no PARTUUID "$(findmnt -n / -o SOURCE)")
[[ -z "$PARTUUID" ]] && { echo "❌ Could not find PARTUUID! Aborting."; exit 1; }

sudo tee "$KERNEL_ENTRY" >/dev/null <<EOF
# Custom Linux Kernel (BORE)
title   Linux CK 6.15 RC2
linux   /vmlinuz-${KERNEL_NAME}
initrd  /amd-ucode.img
initrd  /initramfs-${KERNEL_NAME}.img
options root=PARTUUID=${PARTUUID} rootflags=subvol=@ rw rootfstype=btrfs zswap.enabled=0 nvidia_drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0 nvidia.NVreg_PreserveVideoMemoryAllocations=1 usbcore.autosuspend=-1 quiet splash
EOF

### === STEP 4: Set as Default (Optional) ===
if [ "$SET_AS_DEFAULT" = true ]; then
    echo "> 🎯 Setting $KERNEL_NAME as default boot entry..."
    LOADER_CONF="/boot/loader/loader.conf"
    sudo sed -i "s/^default.*/default ${KERNEL_NAME}.conf/" "$LOADER_CONF" || echo "default ${KERNEL_NAME}.conf" | sudo tee -a "$LOADER_CONF"
fi

### ✅ STEP 5: Complete
echo -e "\n✅ ghostctl-build.sh complete!"
echo "📦 Kernel: $KERNEL_NAME built and backed up to: $BACKUP_DIR"
echo "🛡️ Reboot to test. Rollback available via Snapper or /data/recovery"
