-- ~/.config/nvim/lua/config/lsp.lua

-- 🔧 Common on_attach for all LSPs (used for formatting/autocommands)
local on_attach = function(client, bufnr)
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = bufnr,
		callback = function()
			vim.lsp.buf.format({ async = false })
		end,
	})
end

-- 🧰 Mason & Mason-LSP Setup
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

-- ⚙️ Core LSP Config
local lspconfig = require("lspconfig")

-- 🦀 Rust with rust-tools (best dev experience)
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

-- 📄 YAML
lspconfig.yamlls.setup({ on_attach = on_attach })

-- 📄 JSON with schemas
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

-- 🐚 Bash
lspconfig.bashls.setup({ on_attach = on_attach })

-- 🟨 TypeScript / JavaScript
require("typescript-tools").setup({
	on_attach = on_attach,
})

-- 📦 External null-ls formatter support
require("config.formatting")
