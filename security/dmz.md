# DMZ — thallium (public-facing mini-PC)

A single mini-PC, **thallium** (`cktech-nginx`), is the only publicly-exposed host. It
lives on an isolated DMZ segment (`DMZ30`) behind the FortiGate 90G and is treated as
untrusted: if it is compromised, the blast radius is the DMZ, not the LAN.

## Role

- nginx reverse-proxy / public front door (TLS termination with the `*.cktechnology.io`
  wildcard cert).
- Hosts the CrowdSec `blocklist-mirror` container and publishes
  `https://threat.cktechnology.io/crowdsec.txt` (see
  [`crowdsec/threatfeed.md`](crowdsec/threatfeed.md)).
- Runs the crowdsec web UI container (loopback-bound).
- Essentially a **launchpad that only serves what runs on itself** — it does not act as
  a gateway into the rest of the network.

## Isolation model

- **Inbound:** only the published service ports are allowed from the WAN (80/443),
  gated by the full inbound stack — geo allowlist → threat feeds → deep inspection →
  App Control → IPS (see [`fortigate.md`](fortigate.md)). Everything else is dropped.
- **East-west (DMZ → LAN):** default-deny. thallium **cannot initiate connections into
  the LAN**; a compromise can't pivot inward. Only narrowly-scoped management/proxy
  flows are permitted via explicit policies (e.g. `CK NGINX MGMT (22)` for admin →
  thallium, `Lab 40 to Nginx (42)`, `NGINX LAN COMMS (23)` for the specific backends it
  proxies) — never blanket DMZ→LAN.
- **Outbound (DMZ → WAN):** restricted to what it needs (package updates, ACME/cert
  renewal, reaching the CrowdSec LAPI over Tailscale). DNS still forced through Technitium.
- **Management:** over Tailscale only (`100.88.18.17`), no WAN-exposed SSH.

## Why a separate mini-PC

Keeping the only Internet-reachable workload on dedicated, disposable hardware in its
own segment means the public attack surface is physically and logically separated from
the LAN and the PVE cluster. The published feed it serves is read-only and proxied from
a loopback-bound container, so even the feed path exposes no internal service directly.

## Key facts

| Item | Value |
|------|-------|
| Host | thallium (`cktech-nginx`), mini-PC |
| Segment | DMZ30 (isolated) |
| LAN IP | `10.0.30.7` |
| Tailscale | `100.88.18.17` |
| OS | Debian 13 |
| Public exposure | 80/443 only, via FortiGate inbound stack |
| DMZ → LAN | default-deny (no pivot) |
| Management | Tailscale only |
