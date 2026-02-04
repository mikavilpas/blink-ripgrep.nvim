-- renovate: datasource=github-releases depName=folke/lazy.nvim
local lazy_version = "v11.17.5"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=" .. lazy_version,
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

local config_dir =
  assert(os.getenv("XDG_CONFIG_HOME"), "XDG_CONFIG_HOME not set")
local repo_root =
  vim.fs.abspath(vim.fs.joinpath(config_dir, "..", "..", "..", "..", ".."))

-- install the following plugins
---@type LazySpec
local plugins = {
  {
    "saghen/blink.cmp",
    -- dir = "/Users/mikavilpas/git/blink.cmp/",

    event = "VeryLazy",
    -- use a release tag to download pre-built binaries
    -- https://github.com/Saghen/blink.cmp/releases
    -- renovate: datasource=github-releases depName=saghen/blink.cmp
    version = "v1.9.1",

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
            opts = {
              debug = true,
              toggles = {
                on_off = "<leader>tg",
                debug = "<leader>td",
              },
              backend = {
                customize_icon_highlight = false,
              },
            },
          },
        },
      },
      fuzzy = {
        prebuilt_binaries = {
          ignore_version_mismatch = true,
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

          draw = {
            columns = {
              { "kind_icon", "label", "label_description", gap = 1 },
              { "kind", gap = 6 },
              { "source_name", gap = 1 },
            },
          },
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
    dir = repo_root,
    config = function()
      -- customize the search highlighting (Search)
      local colors = require("catppuccin.palettes.macchiato")
      vim.api.nvim_set_hl(
        0,
        "BlinkRipgrepMatch",
        { fg = colors.base, bg = colors.mauve }
      )

      vim.api.nvim_set_hl(
        0,
        "BlinkRipgrepSearchPrefix",
        { fg = colors.base, bg = colors.flamingo }
      )
    end,
  },

  -- renovate: datasource=github-releases depName=folke/snacks.nvim
  { "folke/snacks.nvim", version = "v2.30.0" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    -- renovate: datasource=github-releases depName=catppuccin/nvim
    version = "v1.11.0",
  },
}
require("lazy").setup({ spec = plugins })

vim.cmd.colorscheme("catppuccin-macchiato")
