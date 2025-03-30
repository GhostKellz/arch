# Neovim Cheatsheet

Quick-reference guide for working with Neovim, LazyVim, and the basics of plugin usage.

---

## 🛠 Core Commands

| Action                | Command                    |
|----------------------|----------------------------|
| Save file            | `:w`                       |
| Quit                 | `:q`                       |
| Save & quit          | `:wq` or `ZZ`              |
| Quit without saving  | `:q!`                      |
| Open file explorer   | `:Ex` or `:Oil`            |
| Reload config        | `:so %`                    |
| Toggle line numbers  | `:set relativenumber!`     |

---

## 🧠 Movement

| Move                 | Command        |
|---------------------|----------------|
| Move by word        | `w`, `b`       |
| Move by paragraph   | `{`, `}`       |
| Start/end of line   | `^`, `$`       |
| Top/bottom of file  | `gg`, `G`      |
| Scroll down/up      | `Ctrl-d`, `Ctrl-u` |

---

## 🧱 Window & Pane Management

| Action                  | Command                |
|-------------------------|------------------------|
| Split horizontally      | `:split` or `<leader>sh`|
| Split vertically        | `:vsplit` or `<leader>sv`|
| Navigate panes          | `Ctrl-w` + direction key|
| Resize pane             | `Ctrl-w` then `>` / `<` |
| Close current pane      | `:q` or `Ctrl-w c`      |

---

## 🔍 Searching

| Action         | Command           |
|----------------|-------------------|
| Search         | `/text`           |
| Repeat search  | `n` / `N`         |
| Find/Replace   | `:%s/old/new/gc`  |

---

## 📦 LazyVim & Plugin Tips

| Action                      | Command           |
|-----------------------------|-------------------|
| Lazy plugin manager         | `:Lazy`           |
| Mason LSP installer         | `:Mason`          |
| Format current buffer       | `:Format`         |
| Toggle diagnostics          | `:ToggleDiag`     |
| File search (Telescope)     | `<leader>ff`      |
| Live grep (Telescope)       | `<leader>fg`      |
| Recent files                | `<leader>fr`      |

---

## 📝 Editing Essentials

| Action                    | Command          |
|---------------------------|------------------|
| Copy/paste system clipboard | `"+y`, `"+p`     |
| Undo / redo               | `u` / `Ctrl-r`    |
| Visual select             | `v`, `V`, `Ctrl-v`|
| Comment line (LazyVim)    | `gcc` or `gc`    |

---

## 🔄 Useful Autocommands (Optional)

```lua
-- Reload config on save
vim.cmd([[
  autocmd BufWritePost ~/.config/nvim/init.lua source %
]])
```

---

**Tip:** Use `:checkhealth` to diagnose common plugin/config issues.

