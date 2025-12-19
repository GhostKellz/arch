-- ~/.config/nvim/lua/config/dap.lua
-- 🚀 DAP setup (CodeLLDB + fallbacks) — GhostKellz edition

local dap = require("dap")

-- 🔎 Helper: pick first existing path
local function first_existing(paths)
  for _, p in ipairs(paths) do
    if p and #p > 0 and vim.fn.executable(p) == 1 then
      return p
    end
  end
end

-- 📦 Mason default install roots (adjust if your Mason path differs)
local mason = vim.fn.stdpath("data") .. "/mason"
local codelldb_adapter = first_existing({
  mason .. "/bin/codelldb",                                      -- Mason shim
  mason .. "/packages/codelldb/extension/adapter/codelldb",      -- Linux
  mason .. "/packages/codelldb/codelldb",                        -- alt
})

-- 🧰 LLDB fallback (system)
local lldb_vscode = first_existing({
  "lldb-vscode",                    -- in PATH
  "/usr/bin/lldb-vscode",
  "/usr/local/bin/lldb-vscode",
})

-- 🧲 Choose adapter (prefer CodeLLDB)
if codelldb_adapter then
  -- CodeLLDB (native adapter binary)
  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = codelldb_adapter,
      args = { "--port", "${port}" },
    },
  }
else
  -- lldb-vscode fallback
  if lldb_vscode then
    dap.adapters.lldb = {
      type = "executable",
      command = lldb_vscode,
      name = "lldb",
    }
  else
    vim.notify(
      "DAP: No CodeLLDB or lldb-vscode found. Install via :Mason -> codelldb",
      vim.log.levels.WARN
    )
  end
end

-- 🦀 Rust / 🦎 Zig / C / C++ configs (use whichever adapter we have)
local cpp_adapter = codelldb_adapter and "codelldb" or (lldb_vscode and "lldb" or nil)
if cpp_adapter then
  local function default_program()
    -- Try current cargo/zig/go build output or ask the user
    local cwd = vim.fn.getcwd()
    local guess = cwd .. "/target/debug/" .. vim.fn.fnamemodify(cwd, ":t")
    if vim.fn.filereadable(guess) == 1 then
      return guess
    end
    return vim.fn.input("Path to executable: ", guess, "file")
  end

  local base_cfg = {
    name = "▶️ Launch",
    type = cpp_adapter,
    request = "launch",
    program = default_program,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = function()
      local a = vim.fn.input("Args: ")
      return vim.fn.split(a, " ", true)
    end,
    runInTerminal = false,
  }

  dap.configurations.c = { base_cfg }
  dap.configurations.cpp = { base_cfg }
  dap.configurations.rust = { base_cfg }
  dap.configurations.zig = { base_cfg }
end

-- 🐍 Python (debugpy via Mason)
local debugpy = first_existing({
  mason .. "/packages/debugpy/venv/bin/python",
  vim.fn.exepath("python3"),
})
if debugpy then
  dap.adapters.python = {
    type = "executable",
    command = debugpy,
    args = { "-m", "debugpy.adapter" },
  }
  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "▶️ Launch file",
      program = "${file}",
      pythonPath = function()
        return vim.fn.exepath("python3")
      end,
    },
  }
end

-- 🐹 Go (dlv via Mason)
local dlv = first_existing({
  mason .. "/bin/dlv",
  vim.fn.exepath("dlv"),
})
if dlv then
  dap.adapters.go = function(callback, _)
    local stdout = vim.loop.new_pipe(false)
    local handle
    local port = 38697
    handle = vim.loop.spawn(dlv, {
      stdio = { nil, stdout },
      args = { "dap", "-l", "127.0.0.1:" .. port },
      detached = true,
    }, function(code)
      stdout:close()
      handle:close()
      if code ~= 0 then
        vim.notify("dlv exited with code " .. code, vim.log.levels.WARN)
      end
    end)
    stdout:read_start(function(err, _)
      assert(not err, err)
      callback({ type = "server", host = "127.0.0.1", port = port })
    end)
  end
  dap.configurations.go = {
    {
      type = "go",
      name = "▶️ Debug",
      request = "launch",
      program = "${file}",
    },
  }
end

-- 🎛️ Keymaps (yours, preserved)
vim.keymap.set("n", "<F5>",  "<cmd>lua require'dap'.continue()<CR>",      { desc = "Start Debug" })
vim.keymap.set("n", "<F10>", "<cmd>lua require'dap'.step_over()<CR>",     { desc = "Step Over" })
vim.keymap.set("n", "<F11>", "<cmd>lua require'dap'.step_into()<CR>",     { desc = "Step Into" })
vim.keymap.set("n", "<F12>", "<cmd>lua require'dap'.step_out()<CR>",      { desc = "Step Out" })
vim.keymap.set("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Toggle Breakpoint" })

-- 💅 Optional UI (install if you like pretty views)
-- require("dapui").setup()
-- vim.keymap.set("n", "<leader>du", function() require("dapui").toggle() end, { desc = "DAP UI" })

-- 🧪 Tips:
-- :Mason -> install: codelldb, debugpy, delve
-- For Rust: `cargo build` then F5 (it will guess target/debug/<crate>)
-- For Zig/C/C++: build your binary, then F5 and pick the path when prompted

