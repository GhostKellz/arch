#!/usr/bin/env bash
set -euo pipefail

echo "🚑 Starting full Arch Linux repair..."

# 1. Fix keyring
echo "🔑 Refreshing archlinux-keyring..."
sudo pacman -Sy --noconfirm archlinux-keyring
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman-key --refresh-keys

# 2. Clean out any broken/cached downloads
echo "🧹 Cleaning up package cache and dbs..."
sudo pacman -Scc --noconfirm || true
sudo rm -f /var/lib/pacman/db.lck

# 3. Install/refresh reflector (get the best mirrors)
if ! command -v reflector >/dev/null 2>&1; then
  echo "📦 Installing reflector..."
  sudo pacman -Sy --noconfirm reflector
fi

# Use US/East Coast, fallback to all US if not found
echo "🌐 Refreshing mirrorlist (East Coast/US, HTTPS, fastest 20)..."
sudo reflector --country 'United States' --age 6 --protocol https --sort score --latest 20 --save /etc/pacman.d/mirrorlist

# 4. Sync DBs, update system, fix packages
echo "🔄 Full pacman database sync..."
sudo pacman -Syyu --noconfirm

# 5. Remove orphans (optional)
echo "🧽 Removing orphaned packages..."
sudo pacman -Rns --noconfirm $(pacman -Qtdq || true) || true

echo "✅ Arch Linux repair complete!"
echo "🚦 If you still have errors, check /var/log/pacman.log or run: sudo pacman -Syu --debug"

