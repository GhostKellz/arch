#!/usr/bin/env bash
set -euo pipefail

# ghostnet-doctor.sh — Arch KVM/Docker networking doctor
# WHAT IT DOES (when --yes):
# - Creates/ensures NetworkManager bridge br0 over your primary NIC
# - Moves the host IP to br0; enslaves the NIC under the bridge
# - Enables IP forwarding
# - Writes a permissive nftables ruleset for local use (accept br0/vnet*/docker0/tailscale0)
# - Restarts Docker to ensure its bridges are up
# - If libvirt VMs exist, (re)attach their NICs to br0 (virtio), persistent
#
# USE:
#   sudo ./ghostnet-doctor.sh            # diagnose only
#   sudo ./ghostnet-doctor.sh --yes      # apply fixes
#
# NOTES:
# - Requires NetworkManager. If you use systemd-networkd, stop here and tell me.
# - Running this WILL loosen your firewall. Good for a lab box; not for hardened hosts.

APPLY=0
[[ "${1:-}" == "--yes" ]] && APPLY=1

say(){ printf '%b\n' "$*"; }
headline(){ echo; echo "=== $* ==="; }

need(){ command -v "$1" >/dev/null 2>&1 || { say "Missing: $1"; exit 1; }; }
need nmcli
need nft
need ip
if command -v systemctl >/dev/null 2>&1; then :; else say "Missing: systemctl"; exit 1; fi

# ---------- DETECT ----------
headline "Detecting current network state"
UPLINK_IF="$(ip route | awk '/^default/ {print $5; exit}')"
[[ -z "${UPLINK_IF:-}" ]] && { say "Could not detect default uplink interface"; exit 1; }
HOST_IP="$(ip -4 -brief addr show | awk '($1=="br0"){print $3; exit}')"

say "Uplink interface : $UPLINK_IF"
ip -brief addr show "$UPLINK_IF" || true
ip -brief addr show br0 || true

# Docker bridges
ip -brief addr show docker0 2>/dev/null || true

# nftables summary
headline "nftables (input/forward policies)"
sudo nft list ruleset | awk '/hook input|hook forward/ {print;getline;print;getline;print}' || true

# libvirt VMs (if any)
if command -v virsh >/dev/null 2>&1; then
  headline "libvirt VMs"
  sudo virsh list --all || true
else
  say "virsh not installed; skipping VM attach checks"
fi

# ---------- BRIDGE br0 ----------
headline "Ensuring bridge br0 over $UPLINK_IF (DHCP from your LAN router)"
if ! ip link show br0 >/dev/null 2>&1; then
  say "br0 does not exist."
  if ((APPLY)); then
    # Create bridge and enslave uplink
    nmcli con add type bridge ifname br0 con-name bridge-br0 || true
    # Move host IP to the bridge: set bridge to use DHCP
    nmcli con modify bridge-br0 ipv4.method auto ipv6.method auto
    # Create/ensure slave for uplink
    nmcli con add type bridge-slave ifname "$UPLINK_IF" master br0 con-name slave-"$UPLINK_IF" || true
    nmcli con up bridge-br0 || true
    nmcli con up slave-"$UPLINK_IF" || true
    sleep 2
  else
    say "DRY-RUN: would create br0 and enslave $UPLINK_IF; set DHCP on br0."
  fi
else
  say "br0 exists; making sure it’s up and enslaving $UPLINK_IF"
  if ((APPLY)); then
    nmcli con up bridge-br0 || true
    nmcli con up slave-"$UPLINK_IF" || true
  else
    say "DRY-RUN: would ensure connections bridge-br0 & slave-$UPLINK_IF are up."
  fi
fi

# ---------- SYSCTL ----------
headline "Enabling IP forwarding"
if ((APPLY)); then
  sysctl -w net.ipv4.ip_forward=1 >/dev/null
  sysctl -w net.ipv6.conf.all.forwarding=1 >/dev/null || true
  sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf || true
  echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
else
  say "DRY-RUN: would enable ipv4 forwarding & persist in /etc/sysctl.conf"
fi

# ---------- FIREWALL (permissive local rules) ----------
headline "Writing permissive nftables ruleset (local dev/lab)"
NFT_FILE="/etc/nftables.conf"
RULES=$(cat <<'EOF'
flush ruleset
table inet filter {
  chain input {
    type filter hook input priority 0; policy accept;
    ct state invalid drop
    # allow everything on loopback, bridges, docker & tailscale
    iifname { "lo", "br0", "docker0" } accept
    iifname "vnet0" accept
    iifname "tailscale0" accept
  }
  chain forward {
    type filter hook forward priority 0; policy accept;
  }
  chain output {
    type filter hook output priority 0; policy accept;
  }
}
# Optional: basic NAT helpers are handled by Docker/libvirt themselves.
EOF
)

if ((APPLY)); then
  printf '%s\n' "$RULES" > "$NFT_FILE"
  systemctl enable --now nftables >/dev/null 2>&1 || true
  nft -f "$NFT_FILE"
  say "Applied $NFT_FILE and (re)loaded nftables."
else
  say "DRY-RUN: would replace $NFT_FILE with a permissive ruleset and reload nftables."
fi

# ---------- DOCKER ----------
headline "Restarting Docker to ensure bridges up"
if systemctl is-enabled docker >/dev/null 2>&1; then
  if ((APPLY)); then
    systemctl restart docker || true
  else
    say "DRY-RUN: would systemctl restart docker"
  fi
else
  say "Docker service not enabled; skipping restart."
fi

# ---------- LIBVIRT VM -> br0 ----------
if command -v virsh >/dev/null 2>&1; then
  headline "Attaching libvirt VMs to br0 (virtio)"
  mapfile -t VMS < <(sudo virsh list --all --name | sed '/^$/d' || true)
  if ((${#VMS[@]}==0)); then
    say "No libvirt domains found; if your VM is unmanaged QEMU, configure its -netdev to use br0."
  else
    for VM in "${VMS[@]}"; do
      say "- $VM"
      # Try to ensure at least one NIC uses br0
      if ((APPLY)); then
        # Detach any 'network=default' NICs and attach bridge
        sudo virsh domiflist "$VM" | awk '/network/ && /default/ {print $1}' | while read -r tgt; do
          sudo virsh detach-interface "$VM" --type network --mac "$tgt" --config --live || true
        done
        # Attach bridge if not already on br0
        if ! sudo virsh domiflist "$VM" | grep -q "br0"; then
          sudo virsh attach-interface "$VM" --type bridge --source br0 --model virtio --config --live || true
        fi
      else
        say "  DRY-RUN: would attach bridge br0 (virtio) to $VM"
      fi
    done
  fi
fi

headline "Done."
echo "Current addresses:"
ip -brief addr show br0 | sed 's/^/  /'

