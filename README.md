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
> By default, a project root is considered to be the nearest ancestor directory
> containing a `.git` directory. This can be configured with the
> `project_root_marker` option.

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
      default = {
        "buffer",
        "ripgrep",  -- 👈🏻 add "ripgrep" here
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

            -- Specifies how to find the root of the project where the ripgrep
            -- search will start from. Accepts the same options as the marker
            -- given to `:h vim.fs.root()` which offers many possibilities for
            -- configuration. If none can be found, defaults to Neovim's cwd.
            --
            -- Examples:
            -- - ".git" (default)
            -- - { ".git", "package.json", ".root" }
            project_root_marker = ".git",

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

            -- When a result is found for a file whose filetype does not have a
            -- treesitter parser installed, fall back to regex based highlighting
            -- that is bundled in Neovim.
            fallback_to_regex_highlighting = true,

            -- Show debug information in `:messages` that can help in
            -- diagnosing issues with the plugin.
            debug = false,
          },
          -- (optional) customize how the results are displayed. Many options
          -- are available - make sure your lua LSP is set up so you get
          -- autocompletion help
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              -- example: append a description to easily distinguish rg results
              item.labelDetails = {
                description = "(rg)",
              }
            end
            return items
          end,
        },
      },
      keymap = {
        -- 👇🏻👇🏻 (optional) add a keymap to invoke the search manually
        ["<c-g>"] = {
          function()
            -- invoke manually, requires blink >v0.8.0
            require("blink-cmp").show({ providers = { "ripgrep" } })
          end,
        },
      },
    },
  },
}
```

## 🏁 Performance

Generally performance is very good, but depending on the size of your project
and your computer's specifications, the search can be fast or slow. Here are a
few things you can do to improve performance:

- Set the `prefix_min_len` option to a larger number avoid starting a search for
  very short words. This can prevent unnecessary searches and improve
  performance.
- Use the `max_filesize` option to exclude large files from the search. This can
  prevent performance issues when searching in projects with large files.
- Disable automatic mode and use the manual mode to start the search only when
  you need it (see below).
- Set the `debug = true` option, which will log debug information to your
  `:messages` in Neovim. You can copy paste these commands to your terminal and
  try to figure out why the search is slow.
- Use ripgrep's extensive options to exclude/include files
  ([ripgrep docs](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#automatic-filtering))

  - ripgrep supports global as well project/directory specific ignore files. By
    default, it uses `.gitignore`, `.git/info/exclude`, `.ignore`, and
    `.rgignore` files.

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
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "ripgrep", -- 👈🏻 including this enables automatic search
      },
    }
  }
}
```

### Manual mode

If you prefer to start the search manually, you can use a keymap to invoke the
search. The example configuration includes a keymap that invokes the search when
pressing `Ctrl+g`.
