#!/usr/bin/env bash
# Sync this repo's stack to the Heimdall server and (re)deploy the core stack.
# Run from the workstation: ./docker/scripts/deploy.sh
set -euo pipefail

HEIMDALL_HOST="${HEIMDALL_HOST:-youruser@192.0.2.10}"
DEST="${DEST:-/opt/heimdall}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/"

echo "==> rsync ${SRC} -> ${HEIMDALL_HOST}:${DEST}"
rsync -az --delete \
  --exclude '.git' \
  --exclude '.env' \
  --exclude 'secrets/' \
  "${SRC}" "${HEIMDALL_HOST}:${DEST}/"

echo "==> docker compose up -d (core stack)"
ssh "${HEIMDALL_HOST}" "cd ${DEST} && docker compose up -d"

echo "==> status"
ssh "${HEIMDALL_HOST}" "cd ${DEST} && docker compose ps"
