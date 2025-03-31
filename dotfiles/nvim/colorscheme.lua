#/home/chris/.config/nvim/lua/plugins/colorscheme.lua
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "moon", -- Options: storm | night | moon | day
    transparent = true,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = { bold = true },
      variables = {},
    },
    sidebars = { "qf", "help", "neo-tree", "lazy", "mason", "terminal" },
    on_highlights = function(hl, c)
      hl.Normal = { bg = "none" }
      hl.NormalNC = { bg = "none" }
      hl.FloatBorder = { fg = c.blue, bg = "none" }
      hl.TelescopeBorder = { fg = c.blue, bg = "none" }
      hl.TelescopePromptBorder = { fg = c.blue, bg = "none" }
      hl.TelescopeResultsBorder = { fg = c.blue, bg = "none" }
      hl.TelescopePreviewBorder = { fg = c.blue, bg = "none" }
      hl.TelescopeTitle = { fg = c.blue, bold = true }
      hl.TelescopeMatching = { fg = c.cyan }
      hl.StatusLine = { fg = c.fg_dark, bg = "none" }
      hl.LineNr = { fg = c.comment }
      hl.CursorLineNr = { fg = "#8aff80", bold = true } -- mint green
      hl.Visual = { bg = c.bg_visual }
      hl.Pmenu = { bg = c.bg_dark, fg = c.fg }
      hl.PmenuSel = { bg = c.bg_highlight, fg = c.fg }
      hl.PmenuSbar = { bg = c.bg_dark }
      hl.PmenuThumb = { bg = c.blue }
      hl.VertSplit = { fg = c.bg_highlight }

      -- Extra minty tweaks
      hl.Function = { fg = "#8aff80", bold = true } -- functions in mint green
      hl.Comment = { fg = "#57c7ff", italic = true } -- comments in hacker blue
      hl.Number = { fg = "#f3f99d", bold = true } -- numbers in yellow
      h1.Normal = { fg = "#8aff80", bold=true } -- normal mint green
    end,
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd.colorscheme("tokyonight")
  end,
}
