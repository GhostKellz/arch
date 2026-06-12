# Threat Feed: CrowdSec decisions -> threat.cktechnology.io/crowdsec.txt

As-built. Live and serving.

Publishes the CrowdSec LAPI decisions (local bans + CAPI community blocklist +
console blocklists, as one union) as a plaintext IP/CIDR list at
`https://threat.cktechnology.io/crowdsec.txt`, served by nginx on the **thallium**
box, for import into FortiGate as an external IP Threat Feed.

## Environment

CrowdSec LAPI box (`10.0.0.23`, Tailscale `100.114.255.16:8080`):
- LAPI-only Security Engine. ~75k active decisions (union of CAPI community,
  console `lists`, and local `crowdsec` origins).
- Bouncer `thallium-blocklist-mirror` registered here pulls the live decision stream.

thallium (`10.0.30.7`, Tailscale `100.88.18.17`, Debian 13):
- nginx `1.26.3` (system package), confs in `/etc/nginx/conf.d/`.
- Wildcard cert `/etc/nginx/certs/cktechnology.io/{fullchain.pem,privkey.pem}`,
  SAN `*.cktechnology.io, cktechnology.io` -> covers `threat.cktechnology.io`.
- Docker present; blocklist-mirror runs as a container with host networking.
- DNS `threat.cktechnology.io` -> public IP (FortiGate pulls over WAN).

## Architecture

```
[edge agents] --tailscale--> [LAPI 100.114.255.16:8080]
                                       ^ bouncer api-key
                                       |
        [docker: crowdsecurity/blocklist-mirror, network_mode: host]
                       listens 127.0.0.1:41412  /security/blocklist (plain_text)
                                       |
        nginx (wildcard cert) reverse-proxies https://threat.cktechnology.io/crowdsec.txt
                                       |
                          FortiGate External Connector (IP Threat Feed)
```

No static file / no export timer. nginx reverse-proxies directly to the mirror, so
the feed is always live (mirror `update_frequency: 10s`). The feed is the **union of
all active decisions** (local + CAPI + console lists).

## Distributed setup (how the pieces relate)

Two purpose-built VMs in the PVE cluster, joined over Tailscale, with one public
egress point:

- **crowdsec VM** (`crowdsec`, LAN `10.0.0.23`, Tailscale `100.114.255.16`) — local
  PVE guest. The **CrowdSec LAPI-only Security Engine** (Postgres-backed). This is the
  brain: every edge agent/bouncer in the estate reports to it and pulls decisions from
  it over Tailscale (`:8080`). It also pulls the CAPI community blocklist and console
  lists, so its decision table is the single source of truth that gets *advertised* out
  to the rest of the fleet. No log processor runs here by design.

- **thallium VM** (`cktech-nginx`, LAN `10.0.30.7`, Tailscale `100.88.18.17`, Debian 13)
  — local PVE guest, the cktech nginx front door. Runs the `blocklist-mirror` Docker
  container (host networking, bound to `127.0.0.1:41412`) which registers back to the
  crowdsec VM's LAPI as a bouncer and mirrors the live decision union. nginx (wildcard
  `*.cktechnology.io` cert) reverse-proxies that mirror to the **public** URL
  `https://threat.cktechnology.io/crowdsec.txt`.

Data flow:

```
edge agents/bouncers ─┐
CAPI community feed ──┼─► crowdsec VM (LAPI, 10.0.0.23) ── tailscale ──► thallium
console lists ────────┘        single source of truth            blocklist-mirror :41412
                                                                         │
                                                          nginx (cktech-nginx, wildcard cert)
                                                                         │
                              public ◄── https://threat.cktechnology.io/crowdsec.txt
                                                                         │
                                                    FortiGate 90G external threat feed (pull)
```

Why split this way: the Security Engine stays on a locked-down internal VM reachable
only over Tailscale/LAN; thallium is the only box with public exposure, so it owns the
TLS cert and the public endpoint. The FortiGate (and anything else) consumes a plain
HTTPS URL without ever touching the engine directly.

### Where this is documented / referenced

- **Website (cktechnology.io):** the feed is advertised under the public
  `threat.cktechnology.io` host (wildcard-cert subdomain of the main site).
- **Hudu:** this runbook is mirrored into the Hudu IT-documentation server as the
  authoritative reference for the CrowdSec engine + threat-feed pipeline (engine VM,
  thallium mirror, nginx vhost, FortiGate connector, rollback). Keep Hudu and this file
  in sync when the pipeline changes.

## Sensors feeding the engine

What ends up in the feed is the deduped union of every CrowdSec detection source
reporting to the engine:

- Edge CrowdSec agents/bouncers across the estate (over Tailscale).
- **Azure website nginx bouncer** — the public cktech website (hosted on Azure) runs a
  CrowdSec nginx bouncer that both *enforces* decisions on the site and acts as a
  *sensor*: an attack on the public site is reported to the engine, lands in this feed,
  and is then blocked at the FortiGate for every other service. Closed
  detection→enforcement loop.
- CAPI community blocklist + console lists (pulled by the engine).

