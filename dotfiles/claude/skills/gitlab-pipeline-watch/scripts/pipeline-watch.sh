#!/usr/bin/env bash
# pipeline-watch.sh — poll a GitLab pipeline to a terminal state, read-only.
# House-authored, inspired by gitlab-org/ai/skills (MIT). Uses only glab GETs.
#
# Exit: 0 success | 1 failed/canceled | 2 timeout | 3 usage/lookup error.
set -Eeuo pipefail
trap 'echo "pipeline-watch: error on line $LINENO" >&2' ERR

INTERVAL=15
TIMEOUT=1800
MR_IID=""
REPO_FLAG=()

usage() {
  cat >&2 <<'EOF'
usage: pipeline-watch.sh [--mr <iid>] [-R group/project]
                         [--interval <sec>] [--timeout <sec>]
Watches the current branch's pipeline (or an MR's) until it finishes.
EOF
  exit 3
}

while [ $# -gt 0 ]; do
  case "$1" in
    --mr)       MR_IID="${2:-}"; shift 2 ;;
    -R|--repo)  REPO_FLAG=(-R "${2:-}"); shift 2 ;;
    --interval) INTERVAL="${2:-}"; shift 2 ;;
    --timeout)  TIMEOUT="${2:-}"; shift 2 ;;
    -h|--help)  usage ;;
    *) echo "pipeline-watch: unknown arg '$1'" >&2; usage ;;
  esac
done

# Numeric guards — refuse anything that isn't a plain positive integer.
for v in INTERVAL TIMEOUT ${MR_IID:+MR_IID}; do
  case "${!v}" in
    ''|*[!0-9]*) echo "pipeline-watch: '$v' must be a positive integer" >&2; exit 3 ;;
  esac
done

command -v glab >/dev/null 2>&1 || { echo "pipeline-watch: glab not found" >&2; exit 3; }

# Resolve the project path (URL-encoded) for glab api calls.
project="$(glab repo view "${REPO_FLAG[@]}" -F json 2>/dev/null \
            | jq -r '.path_with_namespace' 2>/dev/null || true)"
[ -n "$project" ] || { echo "pipeline-watch: cannot resolve project (run inside a repo or pass -R)" >&2; exit 3; }
enc_project="${project//\//%2F}"

# Resolve the pipeline id: MR head pipeline, or current branch HEAD.
if [ -n "$MR_IID" ]; then
  pipeline_id="$(glab api "projects/${enc_project}/merge_requests/${MR_IID}/pipelines" \
                  | jq -r '.[0].id // empty')"
else
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  [ -n "$branch" ] || { echo "pipeline-watch: not in a git branch; pass --mr" >&2; exit 3; }
  enc_branch="$(printf '%s' "$branch" | jq -sRr @uri)"
  pipeline_id="$(glab api "projects/${enc_project}/pipelines?ref=${enc_branch}&per_page=1" \
                  | jq -r '.[0].id // empty')"
fi
[ -n "$pipeline_id" ] || { echo "pipeline-watch: no pipeline found yet" >&2; exit 3; }

web_url="$(glab api "projects/${enc_project}/pipelines/${pipeline_id}" | jq -r '.web_url // empty')"
echo "watching pipeline ${pipeline_id}: ${web_url}"

deadline=$(( $(date +%s) + TIMEOUT ))
while :; do
  status="$(glab api "projects/${enc_project}/pipelines/${pipeline_id}" | jq -r '.status')"
  jobs_json="$(glab api --paginate "projects/${enc_project}/pipelines/${pipeline_id}/jobs?per_page=100")"
  running="$(printf '%s' "$jobs_json" | jq '[.[] | select(.status=="running")] | length')"
  failed="$(printf '%s' "$jobs_json" | jq '[.[] | select(.status=="failed" and (.allow_failure|not))] | length')"
  printf '[%s] status=%s running=%s failed=%s\n' "$(date +%H:%M:%S)" "$status" "$running" "$failed"

  case "$status" in
    success)
      echo "pipeline ${pipeline_id}: SUCCESS"; exit 0 ;;
    failed|canceled)
      echo "pipeline ${pipeline_id}: ${status^^}"
      printf '%s' "$jobs_json" \
        | jq -r '.[] | select(.status=="failed" and (.allow_failure|not)) | "  failed job: \(.name) (id \(.id))"'
      exit 1 ;;
    skipped)
      echo "pipeline ${pipeline_id}: SKIPPED"; exit 1 ;;
  esac

  if [ "$(date +%s)" -ge "$deadline" ]; then
    echo "pipeline-watch: timeout after ${TIMEOUT}s (last status=${status})" >&2
    exit 2
  fi
  sleep "$INTERVAL"
done
