local wezterm = require 'wezterm'

-- Custom color scheme
local custom_scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]

-- Custom color adjustments
custom_scheme.ansi = {
  "#0c0f17", -- black (bg)
  "#ff5c57", -- red
  "#8aff80", -- green
  "#f3f99d", -- yellow
  "#57c7ff", -- hacker blue
  "#ff6ac1", -- pink-purple
  "#9aedfe", -- light blue
  "#57c7ff", -- light blue (white set to blue)
}

custom_scheme.brights = {
  "#686868", -- dark gray
  "#ff5c57", -- red
  "#8aff80", -- green
  "#f3f99d", -- yellow
  "#57c7ff", -- hacker blue
  "#ff6ac1", -- pink-purple
  "#9aedfe", -- light blue
  "#57c7ff", -- light blue (again, white set to blue)
}

-- Set the background and foreground colors to match the theme
custom_scheme.background = "#0d1117"
custom_scheme.foreground = "#57c7ff" -- This sets all the text to light blue (your desired color)
custom_scheme.cursor_bg = "#57c7ff"
custom_scheme.cursor_fg = "#0d1117"
custom_scheme.selection_bg = "#23476a"
custom_scheme.selection_fg = "#ffffff"

return {
  color_schemes = {
    ["ckterm"] = custom_scheme,  -- Custom theme name
  },
  color_scheme = "ckterm",  -- Use this scheme as default
  enable_wayland = true,
  front_end = "WebGpu",
  font = wezterm.font_with_fallback {
    "JetBrainsMono Nerd Font",
    "FiraCode Nerd Font",
  },
  font_size = 13.0,
  default_prog = { "/bin/zsh" },
  window_background_opacity = 0.95,
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  keys = {
    { key = "v", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "s", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "V", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
    { key = "C", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
  },
  window_padding = {
    left = 4,
    right = 4,
    top = 2,
    bottom = 2,
  },
}
