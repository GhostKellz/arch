# 📖 GhostKellz Unbound Setup

Welcome to the **GhostKellz** Unbound deployment!
This setup delivers a hardened, locally-validated DNS experience designed to prioritize **privacy**, **security**, and **performance**.

Built on top of:
- 🚀 **Arch Linux** optimized configs
- 🛡️ **Unbound** recursive resolver
- 🔒 Root-hint management + DNSSEC enforcement
- 🌐 Forwarding to **Apollo** DoT server + Cloudflare fallback

Fully integrated with:
- 📆 Automatic root.hints refresh via **SystemD timer**
- ⚡ Fast failover and secure resolution

---

# ⚡ Why Unbound?

- Full control over DNS resolution
- Validates DNSSEC signatures
- Bypasses ISP DNS manipulation
- Privacy-first (no logging upstream)
- Hardened with aggressive security flags
- Redundant forwarding via your own Apollo server

Unbound is the foundation of **GhostKellz**' resilient and encrypted network layer.

---

# 📂 Folder Layout

| Folder/File        | Purpose |
|--------------------|---------|
| `arch.conf`         | Lightweight optimized config tuned for workstations |
| `unbound.conf`      | Default server config tuned for hardened environments |
| `systemd/`          | Auto root.hints update service + timer |
| `README.md`         | This overview and quickstart |

> Note: Full `systemd/` breakdown is inside its own README.

---

# 🔥 Highlights

- 🚀 **High performance** cache tuning
- 🔒 **Strict security**: QNAME minimization, DNSSEC, hardened options
- 🛡️ **Failsafe forwarders** (Apollo primary, Cloudflare fallback)
- 📈 **Auto-refresh** root.hints every night for maximum reliability

---

> 👻 Stay resilient. Stay encrypted..

