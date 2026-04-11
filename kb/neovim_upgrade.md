# Neovim 0.12 Treesitter Migration

## The Problem

After upgrading to Neovim 0.12.x, treesitter breaks with errors like:

```
/usr/share/nvim/runtime/lua/vim/treesitter.lua:196: attempt to call method 'range' (a nil value)
```

Or:

```
attempt to call field 'install' (a nil value)
```

This breaks syntax highlighting, hover windows, and other treesitter-dependent features.

## Root Cause

The `nvim-treesitter` plugin was completely rewritten for Neovim 0.12. The rewrite lives on the `main` branch, while the old code remains frozen on `master`. Most plugin managers default to `master`, causing the mismatch.

The repository was archived on April 3, 2026 after users kept demanding backward compatibility.

## Requirements for Neovim 0.12

- Neovim 0.12.0+
- `tree-sitter-cli` 0.26.1+ (via package manager, **not npm**)
- `tar` and `curl` in PATH
- A C compiler (gcc, clang)

### Arch Linux

```bash
sudo pacman -S tree-sitter tree-sitter-cli
# Verify version
tree-sitter --version  # needs 0.26.1+
```

If pacman version is outdated, use AUR:

```bash
yay -S tree-sitter-cli-git
```

## Migration Steps

### 1. Update Plugin Config to Use `main` Branch

The critical fix is specifying `branch = 'main'` in your plugin spec.

**Old config (broken):**

```lua
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = { "lua", "bash", "python" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
}
```

**New config (working):**

```lua
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',  -- REQUIRED: new API is on main, not master
  lazy = false,     -- Plugin does not support lazy-loading
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

    -- Enable treesitter highlighting
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

    -- Enable treesitter indentation
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- Enable treesitter folding
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo[0][0].foldmethod = 'expr'
      end,
    })
  end
}
```

### 2. Clean Old Installation

```bash
# Remove old plugin
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter

# Clear parser cache
rm -rf ~/.local/share/nvim/site/parser
rm -rf ~/.local/share/nvim/site/parser-info
rm -rf ~/.local/share/nvim/site/queries
```

### 3. Reinstall

```bash
# Sync plugins (Lazy.nvim)
nvim --headless "+Lazy! sync" +qa

# Install parsers
nvim --headless -c "TSUpdate" -c "sleep 30" -c "qa"
```

### 4. Verify

```vim
:checkhealth nvim-treesitter
```

Should show all green checkmarks for requirements and installed parsers.

## API Changes Summary

| Old API (master) | New API (main) |
|------------------|----------------|
| `require('nvim-treesitter.configs').setup({...})` | `require('nvim-treesitter').setup({...})` |
| `ensure_installed = {...}` | `require('nvim-treesitter').install({...})` |
| `highlight = { enable = true }` | `vim.treesitter.start()` in autocmd |
| `indent = { enable = true }` | `vim.bo.indentexpr = "..."` in autocmd |
| `auto_install = true` | Not available - install explicitly |

## Common Issues

### "Parser not available for language X"

Parser needs to be installed:

```vim
:lua require('nvim-treesitter').install({'language_name'})
```

### Highlighting not working for some filetypes

The `pcall(vim.treesitter.start)` silently fails for filetypes without parsers. Install the missing parser or check `:TSInstall` for available languages.

### Old treesitter install still being picked up

If using `vim.pack` or migrated plugin managers, ensure no old `nvim-treesitter` exists in other plugin directories:

```bash
find ~/.local/share/nvim -name "nvim-treesitter" -type d
```

Remove any duplicates.

### Nix users: outdated tree-sitter-cli

The CLI on unstable channel may be outdated. Use tree-sitter repo as flake input with an overlay to build from latest source.

## Related Plugins

If using `nvim-treesitter-textobjects`, it also needs the `main` branch:

```lua
{
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
}
```

## References

- [nvim-treesitter README](https://github.com/nvim-treesitter/nvim-treesitter)
- [Reddit: Treesitter issues after migrating to 0.12.0](https://www.reddit.com/r/neovim/comments/1s9y00d/for_anyone_experiencing_treesitter_issues_after/)
- [Migration Guide by qu8n](https://www.qu8n.com/posts/treesitter-migration-guide-for-nvim-0-12)
- [Lobsters: nvim-treesitter archived](https://lobste.rs/s/jr4acs/nvim_treesitter_repository_was_archived)
