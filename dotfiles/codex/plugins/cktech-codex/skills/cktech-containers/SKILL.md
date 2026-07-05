---
name: cktech-containers
description: Docker, Docker Compose, cAdvisor, container networking, image builds, volumes, registry auth, and CKTech host-networking conventions. Use for compose stacks, Dockerfiles, container metrics, and deployment debugging.
---

# CKTech Containers

- CKTech local/dev stacks often use host networking to avoid bridge DNS/connectivity problems.
- Verify compose changes with `docker compose ps`, logs, health checks, and exposed listeners.
- Know which services are native host services versus containers.
- Never bake secrets into image layers.
- Be careful with named volumes and `rsync --delete` deploys.
- cAdvisor labels may be sparse; verify dashboard queries against actual metrics.
