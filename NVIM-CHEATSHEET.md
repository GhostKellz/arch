# Neovim Comprehensive Cheatsheet

### 🛠 Core NVIM/LazyVim Commands

| Action               | Command / Keybinding     |
| -------------------- | ------------------------ |
| Save file            | `:w` or `<leader>w`      |
| Quit                 | `:q` or `<leader>q`      |
| Save & quit          | `:wq` or `ZZ`            |
| Quit without saving  | `:q!`                    |
| Reload config        | `:so %` (source buffer)  |
| Toggle line numbers  | `:set relativenumber!`   |
| Open file explorer   | `:Ex` or `:Oil`          |
| Open Lazy plugin mgr | `:Lazy`                  |
| Mason LSP installer  | `:Mason`                 |
| Format buffer        | `:Format` / `<leader>cf` |

---

### 🧠 Navigation & Movement

| Move/Jump             | Command / Keybinding |
| --------------------- | -------------------- |
| Left, Down, Up, Right | `h` `j` `k` `l`      |
| Word/WORD             | `w` / `b`            |
| Line start/end        | `^` / `$`            |
| Top/bottom of file    | `gg` / `G`           |
| Paragraph             | `{` / `}`            |
| Scroll down/up        | `Ctrl-d` / `Ctrl-u`  |
| Page up/down          | `Ctrl-b` / `Ctrl-f`  |
| Jump to matching      | `%`                  |
| Go to file            | `gf`                 |

---

### 🧱 Window, Tab, Pane & Tmux Navigation

| Action             | Command / Keybinding            |
| ------------------ | ------------------------------- |
| Split horizontally | `:split` / `<leader>sh`         |
| Split vertically   | `:vsplit` / `<leader>sv`        |
| Next/Prev window   | `Ctrl-w` + `w`/`W`              |
| Pane navigation    | `Ctrl-h/j/k/l` or `<A-h/j/k/l>` |
| Close current pane | `:q` / `Ctrl-w c`               |
| Resize pane        | `Ctrl-w` then `>` or `<`        |
| New tab            | `:tabnew`                       |
| Next/Prev tab      | `gt` / `gT`                     |
| Switch tmux panes  | `Ctrl-h/j/k/l` (tmux-navigator) |

---

### 🔍 Telescope, Search & Grep

| Action         | Command / Keybinding |
| -------------- | -------------------- |
| File search    | `<leader>ff`         |
| Live grep      | `<leader>fg`         |
| Recent files   | `<leader>fr`         |
| Find buffers   | `<leader>fb`         |
| Project search | `<leader>fp`         |
| In-file search | `/` then `n` / `N`   |
| Find/replace   | `:%s/old/new/gc`     |

---

### 📝 Editing & Essentials

| Action                      | Command / Keybinding        |
| --------------------------- | --------------------------- |
| Copy to system clipboard    | `"+y`                       |
| Paste from system clipboard | `"+p`                       |
| Undo / Redo                 | `u` / `Ctrl-r`              |
| Visual selection            | `v`, `V`, `Ctrl-v`          |
| Delete (cut)                | `d`, `dd`, `x`              |
| Yank (copy)                 | `y`, `yy`                   |
| Paste                       | `p`, `P`                    |
| Change                      | `c`, `cc`                   |
| Comment line/block          | `gcc` (line) / `gc` (block) |
| Auto-indent                 | `=` (normal/visual)         |
| Surround (vim-surround)     | `ys`, `ds`, `cs`            |

---

### 🚀 Git, Lazygit, and Neogit

| Action             | Command / Keybinding |
| ------------------ | -------------------- |
| Lazygit popup      | `<leader>gg`         |
| Neogit status      | `<leader>ng`         |
| Git blame (toggle) | `<leader>gb`         |
| Git diff           | `<leader>gd`         |
| Git commit         | `<leader>gc`         |

---

### 📦 Plugin, LSP & Diagnostics

