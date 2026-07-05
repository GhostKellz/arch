---
name: cktech-wazuh
description: Operate CKTech Wazuh integration with Heimdall/Grafana. Use for Wazuh indexer, OpenSearch datasource, Wazuh dashboard, agent connectivity, index patterns, timestamp fields, and Wazuh-related security telemetry.
---

# CKTech Wazuh

- Heimdall reads Wazuh observe-only; it does not duplicate agents, manager, or storage.
- Grafana OpenSearch datasource uses date-math index pattern: `[wazuh-alerts-4.x-]YYYY.MM.DD` plus `interval: Daily`, not `wazuh-alerts-*`.
- Use `timestamp` as the time field.
- Keep indexer credentials in `.env`/secret store only.
- Changing `network.host` on the indexer requires backup, one-line edit, bootstrap-check awareness, and cluster health verification.
- Empty panels: check datasource health, index pattern, indexer reachability, and time range.
