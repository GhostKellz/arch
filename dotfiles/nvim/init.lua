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


-- Copilot inline suggestions
vim.keymap.set("i", "<M-l>", function()
  require("copilot.suggestion").accept()
end, { desc = "Copilot Accept Suggestion" })

vim.keymap.set("i", "<M-]>", function()
  require("copilot.suggestion").next()
end, { desc = "Copilot Next Suggestion" })

vim.keymap.set("i", "<M-[>", function()
  require("copilot.suggestion").prev()
end, { desc = "Copilot Previous Suggestion" })

-- Copilot Chat
vim.keymap.set({ "n", "v" }, "<leader>aa", function()
  require("CopilotChat").toggle()
end, { desc = "Toggle Copilot Chat" })

vim.keymap.set({ "n", "v" }, "<leader>ax", function()
  require("CopilotChat").reset()
end, { desc = "Clear Copilot Chat" })

vim.keymap.set({ "n", "v" }, "<leader>aq", function()
  vim.ui.input({ prompt = "Quick Chat: " }, function(input)
    if input ~= "" then
      require("CopilotChat").ask(input)
    end
  end)
end, { desc = "Quick Prompt to Copilot Chat" })

vim.keymap.set({ "n", "v" }, "<leader>ap", function()
  require("CopilotChat").select_prompt()
end, { desc = "Choose Prompt Template (CopilotChat)" })

-- Gen.nvim (Ollama / LiteLLM prompt tool)
vim.keymap.set({ "n", "v" }, "<leader>ag", function()
  require("gen").select_model()
end, { desc = "Change AI Model (gen.nvim)" })

vim.keymap.set({ "n", "v" }, "<leader>ar", function()
  require("gen").prompts["Refactor Code"]()
end, { desc = "AI: Refactor Code" })

vim.keymap.set({ "n", "v" }, "<leader>ad", function()
  require("gen").prompts["Explain Code"]()
end, { desc = "AI: Explain Code" })

vim.keymap.set({ "n", "v" }, "<leader>ac", function()
  require("gen").prompts["Complete Code"]()
end, { desc = "AI: Complete Code" })

vim.keymap.set({ "n", "v" }, "<leader>aa", function()
  require("gen").prompts["Add Tests"]()
end, { desc = "AI: Generate Tests" })


-- LSP Defaults
local lsp = require("lspconfig")
lsp.lua_ls.setup({})
lsp.pyright.setup({})

-- Deprecated - using new typescript-tools instead
-- lsp.tsserver.setup({})

-- Recommended replacement using typescript-tools
require("typescript-tools").setup({})
