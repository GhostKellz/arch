# KDE + Krohnkite Cheat Sheet 

## Window is stuck fullscreen / won't tile

### Toggle Float All
Meta + Shift + F

Use when everything suddenly stops tiling.

---

### Toggle Float Current Window
Meta + F

Use when one window refuses to tile.

---

### Cycle Krohnkite Layouts
Meta + \

Cycle through Tile, Columns, Monocle, etc.

---

## Side-by-side terminals

1. Open terminal #1
2. Open terminal #2
3. If they don't tile:
   - Meta + F
4. Cycle layouts:
   - Meta + \
5. Stop when you reach Tile or Columns.

---

## One window takes the entire screen

Usually caused by Monocle Layout.

### Fix

Meta + \

Cycle until Tile or Columns returns.

---

## Move focus between tiled windows

- Meta + H = Left
- Meta + J = Down
- Meta + K = Up
- Meta + L = Right

---

## Move windows

- Meta + Shift + H = Move Left
- Meta + Shift + J = Move Down
- Meta + Shift + K = Move Up
- Meta + Shift + L = Move Right

---

## Resize windows

- Meta + Ctrl + H = Shrink Width
- Meta + Ctrl + L = Grow Width
- Meta + Ctrl + K = Shrink Height
- Meta + Ctrl + J = Grow Height

---

## Set current window as master

Meta + Enter

---

# Virtual Desktops

## Previous Desktop

Meta + Ctrl + Left

## Next Desktop

Meta + Ctrl + Right

## Overview

Meta + W

## Grid View

Meta + G

---

# KDE Window Controls

## Snap Left

Meta + Left

## Snap Right

Meta + Right

## Maximize

Meta + PgUp

## Minimize

Meta + PgDown

## Close Window

Alt + F4

---

# Tmux

## Split Vertical

Ctrl+b %

## Split Horizontal

Ctrl+b "

## Move Between Panes

- Ctrl+h
- Ctrl+j
- Ctrl+k
- Ctrl+l

## Reload tmux.conf

Ctrl+b r

---

# Recommended Workflow

Desktop 1
- Terminals
- Browser
- Discord

Desktop 2
- Neovim
- Claude Code
- OpenCode

Desktop 3
- VMs
- Proxmox
- Remote Sessions

Switch desktops:
- Meta + Ctrl + Left
- Meta + Ctrl + Right

---

# Panic Button

If KDE feels broken:

1. Meta + Shift + F
2. Meta + \
3. Meta + F

These three shortcuts solve most Krohnkite issues.
