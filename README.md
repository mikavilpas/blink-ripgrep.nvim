# blink-ripgrep.nvim

<a href="https://dotfyle.com/plugins/mikavilpas/blink-ripgrep.nvim">
  <img
    src="https://dotfyle.com/plugins/mikavilpas/blink-ripgrep.nvim/shield?style=flat-square"
    alt="shield image for plugin usage"
  />
</a>

Ripgrep source for the [blink.cmp](https://github.com/Saghen/blink.cmp)
completion plugin. Adding it to your configuration offers matching words from
your entire project as completions. This can reduce the chance of typos as well
as repetitive typing.

> [!NOTE]
>
> A project root is considered to be the nearest ancestor directory containing a
> `.git` directory. If none can be found, Neovim's current working directory is
> used.

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
  dependencies = {
    "mikavilpas/blink-ripgrep.nvim",
    -- 👆🏻👆🏻 add the dependency here
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    sources = {
      completion = {
        enabled_providers = {
          -- NOTE: blink >v0.7.6 has moved
          -- `sources.completion.enabled_providers` to `sources.default`
          "lsp",
          "path",
          "snippets",
          "buffer",
          "ripgrep", -- 👈🏻 add "ripgrep" here
        },
      },
      providers = {
        -- 👇🏻👇🏻 add the ripgrep provider config below
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          -- the options below are optional, some default values are shown
          ---@module "blink-ripgrep"
          ---@type blink-ripgrep.Options
          opts = {
            -- For many options, see `rg --help` for an exact description of
            -- the values that ripgrep expects.

            -- the minimum length of the current word to start searching
            -- (if the word is shorter than this, the search will not start)
            prefix_min_len = 3,

            -- The number of lines to show around each match in the preview
            -- (documentation) window. For example, 5 means to show 5 lines
            -- before, then the match, and another 5 lines after the match.
            context_size = 5,

            -- The maximum file size of a file that ripgrep should include in
            -- its search. Useful when your project contains large files that
            -- might cause performance issues.
            -- Examples:
            -- "1024" (bytes by default), "200K", "1M", "1G", which will
            -- exclude files larger than that size.
            max_filesize = "1M",

            -- The casing to use for the search in a format that ripgrep
            -- accepts. Defaults to "--ignore-case". See `rg --help` for all the
            -- available options ripgrep supports, but you can try
            -- "--case-sensitive" or "--smart-case".
            search_casing = "--ignore-case",

            -- (advanced) Any additional options you want to give to ripgrep.
            -- See `rg -h` for a list of all available options. Might be
            -- helpful in adjusting performance in specific situations.
            -- If you have an idea for a default, please open an issue!
            --
            -- Not everything will work (obviously).
            additional_rg_options = {},
          },
        },
      },
      keymap = {
        ["<c-g>"] = {
          function()
            -- invoke manually, requires blink >v0.7.6
            require("blink-cmp").show({ sources = { "ripgrep" } })
          end,
        },
      },
    },
  },
}
```

## 🏁 Performance

Depending on the size of your project and your computer's specifications, the
search can be fast or slow. Here are a few things you can do to improve
performance:

- Set the `prefix_min_len` option to a larger number avoid starting a search for
  very short words. This can prevent unnecessary searches and improve
  performance.
- Use the `max_filesize` option to exclude large files from the search. This can
  prevent performance issues when searching in projects with large files.
- If you still experience performance issues, please open an issue for
  discussion.

### Automatic mode

In this mode, the search starts automatically when typing a word that is at
least `prefix_min_len` in length.

This is enabled by including the `ripgrep` provider in blink-cmp's providers:

```lua
return {
  -- ... other configuration
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    sources = {
      completion = {
        enabled_providers = {
          -- NOTE: blink >v0.7.6 has moved
          -- `sources.completion.enabled_providers` to `sources.default`
          "lsp",
          "path",
          "snippets",
          "buffer",
          "ripgrep", -- 👈🏻 including this enables automatic search
        },
      },
    }
  }
}
```

### Manual mode

If you prefer to start the search manually, you can use a keymap to invoke the
search. The example configuration includes a keymap that invokes the search when
pressing `Ctrl+g`.
