#!/usr/bin/env bash
# KVM/Libvirt Networking Diagnostic Script for Arch

echo "===== Host Network Interfaces ====="
ip -brief addr show

echo -e "\n===== Active Bridges ====="
brctl show 2>/dev/null || echo "brctl not installed (bridge-utils)"

echo -e "\n===== NetworkManager Connections ====="
nmcli connection show --active

echo -e "\n===== Libvirt Networks ====="
virsh net-list --all
echo -e "\n>>> If 'default' is Inactive, run: sudo virsh net-start default && sudo virsh net-autostart default"

echo -e "\n===== Libvirt Network XML (default, if exists) ====="
if virsh net-dumpxml default &>/dev/null; then
    virsh net-dumpxml default | grep -E 'network|bridge|ip'
else
    echo "No 'default' network defined."
fi

echo -e "\n===== VM NICs (replace <vmname> with yours if needed) ====="
for vm in $(virsh list --name); do
    echo "--- $vm ---"
    virsh domiflist "$vm"
done

echo -e "\n===== nftables Rules ====="
sudo nft list ruleset | grep -A2 -E 'input|forward' || echo "nftables not in use"

echo -e "\n===== Systemd Services (libvirt) ====="
systemctl is-active libvirtd virtqemud virtlogd

echo -e "\n===== Routing Table ====="
ip route

echo -e "\n===== DNS Resolution Check ====="
getent hosts us.actual.battle.net || echo "DNS lookup failed for Blizzard domain"

