-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.swapfile = false

-- install the following plugins
---@type LazySpec
local plugins = {
  {
    "saghen/blink.cmp",
    -- dir = "/Users/mikavilpas/git/blink.cmp/",

    event = "VeryLazy",
    -- use a release tag to download pre-built binaries
    -- https://github.com/Saghen/blink.cmp/releases
    version = "v0.8.2",

    -- to (locally) track nightly builds, use the following:
    -- version = false,

    -- to (locally) track nightly builds, use the following:
    -- dir = "/Users/mikavilpas/git/blink.cmp/",
    -- build = "cargo build --release",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        default = {
          "buffer",
          "ripgrep",
        },
        providers = {
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.labelDetails = {
                  description = "(rg)",
                }
              end
              return items
            end,
            ---@type blink-ripgrep.Options
            -- opts = {
            --   Keep the default options empty for tests, so that the we can
            --   make sure they are supported without specifying them
            -- },
          },
        },
      },
      ---@diagnostic disable-next-line: missing-fields
      completion = {
        ---@diagnostic disable-next-line: missing-fields
        documentation = {
          ---@diagnostic disable-next-line: missing-fields
          window = {
            desired_min_height = 30,
          },
          auto_show = true,
          auto_show_delay_ms = 0,
        },
        ---@diagnostic disable-next-line: missing-fields
        menu = {
          max_height = 25,
        },
      },
      keymap = {
        ["<c-g>"] = {
          function()
            require("blink-cmp").show({ providers = { "ripgrep" } })
          end,
        },
      },
    },
  },
  {
    "mikavilpas/blink-ripgrep.nvim",
    -- for tests, always use the code from this repository
    dir = "../..",
    config = function()
      -- customize the search highlighting (Search)
      local colors = require("catppuccin.palettes.macchiato")
      vim.api.nvim_set_hl(
        0,
        "BlinkRipgrepMatch",
        { fg = colors.base, bg = colors.mauve }
      )
    end,
  },

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
}
require("lazy").setup({ spec = plugins })

vim.cmd.colorscheme("catppuccin-macchiato")
