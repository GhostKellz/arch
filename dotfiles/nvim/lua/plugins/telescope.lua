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
        theme = "ivy",
        winblend = 10, -- subtle transparency
        layout_config = {
          height = 0.3,
          prompt_position = "bottom",
        },
        sorting_strategy = "ascending",
      },
      pickers = {
        find_files = { theme = "ivy" },
        buffers = { theme = "dropdown" },
        live_grep = { theme = "ivy" },
      },
    })
  end,
}
