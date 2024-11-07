# blink-ripgrep.nvim

Ripgrep source for [blink.cmp](https://github.com/Saghen/blink.cmp).

![blink-ripgrep search with a context preview](./demo/screenshot.png)

Forked here (mikavilpas/blink.cmp) for my own use from
[niuiic/blink-cmp-rg.nvim](https://github.com/niuiic/blink-cmp-rg.nvim).

## 📦 Installation

The configuration of blink-ripgrep needs to be embedded into the configuration
for blink. Example for [lazy.nvim](https://lazy.folke.io/):

```lua
-- NOTE: you can leave out the type annotations if you don't want to use them

---@module "lazy"
---@type LazySpec
return {
  "saghen/blink.cmp",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    sources = {
      completion = {
        enabled_providers = {
          "lsp",
          "path",
          "snippets",
          "buffer",
          "ripgrep", -- 👈🏻 add "ripgrep"
        },
      },
      providers = {
        -- 👇🏻👇🏻 add the ripgrep provider
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          -- the options below are optional, some default values are shown
          ---@module "blink-ripgrep"
          ---@type blink-ripgrep.Options
          opts = {
            -- the minimum length of the current word to start searching
            -- (if the word is shorter than this, the search will not start)
            prefix_min_len = 3,
            -- The number of lines to show around each match in the preview window
            context_size = 5,
          },
        },
      },
    },
  },
}
```
