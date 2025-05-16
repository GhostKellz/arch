return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim", -- optional but recommended
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gs", "<cmd>Neogit<CR>", desc = "Git Status (Neogit)" }
  },
  config = function()
    require("neogit").setup({
      integrations = {
        diffview = true
      }
    })
  end
}
