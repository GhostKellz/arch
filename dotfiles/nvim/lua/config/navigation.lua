-- Insert-mode arrow keys using Alt + HJKL (60% keyboard-friendly)
vim.keymap.set("i", "<A-h>", "<Left>", { desc = "← in insert" })
vim.keymap.set("i", "<A-j>", "<Down>", { desc = "↓ in insert" })
vim.keymap.set("i", "<A-k>", "<Up>", { desc = "↑ in insert" })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "→ in insert" })

-- Quick line start/end in normal mode
vim.keymap.set("n", "H", "^", { desc = "Start of line" })
vim.keymap.set("n", "L", "$", { desc = "End of line" })
vim.keymap.set("n", "J", "5j", { desc = "Down faster" })
vim.keymap.set("n", "K", "5k", { desc = "Up faster" })

-- Flash.nvim keymap
pcall(function()
  require("flash") -- make sure it's loaded
  vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash Jump" })
  vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
  vim.keymap.set("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
end)
