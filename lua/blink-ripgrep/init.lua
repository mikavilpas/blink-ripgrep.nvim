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

---@class blink-ripgrep.RgSource : blink.cmp.Source
---@field get_command fun(context: blink.cmp.Context, prefix: string): blink-ripgrep.RipgrepCommand | nil
---@field get_prefix fun(context: blink.cmp.Context): string
---@field get_completions? fun(self: blink.cmp.Source, context: blink.cmp.Context, callback: fun(response: blink.cmp.CompletionResponse | nil)):  nil
local RgSource = {}
RgSource.__index = RgSource

local highlight_ns_id = 0
pcall(function()
  highlight_ns_id = require("blink.cmp.config").appearance.highlight_ns
end)
vim.api.nvim_set_hl(0, "BlinkRipgrepMatch", { link = "Search", default = true })

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
}

-- set up default options so that they are used by the next search
---@param options? blink-ripgrep.Options
function RgSource.setup(options)
  RgSource.config = vim.tbl_deep_extend("force", RgSource.config, options or {})
end

---@param input_opts blink-ripgrep.Options
function RgSource.new(input_opts)
  local self = setmetatable({}, RgSource)

  RgSource.config =
    vim.tbl_deep_extend("force", RgSource.config, input_opts or {})

  self.get_prefix = RgSource.config.get_prefix
    or require("blink-ripgrep.search_prefix").default_get_prefix

  self.get_command = RgSource.config.get_command

  return self
end

---@param opts blink.cmp.SourceRenderDocumentationOpts
---@param file blink-ripgrep.RipgrepFile
---@param match blink-ripgrep.RipgrepMatch
local function render_item_documentation(opts, file, match)
  local bufnr = opts.window:get_buf()
  ---@type string[]
  local text = {
    file.relative_to_cwd,
    string.rep(
      "─",
      -- TODO account for the width of the scrollbar if it's visible
      opts.window:get_width()
        - opts.window:get_border_size().horizontal
        - 1
    ),
  }
  for _, data in ipairs(match.context_preview) do
    table.insert(text, data.text)
  end

  -- TODO add extmark highlighting for the divider line like in blink
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, text)

  local filetype = vim.filetype.match({ filename = file.relative_to_cwd })
  local parser_name = vim.treesitter.language.get_lang(filetype or "")
  local parser_installed = parser_name
    and pcall(function()
      return vim.treesitter.get_parser(nil, file.language, {})
    end)

  if
    not parser_installed and RgSource.config.fallback_to_regex_highlighting
  then
    -- Can't show highlighted text because no treesitter parser
    -- has been installed for this language.
    --
    -- Fall back to regex based highlighting that is bundled in
    -- neovim. It might not be perfect but it's much better
    -- than no colors at all
    vim.schedule(function()
      vim.api.nvim_set_option_value("filetype", file.language, { buf = bufnr })
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("syntax on")
      end)
    end)
  else
    assert(parser_name, "missing parser") -- lua-language-server should narrow this but can't
    require("blink.cmp.lib.window.docs").highlight_with_treesitter(
      bufnr,
      parser_name,
      2,
      #text
    )
  end

  require("blink-ripgrep.highlighting").highlight_match_in_doc_window(
    bufnr,
    match,
    highlight_ns_id
  )
end

function RgSource:get_completions(context, resolve)
  local prefix = self.get_prefix(context)

  if string.len(prefix) < RgSource.config.prefix_min_len then
    resolve()
    return
  end

  ---@type blink-ripgrep.RipgrepCommand | nil
  local cmd
  if self.get_command then
    -- custom command provided by the user
    cmd = self.get_command(context, prefix)
  else
    -- builtin default command
    local command_module = require("blink-ripgrep.ripgrep_command")
    cmd = command_module.get_command(prefix, RgSource.config)
  end

  if cmd == nil then
    if RgSource.config.debug then
      local debug = require("blink-ripgrep.debug")
      debug.add_debug_message("no command returned, skipping the search")
      debug.add_debug_invocation({ "ignored-because-no-command" })
    end

    resolve()
    return
  end

  if vim.tbl_contains(RgSource.config.ignore_paths, cmd.root) then
    if RgSource.config.debug then
      local debug = require("blink-ripgrep.debug")
      debug.add_debug_message("skipping search in ignored path" .. cmd.root)
      debug.add_debug_invocation({ "ignored", cmd.root })
    end
    resolve()

    return
  end

  if RgSource.config.debug then
    if cmd.debugify_for_shell then
      cmd:debugify_for_shell()
    end

    require("blink-ripgrep.visualization").flash_search_prefix(prefix)
    require("blink-ripgrep.debug").add_debug_invocation(cmd)
  end

  local rg = vim.system(cmd.command, nil, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        resolve()
        return
      end

      local lines = vim.split(result.stdout, "\n")
      local cwd = vim.uv.cwd() or ""

      local parsed = require("blink-ripgrep.ripgrep_parser").parse(
        lines,
        cwd,
        RgSource.config.context_size
      )
      local kinds = require("blink.cmp.types").CompletionItemKind

      ---@type table<string, blink.cmp.CompletionItem>
      local items = {}
      for _, file in pairs(parsed.files) do
        for _, match in pairs(file.matches) do
          local matchkey = match.match.text

          -- PERF: only register the match once - right now there is no useful
          -- way to display the same match multiple times
          if not items[matchkey] then
            local label = match.match.text
            local docstring = ""
            for _, line in ipairs(match.context_preview) do
              docstring = docstring .. line.text .. "\n"
            end

            ---@diagnostic disable-next-line: missing-fields
            items[matchkey] = {
              documentation = {
                kind = "markdown",
                value = docstring,
                render = function(opts)
                  render_item_documentation(opts, file, match)
                end,
              },
              source_id = "blink-ripgrep",
              kind = kinds.Text,
              label = label,
              insertText = matchkey,
            }
          end
        end
      end

      vim.schedule(function()
        resolve({
          is_incomplete_forward = false,
          is_incomplete_backward = false,
          items = vim.tbl_values(items),
          context = context,
        })
      end)
    end)
  end)

  return function()
    rg:kill(9)
    if RgSource.config.debug then
      require("blink-ripgrep.debug").add_debug_message(
        "killed previous invocation"
      )
    end
  end
end

return RgSource
