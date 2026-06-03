# TMUX_CHEATSHEET.md

# tmux Cheat Sheet 

Based on your current tmux configuration:

```tmux
set -g mouse on
setw -g mode-keys vi

bind -n C-h select-pane -L
bind -n C-j select-pane -D
bind -n C-k select-pane -U
bind -n C-l select-pane -R

bind r source-file ~/.tmux.conf
```

---

# Session Management

## Create New Session

```bash
tmux new -s work
```

## Attach To Session

```bash
tmux attach -t work
```

## List Sessions

```bash
tmux ls
```

## Kill Session

```bash
tmux kill-session -t work
```

## Kill All Sessions

```bash
tmux kill-server
```

---

# Windows

## New Window

```text
Ctrl+b c
```

## Rename Window

```text
Ctrl+b ,
```

## Next Window

```text
Ctrl+b n
```

## Previous Window

```text
Ctrl+b p
```

## List Windows

```text
Ctrl+b w
```

## Window By Number

```text
Ctrl+b 1
Ctrl+b 2
Ctrl+b 3
...
```

---

# Panes

## Vertical Split

```text
Ctrl+b %
```

Result:

+----------+----------+
|          |          |
|          |          |
+----------+----------+

---

## Horizontal Split

```text
Ctrl+b "
```

Result:

+---------------------+
|                     |
+---------------------+
|                     |
+---------------------+

---

## Move Between Panes (Your Custom Bindings)

### Left

```text
Ctrl+h
```

### Down

```text
Ctrl+j
```

### Up

```text
Ctrl+k
```

### Right

```text
Ctrl+l
```

These work without pressing the tmux prefix.

---

## Cycle Panes

```text
Ctrl+b o
```

---

## Show Pane Numbers

```text
Ctrl+b q
```

---

## Resize Pane

### Enter Resize Mode

```text
Ctrl+b :
resize-pane -L 10
resize-pane -R 10
resize-pane -U 5
resize-pane -D 5
```

---

## Close Pane

```text
exit
```

or

```text
Ctrl+d
```

---

# Copy Mode (Vim Style)

You enabled:

```tmux
setw -g mode-keys vi
```

## Enter Copy Mode

```text
Ctrl+b [
```

## Navigation

```text
h j k l
```

```text
w
```

Next word

```text
b
```

Previous word

```text
gg
```

Top

```text
G
```

Bottom

---

## Search

```text
/
```

Search forward

```text
?
```

Search backward

```text
n
```

Next match

```text
N
```

Previous match

---

# Mouse Support

Enabled:

```tmux
set -g mouse on
```

You can:

* Resize panes
* Select panes
* Scroll history
* Copy text

using the mouse.

---

# Configuration

## Reload Config

Custom binding:

```text
Ctrl+b r
```

Displays:

```text
Reloaded!
```

after loading:

```bash
~/.tmux.conf
```

---

# GhostKellz Daily Workflow

Window 1

```text
Neovim
```

Window 2

```text
Claude Code
```

Window 3

```text
OpenCode
```

Window 4

```text
Build Logs
```

Window 5

```text
Git Operations
```

---

# Most Used Commands

| Action           | Shortcut |
| ---------------- | -------- |
| New Window       | Ctrl+b c |
| Vertical Split   | Ctrl+b % |
| Horizontal Split | Ctrl+b " |
| Move Left        | Ctrl+h   |
| Move Down        | Ctrl+j   |
| Move Up          | Ctrl+k   |
| Move Right       | Ctrl+l   |
| Copy Mode        | Ctrl+b [ |
| List Windows     | Ctrl+b w |
| Next Window      | Ctrl+b n |
| Previous Window  | Ctrl+b p |
| Reload Config    | Ctrl+b r |

---

# Panic Commands

List Sessions

```bash
tmux ls
```

Attach To Existing Session

```bash
tmux attach
```

Kill Broken Session

```bash
tmux kill-session -t sessionname
```

Restart tmux

```bash
tmux kill-server
tmux
```

