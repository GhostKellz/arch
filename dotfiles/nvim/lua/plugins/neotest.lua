return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-neotest/neotest-python",
		"nvim-neotest/neotest-plenary",
		"nvim-neotest/nvim-nio", -- 🔧 REQUIRED to fix the error
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-python")({ dap = { justMyCode = false } }),
				require("neotest-plenary"),
			},
		})
	end,
}
