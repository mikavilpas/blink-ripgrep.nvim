local documentation = {}

local highlight_ns_id = 0
pcall(function()
  highlight_ns_id = require("blink.cmp.config").appearance.highlight_ns
end)
vim.api.nvim_set_hl(0, "BlinkRipgrepMatch", { link = "Search", default = true })

---@param config blink-ripgrep.Options
---@param draw_opts blink.cmp.CompletionDocumentationDrawOpts
---@param file blink-ripgrep.RipgrepFile
---@param match blink-ripgrep.RipgrepMatch
function documentation.render_item_documentation(config, draw_opts, file, match)
  local bufnr = draw_opts.window:get_buf()
  ---@type string[]
  local text = {
    file.relative_to_cwd,
    string.rep(
      "─",
      -- TODO account for the width of the scrollbar if it's visible
      draw_opts.window:get_width()
        - draw_opts.window:get_border_size().horizontal
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

  if not parser_installed and config.fallback_to_regex_highlighting then
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

return documentation
