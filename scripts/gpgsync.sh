#!/bin/bash

# Create log directory if missing
mkdir -p ~/.logs/ckel

# Sync pacman and GPG keys
echo "[*] Syncing pacman & keyrings..." | tee -a ~/.logs/ckel/gpgsync.log
sudo pacman -Sy archlinux-keyring --noconfirm 2>&1 | tee -a ~/.logs/ckel/gpgsync.log
