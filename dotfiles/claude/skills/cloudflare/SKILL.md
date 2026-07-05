---
name: cloudflare
description: Configure Cloudflare zones via the REST API v4 — AI bot protection (Super Bot Fight Mode, block AI scrapers), cache rules, WAF custom rules, rate limiting, security level, and cache purge. Use for any "block AI bots / configure cache / add a firewall rule / security / purge cache / tune Cloudflare" task on a zone managed in Cloudflare. Assumes a scoped API token in the environment.
---

# Cloudflare zone configuration (API v4)

Operational skill for configuring Cloudflare via `https://api.cloudflare.com/client/v4`.
This is a footgun-heavy API — the golden rules below prevent wiping existing config.

## Auth & environment
Two auth methods are supported; the skill detects whichever is present. **Prefer
the scoped token** — see the recommendation below.

- **Scoped API token (preferred):** `CF_API_TOKEN`, sent as `Authorization: Bearer`.
  A distinct token from the acme `CF_Token` used for `dns_cf`. Scope it to the
  target zones with: `Zone:Read`, `Zone WAF:Edit`, `Zone Cache Rules:Edit`,
  `Zone Settings:Edit`, `Zone:Cache Purge`, and `Bot Management:Edit` where the plan
  allows.
- **Global API Key (legacy, currently in use):** `CF_Email` + `CF_Key`, sent as
  `X-Auth-Email` + `X-Auth-Key`.

```bash
CF=https://api.cloudflare.com/client/v4
if [ -n "$CF_API_TOKEN" ]; then
  auth=(-H "Authorization: Bearer $CF_API_TOKEN")          # preferred: scoped token
else
  auth=(-H "X-Auth-Email: $CF_Email" -H "X-Auth-Key: $CF_Key")  # legacy Global API Key
fi
auth+=(-H "Content-Type: application/json")

# Resolve a zone id by name
zone_id=$(curl -s "${auth[@]}" "$CF/zones?name=example.com" | jq -r '.result[0].id')
# Check the plan (SBFM + AI-bot blocking need Pro or higher)
curl -s "${auth[@]}" "$CF/zones/$zone_id" | jq -r '.result.plan.name'
```

> [!recommendation] Migrate off the Global API Key
> The Global API Key grants **account-wide** access to every zone and product — if
> it leaks, the whole account is compromised and it can't be narrowly revoked.
> Create a **scoped API token** (My Profile → API Tokens) limited to the zones and
> permissions above, set it as `CF_API_TOKEN`, and the skill uses it automatically.
> Keep the key/token in `pass`/`secret-tool`, not in shell rc files.

## Golden rules
1. **Ruleset phases replace, not append.** Cache Rules and WAF custom rules live in
   Ruleset Engine *phase entrypoints*. A `PUT` to a phase **overwrites every rule in
   that phase.** Always GET the entrypoint, edit the `rules` array, then PUT the full
   set back. Never blind-PUT a single rule.
2. **Read before write.** GET current state and show the diff before changing it.
3. **Test on one zone first.** Use your Pro zone as the canary; only roll a proven
   config to the other zones after it verifies.
4. **Respect plan gating.** If `plan.name` is Free, SBFM/AI-bot fields are unavailable
   — fall back to Bot Fight Mode (`fight_mode: true`).
5. **Verify after write.** Re-GET and confirm; for cache, test with `curl -sI` and read
   `cf-cache-status`.

## AI bot protection & Super Bot Fight Mode (Pro)
Single settings object per zone — read, then PUT the merged object.
```bash
curl -s "${auth[@]}" "$CF/zones/$zone_id/bot_management" | jq        # read current

curl -s -X PUT "${auth[@]}" "$CF/zones/$zone_id/bot_management" --data '{
  "ai_bots_protection": "block",          "//": "block AI scrapers & crawlers",
  "crawler_protection": "enabled",        "//": "link-maze known AI crawlers",
  "sbfm_definitely_automated": "block",
  "sbfm_likely_automated": "managed_challenge",
  "sbfm_verified_bots": "allow",
  "sbfm_static_resource_protection": false,
  "optimize_wordpress": false
}'
```
- Free plan: only `fight_mode: true` (Bot Fight Mode) is available.
- Bot rules run in the `http_request_sbfm` phase, **after** WAF custom rules — so to
  exempt an API path, add a WAF custom rule with the `skip` action (see below); it
  runs first and lets the request bypass SBFM.
- Tuning: start `sbfm_*` on `managed_challenge` (not `block`) for ~2 weeks, watch bot
  analytics, then tighten per-endpoint. Allow-list verified bots first.

## Cache rules (phase: http_request_cache_settings)
```bash
# READ the whole phase entrypoint first
curl -s "${auth[@]}" \
  "$CF/zones/$zone_id/rulesets/phases/http_request_cache_settings/entrypoint" | jq

# PUT the FULL rules array back (this replaces the phase)
curl -s -X PUT "${auth[@]}" \
  "$CF/zones/$zone_id/rulesets/phases/http_request_cache_settings/entrypoint" --data '{
  "rules": [
    {
      "expression": "(http.host eq \"example.com\")",
      "description": "cache everything",
      "action": "set_cache_settings",
      "action_parameters": { "cache": true, "edge_ttl": { "mode": "override_origin", "default": 3600 } }
    }
  ]
}'
```

## WAF custom rules (phase: http_request_firewall_custom)
```bash
curl -s "${auth[@]}" \
  "$CF/zones/$zone_id/rulesets/phases/http_request_firewall_custom/entrypoint" | jq

# actions: block | managed_challenge | js_challenge | skip
# skip example = exempt an API path from SBFM (skip must target the sbfm phase)
curl -s -X PUT "${auth[@]}" \
  "$CF/zones/$zone_id/rulesets/phases/http_request_firewall_custom/entrypoint" --data '{
  "rules": [
    {
      "expression": "(starts_with(http.request.uri.path, \"/api/\"))",
      "description": "let API bypass SBFM",
      "action": "skip",
      "action_parameters": { "phases": ["http_request_sbfm"] }
    },
    {
      "expression": "(ip.geoip.country eq \"CN\" and http.request.uri.path contains \"/wp-login\")",
      "description": "block wp-login abuse",
      "action": "block"
    }
  ]
}'
```

## Rate limiting (phase: http_ratelimit) & security level
```bash
# Security level (legacy zone setting): off|essentially_off|low|medium|high|under_attack
curl -s -X PATCH "${auth[@]}" "$CF/zones/$zone_id/settings/security_level" \
  --data '{"value":"medium"}'
```
Rate-limit rules use the `http_ratelimit` phase entrypoint (same GET→merge→PUT pattern),
with `action_parameters` + a `ratelimit` block (characteristics, period, requests_per_period).

## Purge cache
```bash
curl -s -X POST "${auth[@]}" "$CF/zones/$zone_id/purge_cache" --data '{"purge_everything":true}'
curl -s -X POST "${auth[@]}" "$CF/zones/$zone_id/purge_cache" \
  --data '{"files":["https://example.com/style.css"]}'
```

## Zones & plan gating
Track which zones are on which plan — feature availability depends on it:
- **Pro/Business** zones: full SBFM + AI-bot blocking + WAF custom rules available.
- **Free** zones: Bot Fight Mode (`fight_mode: true`) + cache rules + basic custom
  rules only; SBFM/AI-bot fields are rejected.

Verify every change by re-reading the object and, for cache, checking `cf-cache-status`
on a live request.
