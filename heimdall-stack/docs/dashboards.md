# Dashboards

Grafana dashboards are **provisioned from this repo** — they are read-only in the UI
and the JSON files under `grafana/dashboards/` are authoritative. The provider
(`grafana/provisioning/dashboards/dashboards.yml`) loads them into a Grafana folder
named **Heimdall**, with sub-folders mirroring the directory structure
(`foldersFromFilesStructure: true`), reloading every 30s.

---

## Catalog

| Dashboard | UID | Folder | Datasource | Notes |
|-----------|-----|--------|------------|-------|
| Heimdall Overview | `heimdall-overview` | overview | Prometheus + Loki | Single-pane: target health, CPU/mem, log volume, CrowdSec posture |
| Node Exporter Full | `heimdall-node-exporter` | host | Prometheus | Community 1860, full host metrics |
| Cadvisor exporter | `heimdall-cadvisor` | containers | Prometheus | Community 14282; see name-label caveat below |
| Loki Logs Explorer | `heimdall-loki-logs` | logs | Loki | `$source_type/$host/$app` + line filter |
| FortiGate Firewall | `heimdall-fortigate` | firewall | Loki | `logfmt`-parsed; empty until FortiGate ships to `:5514` |
| CrowdSec Overview | `heimdall-crowdsec` | security | Prometheus | Decisions, alerts, LAPI/bouncer traffic |
| Wazuh SIEM | `heimdall-wazuh` | security | Wazuh (OpenSearch) | Alerts, severity, top rules/agents/MITRE/IPs |

---

## Datasources

`grafana/provisioning/datasources/datasources.yml` (UIDs are stable and referenced by
dashboards):

| Name | UID | Type | URL |
|------|-----|------|-----|
| Prometheus | `prometheus` | prometheus | `http://127.0.0.1:9090` (default) |
| Loki | `loki` | loki | `http://127.0.0.1:3100` |
| Alertmanager | `alertmanager` | alertmanager | `http://127.0.0.1:9093` |
| Wazuh | `wazuh` | grafana-opensearch-datasource | `${WAZUH_INDEXER_URL}` |

The Wazuh datasource is only functional when `WAZUH_*` are set in `.env`. Its index
pattern is a **date-math pattern** (`[wazuh-alerts-4.x-]YYYY.MM.DD`, `interval: Daily`,
`timeField: timestamp`) — see [senders/wazuh.md](senders/wazuh.md).

---

## Authoring conventions

When adding/importing a dashboard JSON:

1. Drop it under the right `grafana/dashboards/<folder>/`.
2. Remove the `__inputs` / `__requires` blocks from community exports.
3. Replace datasource template refs (`${DS_PROMETHEUS}` etc.) with the fixed UID
   (`prometheus`, `loki`, `wazuh`).
4. Set a stable `uid` (`heimdall-<name>`) and `"id": null`.
5. Deploy; confirm via the search API:
   ```bash
   curl -s -u admin:*** http://localhost:3000/api/dashboards/uid/<uid> \
     | jq '.dashboard.title, (.dashboard.panels|length)'
   ```

---

## Known caveats

- **cAdvisor name labels:** the cAdvisor instance emits only the cgroup `id` label, not
  `name`/`image`, so community panels keyed on `name` under-populate. Workarounds use
  the docker cgroup id regex (`id=~"/system.slice/docker-.*"`).
- **FortiGate / Wazuh empties:** the FortiGate dashboard stays empty until the firewall
  is pointed at `:5514`; Wazuh panels need the indexer reachable and `WAZUH_*` set.
