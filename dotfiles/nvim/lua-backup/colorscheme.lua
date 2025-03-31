return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon", -- Try "night", "moon", "storm", or "day"
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = { bold = true },
      },
      sidebars = "transparent",
      floats = "transparent",
      on_highlights = function(hl, c)
        hl.TelescopeNormal = { bg = "none" }
        hl.TelescopeBorder = { fg = c.blue, bg = "none" }
        hl.FloatBorder = { fg = c.border_highlight, bg = "none" }
        hl.NormalFloat = { bg = "none" }
        hl.Pmenu = { bg = "none" }
        hl.NormalNC = { bg = "none" }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
