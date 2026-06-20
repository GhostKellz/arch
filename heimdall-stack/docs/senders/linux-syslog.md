# Onboarding: generic Linux syslog senders

Any standard RFC3164/RFC5424 syslog sender (Linux hosts, network gear, appliances) can
ship to Heimdall's `s_net_standard` source. No per-sender config is needed on Heimdall.

| Transport | Port | Use |
|-----------|------|-----|
| UDP | `514` | low overhead, lossy |
| TCP | `514` | reliable RFC3164 |
| TCP | `601` | reliable RFC5424 (IETF) |

Streams land as `source_type=syslog`, `app=<program>`, `host=<sender>`, with
`facility` + `severity` labels.

---

## rsyslog sender

`/etc/rsyslog.d/60-heimdall.conf`:

```
*.*  @@192.0.2.10:514      # TCP (reliable). Use a single @ for UDP.
```

```bash
sudo systemctl restart rsyslog
```

## systemd-journald (no rsyslog)

Forward the journal to a syslog daemon, or use the RFC5424 path. Simplest is to install
rsyslog and use the snippet above. To send RFC5424 over TCP 601 from rsyslog:

```
*.*  @@192.0.2.10:601;RSYSLOG_SyslogProtocol23Format
```

## One-off / scripted test

```bash
logger -n 192.0.2.10 -P 514 -d -t myapp "hello from $(hostname)"      # UDP
logger -n 192.0.2.10 -P 514 -T -t myapp "hello tcp from $(hostname)"  # TCP
```

The repo ships `docker/scripts/test-syslog.sh [target]` which does exactly this and
prints the Loki query to confirm receipt.

---

## Verify

```bash
# from Heimdall — did it land?
curl -sG http://127.0.0.1:3100/loki/api/v1/query_range \
  --data-urlencode 'query={host="<sender-hostname>"}' \
  --data-urlencode 'limit=5' | jq -r '.data.result[].values[][1]'

# on-disk archive
sudo ls -l /var/log/remote/<sender-hostname>/
```

Then filter in the **Loki Logs Explorer** dashboard by `$host` / `$app`.

---

## Firewall

`scripts/setup-ufw.sh` opens `514/udp`, `514/tcp`, `601/tcp` from the example LAN
`192.0.2.0/24` and DMZ `198.51.100.0/24`. Replace those documentation ranges with
the deployment's actual CIDRs. Senders outside those ranges need their CIDR added (or
must reach Heimdall over Tailscale, which is allowed in full).
