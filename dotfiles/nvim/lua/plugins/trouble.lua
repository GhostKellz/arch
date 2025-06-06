return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "TroubleToggle", "Trouble" },
  keys = {
    { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "💢 Trouble Toggle" },
    { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "💢 Workspace Diagnostics" },
    { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "💢 Document Diagnostics" },
  },
  opts = {},
}
