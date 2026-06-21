---
paths:
  - "**/Dockerfile"
  - "**/docker-compose*.yml"
  - "**/docker/**"
---

# Docker & containers (local dev/test on this workstation)

- Default layout: `docker-compose.yml` + `docker/Dockerfile` + `docker/scripts/`.
- Default to host networking; do NOT create custom bridge networks for local testing.
  - Build config: `dockerfile: docker/Dockerfile`, `network: host`.
  - Runtime config: `network_mode: host`.
  - Reason: bridge networking repeatedly breaks DNS/connectivity here. If a tool fails under non-host networking, switch to host networking instead of debugging the bridge.
- After bringing a stack up, verify: (1) DNS resolves, (2) the app reaches expected local services.
- Image choice: Alpine by default; Arch for Arch-native tooling/package workflows or to match the host; `debian:slim` only when Alpine can't support the stack cleanly.
- Keep setups simple, reproducible, and easy to tear down. These are for dev/verification, not production orchestration.
