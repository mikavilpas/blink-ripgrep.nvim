local RipgrepCommand = {}

---@param prefix string
---@param options blink-ripgrep.Options
function RipgrepCommand.get_command(prefix, options)
  local cmd = {
    "rg",
    "--no-config",
    "--json",
    "--context=" .. options.context_size,
    "--word-regexp",
    "--max-filesize=" .. options.max_filesize,
    options.search_casing,
  }

  for _, option in ipairs(options.additional_rg_options) do
    table.insert(cmd, option)
  end

  table.insert(cmd, "--")
  table.insert(cmd, prefix .. "[\\w_-]+")

  local root = (vim.fs.root(0, options.project_root_marker))
  if root == nil then
    if options.project_root_fallback then
      root = vim.fn.getcwd()
    else
      -- don't supply a ripgrep command
      return nil
    end
  end
  table.insert(cmd, root)

  return cmd
end

-- Change the command from `get_command` to a string that can be executed in a
-- shell
---@param cmd string[]
function RipgrepCommand.debugify_for_shell(cmd)
  -- print the command to :messages for hacky debugging, but don't show it
  -- in the ui so that it doesn't interrupt the user's work
  local debug_cmd = vim.deepcopy(cmd)

  -- The pattern is not compatible with shell syntax, so escape it
  -- separately. The user should be able to copy paste it into their posix
  -- compatible terminal.
  local pattern = debug_cmd[9]
  debug_cmd[9] = "'" .. pattern .. "'"
  debug_cmd[10] = vim.fn.fnameescape(debug_cmd[10])

  local things = table.concat(debug_cmd, " ")
  vim.api.nvim_exec2("echomsg " .. vim.fn.string(things), {})
end

return RipgrepCommand
