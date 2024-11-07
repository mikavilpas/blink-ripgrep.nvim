# blink-ripgrep.nvim

Ripgrep source for [blink.cmp](https://github.com/Saghen/blink.cmp).

![blink-ripgrep search with a context preview](./demo/screenshot.png)

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
          -- The number of lines to show around each match in the preview window
          context_size = 3
        },
      },
    },
  },
})
```
