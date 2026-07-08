#!/usr/bin/env bash
# tui_snapshot.sh — a golden-screen regression harness for a whole TUI.
#
# The idea: don't just debug one screen once — capture EVERY screen worth
# guarding into committed "golden" text/ANSI files, then on every change
# re-capture and diff against the goldens. Any drift (a border artifact, a
# colour that stopped resetting, a misaligned column, a dropped row) shows up
# as a reviewable text diff instead of a bug you find weeks later by eye.
#
# This is the compounding asset: once the corpus exists, every future edit gets
# a fast, deterministic "does the UI still look right?" check for free.
#
# It drives states through the same scenario hooks the skill preaches — an env
# var / flag / keystrokes that boot the app straight into the screen you want.
#
# ---------------------------------------------------------------------------
# Manifest format (default: ./.tui-snapshots/scenarios.txt)
#   One scenario per line, fields separated by '|', surrounding spaces trimmed.
#   Lines starting with '#' and blank lines are ignored.
#
#     name | cmd | opt=value | opt=value | ...
#
#   Required fields:
#     name   short id, used as the golden filename (no spaces/slashes).
#     cmd    command that launches the app (may include args).
#   Optional opts (each its own '|'-delimited field, value may contain spaces):
#     env=A=1 B=2     env vars prepended to cmd (space-separated, one field).
#     size=COLSxROWS  terminal size (default 120x40).
#     wait=TEXT       wait until TEXT appears before capturing.
#     keys=K K K      after boot, send these tmux keys, then capture the result.
#     settle=N        seconds to wait after boot/keys before capturing (0.4).
#     mask=ERE        scrub a volatile region before diffing: every match of this
#                     extended-regex is replaced with a fixed marker in BOTH the
#                     golden and the fresh capture. Repeatable. Use it for parts
#                     that legitimately change every frame — a spinner cell, an
#                     elapsed counter, a clock — so the snapshot guards the stable
#                     layout instead of drifting on animation. See "Determinism"
#                     in SKILL.md: prefer a frozen-clock demo hook in the app; mask
#                     only when you can't add one. Mask sparingly — a masked region
#                     is a blind spot the snapshot no longer checks.
#
#   Example:
#     approval      | myapp tui | env=APP_SCENARIO=approval | size=120x40 | wait=approve
#     list-scrolled | myapp tui | env=APP_SCENARIO=list     | wait=item 01 | keys=Down Down Down
#     thinking      | myapp tui | env=APP_SCENARIO=thinking | wait=working | mask=[|/\\-] working | mask=[0-9]+\.[0-9]s
#
# ---------------------------------------------------------------------------
# Usage:
#   tui_snapshot.sh                 # check mode: capture all, diff vs goldens
#   tui_snapshot.sh --update        # (re)write goldens from current render
#   tui_snapshot.sh --only NAME     # just one scenario (repeatable)
#   tui_snapshot.sh --manifest FILE --dir DIR
#
# Options:
#   --manifest FILE  Scenario manifest (default ./.tui-snapshots/scenarios.txt).
#   --dir DIR        Corpus dir (default ./.tui-snapshots). Goldens live in
#                    DIR/golden/, fresh captures in DIR/current/.
#   --update         Write/refresh goldens instead of diffing. Review the git
#                    diff before committing — you are blessing the new look.
#   --only NAME      Restrict to scenario(s) with this name (may repeat).
#   --png            Also render a golden PNG per scenario via `freeze`.
#
# Exit status: 0 if all scenarios match their goldens (or on --update success),
# 1 if any scenario drifted or a golden is missing, 2 on usage/setup error.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPTURE="$HERE/tui_capture.sh"
DRIVE="$HERE/tui_drive.sh"

MANIFEST="./.tui-snapshots/scenarios.txt"
DIR="./.tui-snapshots"
UPDATE=0
PNG=0
ONLY=()

while [ $# -gt 0 ]; do
  case "$1" in
    --manifest) MANIFEST="$2"; shift 2;;
    --dir) DIR="$2"; shift 2;;
    --update) UPDATE=1; shift;;
    --only) ONLY+=("$2"); shift 2;;
    --png) PNG=1; shift;;
    -h|--help) sed -n '2,60p' "${BASH_SOURCE[0]}"; exit 0;;
    *) echo "tui_snapshot: unknown arg: $1" >&2; exit 2;;
  esac
done

[ -f "$MANIFEST" ] || { echo "tui_snapshot: manifest not found: $MANIFEST" >&2; exit 2; }
command -v tmux >/dev/null || { echo "tui_snapshot: tmux not found" >&2; exit 2; }
[ -x "$CAPTURE" ] || { echo "tui_snapshot: missing $CAPTURE" >&2; exit 2; }
[ -x "$DRIVE" ]   || { echo "tui_snapshot: missing $DRIVE" >&2; exit 2; }

GOLDEN="$DIR/golden"
CURRENT="$DIR/current"
mkdir -p "$GOLDEN" "$CURRENT"

# sed delimiter: a control char that can't appear in a screen capture or a
# hand-written mask regex, so masks may contain '/', '|', etc. without escaping.
SEP=$'\001'
MASKS=""   # per-scenario, set in the loop; consumed by apply_masks.

trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; s="${s%"${s##*[![:space:]]}"}"; printf '%s' "$s"; }

want_scenario() {
  [ "${#ONLY[@]}" -eq 0 ] && return 0
  local n="$1" o
  for o in "${ONLY[@]}"; do [ "$o" = "$n" ] && return 0; done
  return 1
}

pass=0; fail=0; wrote=0; total=0

# Replace each newline-separated ERE in $MASKS (module-level) with a fixed
# marker in the given .txt capture, so animated/volatile regions don't spuriously
# drift. Applied identically to goldens and fresh captures, so a plain diff holds.
apply_masks() {
  local file="$1" re
  [ -n "$MASKS" ] || return 0
  [ -f "$file" ] || return 0
  while IFS= read -r re; do
    [ -n "$re" ] || continue
    sed -E "s${SEP}${re}${SEP}«masked»${SEP}g" "$file" > "$file.__m" 2>/dev/null && mv "$file.__m" "$file"
  done <<< "$MASKS"
}

# Capture one scenario's final screen into $1.txt / $1.ansi (+ optional .png).
capture_one() {
  local name="$1" cmd="$2" env="$3" size="$4" wait="$5" keys="$6" settle="$7" outprefix="$8"
  local session="snap-${name//[^a-zA-Z0-9_-]/_}"

  # Boot the app and wait for readiness, leaving the session alive.
  local -a capargs=(--cmd "$cmd" --session "$session" --keep --out "$CURRENT/.__boot_$name")
  [ -n "$env" ]  && capargs+=(--env "$env")
  [ -n "$size" ] && capargs+=(--size "$size")
  [ -n "$wait" ] && capargs+=(--wait "$wait")
  [ -n "$settle" ] && capargs+=(--settle "$settle")
  "$CAPTURE" "${capargs[@]}" >/dev/null 2>&1 || true

  # Optionally drive keystrokes to reach the target state.
  if [ -n "$keys" ]; then
    "$DRIVE" --session "$session" --keys "$keys" --settle "${settle:-0.4}" \
      --out "$CURRENT/.__drive_$name" >/dev/null 2>&1 || true
  fi

  # Final capture: this is the snapshot.
  tmux capture-pane -t "$session" -p    > "${outprefix}.txt"  2>/dev/null || true
  tmux capture-pane -t "$session" -p -e > "${outprefix}.ansi" 2>/dev/null || true
  # Scrub volatile regions so animated screens diff on their stable layout.
  apply_masks "${outprefix}.txt"
  if [ "$PNG" -eq 1 ] && command -v freeze >/dev/null; then
    freeze "${outprefix}.ansi" -o "${outprefix}.png" --window >/dev/null 2>&1 || true
  fi

  tmux kill-session -t "$session" 2>/dev/null || true
  rm -f "$CURRENT/.__boot_$name".* "$CURRENT/.__drive_$name".* 2>/dev/null || true
}

while IFS= read -r line || [ -n "$line" ]; do
  case "$(trim "$line")" in ''|'#'*) continue;; esac

  IFS='|' read -r -a F <<< "$line"
  name="$(trim "${F[0]:-}")"
  cmd="$(trim "${F[1]:-}")"
  [ -n "$name" ] && [ -n "$cmd" ] || { echo "tui_snapshot: bad line (need name|cmd): $line" >&2; fail=$((fail+1)); continue; }
  want_scenario "$name" || continue

  env=""; size=""; wait=""; keys=""; settle=""; MASKS=""
  for ((i=2; i<${#F[@]}; i++)); do
    opt="$(trim "${F[$i]}")"; [ -n "$opt" ] || continue
    key="${opt%%=*}"; val="${opt#*=}"
    case "$key" in
      env) env="$val";; size) size="$val";; wait) wait="$val";;
      keys) keys="$val";; settle) settle="$val";;
      mask) MASKS="${MASKS:+$MASKS$'\n'}$val";;
      *) echo "tui_snapshot: unknown opt '$key' in: $line" >&2;;
    esac
  done

  total=$((total+1))

  if [ "$UPDATE" -eq 1 ]; then
    capture_one "$name" "$cmd" "$env" "$size" "$wait" "$keys" "$settle" "$GOLDEN/$name"
    if [ -s "$GOLDEN/$name.txt" ]; then
      echo "updated: $name"
      wrote=$((wrote+1))
    else
      echo "FAILED to capture: $name (blank screen — check cmd/wait)"
      fail=$((fail+1))
    fi
    continue
  fi

  # check mode
  capture_one "$name" "$cmd" "$env" "$size" "$wait" "$keys" "$settle" "$CURRENT/$name"
  if [ ! -s "$GOLDEN/$name.txt" ]; then
    echo "MISSING golden: $name  (run: tui_snapshot.sh --update --only $name)"
    fail=$((fail+1)); continue
  fi
  if diff -q "$GOLDEN/$name.txt" "$CURRENT/$name.txt" >/dev/null 2>&1; then
    echo "ok:   $name"
    pass=$((pass+1))
  else
    echo "DRIFT: $name  —  diff golden vs current:"
    diff "$GOLDEN/$name.txt" "$CURRENT/$name.txt" | sed 's/^/    /' || true
    echo "    (golden: $GOLDEN/$name.txt   current: $CURRENT/$name.txt)"
    fail=$((fail+1))
  fi
done < "$MANIFEST"

echo "----"
if [ "$UPDATE" -eq 1 ]; then
  echo "snapshot: wrote $wrote golden(s); $fail failed of $total"
  echo "review the diff before committing — you are blessing this as the reference look."
else
  echo "snapshot: $pass ok, $fail drifted/missing of $total"
fi
[ "$fail" -eq 0 ] || exit 1
exit 0
