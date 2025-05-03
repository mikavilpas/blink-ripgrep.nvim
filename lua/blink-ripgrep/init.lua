---@module "blink.cmp"

---@class blink-ripgrep.Options
---@field prefix_min_len? number # The minimum length of the current word to start searching (if the word is shorter than this, the search will not start)
---@field get_command? fun(context: blink.cmp.Context, prefix: string): blink-ripgrep.RipgrepCommand | nil # Changing this might break things - if you need some customization, please open an issue 🙂
---@field get_prefix? fun(context: blink.cmp.Context): string
---@field context_size? number # The number of lines to show around each match in the preview (documentation) window. For example, 5 means to show 5 lines before, then the match, and another 5 lines after the match.
---@field max_filesize? string # The maximum file size that ripgrep should include in its search. Examples: "1024" (bytes by default), "200K", "1M", "1G"
---@field search_casing? string # The casing to use for the search in a format that ripgrep accepts. Defaults to "--ignore-case". See `rg --help` for all the available options ripgrep supports, but you can try "--case-sensitive" or "--smart-case".
---@field additional_rg_options? string[] # (advanced) Any options you want to give to ripgrep. See `rg -h` for a list of all available options.
---@field fallback_to_regex_highlighting? boolean # (default: true) When a result is found for a file whose filetype does not have a treesitter parser installed, fall back to regex based highlighting that is bundled in Neovim.
---@field project_root_marker? unknown # Specifies how to find the root of the project where the ripgrep search will start from. Accepts the same options as the marker given to `:h vim.fs.root()` which offers many possibilities for configuration. Defaults to ".git".
---@field project_root_fallback? boolean # Enable fallback to neovim cwd if project_root_marker is not found. Default: `true`, which means to use the cwd.
---@field debug? boolean # Show debug information in `:messages` that can help in diagnosing issues with the plugin.
---@field ignore_paths? string[] # Absolute root paths where the rg command will not be executed. Usually you want to exclude paths using gitignore files or ripgrep specific ignore files, but this can be used to only ignore the paths in blink-ripgrep.nvim, maintaining the ability to use ripgrep for those paths on the command line. If you need to find out where the searches are executed, enable `debug` and look at `:messages`.
---@field additional_paths? string[] # Any additional paths to search in, in addition to the project root. This can be useful if you want to include dictionary files (/usr/share/dict/words), framework documentation, or any other reference material that is not available within the project root.
---@field mode? blink-ripgrep.Mode # The mode to use for showing completions. Defaults to automatically showing suggestions.
---@field future_features? blink-ripgrep.FutureFeatures # Features that are not yet stable and might change in the future. You can enable these to try them out beforehand, but be aware that they might change. Nothing is enabled by default.
---@field toggles? blink-ripgrep.ToggleKeymaps # Keymaps to toggle features on/off. This can be used to alter the behavior of the plugin without restarting Neovim. Nothing is enabled by default.

---@class blink-ripgrep.FutureFeatures
---@field backend? blink-ripgrep.BackendConfig

---@class blink-ripgrep.BackendConfig
---@field use? blink-ripgrep.BackendSelection # The backend to use for searching. Defaults to "ripgrep". "gitgrep" is available as a preview right now.

---@alias blink-ripgrep.BackendSelection
---| "gitgrep-or-ripgrep" # Use git grep for searching if in a git repository, otherwise use ripgrep.
---| "ripgrep" # Use ripgrep (rg) for searching. Works in most cases.
---| "gitgrep" # Use git grep for searching. This is faster but only works in git repositories.

---@class blink-ripgrep.ToggleKeymaps
---@field on_off? string # The keymap to toggle the plugin on and off from blink completion results. Example: "<leader>tg"

---@alias blink-ripgrep.Mode
---| "on" # Show completions when triggered by blink
---| "off" # Don't show completions at all

---@class blink-ripgrep.Backend # a backend defines how to get matches from the project's files for a search
---@field config blink-ripgrep.Options
---@field get_matches fun(self: blink-ripgrep.Backend, prefix: string, context: blink.cmp.Context, resolve: fun(response: blink.cmp.CompletionResponse | nil)): nil | fun(): nil # start a search process. Return an optional cancellation function that kills the search in case the user has canceled the completion.

---@class blink-ripgrep.RgSource : blink.cmp.Source
---@field get_command fun(context: blink.cmp.Context, prefix: string): blink-ripgrep.RipgrepCommand | nil
---@field get_prefix fun(context: blink.cmp.Context): string
---@field get_completions? fun(self: blink.cmp.Source, context: blink.cmp.Context, callback: fun(response: blink.cmp.CompletionResponse | nil)):  nil
local RgSource = {}
RgSource.__index = RgSource

---@type blink-ripgrep.Options
RgSource.config = {
  prefix_min_len = 3,
  context_size = 5,
  max_filesize = "1M",
  additional_rg_options = {},
  search_casing = "--ignore-case",
  fallback_to_regex_highlighting = true,
  project_root_marker = ".git",
  ignore_paths = {},
  project_root_fallback = true,
  additional_paths = {},
  toggles = {
    on_off = nil,
  },
  mode = "on",
  future_features = {
    backend = {
      use = "ripgrep",
    },
  },
}

-- set up default options so that they are used by the next search
---@param options? blink-ripgrep.Options
function RgSource.setup(options)
  RgSource.config = vim.tbl_deep_extend("force", RgSource.config, options or {})

  if not RgSource.config.toggles then
    if RgSource.config.debug then
      require("blink-ripgrep.debug").add_debug_message(
        "not enabling toggles because the feature is not enabled"
      )
    end

    return
  else
    require("blink-ripgrep.toggles").init_once(RgSource.config)
  end
end

---@param input_opts blink-ripgrep.Options
function RgSource.new(input_opts)
  local self = setmetatable({}, RgSource)

  RgSource.setup(input_opts)

  self.get_prefix = RgSource.config.get_prefix
    or require("blink-ripgrep.search_prefix").default_get_prefix

  self.get_command = RgSource.config.get_command

  return self
end

function RgSource:get_completions(context, resolve)
  if self.config.mode ~= "on" then
    if self.config.debug then
      local debug = require("blink-ripgrep.debug")
      debug.add_debug_message("mode is off, skipping the search")
      debug.add_debug_invocation({ "ignored-because-mode-is-off" })
    end
    resolve()
    return
  end

  ---@type blink-ripgrep.Backend | nil
  local backend
  do
    local be = (self.config.future_features or {}).backend.use

    if be == "gitgrep" then
      backend =
        require("blink-ripgrep.backends.git_grep.git_grep").new(RgSource.config)
    elseif be == "ripgrep" then
      backend =
        require("blink-ripgrep.backends.ripgrep.ripgrep").new(RgSource.config)
    elseif be == "gitgrep-or-ripgrep" then
      backend = require(
        "blink-ripgrep.backends.git_grep_or_ripgrep.git_grep_or_ripgrep"
      ).new(RgSource.config)
    end

    assert(backend, "Invalid backend " .. vim.inspect(be))
  end

  local prefix = self.get_prefix(context)

  if string.len(prefix) < self.config.prefix_min_len then
    resolve()
    return
  end

  local cancellation_function = backend:get_matches(prefix, context, resolve)
  return cancellation_function
end

return RgSource
