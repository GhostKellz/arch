---
name: cktech-networking
description: "CKTech networking troubleshooting: LAN, tailnet, VPN, DNS, reverse proxies, firewalls, Cloudflare, ACME, nginx, Tailscale, UFW/firewalld/nftables, and reachability between monitored systems."
---

# CKTech Networking

- Determine path first: LAN, tailnet, public internet, reverse proxy, or overlay.
- Check DNS resolution, route, listener, firewall, TLS/cert, and app health in that order.
- Prefer tailnet endpoints for private admin paths.
- Keep public exposure minimal; put admin UIs behind VPN/SSO/reverse proxy.
- For certs, connect DNS/Cloudflare/ACME state with active web server config.
