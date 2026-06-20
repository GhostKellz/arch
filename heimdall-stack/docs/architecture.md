# Architecture

Heimdall is a single-node observability server. It runs two independent pipelines —
**logs** and **metrics** — and a visualization layer (Grafana) that also reaches out
to two external security systems (CrowdSec, Wazuh) read-only.

- **Logs:** `syslog senders → syslog-ng (native) → Loki → Grafana`
- **Metrics:** `exporters → Prometheus → (Alertmanager + Grafana)`
- **Security overlays:** `CrowdSec metrics → Prometheus`, `Wazuh indexer → Grafana`

---

## Component responsibilities

| Component      | Runs as            | Role |
|----------------|--------------------|------|
| **syslog-ng**  | native host service | Receives syslog (514/601/5514), tags streams, pushes to Loki, archives to disk |
| **Loki**       | container           | Log store; 30-day retention, TSDB v13, filesystem backend |
| **Prometheus** | container           | Metrics scrape + storage (30d/40GB), rule evaluation |
| **Alertmanager** | container         | Receives firing alerts from Prometheus; routing (stub today) |
| **node_exporter** | container        | Host-level metrics (CPU, mem, disk, net) |
| **cAdvisor**   | container           | Per-container metrics |
| **Grafana**    | container           | Dashboards over Loki + Prometheus + Alertmanager + Wazuh |

All containers use `network_mode: host`. State lives in named Docker volumes
(`loki-data`, `prometheus-data`, `alertmanager-data`, `grafana-data`) plus the host
paths `/var/log/remote` (syslog archive) and `/var/lib/syslog-ng` (Loki disk-buffer).

---

## Log pipeline (syslog-ng → Loki)

```mermaid
flowchart TD
    A1["FortiGate\nudp/tcp 5514"] --> S2
    A2["RFC3164 senders\nudp/tcp 514"] --> S1
    A3["RFC5424 senders\ntcp 601"] --> S1

    subgraph SNG["syslog-ng (native)"]
        S1["source s_net_standard"] --> R1["rewrite r_tag_standard\nsource_type=syslog\napp=PROGRAM"]
        S2["source s_fortigate\nflags(no-hostname)"] --> R2["rewrite r_tag_fortigate\nsource_type=fortigate\napp=firewall"]
        R1 --> ESC["rewrite r_loki_escape\nJSON-escape message"]
        R2 --> ESC
        ESC --> D1["destination d_loki\nhttp POST /loki/api/v1/push\nbatch 300 / 2000ms\ndisk-buffer 512MB reliable"]
        ESC --> D2["destination d_remote_files\n/var/log/remote/HOST/PROGRAM.log"]
    end

    D1 --> LOKI["Loki :3100"]
    LOKI --> GR["Grafana\nLoki Logs Explorer / FortiGate dashboards"]
```

**Stream labels** are deliberately low-cardinality to keep Loki healthy:
`host`, `facility`, `severity`, `source_type`, `app`.

- FortiGate payloads are `key=value` with no RFC3164 hostname → a dedicated port
  (`5514`) + `flags(no-hostname)` keeps the sender IP as `host` and the full blob in
  the message. Query-time parsing uses LogQL `| logfmt`.
- The on-disk archive (`/var/log/remote/<host>/<program>.log`) is a redundant copy,
  independent of Loki.
- Timestamps use **reception time** (ns); Loki 3 accepts unordered writes within a
  stream, so per-sender clock skew does not reject lines.

> **Why http() not the native loki() driver?** The syslog-ng 4.8.1 build on Heimdall
> ships the `http` + `json` modules but **not** the gRPC `loki()` driver, so the
> pipeline pushes JSON to Loki's HTTP push API directly.

---

## Metrics pipeline (exporters → Prometheus)

