---
name: loki-syslog-ng
description: Maintain and troubleshoot syslog-ng to Loki ingestion. Use for syslog listeners, FortiGate logs, Loki HTTP push, disk-buffer issues, low-cardinality labels, logger tests, /var/log/remote, and missing logs in Grafana.
---

# Loki / syslog-ng

- syslog-ng runs natively so log ingest survives Docker restarts.
- Always validate with `syslog-ng -s` before restarting.
- This build uses `http()` push to Loki because the gRPC `loki()` driver is absent.
- Keep Loki labels low-cardinality: `host`, `facility`, `severity`, `source_type`, `app`.
- FortiGate uses dedicated `5514` and query-time `logfmt`.
- Verify with `logger`, Loki `query_range`, and `/var/log/remote/<host>/`.
- For stuck buffers/Loki 400 loops, preserve evidence, drain or move bad buffers deliberately, then verify fresh writes.
