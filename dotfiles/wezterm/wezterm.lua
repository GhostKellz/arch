-- GhostKellz Terminal 2.0 --
local wezterm = require 'wezterm'
local act = wezterm.action

-- Define the custom GhostKellz color scheme
local ghostkellz_scheme = wezterm.color.get_builtin_schemes()["tokyonight"]

ghostkellz_scheme.ansi = {
  "#0c0f17", "#ff5c57", "#8aff80", "#f3f99d",
  "#57c7ff", "#ff6ac1", "#9aedfe", "#57c7ff",
}
ghostkellz_scheme.brights = {
  "#686868", "#ff5c57", "#8aff80", "#f3f99d",
  "#57c7ff", "#ff6ac1", "#9aedfe", "#57c7ff",
}
ghostkellz_scheme.background = "#0d1117"
ghostkellz_scheme.foreground = "#57c7ff"
ghostkellz_scheme.cursor_bg = "#57c7ff"
ghostkellz_scheme.cursor_fg = "#0d1117"
ghostkellz_scheme.selection_bg = "#23476a"
ghostkellz_scheme.selection_fg = "#ffffff"

return {
  -- Color Scheme (ghostkellz customized)
  color_schemes = {
    ["ghostkellz"] = ghostkellz_scheme,
  },
  color_scheme = "ghostkellz",

  -- GPU and rendering
  enable_wayland = true,
  front_end = "WebGpu",
  webgpu_power_preference = "HighPerformance",
  webgpu_force_fallback_adapter = false,

-- Font settings
font = wezterm.font_with_fallback {
  { family = "FiraCode Nerd Font", weight = "Bold" },
  { family = "JetBrainsMono Nerd Font", weight = "Bold" }, -- fallback
  { family = "Symbols Nerd Font Mono", weight = "Bold" },
  { family = "Noto Color Emoji" },
  { family = "Noto Sans", weight = "Bold" },
},
font_size = 12.0,

  -- Appearance
  window_background_opacity = 0.95,
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  default_prog = { "/bin/zsh" },

  -- Cursor behavior
  default_cursor_style = "BlinkingBlock",
  cursor_blink_rate = 800,

  -- Window padding
  window_padding = {
    left = 4,
    right = 4,
    top = 2,
    bottom = 2,
  },

  -- Keybindings
  keys = {
    -- Split panes
    { key = "v", mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "s", mods = "CTRL|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },

    -- Clipboard
    { key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
    { key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },

    -- Debug overlay
    { key = "L", mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
  },

  -- Performance
  adjust_window_size_when_changing_font_size = false,
  native_macos_fullscreen_mode = true,
}