```mermaid
flowchart TD
    NE["node_exporter :9100\n(host)"] --> P
    CAD["cAdvisor :8085\n(containers)"] --> P
    LOKIm["Loki :3100/metrics"] --> P
    SELF["Prometheus self :9090"] --> P
    PVEn["Proxmox node_exporters\n(file-SD: targets/proxmox-*.yml)"] --> P
    EXTRA["Edge hosts\n(file-SD: targets/node-*.yml)"] --> P
    CSm["CrowdSec LAPI\n192.0.2.23:6060"] -.-> P

    P["Prometheus :9090\n15s scrape · 30d/40GB"] --> RULES["alerts/infra.yml\nTargetDown, NodeHighCpu,\nNodeHighMemory, NodeDiskFillingUp,\nCrowdsecScraperDown"]
    RULES --> AM["Alertmanager :9093"]
    P --> GR["Grafana dashboards"]
```

**File-based service discovery** lets you add Proxmox nodes and edge hosts by editing
`prometheus/targets/*.yml` and reloading — no Prometheus restart:

```bash
curl -X POST http://127.0.0.1:9090/-/reload
```

---

## Security overlays

```mermaid
flowchart LR
    subgraph External
        CS["CrowdSec LAPI\n192.0.2.23 (central)"]
        WZ["Wazuh indexer\n192.0.2.25 (OpenSearch)"]
    end
    CS -->|"Prometheus scrape :6060\ncs_* metrics"| P["Prometheus"]
    P --> GCS["Grafana: CrowdSec Overview"]
    WZ -->|"OpenSearch datasource\n[wazuh-alerts-4.x-]YYYY.MM.DD"| GWZ["Grafana: Wazuh SIEM"]
```

**Observe-only by design.** Heimdall does not run CrowdSec or Wazuh components; it
reads their existing endpoints. CrowdSec stays central on `192.0.2.23` (LAPI + DB);
Heimdall just scrapes its Prometheus endpoint. Wazuh alerts are queried straight from
the indexer via the `grafana-opensearch-datasource` plugin.

---

## Reference deployment: log fan-in

The public template supports a larger deployment without embedding private addresses.
GitLab, public web servers, the DMZ reverse proxy, and the Proxmox fleet all converge
on the same native syslog-ng pipeline:

```mermaid
flowchart LR
    FG["FortiGate"] -->|"udp/tcp 5514"| SNG["syslog-ng"]
    GIT["GitLab\napplication + audit logs"] -->|"tcp 601"| SNG
    TH["Thallium\nNginx + CrowdSec logs"] -->|"tcp 601 over Tailscale"| SNG
    WEB["ckel-web-01\nNginx + CrowdSec logs"] -->|"tcp 601 over Tailscale"| SNG
    PVE["PVE1-PVE9\nhost + service logs"] -->|"514 or 601"| SNG

    SNG -->|"HTTP push"| LOKI["Loki :3100"]
    SNG --> ARCHIVE["On-disk archive"]
    LOKI -->|"LogQL"| GRAFANA["Grafana"]
```

---

## Reference deployment: metrics fan-in

Prometheus scrapes infrastructure exporters directly or through Tailscale-only socket
proxies. File-based service discovery keeps the host inventory outside the main scrape
configuration.

```mermaid
flowchart LR
    subgraph SOURCES["Metric sources"]
        HD["Heimdall\nnode_exporter :9100\ncAdvisor :8085"]
        PVE["PVE1-PVE9\nnode_exporter :9100"]
        GIT["GitLab Omnibus Prometheus\n/federate :9090"]
        TH["Thallium\nnode_exporter :9100\nCrowdSec :6060"]
        WEB["ckel-web-01\nnode_exporter :9100\nCrowdSec :6060"]
        EDGE["Production Nginx\nnode_exporter :9100\nCrowdSec :6060"]
        CSL["Central CrowdSec\nmetrics :6060"]
    end

    HD --> PROM["Prometheus :9090"]
    PVE -->|"file-SD"| PROM
    GIT --> PROM
    TH -->|"Tailscale"| PROM
    WEB -->|"Tailscale"| PROM
    EDGE -->|"Tailscale"| PROM
    CSL --> PROM

    PROM --> RULES["Alert rules"]
    RULES --> AM["Alertmanager :9093"]
    PROM -->|"PromQL"| GRAFANA["Grafana"]
```

---

## Reference deployment: security services

