#!/usr/bin/env bash
# CK Post Install Script for Arch Linux Workstation

set -e

# --- System Update ---
echo "🔄 Updating system..."
sudo pacman -Syu --noconfirm

# --- Kernel + NVIDIA ---
echo "🖥 Installing Zen kernel and NVIDIA Open drivers..."
sudo pacman -S --noconfirm \
  linux-zen linux-zen-headers \
  nvidia-open-dkms nvidia-utils libva-utils libvdpau

# --- Essentials ---
echo "🧰 Installing base tools..."
sudo pacman -S --noconfirm \
  git curl wget unzip nano zsh \
  flatpak neovim neofetch \
  firefox \
  wine winetricks bottles \
  steam

# --- Enable Zsh + Plugins (placeholder for Oh My Zsh) ---
echo "⚙️ Setting default shell to Zsh..."
chsh -s /bin/zsh $USER

# TODO: Add Oh My Zsh, autosuggestions, syntax highlighting, etc.

# --- Flatpak & Flathub Setup ---
echo "📦 Setting up Flatpak & installing apps..."
sudo pacman -S --noconfirm flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
  com.visualstudio.code \
  com.obsproject.Studio \
  com.discordapp.Discord \
  com.valvesoftware.Steam \
  com.termius.Termius \
  io.github.FeralInteractive.GreenWithEnvy \
  io.github.shiftey.Desktop \
  org.gimp.GIMP

# --- Docker Setup ---
echo "🐳 Installing Docker..."
sudo pacman -S --noconfirm docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# --- QEMU/KVM Virtualization ---
echo "🖧 Setting up virtualization (QEMU + libvirt)..."
sudo pacman -S --noconfirm qemu libvirt virt-manager dnsmasq vde2 bridge-utils openbsd-netcat
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt,kvm $USER

# --- KDE Theming ---
echo "🎨 Applying KDE + SDDM theming..."
# SDDM: Dracula
sudo pacman -S --noconfirm sddm
sudo systemctl enable sddm

# KDE Look-and-Feel (manual step for now)
echo "🔔 Remember to apply the following:"
echo "- KDE Global Theme: Sweet Amber"
echo "- Icons: Tela Manjaro Light"
echo "- SDDM Theme: Dracula"
echo "- Firefox: Set icon to Developer Edition manually"

# --- Performance Tweaks ---
echo "🚀 Applying performance sysctl tweaks..."
echo -e 'vm.swappiness=10\nvm.vfs_cache_pressure=50' | sudo tee /etc/sysctl.d/99-sysctl.conf > /dev/null
sudo sysctl --system

# --- Wayland + NVIDIA ---
echo "🧠 Enabling NVIDIA Wayland support..."
echo 'export KWIN_DRM_USE_EGL_STREAMS=1' | sudo tee /etc/profile.d/nvidia-wayland.sh > /dev/null
sudo chmod +x /etc/profile.d/nvidia-wayland.sh

# --- Final Touches ---
echo -e "\n✅ Setup complete. Please reboot and log into KDE Wayland session."
