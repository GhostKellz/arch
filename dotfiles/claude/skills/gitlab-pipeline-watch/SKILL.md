---
name: gitlab-pipeline-watch
description: 'Watch a GitLab MR/branch pipeline to completion and report what passed, failed, or is still running — a read-only poll loop over `glab`, no mutation. Use after pushing to a branch or opening an MR when you need to WAIT for CI and react to the terminal state instead of guessing. House-authored, inspired by gitlab-org/ai/skills (MIT). Triggers: "watch the pipeline", "wait for CI", "poll the pipeline until it''s done", "did the pipeline pass".'
allowed-tools: Bash(glab:*), Bash(sleep:*), Read
---

# GitLab pipeline watch (read-only)

Poll a pipeline until it reaches a terminal state, then report. This is the
**attend, don't touch** companion to the `gitlab` skill: it only ever *reads*
(`glab ci`, `glab api` GETs) — it never retries jobs, edits the MR, or pushes.
For the write-capable loop see `gitlab-babysit-mr`.

## Run it
```bash
# current branch's pipeline, default cadence
scripts/pipeline-watch.sh

# a specific MR by IID, in a given project
scripts/pipeline-watch.sh --mr 42 -R group/project

# tune the poll interval / ceiling (seconds)
scripts/pipeline-watch.sh --interval 20 --timeout 1800
```
The script exits `0` if the pipeline **succeeded**, `1` if it **failed/canceled**,
`2` on timeout — so it composes into `&&` chains and CI-gated follow-ups.

## What it does
- Resolves the pipeline (branch HEAD or `--mr <iid>`), prints its web URL once.
- Loops on a fixed interval, printing a compact per-poll line (overall status +
  running/failed job counts) until the pipeline is `success`, `failed`,
  `canceled`, or `skipped` — or the `--timeout` ceiling trips.
- On a terminal **failure**, lists the failed jobs (name + id) so you can hand
  them to `glab ci trace <job-id>` or the `gitlab-babysit-mr` skill.

## Discipline
- **Read-only, always.** The script uses only `glab ci status`/`glab api` GETs.
  If you need to *act* on a failure (retry, fix, comment), that's a deliberate
  step in `gitlab-babysit-mr`, not here.
- Bounded by `--timeout` (default 30 min) and a sane `--interval` (default 15 s)
  so it can't hammer the instance or hang a session forever.
- Host + auth come from the `gitlab` skill's wiring (`GITLAB_HOST`,
  `GITLAB_TOKEN` from the keyring) — verify `glab auth status` first.

## See also
- `gitlab` — the glab wiring, MRs, `glab api` traps.
- `gitlab-babysit-mr` — the write-capable "fix the red pipeline" loop.
- `rules/ci.md` — GitLab CI authoring conventions (watch to completion).
