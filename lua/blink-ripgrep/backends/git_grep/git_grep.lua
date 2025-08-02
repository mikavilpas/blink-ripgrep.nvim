---@module "blink.cmp"

---@class blink-ripgrep.GitGrepBackend : blink-ripgrep.Backend
local GitGrepBackend = {}

GitGrepBackend.kind_name = "Git"
GitGrepBackend.hl_group_name = "BlinkCmpKindRipgrepGit"

-- https://cmp.saghen.dev/configuration/appearance.html#highlight-groups

---@param config blink-ripgrep.Options
function GitGrepBackend.new(config)
  local self = setmetatable({}, { __index = GitGrepBackend })
  self.config = config

  vim.schedule(function()
    local success, err = pcall(function()
      vim.api.nvim_set_hl(
        0,
        GitGrepBackend.hl_group_name,
        { link = "BlinkCmpKindText", default = true }
      )
    end)

    if not success then
      if config.debug then
        require("blink-ripgrep.debug").add_debug_message(
          "Failed to set highlight group: "
            .. GitGrepBackend.hl_group_name
            .. vim.inspect(err)
        )
      end
    end
  end)
  return self --[[@as blink-ripgrep.GitGrepBackend]]
end

function GitGrepBackend:get_matches(prefix, _, resolve)
  local command_module =
    require("blink-ripgrep.backends.git_grep.gitgrep_command")

  local cwd = assert(vim.uv.cwd())
  local cmd = command_module.get_command(prefix)

  if cmd == nil then
    if self.config.debug then
      local debug = require("blink-ripgrep.debug")
      debug.add_debug_message("no command returned, skipping the search")
      debug.add_debug_invocation({ "ignored-because-no-command" })
    end

    resolve()
    return
  end

  if self.config.debug then
    if cmd.debugify_for_shell then
      cmd:debugify_for_shell()
    end

    require("blink-ripgrep.visualization").flash_search_prefix(prefix)
    require("blink-ripgrep.debug").add_debug_invocation(cmd)
  end

  local gitgrep = vim.system(cmd.command, nil, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        if self.config.debug then
          require("blink-ripgrep.debug").add_debug_message(
            string.format(
              "GitGrepBackend: Failed to execute the command in %s, error code %d",
              vim.inspect(cwd),
              result.code
            )
          )
        end
        resolve()
        return
      end

      local lines = vim.split(result.stdout, "\n")
      local parser = require("blink-ripgrep.backends.git_grep.git_grep_parser")
      local output = parser.parse_output(prefix, lines, cwd)

      ---@type table<string, blink.cmp.CompletionItem>
      local items = {}
      for _, file in pairs(output.files) do
        for _, match in pairs(file.matches) do
          ---@diagnostic disable-next-line: missing-fields
          items[match.match.text] = {
            documentation = {
              kind = "markdown",
              draw = function(draw_opts)
                require("blink-ripgrep.documentation").render_item_documentation(
                  self.config,
                  draw_opts,
                  file,
                  match
                )
              end,
            },
            source_id = "blink-ripgrep",
            kind = 1,
            label = match.match.text,
            insertText = match.match.text,
          }

          if self.config.backend.customize_icon_highlight then
            items[match.match.text].kind_icon = "" -- git logo
            items[match.match.text].kind_hl = GitGrepBackend.hl_group_name
            items[match.match.text].kind_name = GitGrepBackend.kind_name
          end
        end
      end

      -- Had some issues with E550, might be fixed upstream nowadays. See
      -- https://github.com/mikavilpas/blink-ripgrep.nvim/issues/53
      vim.schedule(function()
        resolve({
          is_incomplete_forward = false,
          is_incomplete_backward = false,
          items = vim.tbl_values(items),
        })
      end)
    end)
  end)

  return function()
    gitgrep:kill(9)
    if self.config.debug then
      require("blink-ripgrep.debug").add_debug_message(
        "killed previous GitGrepBackend invocation"
      )
    end
  end
end

return GitGrepBackend
