# Textual / urwid / curses (Python)

Textual (from Textualize) is the modern, richly-testable Python TUI framework and
has the best in-memory test story of the three layers. curses/urwid apps fall back
to the tmux layer for anything visual.

## Layer 1: run_test() + Pilot (async, headless)

Textual's `App.run_test()` runs the app headless in an async context and hands you
a `Pilot` to simulate input. You can query the DOM, assert on widget content, and
even assert on rendered geometry — no terminal required. This is the richest
Layer-1 API of any TUI framework; use it heavily.

```python
import pytest
from myapp import MyApp

@pytest.mark.asyncio
async def test_sidebar_shows_settings():
    app = MyApp()
    async with app.run_test(size=(120, 40)) as pilot:
        await pilot.press("tab")          # simulate a keypress
        await pilot.pause()               # let the message pump settle

        sidebar = app.query_one("#sidebar")
        assert "Settings" in sidebar.render_str() if hasattr(sidebar, "render_str") \
            else "Settings" in str(sidebar.render())

        # Geometry assertions catch layout bugs:
        assert app.query_one("#sidebar").size.width > 0
```

`pilot.press(...)`, `pilot.click(selector)`, and `pilot.pause()` drive the app;
`app.query_one`/`query` inspect the widget tree. Prefer `pilot.pause()` (waits for
the message pump) over `asyncio.sleep` to avoid flaky timing.

## Snapshot testing with pytest-textual-snapshot

The `pytest-textual-snapshot` plugin renders the app to an SVG and compares it to a
committed snapshot — a true visual regression test for "looks-right".

```python
def test_app_snapshot(snap_compare):
    assert snap_compare("path/to/app.py", press=["tab", "down"], terminal_size=(120, 40))
```

First run creates the snapshot; later runs fail on visual drift and produce an
HTML report showing the before/after images. Run with `--snapshot-update` to
accept intended changes. This is the closest Python equivalent to Playwright's
screenshot assertions.

## Layer 2/3: run it in tmux

For curses/urwid (no headless harness) or to see the *real* terminal rendering,
use the bundled helpers:

```bash
scripts/tui_capture.sh --cmd "python3 -m myapp" --size 120x40 --wait "Ready" \
  --out ./.scratch/tui/main --keep
scripts/tui_drive.sh --keys "Down Down Enter" --out ./.scratch/tui/after
```

Add a scenario env var read at startup to boot into the exact state.

## Textual devtools

Textual has a built-in console for live debugging: run `textual console` in one
terminal and `textual run --dev myapp.py` in another to stream logs, print output,
and events **without corrupting the UI** (they go to the console, not the app
screen). Use `self.log(...)` / `print(...)` inside the app — devtools captures it.
This is Textual-specific and very effective; reach for it before tmux when the app
is Textual.

## Logging without corrupting the screen (curses/urwid)

For non-Textual apps, never print to stdout/stderr while the UI is live — route
`logging` to a file handler (`logging.FileHandler("./.scratch/tui/debug.log")`).
Wrap the main loop so `curses.endwin()` runs on exception, or a crash leaves the
terminal in raw mode (recover with `stty sane; tput reset`).

## Common pitfalls
- **Blocking the event loop** — long sync work in an event handler freezes input.
  Use `@work` / `run_worker` (Textual) or a thread; keep handlers snappy.
- **CSS layout surprises** (Textual) — width/height rules, `fr` units, and
  `overflow` behave like CSS; assert on `.size`/`.region` in `run_test` to pin them.
- **Wide-character width** — emoji/CJK are 2 cells; rich/Textual handle it, but
  manual curses `addstr` math must account for it or you get misalignment.
