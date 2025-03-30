-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim", tag = "0.1.5" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "neovim/nvim-lspconfig" },
  { "folke/tokyonight.nvim" },
  { "catppuccin/nvim", name = "catppuccin" },
  { "nvim-tree/nvim-web-devicons" },
})

-- Basic UI
vim.o.termguicolors = true
vim.cmd.colorscheme("catppuccin-mocha")
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"

-- Telescope keymap
vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<cr>", { noremap = true })
vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<cr>", { noremap = true })

-- LSP Defaults
local lsp = require("lspconfig")
lsp.lua_ls.setup({})
lsp.pyright.setup({})
lsp.tsserver.setup({})
