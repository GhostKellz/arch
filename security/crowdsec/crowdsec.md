# CrowdSec Security Engine (host: crowdsec, 10.0.0.23)

LAPI-only Security Engine. Agents and bouncers on edge devices talk to this box's
Local API (LAPI) on `:8080`, backed by PostgreSQL on `:5432`. No log processor /
agent runs here by design (`# SE is LAPI-only` in `config.yaml`).

## Topology

- **LAPI server**: `0.0.0.0:8080` (CrowdSec service `crowdsec.service`)
- **Database**: PostgreSQL `127.0.0.1:5432`, db `crowdsec`, user `crowdsec` (`db_config.type: pgx`)
- **Prometheus**: `127.0.0.1:6060`
- **Auto-registration**: enabled for `10.0.0.0/24` and `100.64.0.0/10`
- **trusted_ips**: `127.0.0.1`, `::1`, `10.0.0.0/24`, `100.64.0.0/10`

Machines and bouncers are stored in PostgreSQL, not in config files. Editing
`config.yaml` or credential files never removes registered endpoints.

## Key files

| Path | Purpose |
|------|---------|
| `/etc/crowdsec/config.yaml` | Main config (`api.client`, `api.server`, `db_config`, etc.) |
| `/etc/crowdsec/local_api_credentials.yaml` | Creds cscli/local clients use to auth to LAPI |
| `/etc/crowdsec/online_api_credentials.yaml` | Creds for CrowdSec central API / console |
| `/var/lib/dpkg/info/crowdsec.postinst` | Debian post-install script (see upgrade caveat) |

`api.client.credentials_path` must point at `local_api_credentials.yaml`, and that
file must contain creds for a machine that **currently exists in the database**.

## Incident: cscli broken + dpkg half-configured after upgrade

### Symptoms
- `cscli lapi status` / `cscli decisions list` → `loading api client: no API client section in configuration`
- `dpkg --configure crowdsec` → `cscli setup unattended: log processor is disabled -- this command cannot run on a LAPI-only instance`, package stuck in `iF` state
- LAPI server, database, agents, bouncers, and console all remained connected throughout — only **local** cscli access and package state were broken.

### Root causes
1. `config.yaml` was missing the `api.client` section entirely → cscli had no client config.
2. `local_api_credentials.yaml` was `0` bytes. Its `.bak` was **stale** — the machine it referenced no longer existed in the DB (`ent: machine not found`), so restoring the `.bak` could never authenticate.
3. The Debian postinst unconditionally runs `cscli setup unattended`, which refuses to run on a LAPI-only instance, so postinst exited non-zero and left dpkg half-configured.

### Fix applied

Fix A — restore local cscli access (no restart, no endpoint loss):
```bash
# 1. add the missing api.client section (sibling of api.server)
sed -i 's|^api:|api:\n  client:\n    credentials_path: /etc/crowdsec/local_api_credentials.yaml|' \
  /etc/crowdsec/config.yaml

# 2. regenerate a fresh local machine + matching creds file (DB and file match by construction)
cscli machines add crowdsec-local --auto --force --file /etc/crowdsec/local_api_credentials.yaml
chmod 600 /etc/crowdsec/local_api_credentials.yaml

# 3. verify
cscli lapi status            # -> "You can successfully interact with Local API (LAPI)"
```

Fix B — clear the dpkg `iF` state:
```bash
cp -a /var/lib/dpkg/info/crowdsec.postinst /root/crowdsec.postinst.bak.$(date +%F-%H%M%S)
sed -i 's/cscli setup unattended/cscli setup unattended || true/g' \
  /var/lib/dpkg/info/crowdsec.postinst
dpkg --configure crowdsec && apt-get -f install -y
dpkg -l crowdsec | tail -1   # -> ii
```

### Verification after fix
- `dpkg -l crowdsec` → `ii`
- `systemctl is-active crowdsec` → `active`
- `cscli lapi status` → success as user `crowdsec-local`
- `cscli machines list` / `cscli bouncers list` → all prior endpoints present

## Upgrade caveat (important)

The `|| true` guard lives in `/var/lib/dpkg/info/crowdsec.postinst`, which is
**overwritten on every `crowdsec` package upgrade**. A future upgrade will
re-trigger the same `cscli setup unattended` failure and leave dpkg in `iF`.

When that happens, reapply Fix B:
```bash
sed -i 's/cscli setup unattended/cscli setup unattended || true/g' /var/lib/dpkg/info/crowdsec.postinst
dpkg --configure crowdsec
```
The durable resolution is upstream guarding that postinst step for LAPI-only
installs.

## Operational notes

- Regenerating local creds with `cscli machines add` adds a row; it never deletes
  existing machines or bouncers.
- Restarting `crowdsec.service` briefly disconnects agents/bouncers (they reconnect);
  it is **not** required for cscli/config-client changes.
- `cscli lapi status` authenticates against the live DB, so a successful result
  confirms both the creds file and DB are consistent.

## SSH access note

Password auth only (no key auth). A literal `!` in a shell-built password string
can get escaped to `\!`, producing a wrong (longer) password and `Permission
denied`. Build the `!` from its octal code to avoid this:
```bash
SSHPASS="$(printf '%b' '<PASS>\041')" sshpass -e ssh ckelley@10.0.0.23   # build the trailing ! from \041
```
Privileged commands: `ckelley` uses `sudo` (pipe the password to `sudo -S`).
