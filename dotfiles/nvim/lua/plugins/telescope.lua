-- ~/.config/nvim/lua/plugins/telescope.lua
vim.g.have_nerd_font = true

return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",

		-- 🔍 FZF Native Extension (blazing fast sorting)
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = vim.fn.executable("make") == 1,
			config = function()
				require("telescope").load_extension("fzf")
			end,
		},

		-- 🎛 Use Telescope for vim.ui.select (optional but sleek)
		{
			"nvim-telescope/telescope-ui-select.nvim",
			config = function()
				require("telescope").load_extension("ui-select")
			end,
		},
	},

	keys = {
		-- 🧭 Root Finder Group
		{ "<leader>f", desc = "🔍 Find…" },

		-- 🔍 Core Pickers
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "📂 Find Files" },
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "🧠 Live Grep" },
		{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "📄 Buffers" },
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "🕘 Recent Files" },

		-- ⚙️ Utility
		{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "❓ Help Tags" },
		{ "<leader>fc", "<cmd>Telescope commands<cr>", desc = "⚙️ Commands" },
		{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "🎛 Keymaps" },

		-- 🧠 Optional LSP integrations
		{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "🔣 Document Symbols" },
		{ "<leader>fw", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "🌐 Workspace Symbols" },
	},

	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				theme = "ivy",
				prompt_prefix = "🔍 ",
				selection_caret = " ",
				winblend = 10,
				sorting_strategy = "ascending",
				layout_config = {
					height = 0.3,
					prompt_position = "bottom",
				},
				mappings = {
					i = {
						["<esc>"] = actions.close,
					},
				},
			},
			pickers = {
				find_files = { theme = "ivy" },
				live_grep = { theme = "ivy" },
				buffers = { theme = "dropdown" },
				oldfiles = { theme = "dropdown" },
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_file_sorter = true,
					override_generic_sorter = true,
					case_mode = "smart_case",
				},
				["ui-select"] = {
					require("telescope.themes").get_dropdown({}),
				},
			},
		})

		-- 🚀 Load extensions safely
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")
	end,
}
