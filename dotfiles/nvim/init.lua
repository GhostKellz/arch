-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  { import = "plugins" }, -- Import Plugins Folder
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
vim.cmd.colorscheme("tokyonight")
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.opt.background = "dark"
vim.cmd.colorscheme("tokyonight")

-- Set custom highlight groups for dark blues, minty greens, and comments
vim.api.nvim_set_hl(0, "Normal", { fg = "#7aa2f7", bg = "none" })         -- Light Blue for main text (Normal)
vim.api.nvim_set_hl(0, "Comment", { fg = "#7aa2f7", italic = true })      -- Light Blue for comments, italic
vim.api.nvim_set_hl(0, "Constant", { fg = "#7aa2f7", bg = "none" })       -- Light Blue constants
vim.api.nvim_set_hl(0, "String", { fg = "#66d9ef", bg = "none" })         -- Teal for strings
vim.api.nvim_set_hl(0, "Function", { fg = "#88aff0", bold = true })       -- Mint green for functions
vim.api.nvim_set_hl(0, "Identifier", { fg = "#7aa2f7", bg = "none" })     -- Light Blue Identifiers
vim.api.nvim_set_hl(0, "Keyword", { fg = "#9a0ade", bold = true })        -- Purple for keywords
vim.api.nvim_set_hl(0, "Operator", { fg = "#7aa2f7", bg = "none" })       -- Light Blue Operators




-- Keywords and keywords functions
vim.api.nvim_set_hl(0, "Keyword", { fg = "#9a0ade", bold = true })        -- Purple for keywords
vim.api.nvim_set_hl(0, "Operator", { fg = "#57c7ff", bg = "none" })       -- Light Blue Operators

-- Telescope keymap
vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<cr>", { noremap = true })
vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<cr>", { noremap = true })

-- LSP Defaults
local lsp = require("lspconfig")
lsp.lua_ls.setup({})
lsp.pyright.setup({})

-- Deprecated - using new typescript-tools instead
-- lsp.tsserver.setup({})

-- Recommended replacement using typescript-tools
require("typescript-tools").setup({})
