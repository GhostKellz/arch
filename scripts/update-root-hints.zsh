#!/bin/zsh
# update-root-hints.zsh
# Updates Unbound root hints and restarts Unbound

set -e

echo "[+] Downloading fresh root hints..."
wget -q -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache

echo "[+] Restarting Unbound..."
sudo systemctl restart unbound

echo "[+] Done."
