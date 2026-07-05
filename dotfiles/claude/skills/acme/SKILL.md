---
name: acme
description: Issue, renew, and deploy Let's Encrypt TLS certificates with acme.sh using Cloudflare DNS-01 (dns_cf), including wildcards. Use for any "cert expired / issue a cert / renew / wildcard / *.domain / TLS not trusted" task on a host running acme.sh. CRITICAL: also use when a cert is expired in the browser but acme.sh says it renewed — that is the silent-deploy bug this skill exists to prevent and fix.
---

# acme.sh — Let's Encrypt + Cloudflare DNS-01

Operational discipline for issuing and **deploying** certs so they never silently
expire. Full runbook (Azure DNS, managed identity, comparison vs certbot) lives in
the brain: `~/brain/wiki/references/acme.sh.md`. This skill is the reflex layer.

## Host layout (these hosts)
- nginx server blocks: `/etc/nginx/conf.d/<domain>.conf` — the `ssl_certificate`
  / `ssl_certificate_key` directives point at the deploy path below.
- deployed certs: `/etc/nginx/certs/<domain>/{fullchain,privkey}.pem` (one dir
  per domain). This is the stable path `--install-cert` writes to, never
  `~/.acme.sh`.
- reload: `sudo systemctl reload nginx` (validate first with `sudo nginx -t`).

## Assumptions
- `acme.sh` is installed (`~/.acme.sh/`), daily cron already wired by install.
- Issuer is **Let's Encrypt**; validation is **DNS-01 via Cloudflare (`dns_cf`)**.
- Cloudflare creds are provided by the environment (a scoped token, `Zone:DNS:Edit`
  + `Zone:Zone:Read`), exported before first issue:
  ```bash
  export CF_Token="<scoped-cloudflare-token>"
  export CF_Account_ID="<cloudflare-account-id>"   # optional but recommended
  ```
  After the first run acme.sh persists them in `~/.acme.sh/account.conf`; renewals
  don't need them re-exported.

## Issue (Let's Encrypt, Cloudflare DNS-01)
```bash
acme.sh --set-default-ca --server letsencrypt        # pin LE (default is ZeroSSL)
acme.sh --issue --dns dns_cf -d example.com                    # single host
acme.sh --issue --dns dns_cf -d example.com -d '*.example.com' # wildcard + apex
# add --server letsencrypt_test while testing to dodge rate limits
```

## Deploy — the step that prevents the outage
NEVER point nginx at files in `~/.acme.sh` (acme.sh rotates them). Use
`--install-cert` to copy to a stable path AND register a reload hook. This is the
non-negotiable step — an `--issue` without an `--install-cert … --reloadcmd`
renews on disk but never touches the served path or reloads the server, so the
live cert quietly expires with no error.

```bash
acme.sh --install-cert -d example.com --ecc \
  --key-file       /etc/nginx/certs/example.com/privkey.pem \
  --fullchain-file /etc/nginx/certs/example.com/fullchain.pem \
  --reloadcmd      "sudo systemctl reload nginx"
```

Two conditions must BOTH hold for auto-deploy to work on every future renewal:
1. `Le_ReloadCmd` is set in `~/.acme.sh/<domain>_ecc/<domain>.conf` (i.e. you ran
   `--install-cert … --reloadcmd`).
2. The deploy files are **writable by the acme.sh user**. If they were seeded
   root-owned by an initial `sudo` copy, the unprivileged cron renew can't
   overwrite them and the deploy silently fails. `chown` them first:
   ```bash
   sudo chown "$USER:$USER" /etc/nginx/certs/example.com/{fullchain,privkey}.pem
   ```

## Diagnose "expired in browser but acme.sh renewed"
```bash
# 1. What is actually SERVED vs what is ON DISK
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null \
  | openssl x509 -noout -enddate
openssl x509 -enddate -noout -in /etc/nginx/certs/example.com/fullchain.pem
openssl x509 -enddate -noout -in ~/.acme.sh/example.com_ecc/example.com.cer

# 2. Which certs are missing the reload hook (audit all at once)
for c in ~/.acme.sh/*_ecc/*.conf; do
  d=$(basename "$c" .conf)
  grep -q "Le_ReloadCmd='__ACME" "$c" && echo "$d: hook OK" || echo "$d: NO RELOAD HOOK"
done
```
Fix is idempotent: re-run `--install-cert … --reloadcmd` (deploys now **and**
persists the hook). `chown` the deploy files first if they are root-owned.

## Operations
```bash
acme.sh --list                        # certs + next renew date
acme.sh --renew -d example.com --ecc --force
acme.sh --cron                        # what the daily job runs (renew-if-due)
```
LE certs are 90-day; acme.sh renews at ~60 days. After any cert change verify the
served cert externally (step 1 above) — do not trust "renew succeeded."
