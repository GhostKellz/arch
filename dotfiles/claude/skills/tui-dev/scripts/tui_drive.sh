#!/usr/bin/env bash
# tui_drive.sh — send keystrokes into a running TUI session and capture the
# result, so you can reproduce input / event-loop bugs and see what changed.
#
# Requires a session already started with `tui_capture.sh --keep` (or any tmux
# session running a TUI). Captures BEFORE, sends keys, captures AFTER, and writes
# a diff so the state change (or lack of one) is obvious.
#
# Usage:
#   tui_drive.sh --keys "Down Down Enter" [options]
#
# Options:
#   --session NAME  tmux session to drive (default tuidbg).
#   --keys "..."   Space-separated tmux send-keys tokens. Literal text with
#                  spaces must be quoted as one token, e.g. --keys "'hello world' Enter".
#                  Special keys: Enter Escape Tab BSpace Space Up Down Left Right
#                  Home End PgUp PgDn C-c (Ctrl+C) M-x (Alt+x) F1..F12.
#   --settle N     Seconds to wait after each key group before capturing (default 0.2).
#   --out PREFIX   Output prefix (default ./.scratch/tui/drive). Writes
#                  PREFIX.before.txt, PREFIX.after.txt, PREFIX.diff.
#   --wait TEXT    Instead of a fixed settle, wait until TEXT appears after sending.
#   --wait-secs N  Max seconds for --wait (default 5).
set -euo pipefail

SESSION="tuidbg"; KEYS=""; SETTLE=0.2; OUT="./.scratch/tui/drive"
WAIT_TEXT=""; WAIT_SECS=5

while [ $# -gt 0 ]; do
  case "$1" in
    --session) SESSION="$2"; shift 2;;
    --keys) KEYS="$2"; shift 2;;
    --settle) SETTLE="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --wait) WAIT_TEXT="$2"; shift 2;;
    --wait-secs) WAIT_SECS="$2"; shift 2;;
    *) echo "tui_drive: unknown arg: $1" >&2; exit 2;;
  esac
done

[ -n "$KEYS" ] || { echo "tui_drive: --keys is required" >&2; exit 2; }

# Guard against "ghost keystrokes": if the TUI already exited, keys land in the
# shell and corrupt the next command. Refuse to send into a dead session.
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "tui_drive: session '$SESSION' not running — nothing to drive." >&2
  echo "  start one first: tui_capture.sh --cmd '...' --keep" >&2
  exit 2
fi

mkdir -p "$(dirname "$OUT")"
tmux capture-pane -t "$SESSION" -p > "${OUT}.before.txt"

# send-keys: word-split KEYS so 'Down Down Enter' sends three key events.
# shellcheck disable=SC2086
tmux send-keys -t "$SESSION" $KEYS

if [ -n "$WAIT_TEXT" ]; then
  deadline=$(( $(date +%s) + WAIT_SECS ))
  while [ "$(date +%s)" -lt "$deadline" ]; do
    if tmux capture-pane -t "$SESSION" -p 2>/dev/null | grep -qF "$WAIT_TEXT"; then break; fi
    sleep 0.1
  done
else
  sleep "$SETTLE"
fi

tmux capture-pane -t "$SESSION" -p > "${OUT}.after.txt"
diff "${OUT}.before.txt" "${OUT}.after.txt" > "${OUT}.diff" || true

echo "before: ${OUT}.before.txt"
echo "after:  ${OUT}.after.txt"
if [ -s "${OUT}.diff" ]; then
  echo "diff:   ${OUT}.diff (screen changed — read it)"
else
  echo "diff:   ${OUT}.diff (EMPTY — screen did NOT change; input may have been dropped)"
fi
