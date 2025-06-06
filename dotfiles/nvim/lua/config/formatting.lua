-- ~/.config/nvim/lua/config/formatting.lua

local null_ls = require("null-ls")

-- 🔧 on_attach for format-on-save (used only by null-ls here)
local on_attach = function(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ async = false })
			end,
		})
	end
end

-- ⚙️ Setup null-ls with selected formatters (excluding rustfmt/clippy)
null_ls.setup({
	on_attach = on_attach,
	sources = {
		null_ls.builtins.formatting.stylua, -- 🌙 Lua
		null_ls.builtins.formatting.black, -- 🐍 Python
		null_ls.builtins.formatting.gofmt, -- 🐹 Go
		null_ls.builtins.formatting.prettier, -- 🟨 JS/TS/HTML/CSS/JSON
	},
})

-- 🧱 Global tab settings (2 spaces)
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
