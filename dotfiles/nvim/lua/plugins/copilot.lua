return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = not vim.g.ai_cmp,
      auto_trigger = true,
      hide_during_completion = vim.g.ai_cmp,
      keymap = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
      },
    },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
      ["*"] = true,
    },
  },
  config = function(_, opts)
    require("copilot").setup(opts)

    -- Safe fallback for LazyVim users
    local ok, Lazy = pcall(require, "lazyvim.util")
    if ok and Lazy and Lazy.cmp and Lazy.cmp.actions then
      Lazy.cmp.actions.ai_accept = function()
        if require("copilot.suggestion").is_visible() then
          Lazy.create_undo()
          require("copilot.suggestion").accept()
          return true
        end
      end
    end
  end,
}
