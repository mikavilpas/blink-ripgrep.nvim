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

  local final = {
    -- NOTE: 2024-11-28 the logic is documented in the README file, and
    -- should be kept up to date
    vim.fn.fnameescape(
      vim.fs.root(0, options.project_root_marker) or vim.fn.getcwd()
    ),
  }

  for _, option in ipairs(final) do
    table.insert(cmd, option)
  end

  return cmd
end

return RipgrepCommand
