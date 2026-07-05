---
name: crowdsec
description: Operate CrowdSec monitoring and edge onboarding. Use for central LAPI, bouncers, machines, Prometheus metrics, GitLab CrowdSec, Grafana dashboards, scraper-down alerts, and secret-safe machine/bouncer credential handling.
---

# CrowdSec

- Heimdall is observe-only; the central CrowdSec LAPI remains source of truth.
- The Prometheus endpoint must bind where Heimdall can reach it; the firewall should restrict access to Heimdall.
- Key metrics: `cs_active_decisions`, `cs_alerts`, `cs_lapi_route_requests_total`, `cs_lapi_bouncer_requests_total`, `cs_papi_last_pull_timestamp`.
- For GitLab, preserve machine/bouncer naming and central LAPI configuration.
- Do not commit machine or bouncer credentials.
