local M = {}

--- In the blink documentation window, when the context for the match is being
--- shown, highlight the match so that the user can easily see where the match
--- is.
---@param bufnr number
---@param match blink-ripgrep.Match
---@param highlight_ns_id number
---@param context_preview blink-ripgrep.NumberedLine[]
function M.highlight_match_in_doc_window(
  bufnr,
  match,
  highlight_ns_id,
  context_preview
)
  ---@type number | nil
  local line_in_docs = nil
  for line, data in ipairs(context_preview) do
    if data.line_number == match.line_number then
      line_in_docs = line
      break
    end
  end

  assert(line_in_docs, "missing line in docs")

  -- highlight the word that matched in this context preview
  vim.api.nvim_buf_set_extmark(
    bufnr,
    highlight_ns_id,
    line_in_docs + 1,
    match.start_col,
    {
      end_col = match.end_col,
      hl_group = "BlinkRipgrepMatch",
    }
  )
end

return M