> **Wider edge architecture** — this feed is just one input into the FortiGate 90G
> perimeter (geo-allowlist, ~30 other threat feeds, SSL deep inspection, App Control,
> IPS, web filtering, SD-WAN, forced DNS). That lives in
> [`../fortigate.md`](../fortigate.md); DNS infra in [`../dns.md`](../dns.md); the
> thallium DMZ model in [`../dmz.md`](../dmz.md).

## Components (as deployed)

### 1. LAPI box: bouncer registration
```bash
cscli bouncers add thallium-blocklist-mirror   # -> API key used below
cscli bouncers list                            # verify present + recent pull
```
Issued key: *(redacted — stored in the mirror's `crowdsec-blocklist-mirror.yaml`)*

### 2. thallium: blocklist-mirror container
`/home/ckelley/crowdsec-mirror/compose.yml`:
```yaml
services:
  blocklist-mirror:
    image: crowdsecurity/blocklist-mirror:latest
    container_name: crowdsec-blocklist-mirror
    network_mode: host
    volumes:
      - ./config:/etc/crowdsec/bouncers
    restart: unless-stopped
```
`/home/ckelley/crowdsec-mirror/config/crowdsec-blocklist-mirror.yaml`:
```yaml
config_version: v1.0
crowdsec_config:
  lapi_key: <REDACTED>   # cscli-issued bouncer key
  lapi_url: http://100.114.255.16:8080/
  update_frequency: 10s
  insecure_skip_verify: false
blocklists:
  - format: plain_text
    endpoint: /security/blocklist
    authentication:
      type: none
      user: ""
      password: ""
      trusted_ips: []
listen_uri: 127.0.0.1:41412
tls:
  cert_file: ""
  key_file: ""
metrics:
  enabled: true
  endpoint: /metrics
log_media: stdout
log_level: info
```
```bash
cd /home/ckelley/crowdsec-mirror && docker compose up -d
curl -s http://127.0.0.1:41412/security/blocklist | wc -l   # ~74,976
```

### 3. thallium: nginx vhost
`/etc/nginx/conf.d/csmirror.conf` reverse-proxies the feed at both `/` and
`/crowdsec.txt`:
```nginx
server {
    listen 80;
    server_name threat.cktechnology.io;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl http2;
    server_name threat.cktechnology.io;

    ssl_certificate     /etc/nginx/certs/cktechnology.io/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/cktechnology.io/privkey.pem;

    location = /crowdsec.txt {
        default_type text/plain;
        proxy_pass http://127.0.0.1:41412/security/blocklist;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    location = / {
        default_type text/plain;
        proxy_pass http://127.0.0.1:41412/security/blocklist;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    location / { return 404; }
}
```
```bash
sudo nginx -t && sudo systemctl reload nginx
```

**Access control:** currently **public** (no IP allowlist) so the FortiGate can pull
over WAN. If you later want to lock it down, add `allow <FortiGate-public-IP>; deny all;`
in the 443 server block (FortiGate pulls from its WAN egress IP, not a LAN/tailnet IP).

### 4. FortiGate: external threat feed
1. Security Fabric -> External Connectors -> Create New -> Threat Feeds -> **IP Address**.
2. URI `https://threat.cktechnology.io/crowdsec.txt`; Refresh Rate e.g. 5 min; enabled.
3. Verify: `diagnose sys external-resource list`,
   `diagnose sys external-resource entry-list <name>`.
4. Reference the feed address object in an IPv4 policy as **source** with action DENY.

Wildcard cert chain is in `fullchain.pem`; recent FortiOS trusts the public issuing CA.

## Size caveat

Union is ~75k entries (~1 MB), dominated by console list `crowdsec_cve_2025_55182`
(~47.6k). Confirm the FortiGate model's max external-resource entries; low/mid models
may truncate. If trimming is needed, use mirror per-blocklist filters (by origin/scope/
scenario) or expose a second filtered endpoint.

## Verification (passed)
- `cscli bouncers list` shows `thallium-blocklist-mirror` with recent pull.
- `curl -s 127.0.0.1:41412/security/blocklist | wc -l` -> 74,976.
- `https://threat.cktechnology.io/crowdsec.txt` -> 200, 74,976 lines, plaintext IPs,
  byte-for-byte match with the mirror.
- `/` serves the same feed; other paths 404.

## Rollback
- nginx: `rm /etc/nginx/conf.d/csmirror.conf && nginx -t && systemctl reload nginx`
- mirror: `cd /home/ckelley/crowdsec-mirror && docker compose down`
- LAPI: `cscli bouncers delete thallium-blocklist-mirror`
- FortiGate: disable/delete the External Connector.

## Future work: PVE firewall blocking from the same feed

- A timer on a PVE node fetches the feed and rewrites a datacenter-level IPSet
  (`/cluster/firewall/ipset/crowdsec`) via `pvesh`/API; a datacenter DROP rule
  referencing it applies cluster-wide.
- At ~75k entries prefer the **nftables** firewall backend (PVE 8); iptables is heavy
  at this size. Consider filtering out the ~47k CVE list for the PVE path.
- Open: per-VM vs datacenter scope, IPv4/IPv6 split.

Out of scope for the initial feed bring-up.
