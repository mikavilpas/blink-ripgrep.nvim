---@class blink-ripgrep.Backend
local RipgrepBackend = {}

---@param config table
function RipgrepBackend.new(config)
  local self = setmetatable({}, { __index = RipgrepBackend })
  self.config = config
  return self --[[@as blink-ripgrep.Backend]]
end

function RipgrepBackend:get_matches(prefix, context, resolve)
  -- builtin default command
  local command_module =
    require("blink-ripgrep.backends.ripgrep.ripgrep_command")
  local cmd = command_module.get_command(prefix, self.config)

  if cmd == nil then
    if self.config.debug then
      local debug = require("blink-ripgrep.debug")
      debug.add_debug_message("no command returned, skipping the search")
      debug.add_debug_invocation({ "ignored-because-no-command" })
    end

    resolve()
    return
  end

  if vim.tbl_contains(self.config.ignore_paths, cmd.root) then
    if self.config.debug then
      local debug = require("blink-ripgrep.debug")
      debug.add_debug_message("skipping search in ignored path" .. cmd.root)
      debug.add_debug_invocation({ "ignored", cmd.root })
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

  local rg = vim.system(cmd.command, nil, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        resolve()
        return
      end

      local lines = vim.split(result.stdout, "\n")
      local cwd = vim.uv.cwd() or ""

      local parsed =
        require("blink-ripgrep.backends.ripgrep.ripgrep_parser").parse(
          lines,
          cwd
        )
      local kinds = require("blink.cmp.types").CompletionItemKind

      ---@type table<string, blink.cmp.CompletionItem>
      local items = {}
      for _, file in pairs(parsed.files) do
        for _, match in pairs(file.matches) do
          local matchkey = match.match.text

          -- PERF: only register the match once - right now there is no useful
          -- way to display the same match multiple times
          if not items[matchkey] then
            local label = match.match.text

            local draw_docs = function(draw_opts)
              require("blink-ripgrep.documentation").render_item_documentation(
                self.config,
                draw_opts,
                file,
                match
              )
            end

            ---@diagnostic disable-next-line: missing-fields
            items[matchkey] = {
              documentation = {
                kind = "markdown",
                draw = draw_docs,
                -- legacy, will be removed in a future release of blink
                -- https://github.com/Saghen/blink.cmp/issues/1113
                render = draw_docs,
              },
              source_id = "blink-ripgrep",
              kind = kinds.Text,
              label = label,
              insertText = matchkey,
            }
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
          context = context,
        })
      end)
    end)
  end)

  return function()
    rg:kill(9)
    if self.config.debug then
      require("blink-ripgrep.debug").add_debug_message(
        "killed previous invocation"
      )
    end
  end
end

return RipgrepBackend
