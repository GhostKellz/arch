-- GhostKellz neovim configuration
--
-- A Neovim config using Lazy.nvim for Plugin Management
-- author : GhostKellz
-- ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.tmux_navigator_no_mappings = 0

-- put this at the VERY top of init.lua, before lazy setup
do
	local orig = vim.notify
	vim.notify = function(msg, level, opts)
		if type(msg) == "string" and msg:match("The `require%('lspconfig'%).*deprecated") then
			return
		end
		return orig(msg, level, opts)
	end
end

-- 🔌 Point Neovim at your host providers to kill provider warnings
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/lsp/bin/python3")
vim.g.node_host_prog = vim.fn.exepath("node")
-- vim.g.ruby_host_prog = vim.fn.exepath("neovim-ruby-host")  -- uncomment if you actually use Ruby provider

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Leader keymaps
vim.g.mapleader = " " -- Spacebar as the leader key
vim.g.maplocalleader = "\\" -- Optional: local leader

-- --- Plugins --- --
local plugins = {
	{ import = "plugins" }, -- Import Plugins Folder
	{ "nvim-lua/plenary.nvim" },

	-- Mason
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		lazy = false,
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = true,
	},

	-- SchemaStore
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},

	-- Treesitter
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

	-- LSP base (configured in lua/config/lsp.lua)
	{ "neovim/nvim-lspconfig" },

	-- TypeScript tools (used by config/lsp.lua)
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	},

	-- More Plugins
	{ "folke/tokyonight.nvim" },
	-- { "catppuccin/nvim", name = "catppuccin" },
	{ "nvim-tree/nvim-web-devicons" },

	-- null-ls (none-ls)
	{
		"nvimtools/none-ls.nvim", -- formerly null-ls.nvim
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.prettier,
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.black,
					null_ls.builtins.formatting.gofmt,
				},
			})
		end,
	},

	-- Optional: LSP progress UI
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		event = "LspAttach",
		opts = {},
	},

	-- Neo tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				window = {
					position = "left",
					width = 30,
				},
				filesystem = {
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = true,
					},
				},
			})
		end,
	},

	{
		"echasnovski/mini.statusline",
		version = "*",
		lazy = false,
		config = function()
			local statusline = require("mini.statusline")
			statusline.setup({
				use_icons = true,
				set_vim_settings = false,
				content = {
					active = function()
						local mode = statusline.section_mode({ trunc_width = 120 })
						local git = statusline.section_git({ trunc_width = 75 })
						local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
						local filename = statusline.section_filename({ trunc_width = 140 })
						local fileinfo = statusline.section_fileinfo({ trunc_width = 60 })
						local location = statusline.section_location({ trunc_width = 60 })

						return statusline.combine_groups({
							{ hl = "MiniStatuslineModeNormal", strings = { mode } },
							{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
							"%<",
							{ hl = "MiniStatuslineFilename", strings = { filename } },
							"%=",
							{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
							{ hl = "MiniStatuslineLocation", strings = { location } },
						})
					end,
				},
			})

			-- GhostKellz™ Color Override 💀
			-- GhostKellz™ Minty Style 🍃
			vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = "#003344", bg = "#7fffd4", bold = true }) -- Aqua bg
			vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo", { fg = "#88ffcc", bg = "#1e1e2e" }) -- Mint green
			vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { fg = "#88ffcc", bg = "#1e1e2e", italic = true }) -- Mint, italic
			vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { fg = "#66f0aa", bg = "#1e1e2e" }) -- Soft mint
			vim.api.nvim_set_hl(0, "MiniStatuslineLocation", { fg = "#44ffbb", bg = "#1e1e2e" }) -- Sharper mint
		end,
	},
}

-- Disable LuaRocks/Hererocks noise from Lazy (you can re-enable later)
require("lazy").setup(plugins, {
	rocks = { enabled = false, hererocks = false },
})

-- -------- Safe module loading --------
local function tryreq(m)
	local ok, err = pcall(require, m)
	if not ok then
		vim.notify("Skipped " .. m .. ": " .. tostring(err), vim.log.levels.WARN)
	end
end

-- Load Config (use safe loader so a missing file never hard-crashes startup)
tryreq("config.options")
tryreq("config.navigation")
tryreq("config.formatting")
tryreq("config.lsp") -- 👈 all LSP setup lives here now
tryreq("config.autocmds")
tryreq("config.dap")
tryreq("config.patch")

-- Basic UI
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.opt.background = "dark"

-- 🎨 Theme
vim.cmd.colorscheme("tokyonight")

-- Tmux
vim.api.nvim_set_hl(0, "StatusLine", {
	fg = "#1a1b26", -- dark text
	bg = "#88aff0", -- mint green
	bold = true,
})
vim.api.nvim_set_hl(0, "StatusLineNC", {
	fg = "#1a1b26", -- dark text
	bg = "#7aa2f7", -- light blue
})

-- Set custom highlight groups for dark blues, minty greens, and comments
vim.api.nvim_set_hl(0, "Normal", { fg = "#7aa2f7", bg = "none" }) -- Light Blue for main text (Normal)
vim.api.nvim_set_hl(0, "Comment", { fg = "#7aa2f7", italic = true }) -- Light Blue for comments, italic
vim.api.nvim_set_hl(0, "Constant", { fg = "#7aa2f7", bg = "none" }) -- Light Blue constants
vim.api.nvim_set_hl(0, "String", { fg = "#66d9ef", bg = "none" }) -- Teal for strings
vim.api.nvim_set_hl(0, "Function", { fg = "#88aff0", bold = true }) -- Mint green for functions
vim.api.nvim_set_hl(0, "Identifier", { fg = "#7aa2f7", bg = "none" }) -- Light Blue Identifiers
vim.api.nvim_set_hl(0, "Keyword", { fg = "#9a0ade", bold = true }) -- Purple for keywords
vim.api.nvim_set_hl(0, "Operator", { fg = "#7aa2f7", bg = "none" }) -- Light Blue Operators

-- Keywords and keywords functions (dupe-safe)
vim.api.nvim_set_hl(0, "Keyword", { fg = "#9a0ade", bold = true })
vim.api.nvim_set_hl(0, "Operator", { fg = "#57c7ff", bg = "none" })

-- Neo Tree Keymap
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })

-- Copilot Inline Suggestions
vim.keymap.set("i", "<C-g>", function()
	require("copilot.suggestion").accept()
end, { desc = "Copilot Accept Suggestion" })
vim.keymap.set("i", "<C-l>", function()
	require("copilot.suggestion").next()
end, { desc = "Copilot Next Suggestion" })
vim.keymap.set("i", "<C-k>", function()
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
vim.keymap.set({ "n", "v" }, "<leader>at", function()
	require("gen").prompts["Add Tests"]()
end, { desc = "AI: Generate Tests" })

-- Monkeypatch deprecated function to suppress warning (compat shim)
vim.lsp.buf_get_clients = function(bufnr)
	vim.notify_once("[GhostKellz] Suppressed deprecated buf_get_clients call", vim.log.levels.DEBUG)
	return vim.lsp.get_clients({ bufnr = bufnr or 0 })
end
