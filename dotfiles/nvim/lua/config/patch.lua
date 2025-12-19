-- ~/.config/nvim/lua/config/patch.lua
-- Patch for lazy vim
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		-- Patch deprecated rust-tools usage
		local inlay = vim.fn.stdpath("data") .. "/lazy/rust-tools.nvim/lua/rust-tools/inlay_hints.lua"

		-- Replace deprecated get_active_clients() with get_clients()
		if vim.fn.filereadable(inlay) == 1 then
			vim.fn.system({ "sed", "-i", [[s/get_active_clients/get_clients/g]], inlay })
		end
	end,
})