The perimeter firewall denies direct DMZ-to-LAN traffic from Thallium. Its CrowdSec
and Wazuh web-proxy connections use destination-specific Tailscale grants instead.

```mermaid
flowchart TD
    subgraph DMZ["DMZ"]
        TH["Thallium\nNginx + CrowdSec agent"]
        UI["CrowdSec Web UI"]
        MIRROR["CrowdSec blocklist mirror"]
        BOUNCER["Firewall bouncer"]
    end

    FW["Perimeter firewall"] -.->|"DENY DMZ to LAN"| LAN["LAN"]
    TH --- FW

    subgraph SECURITY["Security services over Tailscale"]
        CS["Central CrowdSec LAPI\n8080/tcp"]
        WZD["Wazuh dashboard\n443/tcp"]
        WZI["Wazuh indexer\n9200/tcp"]
    end

    UI -->|"8080/tcp"| CS
    MIRROR -->|"8080/tcp"| CS
    BOUNCER -->|"8080/tcp"| CS
    TH -->|"443/tcp"| WZD

    CS -->|"metrics 6060/tcp"| PROM["Prometheus"]
    WZI -->|"OpenSearch datasource"| GRAFANA["Grafana"]
    PROM --> GRAFANA
```

The UI can exclude bulk CAPI/community-blocklist records from its local display cache
without changing the decisions enforced by CrowdSec bouncers or the blocklist mirror.

---

## How Grafana assembles dashboards

Grafana is the visualization layer, not the collector or primary telemetry store. Each
panel queries its corresponding provisioned datasource:

```mermaid
flowchart LR
    USERS["Operators"] --> G["Grafana :3000"]
    G -->|"PromQL"| P["Prometheus\nmetrics + alert state"]
    G -->|"LogQL"| L["Loki\nsyslog + application logs"]
    G -->|"Alertmanager API"| A["Alertmanager\nfiring and silenced alerts"]
    G -->|"OpenSearch query"| W["Wazuh indexer\nsecurity events"]

    P --> PD["Host, container, Proxmox,\nGitLab and CrowdSec panels"]
    L --> LD["FortiGate, Nginx, GitLab,\nCrowdSec and system-log panels"]
    A --> AD["Alert-state panels"]
    W --> WD["Wazuh SIEM panels"]
```

---

## Network & deployment topology

```mermaid
flowchart TB
    subgraph WS["Workstation (Arch)"]
        REPO["~/arch/heimdall-stack\n(source of truth)"]
    end
    REPO -->|"rsync (deploy.sh)"| OPT["/opt/heimdall on Heimdall"]
    OPT -->|"docker compose up -d"| STACK["core containers"]
    REPO -.->|"copy conf.d/*"| SNGHOST["/etc/syslog-ng/conf.d (native)"]

    subgraph LAN["Internal networks\nLAN 192.0.2.0/24 + DMZ 198.51.100.0/24"]
        STACK
        SNGHOST
    end
    TS["Tailnet 100.x"] -.-> STACK
```

The repo is authored on the workstation and pushed to `/opt/heimdall`. The core stack
runs in Docker there; the syslog-ng pipeline is copied into the host's
`/etc/syslog-ng/conf.d/` and runs natively (it needs privileged port 514 and should
not depend on the Docker daemon being up to keep receiving logs).

---

## Design decisions

| Decision | Rationale |
|----------|-----------|
| syslog-ng native, rest in Docker | Privileged `:514`, and log ingest must survive Docker restarts |
| `http()` push to Loki | The installed syslog-ng build lacks the gRPC `loki()` driver |
| Low-cardinality Loki labels | Avoid stream explosion; parse details at query time (`logfmt`) |
| Host networking | Workstation standard; avoids bridge DNS/connectivity issues |
| CrowdSec/Wazuh observe-only | Keep single sources of truth; no duplicate agents/DBs on Heimdall |
| File-SD for Prometheus targets | Add nodes without restarts; targets are versioned config |
| Image pins via `.env` | Reproducible builds; deliberate, reviewable version bumps |

See **[docs/senders/wazuh.md](senders/wazuh.md)** for the OpenSearch index-pattern
detail (the plugin needs a date-math pattern, not a literal `*`).
