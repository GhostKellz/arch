---
name: tui-dev
description: >-
  Develop, test, and debug terminal UI (TUI) applications by giving the agent
  "eyes and hands" on the terminal — run the app headless in tmux, capture and
  SEE the rendered screen, drive keyboard/mouse input, and assert on state. Use
  this whenever building or fixing a TUI, terminal app, text-mode UI, dashboard,
  editor, or CLI with a full-screen interface — Ratatui/crossterm (Rust),
  Bubble Tea/tview (Go), Textual/urwid/curses/rich (Python), or blessed/ink
  (Node). Especially reach for it when a TUI feature is "mostly done but not
  quite right" — rendering artifacts, garbled borders, misalignment, layout or
  constraint panics on resize, colors wrong, dropped keystrokes, event-loop
  bugs, or on-screen state not matching app state. If the task involves a
  terminal interface you cannot literally see, this skill is how you close the
  loop instead of guessing.
allowed-tools: Bash(tmux:*), Bash(freeze:*), Bash(cargo:*), Bash(go:*), Bash(python3:*), Bash(pytest:*), Bash(stty:*), Bash(tput:*), Bash(sleep:*), Bash(kill:*), Bash(pgrep:*), Read, Write, Edit, Glob, Grep
author: Christopher Kelley <ckelley@ghostkellz.sh>
copyright: CK Technology LLC 2026
license: MIT
---

# TUI Development

Web UIs are easy for an agent to iterate on because tools like Playwright give it
eyes (screenshots) and hands (click/type). A terminal UI has neither by default:
the output is a live, raw-mode, alternate-screen buffer the agent can't see, and
input is keystrokes it can't send. So the agent writes plausible render code,
can't verify it, and stalls — the classic "60% there, can't close the last 25%."

This skill closes that loop. The core move: **treat tmux as a headless terminal
you can screenshot and drive.** Run the app in a detached tmux session, capture
the pane (which you *can* read), send keys to it, and assert on what came back.
Combined with in-memory render tests and disciplined logging, this turns TUI work
from guesswork into a real edit → run → observe → fix cycle.

## The one idea that unlocks everything: make states reproducible

The single biggest reason TUI iteration stalls is that the interesting states are
*hard to reach* — you'd have to launch the app, log in, navigate three menus, and
trigger an async event just to see the widget that's broken. You cannot debug
what you cannot reliably reproduce.

So before deep debugging, **give the app a deterministic scenario hook**: an env
var or flag that boots it straight into the state you care about. This is the
highest-leverage change you can make and it pays off on every subsequent loop.

Example (this pattern is already in the jarvis codebase and is worth copying):

```
JARVIS_TUI_DEMO=approval jarvis tui    # boot straight into the approval screen
JARVIS_TUI_MARK=globe    jarvis tui    # force a specific widget variant
```

If the target app has no such hook, **add one first**. A few lines that read an
env var and seed the app into a fixed state converts a flaky manual repro into a
one-command screenshot target — for you now and for tests later.

## Three layers — pick by symptom

Don't reach for the terminal when a unit test is faster, and don't write a unit
test when you need to actually see pixels. Match the layer to the symptom:

| Symptom | Layer | Why |
|---------|-------|-----|
| Layout/constraint panic, off-by-one rects, "state vs screen" mismatch, regressions you want in CI | **1. In-memory render test** | Deterministic, no terminal, fast, runs in CI. Renders the UI into a buffer you assert on directly. |
| Visual artifacts — garbled borders, misalignment, color bleed, Unicode/emoji width, "looks wrong" | **2. tmux capture (see it)** | Renders through a real terminal + real ANSI. Capture the pane and read it; the raw escapes reveal exactly what's on screen. |
| Dropped keys, wrong state transition, focus/scroll bugs, input latency, event-loop stalls | **3. tmux drive (hands)** | Send real keystrokes into a live session and watch state change frame to frame. |

Most real bugs use two layers: reproduce and *see* it with Layer 2/3, then lock
the fix in forever with a Layer 1 test.

### Layer 1 — In-memory render tests (deterministic, CI-friendly)

Every serious TUI framework can render into an in-memory buffer with no terminal
attached. This is where the bulk of layout/state bugs should be caught, because
the tests are fast, deterministic, and reviewable as text.

The exact API differs per framework — read the matching file in `references/`
before writing tests:

- **Ratatui / Rust** → `references/ratatui.md` (`TestBackend`, `Buffer`, insta snapshots)
- **Bubble Tea / Go** → `references/bubbletea.md` (`View()` string assertions, `teatest`)
- **Textual / Python** → `references/textual.md` (`run_test()`, `Pilot`, snapshot plugin)

