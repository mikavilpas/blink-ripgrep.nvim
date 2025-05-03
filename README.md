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

    -- optional dependency used for toggling features on/off
    -- https://github.com/folke/snacks.nvim
    "folke/snacks.nvim",
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    sources = {
      default = {
        "buffer",
        "ripgrep", -- 👈🏻 add "ripgrep" here
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

            -- Enable fallback to neovim cwd if project_root_marker is not
            -- found. Default: `true`, which means to use the cwd.
            project_root_fallback = true,

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

            -- Absolute root paths where the rg command will not be executed.
            -- Usually you want to exclude paths using gitignore files or
            -- ripgrep specific ignore files, but this can be used to only
            -- ignore the paths in blink-ripgrep.nvim, maintaining the ability
            -- to use ripgrep for those paths on the command line. If you need
            -- to find out where the searches are executed, enable `debug` and
            -- look at `:messages`.
            ignore_paths = {},

            -- Any additional paths to search in, in addition to the project
            -- root. This can be useful if you want to include dictionary files
            -- (/usr/share/dict/words), framework documentation, or any other
            -- reference material that is not available within the project
            -- root.
            additional_paths = {},

            -- Keymaps to toggle features on/off. This can be used to alter
            -- the behavior of the plugin without restarting Neovim. Nothing
            -- is enabled by default. Requires folke/snacks.nvim.
            toggles = {
              -- The keymap to toggle the plugin on and off from blink
              -- completion results. Example: "<leader>tg"
              on_off = nil,
            },

            -- Features that are not yet stable and might change in the future.
            -- You can enable these to try them out beforehand, but be aware
            -- that they might change. Nothing is enabled by default.
            future_features = {
              backend = {
                -- The backend to use for searching. Defaults to "ripgrep".
                -- Available options:
                -- - "ripgrep", always use ripgrep
                -- - "gitgrep", always use git grep
                -- - "gitgrep-or-ripgrep", use git grep if possible, otherwise
                --   ripgrep
                use = "ripgrep",
              },
            },

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

## 🤔 How it works

When you enter insert mode and start typing a word, blink triggers a search with
blink-ripgrep. Only one search is done to save resources. After getting the
results, the following keys are used to filter the results.

In this demo (using the option `debug = true` above), we can see the search
starting when the word flashes with a different color. Notice how the word only
flashes once:

<!-- TODO add a better demo -->

<https://github.com/user-attachments/assets/0651ad24-0403-4ab9-81ff-59b152283593>

This is described in much more detail in blink's
[architecture documentation](https://cmp.saghen.dev/development/architecture.html).

## 🏁 Performance

Generally performance is very good, but depending on the size of your project
and your computer's specifications, the search can be fast or slow. Here are a
few things you can do to improve performance:

- Use the experimental git grep backend by setting the
  `future_features.backend = "gitgrep"` option (see above). This can be faster
  in medium/large projects.
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

  - ripgrep supports global as well as project/directory specific ignore files.
    By default, it uses `.gitignore`, `.git/info/exclude`, `.ignore`, and
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
