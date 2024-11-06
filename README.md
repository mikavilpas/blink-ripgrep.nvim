# blink-ripgrep.nvim

Ripgrep source for [blink.cmp](https://github.com/Saghen/blink.cmp).

![blink-ripgrep search with a context preview](https://private-user-images.githubusercontent.com/300791/383677050-02edb59f-df32-4a0b-b3ea-1fb08973db88.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MzA5MTc1NTksIm5iZiI6MTczMDkxNzI1OSwicGF0aCI6Ii8zMDA3OTEvMzgzNjc3MDUwLTAyZWRiNTlmLWRmMzItNGEwYi1iM2VhLTFmYjA4OTczZGI4OC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQxMTA2JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MTEwNlQxODIwNTlaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1lM2IzZGFkYTg5ZmQxZDY5Njg0Yzk5Nzk0OGI3ODRlYzliNzM3NjlmYmUzYmMyYzc3ZWU5YjZhYjFkOTViZDJhJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.iB6q4GvHZx5QvxadCgzO0mOUR8u75MnTkB49Gtdx078)

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
        },
      },
    },
  },
})
```
