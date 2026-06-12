# Security architecture

Perimeter and defense-in-depth documentation for the cktech estate. Connectivity
plumbing (interfaces, nftables, tailscale, resolver configs) lives in
[`../networking/`](../networking/).

## Contents

| File | Scope |
|------|-------|
| [`fortigate.md`](fortigate.md) | FortiGate 90G edge: SD-WAN, inbound geo-allowlist + threat feeds, UTM (SSL deep inspection, App Control, IPS, web filter), DNS enforcement |
| [`dns.md`](dns.md) | DNS infra: Technitium + unbound primary, PiHole + unbound backup, forced-DNS posture |
| [`dmz.md`](dmz.md) | thallium mini-PC public-facing DMZ isolation model |
| [`crowdsec/threatfeed.md`](crowdsec/threatfeed.md) | Self-hosted CrowdSec threat-feed pipeline (engine → mirror → nginx → FortiGate) |
| [`crowdsec/crowdsec.md`](crowdsec/crowdsec.md) | CrowdSec LAPI engine runbook + incident notes |

## At a glance

```
Internet
   │  SD-WAN: fiber (primary) / cable (backup)
   ▼
FortiGate 90G ── inbound: geo allowlist → threat feeds (incl. self-hosted CrowdSec)
   │             → deep inspection → App Control → IPS
   │             outbound: forced DNS (Technitium) → App Control → IPS → web filter
   ├── DMZ30: thallium (public nginx, isolated, no LAN pivot)
   ├── DNS: Technitium+unbound / PiHole+unbound (no client bypass)
   └── mgmt: Tailscale only
```
