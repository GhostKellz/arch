# Ratatui ecosystem — crates and exemplars to build from

When *building* (not just debugging) a Ratatui app, don't reinvent widgets or
animation from scratch — the ecosystem is deep. This is a curated map of the most
useful crates and real projects to copy patterns from, distilled from
[awesome-ratatui](https://github.com/ratatui/awesome-ratatui). It is not
exhaustive; for anything not here, search that list, crates.io reverse
dependencies (<https://crates.io/crates/ratatui/reverse_dependencies>), or ask.

**How to use this:** identify what you're building (a form? an animated splash? a
chat view?), pull the matching crate below, and read its docs/source for the
pattern. For architecture questions ("how do I structure a big app?"), read one
of the exemplar apps end to end — they're the best teachers.

## Official docs & tutorials (start here)
Before the third-party crates, the official site is the canonical reference for
concepts, recipes, and step-by-step tutorials — consult it for how the framework
*itself* wants you to do layout, state, events, and widgets:
- **<https://ratatui.rs>** — tutorials (hello-world → JSON editor → async apps),
  concepts (rendering, layout, event handling, the app pattern), and recipes
  (how-to snippets for widgets, styling, layout, testing).
- **<https://docs.rs/ratatui>** — API reference (the source of truth for the exact
  method signatures used in `ratatui.md`).
