-- ~/.config/nvim/lua/config/lsp.lua
-- 💡 Modernized for Neovim 0.11+ (uses vim.lsp.start)
-- 🧠 No require('lspconfig') — avoids the deprecation warning
-- 🛡️ Falls back nicely if optional plugins aren't installed

-- 🔧 Common on_attach for all LSPs (format on save + keymaps)
local function on_attach(client, bufnr)
  -- 🖊️ Auto-format on save (only if supported)
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
      if client.supports_method("textDocument/formatting") then
        vim.lsp.buf.format({ async = false })
      end
    end,
  })
  -- 🔍 Keymaps
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end
  map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
  map("n", "gr", vim.lsp.buf.references, "LSP: References")
  map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
  map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature")
  map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")
  map("n", "<leader>d", function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end, "Show diagnostics")

  -- 🟨 Enable inlay hints if supported
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(bufnr, true)
  end
end

-- 🌐 Capabilities (nicer completion if cmp_nvim_lsp is present)
local capabilities = vim.lsp.protocol.make_client_capabilities()
do
  local ok, cmp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp.default_capabilities(capabilities)
  end
end

-- 🧰 Mason (still fine to use for installing binaries)
pcall(function()
  require("mason").setup()
  require("mason-lspconfig").setup({
    ensure_installed = {
      "lua_ls",     -- 🌙 Lua
      "rust_analyzer", -- 🦀 Rust
      "zls",        -- 🦎 Zig
      "pyright",    -- 🐍 Python
      "gopls",      -- 🐹 Go
      "dockerls",   -- 🐳 Docker
      "yamlls",     -- 📄 YAML
      "jsonls",     -- 📄 JSON
      "bashls",     -- 🐚 Bash
    },
  })
end)

-- 🗂️ Root dir helper (modern Neovim API)
local function detect_root()
  return vim.fs.root(0, { ".git", "Cargo.toml", "go.mod", "package.json", "pyproject.toml", "build.zig" })
      or vim.loop.cwd()
end

-- 🧠 Define servers (new API; no lspconfig)
local SERVERS = {
  bashls = { filetypes = { "sh", "bash" }, cmd = { "bash-language-server", "start" } },
  dockerls = { filetypes = { "dockerfile" }, cmd = { "docker-langserver", "--stdio" } },
  gopls = {
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    cmd = { "gopls" },
    settings = { gopls = { gofumpt = true, staticcheck = true, usePlaceholders = true } },
  },
  jsonls = {
    filetypes = { "json", "jsonc" },
    cmd = { "vscode-json-language-server", "--stdio" },
    init_options = { provideFormatter = true },
    settings = (function()
      local ok, schemastore = pcall(require, "schemastore")
      return ok and { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } }
          or { json = { validate = { enable = true } } }
    end)(),
  },
  lua_ls = {
    filetypes = { "lua" },
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  pyright = { filetypes = { "python" }, cmd = { "pyright-langserver", "--stdio" } },
  rust_analyzer = {
    filetypes = { "rust" },
    cmd = { "rust-analyzer" },
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        check = { command = "clippy", extraArgs = { "--no-deps" } },
        rustfmt = { extraArgs = { "--edition=2024" } },
      },
    },
  },
  yamlls = {
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
    cmd = { "yaml-language-server", "--stdio" },
    settings = { redhat = { telemetry = { enabled = false } }, yaml = { format = { enable = true } } },
  },
  zls = { filetypes = { "zig", "zir" }, cmd = { "zls" } },
}

-- 🚀 Start helper (pure new API)
local function start_server_for_buf(name, cfg, bufnr)
  local root = detect_root()

  -- prevent duplicate starts for the same server+root_dir
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == name and client.config.root_dir == root then
      return
    end
  end

  vim.schedule(function()
    vim.lsp.start({
      name = name,
      cmd = cfg.cmd,
      root_dir = root,
      on_attach = on_attach,
      capabilities = capabilities,
      settings = cfg.settings,
      init_options = cfg.init_options,
    }, { bufnr = bufnr })
  end)
end

-- 🧷 FileType autocmds per server
for name, cfg in pairs(SERVERS) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = cfg.filetypes or "*",
    group = vim.api.nvim_create_augroup("gk_lsp_" .. name, { clear = true }),
    callback = function(args)
      if name == "rust_analyzer" and package.loaded["rust-tools"] then
        return
      end -- 🦀 rust-tools handles Rust
      start_server_for_buf(name, cfg, args.buf)
    end,
  })
end

-- 🦀 Rust (optional rust-tools; skips if missing)
do
  local ok, rt = pcall(require, "rust-tools")
  if ok then
    rt.setup({
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set(
            "n",
            "<leader>rr",
            rt.runnables.runnables,
            { buffer = bufnr, desc = "Rust Runnables" }
          )
          vim.keymap.set(
            "n",
            "<leader>rd",
            rt.debuggables.debuggables,
            { buffer = bufnr, desc = "Rust Debuggables" }
          )
        end,
        capabilities = capabilities,
        settings = SERVERS.rust_analyzer.settings,
      },
    })
  end
end

-- 🟨 TypeScript / JavaScript (optional typescript-tools; skips if missing)
do
  local ok, ts_tools = pcall(require, "typescript-tools")
  if ok then
    ts_tools.setup({ on_attach = on_attach, capabilities = capabilities })
  end
end

-- 📦 External formatters (null-ls / conform)
pcall(require, "config.formatting")

-- 🐒 Monkeypatch deprecated buf_get_clients to keep noisy plugins quiet
vim.lsp.buf_get_clients = function(bufnr)
  vim.notify_once("[GhostKellz] Suppressed deprecated buf_get_clients call", vim.log.levels.DEBUG)
  return vim.lsp.get_clients({ bufnr = bufnr or 0 })
end

-- ✅ Diagnostics UI
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