The general shape: build the app/widget, render one frame into a buffer, assert
that specific text or styling appears at specific coordinates. For "looks right"
regressions, snapshot the whole buffer to a file and let future diffs catch drift.

### Layer 2 — See the screen with tmux

Use the bundled helper; it handles session setup, correct terminal env, startup
waiting, and cleanup so you don't reinvent it each time:

```bash
scripts/tui_capture.sh --cmd "jarvis tui" --env "JARVIS_TUI_DEMO=approval" \
  --size 120x40 --wait "approve" --out ./.scratch/tui/approval
```

This launches the app headless, waits until the text `approve` appears (or a
timeout), and writes:
- `approval.txt` — plain text of the screen (structure/alignment)
- `approval.ansi` — ANSI-colored capture (`capture-pane -e`; colors, styling)

**Read both files.** The `.txt` shows you layout and alignment at a glance; the
`.ansi` shows color/attribute problems. You can see garbled borders, a widget
one cell too wide, a truncated title, or a color that didn't reset — directly,
without a screen.

**A stale capture is not always a render bug.** If the screen looks a frame
behind or "frozen until a keypress," suspect *synchronized output* — an app that
brackets every frame in `\x1b[?2026h/l` (DEC 2026) can leave tmux showing the
previous frame until it flushes. Send a harmless no-op key to force a flush, or
fix it app-side; see `references/tmux.md` ("Stale captures").

**Optional pixel-accurate screenshot (`freeze`).** For true font/color fidelity
(or a PNG for a PR), pass `--png`. This renders the capture to an image you can
then `Read` and literally look at. `freeze` isn't installed by default here;
install once with `go install github.com/charmbracelet/freeze@latest`. If it's
missing, the text/ANSI captures above are usually enough — don't block on it.

### Layer 3 — Drive input with tmux

Reproduce input and event-loop bugs by sending real keys and re-capturing:

```bash
scripts/tui_drive.sh --session tuidbg \
  --keys "Down Down Enter" --settle 0.2 --out ./.scratch/tui/after
```

