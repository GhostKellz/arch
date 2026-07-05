---
name: gitlab-babysit-mr
description: Drive a GitLab merge request to green — watch its pipeline, classify each failure (real bug vs flaky vs infra vs known-broken-master), apply the MINIMAL fix, and report, looping under strict guardrails. Use when asked to "get this MR passing", "babysit the MR", "fix the red pipeline on my MR". Write-capable (commits/retries/comments), so it runs bounded and asks before anything destructive. House-authored, inspired by gitlab-org/ai/skills (MIT). Triggers: "babysit my MR", "make the MR green", "fix the failing pipeline on MR <n>".
allowed-tools: Bash(glab:*), Bash(git:*), Bash(jq:*), Read, Grep, Glob, Edit
---

# Babysit a merge request to green

The write-capable sibling of `gitlab-pipeline-watch`. Where that skill only
*watches*, this one **acts** on failures — but under a tight leash. Built on the
`gitlab` skill's glab wiring; inspired by `gitlab-org/ai/skills` (MIT), rewritten
lean and house-safe.

## The loop
1. **Watch** the MR pipeline to a terminal state (reuse `gitlab-pipeline-watch`
   or `glab ci status`). If it's green, report and stop.
2. **Classify** each failed job before touching anything:
   - **Real failure** — the job proves a genuine bug in *this* MR's diff
     (compile error, failed assertion on changed code, lint on changed lines).
   - **Flaky** — passes on retry, timing/ordering-sensitive, known-flaky label.
   - **Infra** — runner lost, image pull failure, timeout, 5xx from a service —
     not the code.
   - **Known-broken master** — the same job fails on the target branch too
     (check `master broken`/`flaky-test` issues, or the base pipeline).
3. **Act — minimally, by class:**
   - Real → read the trace, make the **smallest** code fix, commit with a clear
     message, push. One targeted fix, not a refactor.
   - Flaky/Infra → **retry the job** (not the whole pipeline), at most twice.
   - Known-broken master → do **not** fix here; note it on the MR and move on.
4. **Report** each round: what failed, the class, the action, the new status.

## Guardrails (non-negotiable)
- **Max 2 retries per job**, and **never** retry a job classified `real` —
  retrying a real failure just burns minutes and hides the bug.
- **Max 5 action rounds** per babysit run, then stop and hand back to the user
  with a summary — no infinite loops.
- **No `--force`/`--force-with-lease` push, no `commit --amend`, no history
  rewrite** on the MR branch. Additive commits only.
- **Never touch protected branches.** Scope the glab token / git credentials to
  the MR's own source branch; if a fix implies changing `main`/`master`, stop
  and ask.
- One MR at a time; confirm the project + MR IID before the first write.
- Trace reads are read-only; the moment you *commit/retry/comment* you're
  mutating — say so in the report.

## Failure-trace hygiene
```bash
glab ci status                        # terminal state of the MR's pipeline
glab api "projects/:id/pipelines/<pid>/jobs?per_page=100" | jq '...'  # per-job
glab ci trace <job-id>                # the log — read to classify, then act
glab ci retry <job-id>                # flaky/infra only, ≤2×
```
Strip ANSI/section noise when quoting a trace back; quote the *smallest* span
that proves the class.

## When to stop and ask
- A fix would touch a protected branch, CI config secrets, or more than the MR's
  own scope.
- Same job fails `real` after your minimal fix — the diagnosis was wrong; surface
  it rather than piling on commits.
- Round budget (5) exhausted, or a failure you can't confidently classify.

## See also
- `gitlab-pipeline-watch` — the read-only watch step this loop builds on.
- `gitlab` — glab wiring, MR commands, `glab api` traps.
- `secrets` — scope the PAT; never inline it. `rules/ci.md` — CI conventions.
