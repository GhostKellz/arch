return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("diffview").setup({
      use_icons = true,
    })

    vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Git Diff View" })
    vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>", { desc = "Git File History" })
    vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<CR>", { desc = "Git Diff Close" })
  end
}
