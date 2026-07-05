---
paths:
  - "**/.github/workflows/**"
  - "**/.gitlab-ci.yml"
  - "**/package.json"
  - "**/package-lock.json"
  - "**/go.mod"
  - "**/Cargo.toml"
  - "**/Dockerfile"
---

# CI, runners & dependencies — no legacy, ever

Hard rules. Violating these wastes the user's time and usage and is not acceptable.

## Runtimes and CI actions
- NEVER pin a deprecated runtime. No Node 20 in runners, images, or `setup-node`.
  Use the current LTS/stable the user runs (Node 24 as of now).
- ALWAYS use the latest MAJOR of GitHub Actions. Do not copy old majors from
  existing YAML. Verify the current tag first:
  `gh api repos/<owner>/<action>/releases/latest --jq .tag_name`.
  (e.g. `actions/checkout@v7`, `actions/setup-node@v6`, `actions/setup-go@v6`.)
- Older action majors run on deprecated Node runtimes and emit deprecation
  annotations — treat those annotations as failures to fix, not warnings to ignore.

## Dependencies
- Keep dependencies CURRENT and VERIFY them. Do not leave stale pins.
- NEVER use deprecated/legacy escape hatches to paper over a real problem:
  no `--legacy-peer-deps`, no `--force`, no pinning to an EOL version.
  If a dep conflict is real, resolve it at the root.

## Dependabot — do not forget it
When a repo has CI or tracked dependencies but no `.github/dependabot.yml`,
PROPOSE adding one (this gets skipped by default — don't let it).
- `version: 2`; one `updates` block per ecosystem actually present
  (`cargo`, `gomod`, `npm`, `docker`), each `interval: weekly` with a named `groups`.
- **ALWAYS include a `github-actions` ecosystem block** — it is what keeps
  workflows from silently drifting back onto deprecated action majors.
- Group `update-types: ["minor", "patch"]` only; MAJOR bumps are reviewed by hand.
- Multi-stack repos get a block per directory (e.g. `gomod` at `/backend`,
  `npm` at `/frontend`); secondary workspaces use a lower `open-pull-requests-limit`.
- The `repo-docs` skill's `github-meta.md` has the copy-paste template.

## GitLab CI (self-hosted at gitlab.example.com)
The house is migrating toward GitLab — apply the same "no legacy" discipline there.
- Use `rules:` with `if:`/`changes:`/`exists:` — NEVER the deprecated `only:`/`except:`.
- Build a DAG with `needs:` so jobs start as soon as their deps finish (not stage-gated); scope artifact pulls with `dependencies:`.
- DRY with `include:` (local/project/remote/template) + `extends:` and hidden `.job` templates; use YAML anchors sparingly.
- `workflow:` rules to kill duplicate pipelines (the MR-vs-branch double-run); `interruptible: true` so superseded pipelines auto-cancel.
- Secrets are **masked + protected** CI/CD variables (protected = protected branches/tags only), file-type for certs/kubeconfigs — never inline in `.gitlab-ci.yml` (see the `secrets` skill).
- Serialize deploys with `resource_group:`; track them with `environment:`.
- `cache:` needs a real `key:` (per-branch or files-based); `artifacts:` always get `expire_in`. Select runners with `tags:`.
- `retry:` only with a narrow `when:` (known infra-flake classes), never a blanket retry that masks a real failure.
- Watch the pipeline to completion after pushing (`glab ci status`/`glab ci view` — see the `gitlab` skill); one correct commit, not three hopeful ones.

## Lockfiles
- A lockfile fix means a FULL re-resolve, not a backfill.
  `npm install --package-lock-only` can report "up to date" and leave the lock
  inconsistent — that is the flukey non-fix that already burned three commits.
- Correct procedure: `rm package-lock.json && rm -rf node_modules && npm install`,
  then PROVE it with a clean `npm ci` (exactly what CI runs).

## Verify before pushing CI changes
- Mirror CI locally before committing: `npm ci` → `npm run check` → `npm run build`
  for frontend; `go vet ./...` → `go test ./...` for backend; `docker build .` if
  the Docker job is affected.
- After pushing, WATCH the run to completion (`gh run watch <id> --exit-status`).
  Do not declare CI fixed on assumption. One correct commit, not three hopeful ones.

## Self-hosted runner
- The self-hosted runner is a real VM (see the project's dev.env / infra notes).
  SSH creds/keys for it live there when a runner-side change is genuinely needed.
- A `Failed to restore: "/usr/bin/tar" ... exit code 2` from actions/cache is a
  corrupt cache entry: it is non-fatal (the job runs cache-less) but silence it by
  clearing the stale cache rather than ignoring the recurring annotation.
