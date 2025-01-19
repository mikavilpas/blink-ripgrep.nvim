local M = {}

-- selene: allow(global_usage)
_G.blink_ripgrep_invocations = _G.blink_ripgrep_invocations or {}

--- Add the invocation to the global list of invocations so that they can be
--- asserted against in tests. Otherwise the tests cannot reliably verify that
--- something did or not happen.
---@param invocation unknown
function M.add_debug_invocation(invocation)
  -- selene: allow(global_usage)
  table.insert(_G.blink_ripgrep_invocations, invocation)
end

--- Variant of vim.notify that does not display the messages to the user until
--- they execute `:messages`. Displaying the messages might disturb the user or
--- interfere with tests.
---@param message string
function M.add_debug_message(message)
  vim.api.nvim_exec2(string.format("echomsg '%s'", message), {})
end

return M
