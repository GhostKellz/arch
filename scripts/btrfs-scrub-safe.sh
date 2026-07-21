#!/usr/bin/bash
# Bound Btrfs verification so maintenance cannot monopolize an interactive host.

set -euo pipefail

readonly LOCK_FILE=/run/btrfs-scrub-safe.lock
readonly RATE_LIMIT=64M
readonly MAX_LOAD=4
readonly MAX_IO_FULL_AVG10=5
readonly MIN_UPTIME_SECONDS=1800
readonly FILESYSTEMS=(/ /data)
CHECK_ONLY=false

if [[ ${1:-} == --check ]]; then
    CHECK_ONLY=true
elif (( $# != 0 )); then
    echo "Usage: ${0##*/} [--check]" >&2
    exit 2
fi

if (( EUID != 0 )); then
    echo "btrfs-scrub-safe.sh must run as root" >&2
    exit 1
fi

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    echo "Another bounded Btrfs scrub is already active; skipping"
    exit 0
fi

active_filesystem=
cancel_active_scrub() {
    if [[ -n "$active_filesystem" ]]; then
        btrfs scrub cancel "$active_filesystem" >/dev/null 2>&1 || true
    fi
}
trap cancel_active_scrub INT TERM

host_is_safe() {
    local io_full_avg10 load_average uptime_seconds

    read -r uptime_seconds _ </proc/uptime
    if (( ${uptime_seconds%.*} < MIN_UPTIME_SECONDS )); then
        echo "Host booted less than 30 minutes ago; skipping scrub"
        return 1
    fi

    read -r load_average _ </proc/loadavg
    if awk -v current_load="$load_average" -v maximum="$MAX_LOAD" 'BEGIN { exit !(current_load > maximum) }'; then
        echo "Load average is ${load_average}, above ${MAX_LOAD}; skipping scrub"
        return 1
    fi

    io_full_avg10=$(awk '/^full / { for (i = 1; i <= NF; i++) if ($i ~ /^avg10=/) { sub(/^avg10=/, "", $i); print $i } }' /proc/pressure/io)
    if [[ -n "$io_full_avg10" ]] && awk -v pressure="$io_full_avg10" -v maximum="$MAX_IO_FULL_AVG10" 'BEGIN { exit !(pressure > maximum) }'; then
        echo "Full I/O PSI avg10 is ${io_full_avg10}%, above ${MAX_IO_FULL_AVG10}%; skipping scrub"
        return 1
    fi
}

for filesystem in "${FILESYSTEMS[@]}"; do
    if [[ $(findmnt -n -o FSTYPE --target "$filesystem") != btrfs ]]; then
        echo "$filesystem is not a mounted Btrfs filesystem; refusing to continue" >&2
        exit 1
    fi
done

if [[ $CHECK_ONLY == true ]]; then
    if host_is_safe; then
        echo "Preflight passed; --check guarantees no scrub was started"
    else
        echo "Preflight safely rejected the current host state; --check guarantees no scrub was started"
    fi
    exit 0
fi

echo "Bounded sequential Btrfs verification started: $(date --iso-8601=seconds)"
for filesystem in "${FILESYSTEMS[@]}"; do
    if ! host_is_safe; then
        echo "Host is busy before $filesystem; ending this maintenance run"
        exit 0
    fi
    echo "Verifying $filesystem read-only at no more than $RATE_LIMIT"
    active_filesystem=$filesystem
    btrfs scrub start -B -r --limit "$RATE_LIMIT" "$filesystem"
    active_filesystem=
done
echo "Bounded sequential Btrfs verification completed: $(date --iso-8601=seconds)"