- **[ratatui/ratatui `examples/`](https://github.com/ratatui/ratatui/tree/main/examples)**
  — runnable official examples; the fastest way to see an idiom in real code.
- **[templates](https://github.com/ratatui/templates)** — official starter
  scaffolds (simple, component, async) — good skeletons to build a new app on.

## Contents
- [Animations & visual effects](#animations--visual-effects)
- [Text, markdown & syntax](#text-markdown--syntax)
- [Input, editors & prompts](#input-editors--prompts)
- [Widgets (lists, trees, tables, dialogs)](#widgets)
- [Layout, composition & overlays](#layout-composition--overlays)
- [Theming & color](#theming--color)
- [Dev & test tooling for widgets](#dev--test-tooling)
- [Exemplar apps to read for architecture](#exemplar-apps)

## Animations & visual effects
The 60→100% polish often lives here. Study these before hand-rolling animation.
- **[tachyonfx](https://github.com/junkdog/tachyonfx)** — shader-like effects
  (fades, dissolves, transitions) driven by elapsed time. The go-to for motion.
  Its author's app **[exabind](https://github.com/junkdog/exabind)** is a full
  animated TUI worth reading for how effects are sequenced.
- **[tui-rain](https://github.com/levilutz/tui-rain)** — matrix/rain effects.
- **[tui-shimmer](https://github.com/vinhnx/tui-shimmer)** — shimmer text effect.
- **[tui-skeleton](https://crates.io/crates/tui-skeleton)** — placeholder widgets
  that pulse/sweep/shimmer while content loads (loading states done right).
- **[throbber-widgets-tui](https://crates.io/crates/throbber-widgets-tui)** —
  spinners/throbbers.
- **[tui-big-text](https://crates.io/crates/tui-big-text)** — large banner text.
- **[ratatui-splash-screen](https://github.com/orhun/ratatui-splash-screen)** /
  **[tui-globe](https://github.com/d10n/tui-globe)** (braille 3D globe) — jarvis's
  own presence marks (orb/globe/radar) are the same braille-canvas idea.

Key principle these share: drive animation by **wall-clock elapsed time**, not
frame count, and redraw at a steady rate only while animating (jarvis does this).

## Text, markdown & syntax
- **[ansi-to-tui](https://crates.io/crates/ansi-to-tui)** — turn ANSI-coded text
  into `ratatui::text::Text`. Essential when piping colored output into a widget.
- **[tui-markdown](https://github.com/joshka/tui-markdown)** /
  **[ratatui-markdown](https://github.com/celestia-island/ratatui-markdown)** —
  render markdown (the latter adds mermaid, collapsible JSON/TOML trees).
- **[tui-syntax-highlight](https://github.com/aschey/tui-syntax-highlight)** and
  **[ratatui-code-editor](https://github.com/vipmax/ratatui-code-editor)**
  (tree-sitter powered) — code display/editing with highlighting.
- **[md-tui](https://github.com/henriklovhaug/md-tui)** — full markdown-renderer
  app to read for layout of rich text.

## Input, editors & prompts
- **[tui-textarea](https://crates.io/crates/tui-textarea)** — the standard
  multi-line text editor widget (undo/redo, selection). First reach for text input.
- **[edtui](https://github.com/preiter93/edtui)** — vim-inspired editor widget
  (directly relevant to your nvim-clone project — read this before rolling your own).
- **[tui-input](https://crates.io/crates/tui-input)** — headless single-line input.
- **[tui-prompts](https://crates.io/crates/tui-prompts)** — interactive prompts.

## Widgets
- **[rat-widget](https://crates.io/crates/rat-widget)** — a large batteries-
  included set: text/date/number input, choice, radio, slider, calendar, split,
  tabbed, multi-page, big-data table, file dialog, menubar, status bar, with
  built-in event + focus handling. Great when you want a coherent kit rather than
  a pile of single crates. Pairs with **[rat-salsa](https://github.com/thscharler/rat-salsa)**
  (event queue, timers, focus, dialogs).
- **[tui-tree-widget](https://crates.io/crates/tui-tree-widget)** — trees.
- **[tui-widget-list](https://crates.io/crates/tui-widget-list)** /
  **[ratatui-cheese](https://crates.io/crates/ratatui-cheese)** (bubbletea-inspired
  list, spinner, help, paginator, tree) — richer lists than the built-in.
- **[tui-scrollview](https://crates.io/crates/tui-scrollview)** — scroll a region
  larger than the viewport.
- **[ratatui-image](https://crates.io/crates/ratatui-image)** — images via sixel /
  unicode half-blocks.
- **[tui-term](https://crates.io/crates/tui-term)** — embed a pseudoterminal.
- Charts/data: **[tui-piechart](https://crates.io/crates/tui-piechart)**,
  **[ratatui-stacked-bar](https://github.com/zeqianli/ratatui-stacked-bar)**,
  **[tui-nodes](https://crates.io/crates/tui-nodes)** (node graphs).

## Layout, composition & overlays
- **[ratatui-macros](https://github.com/kdheepak/ratatui-macros)** — cut layout/
  constraint/line boilerplate. Reduces the exact math bugs Layer 1 tests catch.
- **[ratatui-garnish](https://github.com/franklaranja/ratatui-garnish)** —
  composition system for combining widgets.
- **[tui-popup](https://github.com/joshka/tui-popup)** /
  **[tui-overlay](https://crates.io/crates/tui-overlay)** — modals, popovers,
  drawers, toasts from one primitive.
- **[tui-comfy-tabs / tui-tabs](https://crates.io/crates/tui-tabs)** — tab nav.

## Theming & color
- **[opaline](https://crates.io/crates/opaline)** — token-based theme engine with
  gradients, 20 built-in themes, and a theme-selector widget. Closest to jarvis's
  semantic-slot palette approach if you want a ready-made version.
- **[coolor](https://github.com/Canop/coolor)** / **[color-to-tui](https://crates.io/crates/color-to-tui)**
  — color conversion helpers.
- **[termprofile](https://github.com/aschey/termprofile)** — detect terminal
  color/style support and downconvert gracefully (fixes "looks wrong on this
  terminal" bugs).

## Dev & test tooling
- **[tui-pantry](https://crates.io/crates/tui-pantry)** — Storybook-style
  component workbench for developing widgets in isolation. Excellent companion to
  the Layer-2 capture loop: render one widget in every state and screenshot it.
- **[tui-logger](https://crates.io/crates/tui-logger)** — in-app log widget (but
  remember: for debugging, log to a *file*, per the SKILL.md logging rule).

## Exemplar apps
Read these end-to-end when you need architecture, not a widget. Pick by shape:
- **LLM / chat TUIs (closest to jarvis):** **[oatmeal](https://github.com/dustinblackman/oatmeal)**,
  **[tenere](https://github.com/pythops/tenere)** — streaming model output, chat
  transcript layout, backend abstraction. Study how they handle async streaming
  without tearing.
- **Large, mature apps:** **[gitui](https://github.com/extrawurst/gitui)** and
  **[yazi](https://github.com/sxyazi/yazi)** (async file manager) — how to
  structure state, event loop, and many panels at scale.
- **[atuin](https://github.com/atuinsh/atuin)** — a polished, widely-used TUI;
  good reference for restraint and clean rendering.
- **[slumber](https://github.com/LucasPickering/slumber)** /
  **[ATAC](https://github.com/Julien-cpsn/ATAC)** — form-heavy request clients;
  good for multi-field input + focus management.
- **Editors (for the nvim-clone):** **[edtui](https://github.com/preiter93/edtui)**
  (widget) and **[VLE](https://github.com/tuffy/vle)** (lightweight editor app).
