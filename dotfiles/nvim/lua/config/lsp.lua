-- ~/.config/nvim/lua/config/lsp.lua

-- 🔧 Common on_attach for LSP + null-ls autoformatting
local on_attach = function(client, bufnr)
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = bufnr,
		callback = function()
			vim.lsp.buf.format({ async = false })
		end,
	})
end

-- 🧰 Mason LSP support
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls", -- 🌙 Lua
		"rust_analyzer", -- 🦀 Rust
		"zls", -- 🦎 Zig
		"pyright", -- 🐍 Python
		"gopls", -- 🐹 Go
		"dockerls", -- 🐳 Docker
		"yamlls", -- 📄 YAML
		"jsonls", -- 📄 JSON
		"bashls", -- 🐚 Bash
	},
})

-- 🔌 Null-ls setup (formatters only!)
local null_ls = require("null-ls")
null_ls.setup({
	on_attach = on_attach,
	sources = {
		null_ls.builtins.formatting.stylua, -- 🌙 Lua
		null_ls.builtins.formatting.black, -- 🐍 Python
		null_ls.builtins.formatting.gofmt, -- 🐹 Go
		null_ls.builtins.formatting.prettier, -- 🟨 JS/TS/HTML/CSS
		-- ⚠️ NO clippy or rustfmt here (handled by rust-analyzer)
	},
})

-- ⚙️ Core LSP config
local lspconfig = require("lspconfig")

-- 🦀 Rust via rust-tools
local rt = require("rust-tools")
rt.setup({
	server = {
		on_attach = function(_, bufnr)
			vim.keymap.set("n", "<leader>rr", rt.runnables.runnables, { buffer = bufnr, desc = "Rust Runnables" })
			vim.keymap.set("n", "<leader>rd", rt.debuggables.debuggables, { buffer = bufnr, desc = "Rust Debuggables" })
		end,
		settings = {
			["rust-analyzer"] = {
				cargo = { allFeatures = true },
				checkOnSave = { command = "clippy" },
				rustfmt = { extraArgs = { "--edition=2024" } },
			},
		},
	},
})

-- 🦎 Zig
lspconfig.zls.setup({ on_attach = on_attach })

-- 🐍 Python
lspconfig.pyright.setup({ on_attach = on_attach })

-- 🐹 Go
lspconfig.gopls.setup({
	on_attach = on_attach,
	settings = {
		gopls = {
			gofumpt = true,
			staticcheck = true,
			usePlaceholders = true,
		},
	},
})

-- 🌙 Lua
lspconfig.lua_ls.setup({
	on_attach = on_attach,
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})

-- 🐳 Docker
lspconfig.dockerls.setup({ on_attach = on_attach })

-- 🧾 YAML / JSON
lspconfig.yamlls.setup({ on_attach = on_attach })

local schemastore = require("schemastore")

lspconfig.jsonls.setup({
	on_attach = on_attach,
	settings = {
		json = {
			schemas = schemastore.json.schemas(),
			validate = { enable = true },
		},
	},
})

-- 🐚 Shell
lspconfig.bashls.setup({ on_attach = on_attach })

-- 🟨 TypeScript / JavaScript
require("typescript-tools").setup({
	on_attach = on_attach,
})
