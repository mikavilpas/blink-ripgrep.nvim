---@class blink-ripgrep.GitgrepCommand
---@field command string[]
local GitgrepCommand = {}
GitgrepCommand.__index = GitgrepCommand

--- Constructor.
---@param prefix string
---@return blink-ripgrep.GitgrepCommand | nil, string? # The command to run, or an error message.
---@nodiscard
function GitgrepCommand.get_command(prefix)
  local cmd = {
    "git",
    "grep",
    "--only-matching",
    "--ignore-case",
    "--perl-regexp",
    "--line-number",
    "--column",
    -- ignore binary files
    "-I",
    "--word-regexp",
    -- use a null byte as the separator. This avoids issues with whitespace
    -- being padded in the line and column number output.
    "--null",
    "--",
    prefix .. "[\\w_-]+",
  }

  -- TODO support additional options to git grep

  local command = setmetatable({
    command = cmd,
  }, GitgrepCommand)

  return command
end

-- Print the command to :messages for debugging purposes.
function GitgrepCommand:debugify_for_shell()
  -- print the command to :messages for hacky debugging, but don't show it
  -- in the ui so that it doesn't interrupt the user's work
  local debug_cmd = vim.deepcopy(self.command)
  assert(#debug_cmd == 12, "unexpected command length")

  -- The pattern is not compatible with shell syntax, so escape it
  -- separately. The user should be able to copy paste it into their posix
  -- compatible terminal.
  local pattern = debug_cmd[12]
  debug_cmd[12] = "'" .. pattern .. "'"

  local things = table.concat(debug_cmd, " ")
  vim.api.nvim_exec2("echomsg " .. vim.fn.string(things), {})
end

return GitgrepCommand
