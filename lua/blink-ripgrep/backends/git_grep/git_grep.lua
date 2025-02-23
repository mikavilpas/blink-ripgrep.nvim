---@module "blink.cmp"

---@class blink-ripgrep.GitGrepBackend : blink-ripgrep.Backend
local GitGrepBackend = {}

---@param config table
function GitGrepBackend.new(config)
  local self = setmetatable({}, { __index = GitGrepBackend })
  self.config = config
  return self --[[@as blink-ripgrep.GitGrepBackend]]
end

function GitGrepBackend:get_matches(prefix, context, resolve)
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
        resolve()
        return
      end

      local lines = vim.split(result.stdout, "\n")
      local parser = require("blink-ripgrep.backends.git_grep.git_grep_parser")
      local output = parser.parse_output(lines, cwd)

      ---@type table<string, blink.cmp.CompletionItem>
      local items = {}
      for _, file in pairs(output.files) do
        for _, match in pairs(file.matches) do
          local draw_docs = function(draw_opts)
            require("blink-ripgrep.documentation").render_item_documentation(
              self.config,
              draw_opts,
              file,
              match
            )
          end

          ---@diagnostic disable-next-line: missing-fields
          items[match.match.text] = {
            documentation = {
              kind = "markdown",
              draw = draw_docs,
              -- legacy, will be removed in a future release of blink
              -- https://github.com/Saghen/blink.cmp/issues/1113
              render = draw_docs,
            },
            source_id = "blink-ripgrep",
            kind = 1,
            label = match.match.text,
            insertText = match.match.text,
          }
        end
      end

      -- Had some issues with E550, might be fixed upstream nowadays. See
      -- https://github.com/mikavilpas/blink-ripgrep.nvim/issues/53
      vim.schedule(function()
        resolve({
          is_incomplete_forward = false,
          is_incomplete_backward = false,
          items = vim.tbl_values(items),
          context = context,
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
