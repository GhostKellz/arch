
return {
  -- Fast cursor jumps (f/F/t/T replacement + Treesitter motion)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },

  -- Bracket, keyword, and tag matching enhancements
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- Easy comment toggling
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = true,
  },

  -- Global search/replace across files
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    keys = {
      { "<leader>S", function() require("spectre").toggle() end, desc = "Toggle Spectre" },
    },
  },

  -- File explorer tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = true,
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
    },
  },
}
