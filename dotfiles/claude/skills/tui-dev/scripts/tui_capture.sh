#!/usr/bin/env bash
# tui_capture.sh — launch a TUI headless in tmux, wait for it to be ready,
# and capture the rendered screen as plain text + ANSI (and optionally a PNG).
#
# The point: give the agent something it can actually READ back — the .txt shows
# layout/alignment, the .ansi shows color/attribute problems. Read both.
#
# Usage:
#   tui_capture.sh --cmd "jarvis tui" [options]
#
# Options:
#   --cmd   CMD     Command to run (required).
#   --env   "A=1 B=2"  Space-separated env vars prepended to CMD.
#   --size  COLSxROWS  Terminal size (default 120x40).
#   --wait  TEXT    Wait until TEXT appears in the pane before capturing.
#   --wait-secs N   Max seconds to wait for --wait / startup (default 10).
#   --settle N      Extra seconds to wait after ready before capturing (default 0.3).
#   --session NAME  tmux session name (default tuidbg). Reused by tui_drive.sh.
#   --scrollback N  Also capture N lines of scrollback history (for streaming /
#                   scrolling views where the bug scrolled off-screen).
#   --out   PREFIX  Output path prefix (default ./.scratch/tui/capture).
#                   Writes PREFIX.txt and PREFIX.ansi (and PREFIX.png with --png).
#   --png           Also render a PNG via `freeze` (must be installed).
#   --keep          Leave the session running (for follow-up tui_drive.sh).
#   --log   FILE    Redirect the app's stderr to FILE (default PREFIX.log).
#
# Exit status: 0 on capture (even if --wait timed out — you still get the screen,
# which is often the bug). Non-zero only on bad usage or tmux failure.
set -euo pipefail

CMD=""; ENV_VARS=""; SIZE="120x40"; WAIT_TEXT=""; WAIT_SECS=10
SETTLE=0.3; SESSION="tuidbg"; OUT="./.scratch/tui/capture"; PNG=0; KEEP=0; LOG=""
SCROLLBACK=0

while [ $# -gt 0 ]; do
  case "$1" in
    --cmd) CMD="$2"; shift 2;;
    --env) ENV_VARS="$2"; shift 2;;
    --size) SIZE="$2"; shift 2;;
    --wait) WAIT_TEXT="$2"; shift 2;;
    --wait-secs) WAIT_SECS="$2"; shift 2;;
    --settle) SETTLE="$2"; shift 2;;
    --session) SESSION="$2"; shift 2;;
    --scrollback) SCROLLBACK="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --png) PNG=1; shift;;
    --keep) KEEP=1; shift;;
    --log) LOG="$2"; shift 2;;
    *) echo "tui_capture: unknown arg: $1" >&2; exit 2;;
  esac
done

[ -n "$CMD" ] || { echo "tui_capture: --cmd is required" >&2; exit 2; }
command -v tmux >/dev/null || { echo "tui_capture: tmux not found" >&2; exit 2; }

COLS="${SIZE%x*}"; ROWS="${SIZE#*x}"
mkdir -p "$(dirname "$OUT")"
[ -n "$LOG" ] || LOG="${OUT}.log"

# Standard terminal env for correct color + unicode rendering.
TENV="TERM=xterm-256color COLORTERM=truecolor LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8"
FULL="$TENV ${ENV_VARS:+$ENV_VARS }$CMD 2>'$LOG'"

# Fresh session at the requested size.
tmux kill-session -t "$SESSION" 2>/dev/null || true
tmux new-session -d -s "$SESSION" -x "$COLS" -y "$ROWS" "$FULL"

# Wait for readiness: either the target text, or any non-empty content.
deadline=$(( $(date +%s) + WAIT_SECS ))
while [ "$(date +%s)" -lt "$deadline" ]; do
  pane="$(tmux capture-pane -t "$SESSION" -p 2>/dev/null || true)"
  if [ -n "$WAIT_TEXT" ]; then
    if printf '%s' "$pane" | grep -qF "$WAIT_TEXT"; then break; fi
  else
    if printf '%s' "$pane" | grep -q '[^[:space:]]'; then break; fi
  fi
  sleep 0.1
done
sleep "$SETTLE"

# Capture: plain text (layout) and ANSI (color/attrs).
tmux capture-pane -t "$SESSION" -p    > "${OUT}.txt"
tmux capture-pane -t "$SESSION" -p -e > "${OUT}.ansi"

# Optional scrollback history — for streaming/scrolling views where the
# interesting output has already scrolled off the visible pane.
if [ "$SCROLLBACK" -gt 0 ] 2>/dev/null; then
  tmux capture-pane -t "$SESSION" -p -S "-$SCROLLBACK" > "${OUT}.scrollback.txt"
  echo "scrollback: ${OUT}.scrollback.txt (last ~$SCROLLBACK lines)"
fi

if [ "$PNG" -eq 1 ]; then
  if command -v freeze >/dev/null; then
    if freeze "${OUT}.ansi" -o "${OUT}.png" --window 2>/dev/null; then
      echo "png:  ${OUT}.png"
    else
      echo "tui_capture: freeze failed to render PNG (continuing)." >&2
    fi
  else
    echo "tui_capture: freeze not installed; skipping PNG." >&2
    echo "  install: go install github.com/charmbracelet/freeze@latest" >&2
  fi
fi

if [ "$KEEP" -eq 0 ]; then
  tmux kill-session -t "$SESSION" 2>/dev/null || true
else
  echo "session: $SESSION (left running; drive it or kill with: tmux kill-session -t $SESSION)"
fi

echo "text: ${OUT}.txt"
echo "ansi: ${OUT}.ansi"
[ -s "$LOG" ] && echo "log:  ${LOG} (non-empty — check it for errors)"
exit 0
