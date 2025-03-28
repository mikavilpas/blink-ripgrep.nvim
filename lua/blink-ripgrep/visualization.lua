local visualization = {}

local ns_id = vim.api.nvim_create_namespace("blink_ripgrep_debug")

vim.api.nvim_set_hl(
  0,
  "BlinkRipgrepSearchPrefix",
  { link = "Search", default = true }
)

-- Temporarily flash the search prefix so that the user can see what searches
-- are being performed. Should be called in debug mode only.
---@param prefix string
function visualization.flash_search_prefix(prefix)
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  local cursor = vim.api.nvim_win_get_cursor(0)

  local hlstart = cursor[2] - #prefix
  local hlend = cursor[2]
  ---@diagnostic disable-next-line: deprecated
  vim.api.nvim_buf_add_highlight(
    0,
    ns_id,
    "BlinkRipgrepSearchPrefix",
    cursor[1] - 1,
    hlstart,
    hlend
  )

  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  end, 500)
end

return visualization
