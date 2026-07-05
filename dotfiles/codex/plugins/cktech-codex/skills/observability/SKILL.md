---
name: observability
description: "Operate the Heimdall observability stack: Loki, Prometheus, Grafana, Alertmanager, node_exporter, cAdvisor, syslog-ng, CrowdSec metrics, and Wazuh datasource. Use for dashboards, targets, alerts, logs, metrics, and troubleshooting missing data."
---

# Observability

Heimdall model:

- Logs: syslog senders -> native syslog-ng -> Loki -> Grafana.
- Metrics: exporters -> Prometheus -> Alertmanager/Grafana.
- Security overlays: CrowdSec metrics and Wazuh OpenSearch datasource.

Rules:

- syslog-ng runs native, not Docker.
- The core stack uses Docker Compose with host networking.
- Prometheus targets are file-SD; reload with `/-/reload`.
- Verify datasource/target health before editing dashboards.
- For missing data, trace sender -> listener -> pipeline -> store -> dashboard.
