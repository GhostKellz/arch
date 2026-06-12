#!/usr/bin/env bash
# Heimdall host firewall (ufw). LAN-scoped ingest + admin; SSH and Tailscale
# always permitted so we never lock ourselves out. Idempotent: ufw dedups
# identical rules, so re-running is safe.
#
# Run on Heimdall:  sudo bash setup-ufw.sh
set -euo pipefail

LAN1="10.0.0.0/24"     # primary LAN (FortiGate, Proxmox, workstation)
LAN2="192.0.2.0/24"    # secondary segment

ufw default deny incoming
ufw default allow outgoing

# --- Always-on management access (added BEFORE enable to avoid lockout) ---
ufw allow OpenSSH comment 'SSH'
ufw allow in on tailscale0 comment 'tailnet (full access over WireGuard)'

# --- Syslog ingest (standard RFC3164/5424) ---
for net in "$LAN1" "$LAN2"; do
    ufw allow from "$net" to any port 514 proto udp  comment 'syslog udp'
    ufw allow from "$net" to any port 514 proto tcp  comment 'syslog tcp'
    ufw allow from "$net" to any port 601 proto tcp  comment 'syslog RFC5424'
    # FortiGate dedicated port
    ufw allow from "$net" to any port 5514 proto udp comment 'fortigate udp'
    ufw allow from "$net" to any port 5514 proto tcp comment 'fortigate tcp'
    # Admin UIs
    ufw allow from "$net" to any port 3000 proto tcp comment 'grafana'
    ufw allow from "$net" to any port 9090 proto tcp comment 'prometheus'
    ufw allow from "$net" to any port 9093 proto tcp comment 'alertmanager'
done

ufw --force enable
ufw status verbose
