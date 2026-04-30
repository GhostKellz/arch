-- plugins/enhancements.lua
-- ✨ GhostKellz Enhancements – UI, DX, Dev Tools, Pretty Things
return {
	-- 🔹 Indentation Guides
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		main = "ibl",
		opts = {
			indent = { char = "│" },
			scope = { enabled = true },
		},
	},

	-- 🔹 Autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
		},
	},

	-- 🔹 Telescope FZF Native
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		cond = vim.fn.executable("make") == 1,
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},

	-- 🪄 Noice UI (Fancy messages + popups)
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			notify = { enabled = false }, -- using custom vim.notify wrapper for deprecation suppression
		},
	},

	-- 🌈 Inline hex/css color preview
	{
		"NvChad/nvim-colorizer.lua",
		event = "BufReadPre",
		config = function()
			require("colorizer").setup()
		end,
	},

	-- 🧪 Neotest core + adapters
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-neotest/nvim-nio", -- REQUIRED
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-go"),
					require("neotest-rust"),
					require("neotest-vitest"),
				},
			})
		end,
	},
	{ "nvim-neotest/neotest-go", ft = "go" },
	{ "rouge8/neotest-rust", ft = "rust" },
	{ "marilari88/neotest-vitest", ft = { "javascript", "typescript" } },

	-- 🐞 DAP core + UI
	{ "mfussenegger/nvim-dap", event = "VeryLazy" },
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" }, config = true },
	{ "theHamsta/nvim-dap-virtual-text", config = true },

	-- ❗ Trouble for diagnostics and TODOs
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
		opts = {},
	},
}
