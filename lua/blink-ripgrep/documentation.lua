---@module "blink-ripgrep.backends.git_grep.git_grep_parser"

local documentation = {}

local highlight_ns_id = 0
pcall(function()
  highlight_ns_id = require("blink.cmp.config").appearance.highlight_ns
end)
vim.api.nvim_set_hl(0, "BlinkRipgrepMatch", { link = "Search", default = true })

---@alias blink-ripgrep.NumberedLine {line_number: number, text: string}

---@param config blink-ripgrep.Options
---@param draw_opts blink.cmp.CompletionDocumentationDrawOpts
---@param file blink-ripgrep.RipgrepFile | blink-ripgrep.GitgrepFile
---@param match blink-ripgrep.Match | blink-ripgrep.Match
function documentation.render_item_documentation(config, draw_opts, file, match)
  local bufnr = draw_opts.window:get_buf()
  ---@type string[]
  local text = {
    file.path,
    string.rep(
      "─",
      -- TODO account for the width of the scrollbar if it's visible
      draw_opts.window:get_width()
        - draw_opts.window:get_border_size().horizontal
        - 1
    ),
  }

  local context_preview = documentation.get_match_context(
    config.backend.context_size,
    match.line_number,
    file.path
  )
  for _, line in ipairs(context_preview) do
    table.insert(text, line.text)
  end

  -- TODO add extmark highlighting for the divider line like in blink
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, text)

  local filetype = vim.filetype.match({ filename = file.path })
  local parser_name = vim.treesitter.language.get_lang(filetype or "")
  local parser_installed = parser_name
    and pcall(function()
      return vim.treesitter.get_parser(nil, file.language, {})
    end)

  if not parser_installed then
    if config.fallback_to_regex_highlighting then
      -- Can't show highlighted text because no treesitter parser
      -- has been installed for this language.
      --
      -- Fall back to regex based highlighting that is bundled in
      -- neovim. It might not be perfect but it's much better
      -- than no colors at all
      vim.schedule(function()
        vim.api.nvim_set_option_value(
          "filetype",
          file.language,
          { buf = bufnr }
        )
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("syntax on")
        end)
      end)
    end
  else
    assert(parser_name, "missing parser for " .. file.path) -- lua-language-server should narrow this but can't
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
    file,
    highlight_ns_id,
    context_preview,
    config.debug
  )
end

---@param context_size number
---@param match_line number # the line number the match was found on
---@param file_path string
function documentation.get_match_context(context_size, match_line, file_path)
  local start_line = math.max(1, match_line - context_size)
  local end_line = match_line + context_size

  local text = vim.fn.readfile(file_path, "", end_line)
  assert(type(text) == "table", "expected table from readfile")
  ---@cast text string[]

  ---@type blink-ripgrep.NumberedLine[]
  local context = {}
  for i, line in ipairs(text) do
    if i >= start_line then
      table.insert(context, {
        line_number = i,
        text = line,
      } --[[@as blink-ripgrep.NumberedLine]])
    end
  end

  return context
end

return documentation
