# Uptime Kuma: reachability monitoring + notifications

Uptime Kuma is the **human-facing** reachability layer. Prometheus/Alertmanager own
infrastructure metrics and rule-based alerting; Kuma owns "is this host/service up?"
checks — client servers, public portals, LAN↔cloud heartbeats — with a friendly status
page and its own Discord + SMTP2Go notifications.

| Layer | Owns | Alerts via |
|-------|------|-----------|
| Prometheus + Alertmanager | infra metrics, targets, exporters | Alertmanager → Discord/email |
| Uptime Kuma | up/down reachability, certs, keywords, heartbeats | Kuma → Discord/email |

In the reference deployment Kuma runs in a container on a Proxmox host **behind nginx**
with no public IP of its own. It reaches targets outbound and is published as a friendly
hostname (e.g. `uptime.example.com`) through the reverse proxy, restricted to LAN +
tailnet like the other portals.

---

## 1. Deploy

```bash
cd uptime-kuma
cp .env.example .env        # set KUMA_BIND_IP if nginx is remote
docker compose up -d
# front with nginx (TLS + LAN/tailnet allow-list), as per reverse-proxy/heimdall-portals.conf
```

First load: create the admin user in the web UI.

---

## 2. Monitor types

### Ping (ICMP) — client servers / LAN hosts
Use for bare reachability of devices that don't speak HTTP. One monitor per host; the
monitor name is what shows up in the alert.

- Type: `Ping`
- Hostname: `192.168.10.5` (the client/server IP)
- Friendly name: e.g. `ACME-IRON` → alert reads "ACME-IRON is down" when ping fails.

Create one per client server IP. If any stops responding, Kuma notifies.

### Keyword (HTTP) — portals & web apps
Confirms the page is not just up but serving the expected content.

- Type: `HTTP(s) - Keyword`
- URL: `https://grafana.example.com`
- Keyword: a string that only appears when the app is healthy (e.g. `Grafana`).
- Also surfaces **TLS certificate expiry** automatically.

### TCP — non-HTTP services
- Type: `TCP Port`
- Host/Port: e.g. `192.0.2.25:9200` (indexer), `:22`, `:3389`, etc.

### Push — LAN → cloud heartbeat
Kuma lives in the cloud and **cannot reach into a NATed client LAN**. Invert the flow:
Kuma gives a push URL, and an agent inside the LAN calls it on a schedule. If the
heartbeat stops arriving, Kuma alerts.

- Type: `Push`
- Set **Heartbeat Interval** (e.g. 60s) and a grace period.
- On a LAN host, cron/systemd-timer hits the push URL:

```bash
# every minute; --fsS keeps cron quiet unless curl itself errors
* * * * * curl -fsS "https://uptime.example.com/api/push/REPLACE_TOKEN?status=up&msg=OK" >/dev/null
```

Use a push monitor as a local probe: the on-LAN agent can itself ping internal client
IPs and only push `up` when they all respond, turning "Kuma can't see the LAN" into an
inside-out check.

### Docker Container — container health (via socket proxy)
Reads container state through the read-only [docker-socket-proxy](../../docker-socket-proxy/).

- Type: `Docker Container`
- Container name: e.g. `grafana`
- Docker Host → **Connection Type:** `TCP / HTTP`, **Docker Daemon:** `http://100.64.0.40:2375`

> **No trailing space** in the Docker Daemon field. A stray space makes Kuma request
> `%20/containers/json` and the proxy returns `400 Bad request`. First thing to check if
> a working Docker host monitor suddenly 400s.

---

## 3. Notifications (Discord + SMTP2Go)

**Settings → Notifications → Setup Notification**, then attach to each monitor (or set as
default for all).

**Discord**
- Type: `Discord`
- Discord Webhook URL: the `#monitoring` (or dedicated uptime) channel webhook.

**SMTP2Go email**
- Type: `Email (SMTP)`
- Host: `mail.smtp2go.com`, Port: `587`, Security: `STARTTLS`
- Username: `uptime@example.com`, Password: SMTP2Go SMTP password
- From: `uptime@example.com`, To: `alerts@example.com`

Use the **Test** button on each before saving. Tune **Retries** and
**Resend Notification every X** to avoid flap spam.

---

## 4. What to monitor

Home lab / cloud (alert if down):

- `heimdall`, `wazuh`, Kasm, `pve1` (cloud), Hudu VM, ScreenConnect, Nexus ticketing
- Proxmox cluster nodes (`:8006` HTTP keyword or `:22` TCP)
- Public portals: `grafana.example.com`, `prometheus.example.com`, `alerts.example.com`,
  `uptime.example.com`, `cs.example.com`

Client edge (ping monitors), e.g. `192.168.10.5`, `192.168.10.6`, `192.168.20.20` — one
per client server, named so the alert identifies the client.

---

## 5. Relationship to Prometheus

Keep the split clean: don't recreate every node_exporter target as a Kuma monitor. Use
Kuma for reachability/heartbeats/certs and client-facing status; let Prometheus rules
(see [docs/alerting.md](../alerting.md)) handle metric thresholds and exporter health.