| Action                 | Command / Keybinding |
| ---------------------- | -------------------- |
| Open Mason LSP manager | `:Mason`             |
| LSP info/status        | `:LspInfo`           |
| Format buffer          | `<leader>cf`         |
| Hover docs             | `K`                  |
| Go to definition       | `gd` / `<leader>ld`  |
| Go to references       | `gr` / `<leader>lr`  |
| Rename symbol          | `<leader>rn`         |
| Code actions           | `<leader>ca`         |
| Toggle diagnostics     | `<leader>cd`         |

---

### 🤖 Copilot & AI (incl. inline)

| Action                    | Command / Keybinding                       |
| ------------------------- | ------------------------------------------ |
| Copilot Chat panel        | `<leader>ac` or `<leader>cc`               |
| Copilot Accept suggestion | `Ctrl-G` / `Ctrl-L` *(set in your config)* |
| Copilot Next/Prev         | `Ctrl-]` / `Ctrl-[`                        |
| Copilot Dismiss           | `Ctrl-\\`                                  |
| Accept inline suggestion  | `Ctrl-G` or your custom key                |
| Open AI command palette   | `<leader>ai`                               |
| Toggle AI suggestions     | `<leader>at`                               |

> **Note:** You can remap Copilot inline accept to whatever is easiest (e.g., `<Tab>` or `<C-Space>`) if not already used!

---
---

### 🧠 Claude Code (AI Agent)

| Action                      | Command / Keybinding     |
|----------------------------|---------------------------|
| Toggle Claude Code panel   | `<leader>ac` or `<C-,>`   |
| Resume last session        | `<leader>cC`              |
| Show verbose output        | `<leader>cV`              |
| Open Claude terminal       | `:ClaudeCode`             |
| Resume interactive convo   | `:ClaudeCodeResume`       |
| Verbose turn-by-turn log   | `:ClaudeCodeVerbose`      |

> **Note:** Claude Code auto-detects git roots, syncs with external changes, and updates buffers live.

---
### ⌨️ Custom & Useful Keybinds

| Keybind     | What it Does              |
| ----------- | ------------------------- |
| `<Space>`   | Leader key (main prefix)  |
| `<leader>f` | File actions / search     |
| `<leader>t` | Test commands (neotest)   |
| `<leader>n` | Toggle filetree/NERDTree  |
| `<leader>u` | Undo tree                 |
| `<leader>s` | Split (window management) |
| `<leader>b` | Buffers                   |
| `<leader>q` | Quit                      |
| `<leader>c` | Comment                   |

---

### 🛡️ Troubleshooting / Diagnostics

* `:checkhealth`        → Check plugin health & problems
* `:messages`           → View recent errors/messages
* `:LspLog`             → LSP logs if LSP misbehaving

---

### 🔄 Sample Useful Autocommands

```lua
-- Reload init.lua on save
vim.cmd([[\n  autocmd BufWritePost ~/.config/nvim/init.lua source %\n]])
```

---

### 🐣 Beginner Reference (MUST KNOW)

* **hjkl** for movement (left, down, up, right)
* **:w, \:q, \:wq** for save/quit
* **Visual mode**: `v` (char), `V` (line), `Ctrl-v` (block)
* **Leader** is `<Space>` — most plugin/command keybinds are `<leader>` + something.

---

## 🤝 Pro-Tip Section

* **Use `<Tab>` for autocompletion in insert mode unless you need it for snippet/other plugin.**
* **Remap Copilot Accept to `<C-G>`/`<C-L>` or `<Tab>` for speed.**
* **Use Telescope (`<leader>ff`) for file/buffer/project searching—it's life-changing!**
* **Toggle file tree or outline frequently for navigation speed.**

---

## 🎯 How to Get Help

* `:help <topic>` — e.g., `:help key-mappings`
* `:Telescope help_tags` — fuzzy search help topics

---

