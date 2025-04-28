# 🌐 Tailscale on Arch (GhostKellz Edition)

![Tailscale](https://img.shields.io/badge/Tailscale-00C7B7?style=for-the-badge&logo=tailscale&logoColor=white)
![Headscale](https://img.shields.io/badge/Headscale-0078D4?style=for-the-badge&logo=proxmox&logoColor=white)
![WireGuard](https://img.shields.io/badge/WireGuard-88171A?style=for-the-badge&logo=wireguard&logoColor=white)
![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)
![Technitium DNS](https://img.shields.io/badge/Technitium_DNS-5C2D91?style=for-the-badge)
![Microsoft Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![OIDC](https://img.shields.io/badge/OIDC-0052CC?style=for-the-badge&logo=openid&logoColor=white)

---

# 📖 Overview

This section highlights the GhostKellz networking setup using **Tailscale**, **Headscale**, and a fleet of additional technologies to form a **zero-trust, resilient mesh** across cloud and home infrastructure.

Built around:
- 🛡️ Tailscale client for encrypted device-to-device communication.
- 🧠 Headscale (self-hosted identity server) running in a lightweight Debian LXC.
- 🛰️ Two custom DERP relays (Docker-based) across cloud and home for the **lowest possible latency**.
- 🧵 WireGuard tunnels acting as fallback links if Tailscale fails.
- 🌐 Vanilla NGINX servers: one public-facing, another internal for cloud service SSL termination (e.g., Hudu, UniFi).
- 🧬 Technitium DNS server acting as a Tailscale resolver (NS3 slave).
- 🔐 Full OIDC authentication via Microsoft Entra ID, powered by Headplane.

Infrastructure Highlights:
- Dual WAN SD-WAN failover (Fiber + Cable) 🛰️
- Fortigate 90G Firewall for LAN/WAN security 🔥
- Hourly Headscale snapshots via Proxmox Backup Server ☁️
- Full Home/Cloud Proxmox cluster linked with secure overlay networking 🌎

---

# 🧩 Trayscale GUI - Visualize Your Network

[Trayscale](https://github.com/DeedleFake/trayscale) is a **fantastic lightweight GUI** that interfaces with `tailscaled` and gives real-time visual feedback:

- Quick glance at peer status, relay paths, direct routes.
- Useful when debugging routing issues or DERP fallback behavior.
- Recommended for anyone wanting extra **network situational awareness**.

### Important Note ⚡
You must set yourself as a Tailscale "operator" first:
```bash
sudo tailscale set --operator=$USER
```

Otherwise, Trayscale will fail to connect to the local Tailscale daemon.

---

# 🛠️ Stack Components

| Service            | Details |
|--------------------|---------|
| **Tailscale**       | Encrypted overlay network |
| **Headscale**       | Self-hosted identity server (LXC container) |
| **WireGuard**       | Fallback encrypted tunnels |
| **DERP Servers**    | Home + 2 Cloud relays (Docker `derper`) |
| **NGINX**           | SSL termination, proxying cloud services |
| **Technitium DNS**  | Local authoritative + Tailscale resolver |
| **Headplane**       | OIDC-enabled Headscale web UI (Docker) |

---

# 🔒 Security & High Availability
- OIDC login enforced with Microsoft Azure Entra ID
- Redundant DERP relay paths + direct WireGuard tunnels
- Local and cloud storage of Headscale config via Synology NAS + Veeam
- SDWAN failover with automatic connection switching
- SDWAN used to maintain DNS Resolution between a local Technitium DNS server with unbound and a Pihole + unbound in a proxmox LXC Container
- Uptime backed by multiple UPS units for servers + home system,  Standby Generator at home, SDWAN Technology for ISP interruptions 

---

# 📸 Showcase Mesh VPN Stack
| Screenshot | Description |
|:-----------|:------------|
| ![Headscale DERP Map](../../assets/headscale-derper.png) | Custom DERP Region Map View |
| ![Headplane GUI](../../assets/headplane.png) | Headplane Web UI (OIDC Login) |
| ![Trayscale GUI](../../assets/trayscale.png) | Live Peer Connection Graph |

---

> 👻 **GhostKellz Networking Stack**: Zero Trust. Maximum Resilience. Absolute Control.
>  
> 🛡️ _Stay encrypted. Stay sovereign._



---

> ✨ **GhostKellz Networking Stack: Zero Trust. Maximum Resilience. Absolute Control.**

> 👻 *Stay encrypted. Stay sovereign.*
