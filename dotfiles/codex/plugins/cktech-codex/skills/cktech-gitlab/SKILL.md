---
name: cktech-gitlab
description: Work with CKTech self-hosted GitLab through glab. Use for MRs, issues, releases, pipelines, CI traces, REST/GraphQL via glab api, watching CI after pushes, or driving an MR to green. Defaults to git.cktechx.com and secret-store token discipline.
---

# CKTech GitLab

- Set `GITLAB_HOST=git.cktechx.com`; do not accidentally target gitlab.com.
- Fetch `GITLAB_TOKEN` from the secret store at runtime.
- Use `glab <cmd> -R group/project` for explicit repo targeting.
- For MRs: inspect diff, check CI, use `--description-file` for generated bodies.
- For failures: classify real/flaky/infra/known-broken-target before acting.
- Retry only flaky/infra jobs, at most twice. Real failures require fixes.
- Additive commits only unless the user explicitly asks for history rewrite.
