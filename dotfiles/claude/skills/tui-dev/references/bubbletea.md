# Bubble Tea / tview (Go)

Bubble Tea is the Elm-architecture TUI framework (Model/Update/View) from Charm;
tview is the widget-oriented alternative. The three-layer approach is the same;
only the in-memory test API differs.

## Layer 1: assert on View() output

A Bubble Tea `Model.View()` returns the full screen as a `string`. That makes
unit testing trivial and terminal-free: drive the model with messages, then
assert on the rendered string. This is where most layout/state logic should be
verified.

```go
func TestSidebarShowsSettings(t *testing.T) {
    m := NewModel( /* seed exact state under test */ )

    // Apply the messages that produce the state you care about.
    m2, _ := m.Update(tea.KeyMsg{Type: tea.KeyTab})
    view := m2.View()

    if !strings.Contains(view, "Settings") {
        t.Fatalf("expected sidebar to contain Settings, got:\n%s", view)
    }
}
```

Because `View()` is a pure function of the model, you can assert on exact lines,
substring presence, or (for regression) snapshot the whole string to a golden
file and diff on change. Keep `Update` free of I/O (do side effects via `tea.Cmd`)
so the model stays testable — this is the single most important design rule.

## teatest for full-program tests

`github.com/charmbracelet/x/exp/teatest` runs a whole Bubble Tea program against a
simulated terminal of a fixed size, lets you send input, and captures final
output — the closest thing to an integration test.

```go
func TestApp(t *testing.T) {
    tm := teatest.NewTestModel(t, NewModel(), teatest.WithInitialTermSize(120, 40))

    tm.Send(tea.KeyMsg{Type: tea.KeyDown})
    tm.Send(tea.KeyMsg{Type: tea.KeyEnter})

    // Wait for expected content to appear before asserting (avoid races).
    teatest.WaitFor(t, tm.Output(), func(b []byte) bool {
        return bytes.Contains(b, []byte("Feature Active"))
    }, teatest.WithDuration(3*time.Second))

    tm.Send(tea.KeyMsg{Type: tea.KeyCtrlC})
    out, _ := io.ReadAll(tm.FinalOutput(t))
    teatest.RequireEqualOutput(t, out)  // golden-file compare (update with -update)
}
```

`RequireEqualOutput` stores/compares a golden file, so "looks-right" regressions
surface as reviewable diffs. Run with `-update` to accept intentional changes.

## Layer 2/3: run it in tmux

Same as any TUI — use the bundled helpers. Go apps start fast, so a short wait is
usually enough, but still prefer `--wait TEXT` over a blind sleep:

```bash
scripts/tui_capture.sh --cmd "go run ." --size 120x40 --wait "ready" \
  --out ./.scratch/tui/main --keep
scripts/tui_drive.sh --keys "Down Down Enter" --out ./.scratch/tui/after
```

Add a deterministic scenario hook (env var read in `main`/`initialModel`) so you
can boot straight into the state you're screenshotting.

## Logging without corrupting the screen

Bubble Tea owns stdout; never `fmt.Println` while the program runs. Use the
framework's own file logger:

```go
f, _ := tea.LogToFile("./.scratch/tui/debug.log", "debug")
defer f.Close()
// or: log.SetOutput(f)
```

Then `Read`/`Grep` that file for the real error after a crash. Bubble Tea restores
the terminal on normal exit; ensure your program returns from `Run()` rather than
`os.Exit`-ing mid-render, or the terminal is left in raw mode (recover with
`stty sane; tput reset`).

## Common pitfalls
- **Blocking work in `Update`** freezes the event loop → "unresponsive input".
  Move it into a `tea.Cmd` that runs off the update goroutine.
- **`lipgloss` width vs rune width** — styled strings with wide runes (emoji/CJK)
  can overflow; measure with `lipgloss.Width`, not `len`.
- **Alt-screen not entered/left** — use `tea.WithAltScreen()` and let normal exit
  restore it; abrupt exits leave a garbled terminal.
