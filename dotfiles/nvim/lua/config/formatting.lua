-- Autoformat on save using LSP
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Autoformat on save using built-in LSP (safe fallback)
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
-- Autoformat on save using null-ls

-- Tabs and spacing (2-space indentation everywhere)
vim.opt.tabstop = 2      -- Number of spaces a tab counts for
vim.opt.shiftwidth = 2   -- Spaces to use for (auto)indent
vim.opt.expandtab = true -- Convert tabs to spaces
