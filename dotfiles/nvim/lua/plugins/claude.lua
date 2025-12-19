return {
	"greggh/claude-code.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose" },
	keys = {
		{ "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude Code" },
		{ "<leader>cC", "<cmd>ClaudeCodeContinue<CR>", desc = "Claude: Continue Last" },
		{ "<leader>cV", "<cmd>ClaudeCodeVerbose<CR>", desc = "Claude: Verbose Mode" },
	},
	config = function()
		require("claude-code").setup({
			-- 🔑 point the plugin at the *stdio* editor process
			-- option A: if the plugin supports a list:
			cmd = { "claude-code", "editor", "--stdio" },
			-- option B: if it only accepts a string, use this instead:
			-- command = "claude-code editor --stdio",

			window = {
				split_ratio = 0.3,
				position = "botright",
				enter_insert = true,
				hide_numbers = true,
				hide_signcolumn = true,
			},
			refresh = { enable = true, updatetime = 100, timer_interval = 1000, show_notifications = true },
			git = { use_git_root = true },

			-- if your plugin expects these variants, keep them:
			command_variants = { continue = "--continue", resume = "--resume", verbose = "--verbose" },

			keymaps = {
				toggle = {
					normal = "<C-,>",
					terminal = "<C-,>",
					variants = { continue = "<leader>cC", verbose = "<leader>cV" },
				},
				window_navigation = true,
				scrolling = true,
			},
		})
	end,
}
