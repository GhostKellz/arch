return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = vim.fn.executable("make") == 1,
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help Tags" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        layout_strategy = "vertical",
        layout_config = { height = 0.9 },
        sorting_strategy = "ascending",
        file_sorter = require("telescope.sorters").get_fzf_sorter,
        generic_sorter = require("telescope.sorters").get_generic_fzf_sorter,
      },
    })
  end,
}
