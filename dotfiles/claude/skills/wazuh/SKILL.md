---
name: wazuh
description: Operate Wazuh integration with Heimdall/Grafana. Use for the Wazuh indexer, OpenSearch datasource, Wazuh dashboard, agent connectivity, index patterns, timestamp fields, and Wazuh-related security telemetry.
---

# Wazuh

- Heimdall reads Wazuh observe-only; it does not duplicate agents, manager, or storage.
- The Grafana OpenSearch datasource uses a date-math index pattern: `[wazuh-alerts-4.x-]YYYY.MM.DD` plus `interval: Daily`, not `wazuh-alerts-*`.
- Use `timestamp` as the time field.
- Keep indexer credentials in `.env`/secret store only.
- Changing `network.host` on the indexer requires backup, a one-line edit, bootstrap-check awareness, and cluster health verification.
- Empty panels: check datasource health, index pattern, indexer reachability, and time range.
