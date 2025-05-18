return {
  "zbirenbaum/copilot-cmp",
  dependencies = { "hrsh7th/nvim-cmp" },
  opts = {},
  config = function(_, opts)
    local copilot_cmp = require("copilot_cmp")
    copilot_cmp.setup(opts or {})

    local ok, LazyLsp = pcall(function()
      return require("lazyvim.util").lsp
    end)

    if ok and LazyLsp and LazyLsp.on_attach then
      LazyLsp.on_attach(function()
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
}
