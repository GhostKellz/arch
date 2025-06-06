-- plugins/enhancements.lua

return {
  -- 🔹 Indentation Guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" }, -- vertical bar
      scope = { enabled = true },
    },
  },

  -- 🔹 Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
    },
  },

  -- 🔹 Telescope FZF Native (Faster fuzzy search)
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = vim.fn.executable("make") == 1,
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  -- 🔹 Symbols Outline (Code structure tree view)
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = {
      { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" },
    },
    opts = {
      auto_close = true,
      highlight_hovered_item = true,
      show_guides = true,
    },
  },
}
