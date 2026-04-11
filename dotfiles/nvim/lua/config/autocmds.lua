-- ~/.config/nvim/lua/config/autocmds.lua

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight on yank",
	group = vim.api.nvim_create_augroup("ghostkellz-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
