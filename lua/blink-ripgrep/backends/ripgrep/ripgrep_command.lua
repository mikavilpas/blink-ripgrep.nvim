---@class blink-ripgrep.RipgrepCommand
---@field command string[]
---@field root string
---@field additional_roots string[]
local RipgrepCommand = {}
RipgrepCommand.__index = RipgrepCommand

---@param prefix string
---@param options blink-ripgrep.Options
---@return blink-ripgrep.RipgrepCommand | nil, string? # The command to run, or an error message.
---@nodiscard
function RipgrepCommand.get_command(prefix, options)
  local cmd = {
    "rg",
    "--no-config",
    "--json",
    "--word-regexp",
    "--max-filesize=" .. options.max_filesize,
    options.search_casing,
  }

  for _, option in ipairs(options.additional_rg_options) do
    table.insert(cmd, option)
  end

  table.insert(cmd, "--")
  table.insert(cmd, prefix .. "[\\w_-]+")

  local root = vim.fs.root(0, options.project_root_marker)
  if options.project_root_fallback then
    root = root or vim.fn.getcwd()
  end
  if root == nil then
    return nil,
      "Could not find project root, and project_root_fallback is disabled."
  end

  table.insert(cmd, root)
  for _, additional_root in ipairs(options.additional_paths or {}) do
    table.insert(cmd, additional_root)
  end

  local command = setmetatable({
    command = cmd,
    root = root,
  }, RipgrepCommand)

  return command
end

-- Print the command to :messages for debugging purposes.
function RipgrepCommand:debugify_for_shell()
  -- print the command to :messages for hacky debugging, but don't show it
  -- in the ui so that it doesn't interrupt the user's work
  local debug_cmd = vim.deepcopy(self.command)
  assert(#debug_cmd >= 9)

  -- The pattern is not compatible with shell syntax, so escape it
  -- separately. The user should be able to copy paste it into their posix
  -- compatible terminal.
  local pattern = debug_cmd[8]
  assert(pattern)
  debug_cmd[8] = "'" .. pattern .. "'"

  assert(debug_cmd[9])
  debug_cmd[9] = vim.fn.fnameescape(debug_cmd[9])

  local things = table.concat(debug_cmd, " ")
  vim.api.nvim_exec2("echomsg " .. vim.fn.string(things), {})
end

return RipgrepCommand
