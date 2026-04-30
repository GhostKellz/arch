return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  init = function()
    vim.g.opencode_opts = {
      server = {
        toggle = function()
          require("opencode.terminal").toggle("opencode --port", {
            split = "below",
            height = math.floor(vim.o.lines * 0.3),
          })
        end,
        start = function()
          require("opencode.terminal").open("opencode --port", {
            split = "below",
            height = math.floor(vim.o.lines * 0.3),
          })
        end,
        stop = function()
          require("opencode.terminal").close()
        end,
      },
    }
    vim.o.autoread = true
    vim.api.nvim_create_user_command("OpenCode", function()
      require("opencode").toggle()
    end, { desc = "Toggle OpenCode" })
  end,
  keys = {
    { "<leader>ao", function() require("opencode").toggle() end, desc = "Toggle OpenCode" },
    { "<leader>os", function() require("opencode").select() end, desc = "OpenCode Select Action" },
    { "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, desc = "OpenCode Ask", mode = { "n", "x" } },
    { "<leader>op", function() require("opencode").prompt("@this") end, desc = "OpenCode Add Context", mode = { "n", "x" } },
  },
}
