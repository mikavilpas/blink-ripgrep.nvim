local M = {}

---@param s string
---@param pattern string
local function find_all_matches_on_line(s, pattern)
  ---@type table<number, number>
  local indices = {}
  local init = 1

  while true do
    local start_idx, end_idx = string.find(s, pattern, init, true) -- true = plain match
    if not start_idx then
      break
    end
    table.insert(indices, { start_idx, end_idx })
    init = start_idx + 1 -- move past current match
  end

  return indices
end

--- In the blink documentation window, when the context for the match is being
--- shown, highlight the match so that the user can easily see where the match
--- is.
---@param bufnr number
---@param match blink-ripgrep.Match
---@param file blink-ripgrep.GitgrepFile | blink-ripgrep.RipgrepFile
---@param highlight_ns_id number
---@param context_preview blink-ripgrep.NumberedLine[]
---@param debug boolean
function M.highlight_match_in_doc_window(
  bufnr,
  match,
  file,
  highlight_ns_id,
  context_preview,
  debug
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

  local success = pcall(function()
    local highlights = {}

    if file.type == "gitgrep" then
      local text = context_preview[line_in_docs].text
      local match_indices = find_all_matches_on_line(text, match.match.text)

      for _, line_match in ipairs(match_indices) do
        table.insert(highlights, { line_match[1] - 1, line_match[2] })
      end
    else
      table.insert(highlights, { match.start_col, match.end_col })
    end

    for _, range in ipairs(highlights) do
      local start_col, end_col = unpack(range)

      vim.api.nvim_buf_set_extmark(
        bufnr,
        highlight_ns_id,
        line_in_docs + 1,
        start_col,
        {
          end_col = end_col,
          hl_group = "BlinkRipgrepMatch",
        }
      )
    end
  end)

  if debug and not success then
    require("blink-ripgrep.debug").add_debug_message(
      "Failed to highlight match in documentation window: "
        .. vim.inspect(match)
    )
  end
end

return M
