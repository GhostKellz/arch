#!/usr/bin/env bash
# Send test syslog messages to Heimdall and verify they reach Loki.
# Usage: ./test-syslog.sh [target_ip]
set -euo pipefail
TARGET="${1:-192.0.2.10}"
TAG="heimdall-selftest"
MSG="syslog->loki pipeline test $(date -u +%FT%TZ) id=$RANDOM"

echo "==> UDP/514"; logger -n "$TARGET" -P 514 -d -t "$TAG" "$MSG udp"
echo "==> TCP/514"; logger -n "$TARGET" -P 514 -T -t "$TAG" "$MSG tcp"
echo "Sent. Query Loki on Heimdall:"
echo "  curl -sG http://127.0.0.1:3100/loki/api/v1/query_range --data-urlencode 'query={job=\"syslog\"}' --data-urlencode 'limit=20' | jq ."
