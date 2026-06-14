# 🌐 CKTech Networking Stack 👻🔥 — GhostKellz Edition

[![Tailscale](https://img.shields.io/badge/Tailscale-ZeroTrust-007ACC?style=for-the-badge&logo=tailscale&logoColor=white)](https://tailscale.com)
[![Headscale](https://img.shields.io/badge/Headscale-SelfHosted-00BFFF?style=for-the-badge)](https://github.com/juanfont/headscale)
[![WireGuard VPN](https://img.shields.io/badge/WireGuard-ModernVPN-88171A?style=for-the-badge&logo=wireguard&logoColor=white)](https://www.wireguard.com)
[![Fortinet Secured](https://img.shields.io/badge/Fortinet-Secured-red?style=for-the-badge&logo=fortinet&logoColor=white)](https://www.fortinet.com/)
[![SD-WAN Powered](https://img.shields.io/badge/SD--WAN-Enabled-00B386?style=for-the-badge)](https://en.wikipedia.org/wiki/SD-WAN)
[![Unbound Powered](https://img.shields.io/badge/Powered%20by-Unbound-blue?style=for-the-badge)](https://nlnetlabs.nl/projects/unbound/)
[![Next-Gen Networking](https://img.shields.io/badge/Networking-CuttingEdge-0078D7?style=for-the-badge)]()

---

# 🔒 Overview

This section covers advanced **networking scripts**, **notes**, and **tuning configurations** for GhostKellz' home and cloud infrastructure.

Built on top of:
- 🛸️ **Tailscale** Zero-Trust mesh VPN — coordination plane for work infra + lab
- 🚱️ **Headscale + Tailscale client** (self-hosted control server) — **lab setting only**
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

# 🗺️ Global Topology

Two WAN links into a FortiGate edge, a local Proxmox cluster, a cloud node, a public
DMZ, and a second homelab — stitched together by a Tailscale control plane so
management never crosses the public internet.

```mermaid
flowchart TD
    subgraph WAN["WAN uplinks"]
        W1["Fiber 2.5 GbE<br/>primary · static block"]
        W2["Cable ~1 GbE<br/>backup"]
    end
    W1 --> FG["FortiGate 90G SD-WAN<br/>failover · SLA steering · IPS/UTM · threat feeds"]
    W2 --> FG
    FG --> CORE["Resolution & core<br/>Technitium/Unbound DNS · core switch (VLAN trunk · LACP)"]
    CORE --> S1["Local PVE cluster<br/>10.0.0.0/24"]
    CORE --> S2["DMZ<br/>nginx + Docker · public"]
    CORE --> S3["Cloud PVE<br/>public web · CrowdSec"]
    CORE --> S4["Second homelab<br/>Hyper-V · Veeam"]
    subgraph BDR["Backup & DR (3-2-1)"]
        B1["Synology NAS<br/>active backup"] --> B2["Proxmox Backup Server<br/>dedup · encrypted"]
        B2 --> B3["Wasabi S3<br/>offsite"]
    end
    S1 --> BDR
    TS["🔗 Tailscale control plane<br/>spans every site · strict ACLs · per-session SSH"] -.-> S1
    TS -.-> S2
    TS -.-> S3
    TS -.-> S4
```

> All infra comms (SSH, APIs, dashboards) ride the **Tailscale tailnet** with strict
> ACLs — management traffic never crosses the public internet. A self-hosted
> **Headscale + Tailscale client** runs alongside in a **lab setting only**. See
> [`tailscale.md`](tailscale.md) for the mesh, DERP relays, and OIDC details.

---

# 🛰️ SD-WAN Failover & SLA Steering

The FortiGate runs both WAN members and steers per-application traffic by live SLA
probes (latency / jitter / loss), failing over to cable if the fiber degrades.

```mermaid
flowchart TD
    LAN["LAN + VLANs<br/>10.0.0.0/24 · VLAN 10–80"] --> RULES["SD-WAN rules<br/>SLA steering · app-aware · source/dest"]
    SLA["Performance SLA<br/>probes: latency / jitter / loss"] -.->|feeds decision| RULES
    RULES --> WAN1["WAN1 — Fiber<br/>2.5 GbE · primary"]
    RULES --> WAN2["WAN2 — Cable<br/>~1 GbE · backup"]
    WAN1 --> NET["Internet"]
    WAN2 --> NET
```

> Dotted = the Performance SLA feeding the steering decision. Both members can carry
> traffic at once (load-balance by bandwidth ratio) or act as strict primary/backup,
> depending on the rule.

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
