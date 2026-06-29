# Runbook: syslog-ng → Loki ingestion stalled (stuck disk-buffer)

**Symptom:** Loki-backed Grafana panels (e.g. FortiGate dashboards, Threat Geography) go
empty, while Prometheus-backed panels (e.g. CrowdSec) keep working. Logs are still
arriving at the host but not reaching Loki.

---

## Why this happens

syslog-ng writes to two independent destinations: an on-disk archive
(`/var/log/remote/<host>/<program>.log`) and a Loki HTTP destination. The archive can
keep filling while the Loki path is broken.

If Loki starts rejecting writes (e.g. `HTTP 400` on a batch), syslog-ng's **reliable
disk-buffer** queues messages and retries. A persistently-rejected batch at the head of
the queue makes the buffer fill and **all** new Loki writes stall behind it — even though
syslog itself is healthy and the archive keeps growing.

Quick triage — confirms it's the Loki path, not Grafana or the sender:

```bash
# Logs still landing on disk? (archive independent of Loki)
ls -l /var/log/remote/192.0.2.1/firewall.log    # FortiGate src; size still growing

# syslog-ng queue backing up toward Loki?
sudo syslog-ng-ctl stats | grep -i loki         # look for non-zero queued / dropped
du -sh /var/lib/syslog-ng                        # disk-buffer growing large

# Loki itself up and writable?
curl -s http://127.0.0.1:3100/ready
docker compose -f /opt/heimdall/docker-compose.yml ps loki
```

---

## Recovery

Preserve the stuck buffer rather than deleting it — the on-disk archive still has the raw
logs, but the buffer is the only copy of anything that was queued-but-not-archived.

```bash
sudo systemctl stop syslog-ng

# Move the stuck reliable-queue file aside (do NOT rm). Path/name vary by config;
# identify the loki destination's .rqf/.qf under /var/lib/syslog-ng.
sudo mkdir -p /var/lib/syslog-ng/stuck-buffers
sudo mv /var/lib/syslog-ng/syslog-ng-loki-*.rqf \
        /var/lib/syslog-ng/stuck-buffers/syslog-ng-loki-$(date +%Y%m%d-%H%M%S).rqf

sudo systemctl start syslog-ng
```

---

## Verify

```bash
# Direct Loki push/query works
curl -s http://127.0.0.1:3100/ready

# Fresh syslog-ng stats: queued=0, dropped=0, fresh Loki writes
sudo syslog-ng-ctl stats | grep -i loki

# Loki sees the source again
curl -sG http://127.0.0.1:3100/loki/api/v1/label/source_type/values | jq .data
curl -sG http://127.0.0.1:3100/loki/api/v1/query_range \
  --data-urlencode 'query={source_type="fortigate"}' \
  --data-urlencode 'limit=10' | jq -r '.data.result[].values[][1]'
```

FortiGate panels and Threat Geography repopulate once `source_type=fortigate` returns.

---

## Aftercare

- The preserved buffer (`/var/lib/syslog-ng/stuck-buffers/…rqf`) can be inspected/replayed
  carefully, or deleted once you accept losing that buffered Loki copy. The raw FortiGate
  archive under `/var/log/remote/` is unaffected either way.
- **Root-cause the 400.** A recurring stall usually means Loki rejected a batch — common
  causes: timestamps too far out of Loki's accepted window, label cardinality/format, or
  body exceeding limits. Check Loki logs (`docker compose logs loki`) around the first
  stall and fix the syslog-ng Loki destination (labels/timestamp) so it doesn't recur.
- Consider a Prometheus alert on syslog-ng disk-buffer growth / no-recent-Loki-write so
  this surfaces before dashboards go dark (see [docs/alerting.md](../alerting.md)).