Capture before, send keys, capture after, and diff the two screens to see exactly
what changed (or didn't). Key names follow tmux `send-keys` conventions —
`Enter`, `Escape`, `Tab`, `BSpace`, `C-c` (Ctrl+C), `Up/Down/Left/Right`, etc.
See `references/tmux.md` for the full key table, timing guidance (why blind
`sleep` is fragil and how to wait-for-content instead), and manual commands when
the helpers don't fit.

## Logging: never let the app print to the screen it's drawing

A TUI owns the screen via raw mode + the alternate screen buffer. Anything written
to stdout/stderr while it runs corrupts the display and your capture. So route all
diagnostics to a **file**, and install a panic/crash hook that restores the
terminal and flushes the log before exiting — otherwise a panic leaves you with a
dead, garbled terminal and no error.

- Log to a file (e.g. `./.scratch/tui/debug.log`), never stdout/stderr, while the
  UI is live. Many apps (jarvis included) log to stderr by default, so always
  launch with `2>debug.log` and then `Read`/`Grep` that file for the real error.
- On panic: leave the alternate screen and disable raw mode *first*, then print.
  Framework specifics are in the `references/` files.

## When the terminal gets wedged

Testing raw-mode apps can leave your own shell in a broken state — no echo, mouse
escape codes spraying, a stuck session. Recover immediately:

```bash
stty sane; tput reset          # fix a broken shell
tmux kill-session -t tuidbg    # kill one debug session by name
```

Kill sessions by explicit name, and clean up every session you start. Don't
pattern-kill processes — you can take out unrelated work on a shared machine.

## The development loop

1. **Reproduce deterministically** — boot the exact state via a scenario hook
   (add one if missing). Guessing at state is where loops go to die.
2. **See it** — Layer 2 capture; read the `.txt` and `.ansi`. State the concrete
   defect ("right border is one column past the pane; title truncated at 'Sett').
3. **Locate the cause** — map the on-screen defect to the render/layout code.
   Layout math (constraints, rects, wrapping, Unicode width) is the usual culprit.
4. **Fix, then prove it** — re-capture to confirm visually, and add a Layer 1
   test that would have caught it so it can't regress.
5. **Clean up** — kill sessions; remove `./.scratch/tui/` artifacts you created.

Put all scratch captures under `./.scratch/tui/` (project-local, gitignored) —
never `/tmp`. Remove them when done and re-list the paths to confirm.

## Guard the whole UI: golden-screen snapshots

Fixing one screen is a point-in-time win; the next edit can silently break three
others. The compounding move is a **golden-screen corpus** — capture every screen
worth guarding once, commit those captures, and on every change re-capture and
diff. Drift (a border artifact, a colour that stopped resetting, a shifted
column, a dropped row) shows up as a reviewable text diff instead of a bug you
find weeks later by eye. This is how "Claude struggles on my TUI" becomes a fast,
deterministic loop: the goldens *are* the eyes, and they persist across sessions.

Use `scripts/tui_snapshot.sh`. The scenario manifest lives in the *target
project* (never in this skill), one scenario per line, `name | cmd | opts`, each
booting a screen via the same scenario hooks / keys from the sections above:

```
# .tui-snapshots/scenarios.txt  (lives in the app repo, committed with the goldens)
approval      | myapp tui | env=APP_SCENARIO=approval | size=120x40 | wait=approve
list-scrolled | myapp tui | env=APP_SCENARIO=list     | wait=item 01 | keys=Down Down Down
thinking      | myapp tui | env=APP_SCENARIO=thinking | wait=working | mask=[|/\-] working | mask=[0-9]+\.[0-9]s
```

```bash
scripts/tui_snapshot.sh --update      # seed/bless goldens (review the git diff!)
scripts/tui_snapshot.sh               # check: re-capture all, diff vs goldens, exit 1 on drift
scripts/tui_snapshot.sh --only approval
```

Workflow: seed goldens once (`--update`), commit `.tui-snapshots/golden/`, then
run the checker in the dev loop and in CI. When a change *intentionally* alters a
screen, re-run `--update` and review the diff — you're deliberately blessing the
new look, not rubber-stamping a regression. Every new screen or fixed bug earns a
scenario line, so the net only grows. The corpus depends on scenario hooks: if a
screen can't be booted deterministically, add the hook first (see the top of this
file) — that single investment pays off for every snapshot and every future loop.

### Determinism: a byte-diff can't guard a screen that changes every frame

Snapshots (and Layer 1 buffer tests) only work if the render is **deterministic**
— identical bytes every capture. Anything wall-clock- or randomness-driven breaks
that and the checker cries drift on a screen nobody touched. The usual culprits:

- **Animation on a monotonic clock** — a spinner, pulse, glow, or waveform whose
  frame is `clock.elapsed()`. Two captures milliseconds apart land on different
  frames (`✻` vs `✶`). *Verify before you trust:* capture the same screen twice
  and diff; if it differs, it animates.
- **Elapsed / timestamp readouts** — `66.2s`, a clock, an ETA, "3h ago".
- **RNG or ordering** — unseeded shuffles, hashmap iteration, PIDs, temp paths.

Two remedies, in order of preference:

1. **Freeze the clock in the app's scenario hook (best).** The same demo hook that
   boots a screen should also pin its clock/seed so *every* frame is identical —
   e.g. have the animation read a `demo_now` the hook sets, instead of the live
   clock. This is an app-side change (the skill only advises it); it makes the
   goldens exact and the animation testable at a chosen frame. If you don't own
   the app, hand this to whoever does.
2. **Mask the volatile region (fallback).** When you can't freeze the clock, add a
   `mask=ERE` opt to the scenario: each match is replaced with a fixed marker in
   *both* golden and fresh capture, so the diff holds on the stable layout around
   it. Mask *narrowly* — a masked region is a blind spot the snapshot stops
   checking, so scrub the one counter/glyph that moves, not the whole line.

## Building, not just fixing

When the task is to *build* or *finish* a Ratatui feature (a widget, an
animation, a view) rather than debug one, don't hand-roll what the ecosystem
already solves — reach for an existing crate or read a real app for the pattern.
`references/ratatui-ecosystem.md` is a curated map (animations/effects, text/
markdown, editors/input, widgets, layout, theming, and exemplar apps to read
end-to-end — including LLM-chat TUIs closest to jarvis). Consult it before
writing a widget or effect from scratch.

## Bundled scripts

- `scripts/tui_capture.sh` — boot a TUI headless in tmux and capture the screen
  as readable `.txt` + `.ansi` (Layer 2).
- `scripts/tui_drive.sh` — send keystrokes into a running session and diff
  before/after (Layer 3).
- `scripts/tui_snapshot.sh` — manifest-driven golden-screen corpus: capture every
  screen, diff on change, exit non-zero on drift (whole-UI regression net).

## Reference files

- `references/tmux.md` — session/capture/send-keys command reference, key table,
  timing and wait-for-content patterns, troubleshooting (colors, size, locale).
- `references/ratatui.md` — Rust: `TestBackend`/`Buffer` tests, insta snapshots,
  panic-hook + terminal-restore pattern, common Ratatui layout pitfalls.
- `references/ratatui-ecosystem.md` — Rust: curated crates and exemplar projects
  for views, animations, widgets, text — read when building/finishing a feature.
- `references/bubbletea.md` — Go: `View()` assertions, `teatest`, logging to file.
- `references/textual.md` — Python: `run_test()`/`Pilot`, snapshot testing, devtools.
