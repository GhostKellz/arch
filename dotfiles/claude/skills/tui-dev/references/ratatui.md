# Ratatui / crossterm (Rust)

APIs below match Ratatui 0.30 (what jarvis uses). Ratatui re-exports the
crossterm backend, so depend on `ratatui` alone to avoid a version split.

## Layer 1: render into a buffer with TestBackend

`TestBackend` is an in-memory backend — no real terminal. Render a frame into it,
then assert on the resulting `Buffer`. Deterministic, fast, CI-friendly. This is
where most layout/state bugs should be caught.

```rust
use ratatui::{Terminal, backend::TestBackend};

#[test]
fn sidebar_shows_settings() {
    let backend = TestBackend::new(30, 10);      // width, height in cells
    let mut terminal = Terminal::new(backend).unwrap();
    let app = App::new(/* seed into the exact state under test */);

    terminal.draw(|f| draw(f, &app)).unwrap();   // your real render fn

    // Assert on the rendered buffer. Several styles:
    terminal.backend().assert_buffer_lines([
        "┌ Settings ──────────────────┐",
        "│ Theme:  Jarvis             │",
        // ... one string per row (must match width exactly)
    ]);
}
```

Assertion options on `terminal.backend()` (a `&TestBackend`):

- `assert_buffer_lines([...])` — compare against expected lines; panics with a
  clear cell-by-cell diff on mismatch. Best for readable, targeted checks.
- `assert_buffer(&expected)` — compare against a full `Buffer` (use when you also
  need to assert *styles*, not just text).
- `terminal.backend().buffer()` — get the `&Buffer` to inspect specific cells,
  e.g. `buffer[(x, y)].symbol()` for text and `.style()`/`.fg` for color at a
  coordinate. Use this to assert "the word 'Settings' is at row 0, and its style
  is the accent color" without pinning the whole screen.

Build an expected buffer with styles via `Buffer::with_lines([...])` when needed.

### Test the panic sizes

Resize/constraint panics love tiny and zero-area rects. jarvis already guards
this (`renders_without_panic_on_tiny_terminals`) — copy the pattern:

```rust
#[test]
fn renders_without_panic_on_tiny_terminals() {
    for (w, h) in [(0, 0), (1, 1), (3, 3), (20, 5), (40, 10)] {
        let mut terminal = Terminal::new(TestBackend::new(w, h)).unwrap();
        let app = App::new(/* ... */);
        terminal.draw(|f| draw(f, &app)).unwrap();   // must not panic
    }
}
```

## Snapshot testing with insta

For "looks-right" regressions where hand-writing expected lines is tedious,
snapshot the whole buffer and let future diffs catch drift. Add `insta` as a
dev-dependency, then:

```rust
#[test]
fn main_screen_snapshot() {
    let mut terminal = Terminal::new(TestBackend::new(80, 24)).unwrap();
    terminal.draw(|f| draw(f, &App::demo())).unwrap();
    // Debug-format of the Buffer is a readable text grid.
    insta::assert_debug_snapshot!(terminal.backend().buffer());
}
```

`cargo insta review` accepts/rejects changes; snapshots live in `snapshots/` and
are committed, so a rendering regression shows up as a reviewable text diff.

## Layer 2/3: run it in tmux

Use the bundled helpers to see and drive the real app:

```bash
scripts/tui_capture.sh --cmd "cargo run --release" --size 120x40 \
  --wait "some text that means it's up" --out ./.scratch/tui/main --keep
scripts/tui_drive.sh --keys "Tab Down Enter" --out ./.scratch/tui/after
```

Prefer `--release` in tmux: debug builds start slowly and can trip the wait
timeout. If the app has a scenario/env hook, use `--env` to boot the exact state
(jarvis: `--env "JARVIS_TUI_DEMO=approval"`).

## Terminal restore + panic hook (so a crash doesn't leave a dead terminal)

Ratatui 0.30 ships `ratatui::init()`/`ratatui::restore()`. Install a panic hook
that restores before the default hook runs, so a panic prints its message on a
clean screen instead of a garbled alternate buffer:

```rust
let hook = std::panic::take_hook();
std::panic::set_hook(Box::new(move |info| {
    ratatui::restore();     // leave alt screen, disable raw mode
    hook(info);
}));
```

If you manage the terminal manually (as jarvis does with a `TerminalGuard` Drop
impl), the same rule applies: a `Drop` guard that calls `disable_raw_mode()` +
`LeaveAlternateScreen` guarantees restoration on early return. Keep it.

## Logging without corrupting the screen

The UI owns stdout via the alternate screen; writing logs there corrupts it.
Route tracing/log output to a file. jarvis logs to stderr by default, so when
capturing in tmux, redirect: the helpers already run the command with
`2>PREFIX.log`. `Read`/`Grep` that log for the real error after a crash.

## Common Ratatui layout pitfalls (what on-screen defects usually mean)

- **Widget one cell too wide / border clipped** — a `Constraint` sums to more
  than the parent area, or you forgot the border consumes 1 cell each side
  (inner area is 2 smaller in each dimension). Check `Layout::default().constraints([...])`
  and whether you rendered into `area` vs `block.inner(area)`.
- **Panic on resize** — indexing a `Rect` or slicing text by a width that can be
  0 at small sizes. Clamp/saturate; guard `width == 0 || height == 0`.
- **Misaligned/overflowing text** — Unicode width: emoji and CJK are 2 cells
  wide. Use `unicode-width` for truncation math, not `.len()`/`.chars().count()`.
- **Color that "bleeds" into later cells** — a style set without a reset, or a
  `Span` whose style leaks. Inspect the `-e` ANSI capture for a missing reset.
- **Flicker/tearing on multi-region repaint** — wrap the frame in synchronized
  output (DEC 2026); jarvis does this in its `synced()` helper.

## Building widgets, animations, views

Before writing a widget, effect, editor, or theme from scratch, check
`references/ratatui-ecosystem.md` — it maps the mature crates (tachyonfx for
effects, tui-textarea/edtui for editing, rat-widget for a full kit, opaline for
theming) and real apps to read for architecture. Copying a proven pattern is how
you close the last stretch instead of reinventing layout math.
