return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',  -- Required: new API is on main, not master
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup({
      install_dir = vim.fn.stdpath('data') .. '/site'
    })

    -- Install parsers (async, idempotent)
    require('nvim-treesitter').install({
      'lua', 'bash', 'json', 'yaml', 'markdown', 'vim', 'python', 'go',
      'rust', 'zig', 'toml', 'html', 'css', 'javascript', 'typescript'
    })

    -- Enable treesitter highlighting for supported filetypes
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

    -- Enable treesitter-based indentation
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

  end
}
