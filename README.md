# blink-ripgrep.nvim

Ripgrep source for [blink.cmp](https://github.com/Saghen/blink.cmp).

Forked here (mikavilpas/blink.cmp) for my own use from
[niuiic/blink-cmp-rg.nvim](https://github.com/niuiic/blink-cmp-rg.nvim).

```lua
-- NOTE: you can skip the type annotations if you don't want to use them
--
---@module "lazy"
---@module "blink-ripgrep"
---@type LazySpec
require("blink.cmp").setup({
  sources = {
    completion = {
      enabled_providers = { "lsp", "path", "snippets", "buffer", "ripgrep" }, -- add "ripgrep" here
    },
    providers = {
      -- other sources
      ripgrep = {
        module = "blink-ripgrep",
        name = "Ripgrep",
        -- options below are optional, these are the default values
        ---@type blink-ripgrep.Options
        opts = {
          -- blink.cmp get prefix in a different way,
          -- thus use `prefix_min_len` instead of `min_keyword_length`
          prefix_min_len = 3,
          get_command = function(context, prefix)
            return {
              "rg",
              "--no-config",
              "--json",
              "--word-regexp",
              "--ignore-case",
              "--",
              prefix .. "[\\w_-]+",
              vim.fs.root(0, ".git") or vim.fn.getcwd(),
            }
          end,
          get_prefix = function(context)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local line = vim.api.nvim_get_current_line()
            local prefix = line:sub(1, col):match("[%w_-]+$") or ""
            return prefix
          end,
        },
      },
    },
  },
})
```
