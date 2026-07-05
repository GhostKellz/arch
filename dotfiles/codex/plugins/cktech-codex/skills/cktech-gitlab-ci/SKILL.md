---
name: cktech-gitlab-ci
description: Author, review, and debug GitLab CI/CD for CKTech self-hosted GitLab. Use for .gitlab-ci.yml, pipeline failures, runners, artifacts, caches, deploy jobs, masked/protected variables, rules/workflow/needs, and CI modernization.
---

# CKTech GitLab CI

- Prefer `rules:` and `workflow:` over legacy `only:` / `except:`.
- Use `needs:` to build DAGs where it shortens feedback.
- Prevent duplicate branch/MR pipelines with top-level `workflow: rules`.
- Store secrets as masked/protected CI variables; never inline in YAML.
- Use `retry:` narrowly for known infra flakes only.
- Give artifacts `expire_in`; give caches real keys.
- Mirror CI locally before push when practical, then watch the pipeline to terminal state.
