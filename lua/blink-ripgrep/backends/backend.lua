---@class blink-ripgrep.Backend # a backend defines how to get matches from the project's files for a search
---@field config blink-ripgrep.Options
local Backend = {}

--- start a search process. Return an optional cancellation function that kills
--- the search in case the user has canceled the completion.
---@param prefix string
---@param context blink.cmp.Context
---@param resolve fun(response?: blink.cmp.CompletionResponse)
---@return nil | fun(): nil
-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
function Backend:get_matches(prefix, context, resolve)
  -- This function should be overridden by the backend
  error("get_matches not implemented in backend")
end
