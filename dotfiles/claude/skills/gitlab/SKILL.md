---
name: gitlab
description: Drive the self-hosted GitLab instance (gitlab.example.com) from the CLI with glab — MRs, pipelines/CI, issues, releases, and raw REST/GraphQL via glab api. Use when creating/reviewing a merge request, checking or debugging a pipeline, working issues, cutting a release, or scripting against the GitLab API on this instance. Knows the self-hosted host/token wiring and the glab-api pagination + message-escaping traps. Triggers: "open an MR", "check the pipeline", "glab", "gitlab api", GitLab issues/releases on gitlab.example.com.
---

# GitLab via glab (self-hosted)

The house GitLab is **self-hosted at `gitlab.example.com`** (EE, moving toward
Premium). `glab` is the CLI; it defaults to gitlab.com, so the host must be set
explicitly or every command hits the wrong instance.

## Wiring — point glab at the self-hosted instance
```bash
glab auth login --hostname gitlab.example.com          # interactive, stores token
# or non-interactively / in scripts:
export GITLAB_HOST=gitlab.example.com
export GITLAB_TOKEN="$(secret-tool lookup service gitlab account ck-arch)"  # see the secrets skill
glab auth status                                      # verify the right host + user
```
Per-repo override for a one-off: `glab <cmd> -R group/project`. The token is a
PAT — fetch it at runtime from the keyring, never inline it (see `secrets`).

## Merge requests
```bash
glab mr create --fill --target-branch main            # title/body from commits
glab mr list --assignee=@me
glab mr view 42 --comments
glab mr diff 42
glab mr approve 42 && glab mr merge 42 --squash --remove-source-branch
```
- `--fill` reuses commit messages; for a hand-written body use `--description-file`
  (see escaping below), not a giant inline `--description`.
- Check CI before merging: `glab ci status` on the MR's branch.

## Pipelines / CI
```bash
glab ci status                       # current branch's pipeline
glab ci view                         # interactive job tree (the DAG)
glab ci list                         # recent pipelines
glab ci trace <job-id>               # stream a job's log
glab ci retry <job-id>  /  glab ci cancel
glab ci lint                         # validate .gitlab-ci.yml BEFORE pushing
```
`glab ci lint` locally is the cheap check — run it before a push that touches
`.gitlab-ci.yml`. Pipeline *authoring* conventions live in `rules/ci.md`
(GitLab CI section: `rules:` not `only:`, `needs:` DAG, masked+protected vars).

## Issues & releases
```bash
glab issue create --title "…" --description-file ./body.md
glab issue list --label bug --assignee=@me
glab release create v1.2.0 --notes-file ./notes.md ./dist/*
```

## glab api — the two traps
`glab api` speaks the REST (and GraphQL) API directly. Two things bite:

1. **Pagination:** `--paginate` follows Link headers, but query params go **in
   the path**, not as flags:
   ```bash
   glab api --paginate "projects/:id/issues?state=opened&per_page=100"
   ```
   Without `per_page` you get 20/page; without `--paginate` you get only page 1.
   `:id` is URL-encoded `group/project` (`group%2Fproject`) or the numeric ID.

2. **Message escaping:** never cram a multi-line/special-char body onto the
   command line — write it to a file and reference it (`--description-file`,
   `--notes-file`, or a heredoc into a temp file **under `./.scratch/`, never
   `/tmp`**), then delete it. For `glab api` fields use `-f key=@file` / `-F`.

GraphQL passthrough (GLQL): `glab api graphql -f query='{ … }'` — use it for
queries the REST endpoints can't express in one call.

## Discipline
- Verify the host on every session (`glab auth status`) — a command silently
  run against gitlab.com instead of `gitlab.example.com` is the classic mistake.
- Read-heavy by default: list/view/diff freely; create/merge/close only when
  asked, and confirm the target project + MR/issue number first.
- After pushing CI changes, WATCH to completion (`glab ci status`/`view`) — one
  correct commit, not three hopeful ones (mirrors `rules/ci.md`).
- Secrets (PATs, CI variables) follow the `secrets` skill: keyring at runtime,
  masked+protected CI/CD variables, never in `.gitlab-ci.yml` or chat.

## See also
- `rules/ci.md` — GitLab CI pipeline authoring conventions (loads on `.gitlab-ci.yml`).
- `secrets` — PAT storage/rotation + masked/protected CI/CD variables.
- `gitlab-pipeline-watch` / `gitlab-babysit-mr` — script-driven pipeline/MR attendance.
