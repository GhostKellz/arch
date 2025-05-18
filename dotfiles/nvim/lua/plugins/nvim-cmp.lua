return {
  "hrsh7th/nvim-cmp",
  optional = true,
  dependencies = {
    {
      "zbirenbaum/copilot-cmp",
      opts = {},
      config = function(_, opts)
        local copilot_cmp = require("copilot_cmp")
        copilot_cmp.setup(opts)

        local ok, LazyLsp = pcall(require, "lazyvim.util")
        if ok and LazyLsp and LazyLsp.lsp and LazyLsp.lsp.on_attach then
          LazyLsp.lsp.on_attach(function()
            copilot_cmp._on_insert_enter({})
          end, "copilot")
        else
          vim.api.nvim_create_autocmd("InsertEnter", {
            callback = function()
              copilot_cmp._on_insert_enter({})
            end,
          })
        end
      end,
    },
  },
  opts = function(_, opts)
    opts.sources = opts.sources or {} -- ✅ Ensure it's a table
    table.insert(opts.sources, 1, {
      name = "copilot",
      group_index = 1,
      priority = 100,
    })
  end,
}
