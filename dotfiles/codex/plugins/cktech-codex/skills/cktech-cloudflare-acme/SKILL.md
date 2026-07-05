---
name: cktech-cloudflare-acme
description: "Use for CKTech Cloudflare zone configuration and ACME certificate work: DNS-01 validation, acme.sh, wildcard certificates, cert renewal/deploy issues, WAF/cache/rate-limit/bot settings, purge, or browser TLS errors after renewal."
---

# CKTech Cloudflare / ACME

- Prefer scoped Cloudflare API tokens over Global API Key.
- Read existing zone/rules/settings before writing.
- ACME renewal success is not enough: verify deployed cert path and service reload.
- For nginx, run `nginx -t` before reload.
- If browser cert is expired but acme.sh renewed, suspect silent deploy failure first.
- Preserve rollback paths for WAF/cache/rate-limit/bot changes.
