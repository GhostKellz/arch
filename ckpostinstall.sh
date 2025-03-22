
#!/usr/bin/env bash

# CK Post Install Script for Arch Linux Workstation
# Includes: Zen Kernel, NVIDIA Open Drivers, KDE + PipeWire, Flatpak, ZRAM, SDDM + Nordic Theme, Dev Tools

set -e

# --- System Update ---
echo "Updating system..."
sudo pacman -Syu --noconfirm

# --- Base Packages ---
echo "Installing base packages..."
sudo pacman -S --noconfirm \
  linux-zen linux-zen-headers \
  nvidia-open-dkms nvidia-utils libva \
  plasma kde-applications sddm sddm-kcm \
  pipewire pipewire-alsa pipewire-pulse pipewire-jack \
  flatpak git base-devel curl wget nano neofetch \
  btrfs-progs snapper grub grub-btrfs \
  systemd-zram-generator xdg-user-dirs \
  noto-fonts ttf-fira-code

# --- Enable KDE and SDDM ---
echo "Enabling KDE and SDDM..."
sudo systemctl enable sddm
sudo systemctl enable NetworkManager

# --- Set Up Flatpak ---
echo "Setting up Flatpak..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --- ZRAM Config ---
echo "Configuring ZRAM..."
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd" | sudo tee /etc/systemd/zram-generator.conf > /dev/null
sudo systemctl daemon-reexec

# --- SDDM Nordic Theme Setup ---
echo "Installing Nordic SDDM theme..."
yay -S --noconfirm sddm-nordic-theme-git
sudo sed -i 's/^Current=.*/Current=Nordic/' /etc/sddm.conf

# --- VSCode, Brave, Discord, OBS, Steam (via Flatpak) ---
echo "Installing dev and desktop apps via Flatpak..."
flatpak install -y flathub com.visualstudio.code
flatpak install -y flathub com.obsproject.Studio
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub com.valvesoftware.Steam
flatpak install -y flathub com.brave.Browser

# --- Done ---
echo "\n✅ Post-install setup complete. Please reboot and log into KDE Wayland session."
