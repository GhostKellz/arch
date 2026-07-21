#!/usr/bin/bash
# Bounded weekly workstation maintenance. Package upgrades remain interactive.

set -euo pipefail

if [[ ${1:-} == --check ]]; then
    required_commands=(
        btrfs
        df
        free
        journalctl
        paccache
        swapon
        systemctl
        timeout
        zramctl
    )

    for command_name in "${required_commands[@]}"; do
        command -v "$command_name" >/dev/null || {
            echo "Missing required command: $command_name" >&2
            exit 1
        }
    done

    for pressure_file in /proc/pressure/memory /proc/pressure/io /proc/pressure/cpu; do
        [[ -r $pressure_file ]] || {
            echo "Missing readable pressure interface: $pressure_file" >&2
            exit 1
        }
    done

    echo "Weekly maintenance preflight passed; --check performed no maintenance"
    exit 0
elif (( $# != 0 )); then
    echo "Usage: ${0##*/} [--check]" >&2
    exit 2
fi

if (( EUID != 0 )); then
    echo "weeklyMain.sh must run as root" >&2
    exit 1
fi

run_bounded() {
    local description=$1
    local duration=$2
    shift 2

    echo "$description"
    if ! timeout --signal=TERM "$duration" "$@"; then
        echo "WARNING: $description failed or exceeded $duration" >&2
    fi
}

echo "Weekly maintenance started: $(date --iso-8601=seconds)"

echo "Filesystem capacity"
df -h / /data

echo "Memory and swap"
free -h
zramctl
swapon --show

echo "Pressure stall information"
cat /proc/pressure/memory
cat /proc/pressure/io
cat /proc/pressure/cpu

echo "OOM services"
systemctl is-active systemd-oomd.service || true
systemctl is-active earlyoom.service || true

run_bounded "Btrfs allocation for /" 30s btrfs filesystem usage /
run_bounded "Btrfs allocation for /data" 30s btrfs filesystem usage /data
run_bounded "Btrfs device error counters for /" 30s btrfs device stats /
run_bounded "Btrfs device error counters for /data" 30s btrfs device stats /data
run_bounded "Latest scrub status for /" 30s btrfs scrub status /
run_bounded "Latest scrub status for /data" 30s btrfs scrub status /data
run_bounded "Snapper cleanup timer status" 30s systemctl --no-pager --full status snapper-cleanup.timer

run_bounded "Pacman cache cleanup: retaining two package versions" 10m paccache -rk2

echo "Journal usage"
journalctl --disk-usage

echo "Failed system units"
systemctl --failed --no-pager || true

echo "Weekly maintenance completed: $(date --iso-8601=seconds)"
