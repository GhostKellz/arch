#!/usr/bin/bash
# Run one agent/build command inside the aggregate resource-controlled user slice.

set -euo pipefail

if (( $# == 0 )); then
    echo "Usage: agent-scope.sh COMMAND [ARG ...]" >&2
    exit 2
fi

exec systemd-run \
    --user \
    --scope \
    --collect \
    --quiet \
    --slice=agent-workload.slice \
    --unit="agent-workload-$PPID-$$" \
    -- "$@"

