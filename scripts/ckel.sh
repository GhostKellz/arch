#!/usr/bin/env bash
# ckel.sh – CK Easy Linux Post-Install Script
# Sets up Arch Linux with NVIDIA, KDE, Flatpak, development tools, Docker, virtualization, backup, Tailscale, theming, and performance tweaks.

set -e

# --- System Update ---
echo "🔄 Updating system..."
sudo pacman -Syu --noconfirm

# --- Kernel + NVIDIA ---
echo "🖥 Installing Zen kernel and NVIDIA Open drivers..."
sudo pacman -S --noconfirm \
  linux-zen linux-zen-headers \
  nvidia-open-dkms nvidia-utils libva-utils libvdpau

# --- Essentials + Zsh + Dev Tools ---
echo "🧰 Installing base tools and Zsh..."
sudo pacman -S --noconfirm \
  git curl wget unzip nano zsh \
  flatpak neovim neofetch \
  firefox \
  wine winetricks bottles \
  steam

# Set default shell to Zsh
echo "⚙️ Setting default shell to Zsh..."
chsh -s /bin/zsh $USER

# --- Flatpak & Flathub Setup ---
echo "📦 Setting up Flatpak & installing apps..."
sudo pacman -S --noconfirm flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
  com.visualstudio.code \
  com.obsproject.Studio \
  com.discordapp.Discord \
  com.termius.Termius \
  io.github.FeralInteractive.GreenWithEnvy \
  io.github.shiftey.Desktop \
  org.gimp.GIMP

# --- Docker Setup ---
echo "🐳 Installing Docker + Docker Compose..."
sudo pacman -S --noconfirm docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# --- Clone Dev Repositories ---
echo "📁 Cloning personal GitHub repositories..."
mkdir -p ~/{arch,docker,proxmox}

if [ ! -d ~/arch/.git ]; then
  git clone https://github.com/Christopherkelley89/arch.git ~/arch
fi

if [ ! -d ~/docker/.git ]; then
  git clone https://github.com/Christopherkelley89/docker.git ~/docker
fi

if [ ! -d ~/proxmox/.git ]; then
  git clone https://github.com/Christopherkelley89/proxmox.git ~/proxmox
fi

# --- QEMU/KVM Virtualization ---
echo "🖧 Setting up virtualization (QEMU + libvirt)..."
sudo pacman -S --noconfirm qemu libvirt virt-manager dnsmasq vde2 bridge-utils openbsd-netcat
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt,kvm $USER

# --- KDE Theming ---
echo "🎨 KDE theming setup..."
sudo pacman -S --noconfirm sddm
sudo systemctl enable sddm

echo "🔔 Manual theming steps after reboot:"
echo "- Global Theme: Sweet Amber"
echo "- Icon Theme: Tela Manjaro Light"
echo "- SDDM Theme: Dracula"
echo "- Firefox Icon: Developer Edition (set manually)"

# --- Performance Tweaks ---
echo "🚀 Applying performance sysctl tweaks..."
echo -e 'vm.swappiness=10\nvm.vfs_cache_pressure=50' | sudo tee /etc/sysctl.d/99-sysctl.conf > /dev/null
sudo sysctl --system

# --- NVIDIA Wayland Compatibility ---
echo "🧠 Enabling NVIDIA Wayland compatibility..."
echo 'export KWIN_DRM_USE_EGL_STREAMS=1' | sudo tee /etc/profile.d/nvidia-wayland.sh > /dev/null
sudo chmod +x /etc/profile.d/nvidia-wayland.sh

# --- Snapper + Restic Backups ---
echo "📸 Setting up Btrfs Snapshots + Restic automated backups..."
sudo pacman -S --noconfirm snapper
sudo snapper -c root create-config /
sudo systemctl enable --now snapper-timeline.timer

sudo pacman -S --noconfirm restic
git clone https://github.com/Christopherkelley89/dotfiles.git ~/dotfiles || true
sudo cp ~/dotfiles/restic-backup.* /etc/systemd/system/
sudo cp ~/dotfiles/restic.env /etc/restic.env
sudo systemctl enable --now restic-backup.timer

# --- Tailscale ---
echo "🔐 Installing and enabling Tailscale..."
sudo pacman -S --noconfirm tailscale
sudo systemctl enable --now tailscaled

# Optional: uncomment to auto-authenticate Tailscale
# sudo tailscale up --accept-routes --ssh

# --- Done ---
echo -e "\n✅ Setup complete. Please reboot and log into your KDE Wayland session."
