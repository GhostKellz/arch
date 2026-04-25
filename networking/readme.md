# 🌐 CKTech Networking Stack 👻🔥 — GhostKellz Edition

[![Tailscale](https://img.shields.io/badge/Tailscale-ZeroTrust-007ACC?logo=tailscale&logoColor=white)](https://tailscale.com) 
[![Headscale](https://img.shields.io/badge/Headscale-SelfHosted-00BFFF)](https://github.com/juanfont/headscale) 
[![WireGuard VPN](https://img.shields.io/badge/WireGuard-ModernVPN-88171A?logo=wireguard&logoColor=white)](https://www.wireguard.com) 
[![Fortinet Secured](https://img.shields.io/badge/Fortinet-Secured-red?logo=fortinet&logoColor=white&style=flat)](https://www.fortinet.com/)		
[![SD-WAN Powered](https://img.shields.io/badge/SD--WAN-Enabled-00B386)](https://en.wikipedia.org/wiki/SD-WAN) 
[![Unbound Powered](https://img.shields.io/badge/Powered%20by-Unbound-blue)](https://nlnetlabs.nl/projects/unbound/)
[![Next-Gen Networking](https://img.shields.io/badge/Networking-CuttingEdge-0078D7)]()

---

# 🔒 Overview

This section covers advanced **networking scripts**, **notes**, and **tuning configurations** for GhostKellz' home and cloud infrastructure.

Built on top of:
- 🛸️ **Tailscale** Zero-Trust mesh VPN
- 🚱️ **Headscale** (self-hosted identity server)
- ⚡ **WireGuard** for blazing-fast peer-to-peer connections
- 🏰 **Fortigate 90G** firewall securing WAN and LAN edges
- 🌐 **SD-WAN** failover (Fiber + Cable) for redundant, always-on connectivity
- 🔵 **Unbound** DNS resolver with hardened root hints and DNSSEC validation

All optimized for:
- 🔒 Maximum Security
- 🌎 Global Mesh Networking
- 🚀 Fast failover and route optimization
- 🧹 Self-healing and automatic refresh systems
- Handling network sevice interruptions 

---

# ⚡ What's Inside

| Folder/File            | Purpose |
|-------------------------|---------|
| `tailscale.md`           | Tailscale/Headscale setup, tweaks, and peer configuration |
| `nftables.md`            | nftables performance tuning and security baseline |
| `unbound/`               | Local Unbound configuration for secure DNS resolution |
| `readme.md`              | (This file) Networking structure and overview |

---

# 🛠️ Future Plans
- Automated Fortigate API script integration
- Dynamic DNS failover using SD-WAN event hooks
- Headscale + WireGuard multi-hop relay and fallback system
- Mesh network monitoring, auto-healing, and route optimization
- Templated Unbound zone overrides for faster internal DNS resolution

---

> 🔥 **CKTech Networking: battle-tested, GhostKellz optimized.**  
> 👻 Stay encrypted. Stay resilient. Stay Secure. 
