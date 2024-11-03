-- This files defines how to initialize the test environment for the
-- integration tests. It should be executed before running the tests.

---@module "lazy"
---@module "blink-cmp-rg"
---@module "catppuccin"

-- DO NOT change the paths and don't remove the colorscheme
local root = vim.fn.fnamemodify("./.repro", ":p")
vim.env.LAZY_STDPATH = ".repro"

-- set stdpaths to use .repro
for _, name in ipairs({ "config", "data", "state", "cache" }) do
  vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=v11.14.1",
    lazyrepo,
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.rtp:prepend("../../")

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
    event = "VeryLazy",
    -- use a release tag to download pre-built binaries
    version = "v0.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        completion = {
          enabled_providers = {
            "ripgrep",
          },
        },
        providers = {
          ripgrep = {
            module = "blink-cmp-rg",
            name = "Ripgrep",
          },
        },
      },
      windows = {
        autocomplete = {
          max_height = 25,
        },
      },
    },
  },
  {
    "https://github.com/niuiic/blink-cmp-rg.nvim",
    -- for tests, always use the code from this repository
    dir = "../..",
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
}
require("lazy").setup({ spec = plugins })

vim.cmd.colorscheme("catppuccin-macchiato")
