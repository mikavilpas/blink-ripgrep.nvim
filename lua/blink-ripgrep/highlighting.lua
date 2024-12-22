local M = {}

---@param bufnr number
---@param match blink-ripgrep.RipgrepMatch
---@param highlight_ns_id number
function M.highlight_match_in_doc_window(bufnr, match, highlight_ns_id)
  ---@type number | nil
  local line_in_docs = nil
  for line, data in ipairs(match.context_preview) do
    if data.line_number == match.line_number then
      line_in_docs = line
      break
    end
  end

  assert(line_in_docs, "missing line in docs")

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
