# Networking

## Segments

| Name | CIDR | Hosts |
|------|------|-------|
| LAN | `192.0.2.0/24` | Firewall, Proxmox, workstation, CrowdSec (`.23`), Wazuh (`.25`), Heimdall (`.10`) |
| DMZ | `198.51.100.0/24` | Public-edge hosts (e.g. reverse proxy `.7`) |
| Tailnet | `100.x` | Heimdall `100.64.0.10`, Wazuh `100.64.0.25` |

`192.0.2.0/24` and `198.51.100.0/24` are documentation ranges. Replace them with
your actual LAN and DMZ CIDRs before deployment.

---

## Listening ports (Heimdall)

| Port | Proto | Service | Exposure |
|------|-------|---------|----------|
| 3000 | tcp | Grafana | LAN + tailnet |
| 9090 | tcp | Prometheus | LAN + tailnet |
| 9093 | tcp | Alertmanager | LAN + tailnet |
| 3100 | tcp | Loki HTTP | loopback (push/query/scrape) |
| 9096 | tcp | Loki gRPC | loopback |
| 9100 | tcp | node_exporter | loopback (scraped) |
| 8085 | tcp | cAdvisor | loopback (scraped) |
| 514  | udp+tcp | syslog-ng RFC3164 | LAN |
| 601  | tcp | syslog-ng RFC5424 | LAN |
| 5514 | udp+tcp | syslog-ng FortiGate | LAN |
| 6514 | tcp | syslog-ng RFC5425 TLS | scaffolded, disabled |

Outbound from Heimdall: CrowdSec metrics `192.0.2.23:6060`, Wazuh indexer
`192.0.2.25:9200`, Proxmox/edge node_exporters `:9100`.

---

## DMZ isolation and security-service access

The edge reverse proxy is isolated in the DMZ. The perimeter firewall keeps the
default DMZ-to-LAN deny policy in place; there are no direct exceptions from the
reverse proxy to the LAN-hosted CrowdSec or Wazuh systems.

```mermaid
flowchart LR
    RP_LAN["Reverse proxy\nDMZ address"] -.->|"DENY"| LAN["LAN"]
    RP_TS["Reverse proxy\nTailscale address"] -->|"8080/tcp"| CS["CrowdSec LAPI\nTailscale address"]
    RP_TS -->|"443/tcp"| WZ["Wazuh dashboard\nTailscale address"]
```

Restrict those application paths with Tailscale grants and/or host firewalls:

| Source | Destination | Service |
|--------|-------------|---------|
| Reverse proxy tailnet identity | CrowdSec tailnet identity | `8080/tcp` |
| Reverse proxy tailnet identity | Wazuh tailnet identity | `443/tcp` |

These web-interface paths are separate from Heimdall's observe-only connections to
CrowdSec metrics on `6060/tcp` and the Wazuh indexer on `9200/tcp`.

---

## Firewall (UFW)

`scripts/setup-ufw.sh` (run on the host) sets default-deny inbound and allows:

```mermaid
flowchart LR
    SSH["SSH (any)"] --> H
    TS["tailscale0 (any)"] --> H
    subgraph FromInternal["from LAN 192.0.2.0/24 + DMZ 198.51.100.0/24"]
        ING["514/601/5514 syslog"]
    end
    subgraph FromLAN["from trusted LAN only"]
        UI["3000/9090/9093 admin UIs"]
    end
    FromInternal --> H
    FromLAN --> H["Heimdall"]
    OTHER["everything else"] -.->|"DENY"| H
```

- SSH and `tailscale0` are allowed **before** `ufw enable` — no lockout.
- DMZ hosts may send syslog but cannot reach Heimdall's admin UIs directly.
- Idempotent: UFW dedups identical rules, so re-running is safe.
- Loki/node_exporter/cAdvisor are loopback-only and intentionally not opened.

---

## Tailscale

Heimdall joins the tailnet so the stack is reachable off-LAN and so future cloud hosts
can talk to it over WireGuard:

```bash
sudo tailscale up --hostname heimdall --ssh
```

To expose admin UIs over the tailnet, set `GF_SERVER_ROOT_URL` to the tailnet address
and rely on the `allow in on tailscale0` UFW rule (already present).

---

## TLS syslog (future)

`syslog-ng/conf.d/99-tls-listener.conf.disabled` scaffolds an RFC5425 TLS listener on
`6514`. To enable: generate certs under `/etc/syslog-ng/certs/`, drop the `.disabled`
suffix, `syslog-ng -s`, restart, and open `6514/tcp` in UFW.
