# tmux as a headless terminal — command reference

The bundled `scripts/tui_capture.sh` and `scripts/tui_drive.sh` cover the common
path. Use the raw commands here when you need something the helpers don't do
(custom layouts, multi-step interaction sequences, live inspection).

## Contents
- [Session lifecycle](#session-lifecycle)
- [Terminal environment](#terminal-environment)
- [Sizing](#sizing)
- [Capturing the screen](#capturing-the-screen)
- [Sending input](#sending-input)
- [Key name table](#key-name-table)
- [Timing: wait, don't blind-sleep](#timing-wait-dont-blind-sleep)
- [Split-pane variant](#split-pane-variant)
- [Stale captures: synchronized output (DEC 2026)](#stale-captures-synchronized-output-dec-2026)
- [Troubleshooting](#troubleshooting)

## Session lifecycle

```bash
# Detached session (preferred for agent use — no visible pane needed)
tmux new-session -d -s tuidbg -x 120 -y 40 'TERM=xterm-256color ./app 2>debug.log'

tmux has-session -t tuidbg            # exit 0 if alive, 1 if gone
tmux list-sessions
tmux kill-session -t tuidbg           # kill ONE session by name
```

Always kill sessions by explicit name and clean up what you start. Never
`pkill`/`pattern-kill` — you can take out unrelated processes on a shared box.

## Terminal environment

Set these on the launched command so color and Unicode render correctly;
otherwise you get missing colors or garbled box-drawing/emoji:

```
TERM=xterm-256color   COLORTERM=truecolor
LANG=en_US.UTF-8      LC_ALL=en_US.UTF-8
```

## Sizing

Terminal size changes layout, so test the sizes that matter. Pass `-x COLS -y ROWS`.

| Use case | Size |
|----------|------|
| Standard | 80x24 |
| Wide dashboard / tables | 120x40 |
| Full-screen | 160x50 |
| Narrow / stress | 40x20, and 3x3 / 1x1 / 0x0 to hunt resize panics |

Tiny and zero sizes are the classic constraint-panic triggers — worth a Layer-1
render test (see `ratatui.md`).

## Capturing the screen

```bash
tmux capture-pane -t tuidbg -p            # visible pane, plain text (layout)
tmux capture-pane -t tuidbg -p -e         # include ANSI escapes (color/attrs)
tmux capture-pane -t tuidbg -p -S -200    # + 200 lines of scrollback history
tmux capture-pane -t tuidbg -p -J         # join wrapped lines
```

| Flag | Meaning |
|------|---------|
| `-p` | print to stdout (not a tmux buffer) |
| `-e` | keep ANSI color/attribute escapes |
| `-S n` | start line; negative = scrollback |
| `-E n` | end line |
| `-J` | join wrapped lines |

Read the plain-text capture for alignment/layout; read the `-e` capture (via
`Read` or `cat -v` to make escapes visible) for color/reset bugs.

## Sending input

```bash
tmux send-keys -t tuidbg 'literal text'   # types the text
tmux send-keys -t tuidbg Enter            # a named key
tmux send-keys -t tuidbg Down Down Enter  # several keys in order
tmux send-keys -t tuidbg C-c              # Ctrl+C
```

## Key name table

| Key | tmux token |
|-----|-----------|
| Enter / Return | `Enter` |
| Escape | `Escape` |
| Tab / Shift-Tab | `Tab` / `BTab` |
| Backspace / Delete | `BSpace` / `DC` |
| Space | `Space` |
| Arrows | `Up` `Down` `Left` `Right` |
| Home / End | `Home` / `End` |
| Page Up / Down | `PgUp` / `PgDn` |
| Ctrl+X | `C-x` |
| Alt/Meta+X | `M-x` |
| Function keys | `F1`..`F12` |

## Timing: wait, don't blind-sleep

The #1 cause of "capture shows an empty screen" is capturing before the app has
drawn. Apps that do async work (network, model streaming) can take 15-30s to show
content. A fixed `sleep 2` is fragile — too short and you miss it, too long and
you waste time. Poll for a known string instead:

```bash
for i in $(seq 1 100); do
  tmux capture-pane -t tuidbg -p | grep -q "Ready" && break
  sleep 0.1
done
```

The helpers expose this as `--wait TEXT` / `--wait-secs N`. Prefer it over `sleep`.

## Split-pane variant

Instead of a fully detached session you can split your current window so the app
runs beside you and your main pane stays free for inspection:

```bash
tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}'  # who am I
tmux split-window -h -c "$PWD" './app'                                   # side pane
tmux list-panes
tmux capture-pane -t "$SESSION:$WINDOW.$PANE" -p -S -60
tmux kill-pane -t "$SESSION:$WINDOW.$PANE"
```

Useful when a human is watching live. For unattended agent loops the detached
session is cleaner (deterministic teardown, no dependence on the current window).

## Stale captures: synchronized output (DEC 2026)

A **stale capture is not always a render bug.** Some apps bracket every frame in
*synchronized-update* escapes — `\x1b[?2026h` … draw … `\x1b[?2026l` (DEC private
mode 2026) — so the terminal shows the whole frame atomically instead of tearing.
Under tmux this can mean a freshly-drawn frame sits **buffered until tmux's own
refresh cycle flushes it**, so `capture-pane` reads the *previous* frame. The
human-visible version of this: the screen looks frozen until you press a key
(the keypress triggers a flush) — streamed text, a prompt, or an animation that
"isn't showing" is actually drawn, just not flushed.

So when a capture looks a frame behind the true state:

- **Suspect synchronized output first**, not your render code — grep the source
  for `2026`, `BeginSynchronizedUpdate`, `SynchronizedUpdate`, or a `synced`
  wrapper around the draw call.
- **Force a flush before capturing:** send a harmless no-op key (`tmux send-keys
  -t S Space` then `BSpace`, or a bare `Enter` if safe) or nudge `--settle`, then
  re-capture. The drive-a-key path in `tui_snapshot.sh` does this incidentally.
- The real fix is app-side: draw straight to the terminal and let the framework's
  cell-diff handle tearing, rather than wrapping frames in 2026h/2026l. Once the
  bracketing is gone, a plain `capture-pane` reads true and the flush workaround
  is no longer load-bearing.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| App exits instantly | needs a TTY | run it inside tmux (it provides one) |
| Capture empty | captured too early | `--wait TEXT`, not blind sleep |
| Capture one frame behind / screen "frozen until a keypress" | app brackets frames in synchronized-update (`\x1b[?2026h/l`); tmux buffers until its refresh flushes | send a no-op key to flush, or fix app-side (see [Stale captures](#stale-captures-synchronized-output-dec-2026)) |
| No colors in capture | missing `-e` | add `-e` to `capture-pane` |
| Wrong wrapping/overflow | size not set | pass explicit `-x`/`-y` |
| Box-drawing / emoji garbled | locale | set `LANG`/`LC_ALL` to a UTF-8 locale |
| Keys do nothing | wrong session/pane target, or app not focused | check `has-session`; verify target id |
| Stray `q`/letters in your shell | **ghost keystrokes** — TUI already exited, keys hit the shell | check `has-session` before sending; the drive helper refuses dead sessions |
| Command in split pane "not found" | split panes inherit the tmux server's default shell/env, not your parent's | pass an absolute path, or set env in the launched command directly |
| Your own shell is wedged after testing | raw mode left on | `stty sane; tput reset` |
