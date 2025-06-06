return {
  "nvim-lualine/lualine.nvim",
  optional = true,
  event = "VeryLazy",
  opts = function(_, opts)
    table.insert(
      opts.sections.lualine_x,
      2,
      require("lazyvim.util.lualine").status(require("lazyvim.config").icons.kinds.Copilot, function()
        local clients = vim.lsp.get_clients({ name = "copilot" })
        if #clients > 0 then
          local status = require("copilot.api").status.data.status
          return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
        end
      end)
    )
  end,
}
