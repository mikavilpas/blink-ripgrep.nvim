---@class blink-ripgrep.RipgrepBackend : blink-ripgrep.Backend
local RipgrepBackend = {}

RipgrepBackend.kind_name = "Ripgrep"
RipgrepBackend.hl_group_name = "BlinkCmpKindRipgrepRipgrep"

---@param config blink-ripgrep.Options
function RipgrepBackend.new(config)
  local self = setmetatable({}, { __index = RipgrepBackend })
  self.config = config

  vim.schedule(function()
    local success, err = pcall(function()
      -- https://cmp.saghen.dev/configuration/appearance.html#highlight-groups
      vim.api.nvim_set_hl(
        0,
        RipgrepBackend.hl_group_name,
        { link = "BlinkCmpKindText", default = true }
      )
    end)

    if not success then
      if self.config.debug then
        require("blink-ripgrep.debug").add_debug_message(
          "Failed to set highlight group: "
            .. RipgrepBackend.hl_group_name
            .. vim.inspect(err)
        )
      end
    end
  end)
  return self --[[@as blink-ripgrep.RipgrepBackend]]
end

function RipgrepBackend:get_matches(prefix, _, resolve)
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

  if vim.tbl_contains(self.config.backend.ripgrep.ignore_paths, cmd.root) then
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
          prefix,
          lines,
          cwd
        )
      local kinds = require("blink.cmp.types").CompletionItemKind

      ---@type table<string, blink.cmp.CompletionItem>
      local items = {}
      for _, file in pairs(parsed.files) do
        for _, match in pairs(file.matches) do
          local match_text = match.match.text

          -- PERF: only register the match once - right now there is no useful
          -- way to display the same match multiple times
          if not items[match_text] then
            ---@diagnostic disable-next-line: missing-fields
            items[match_text] = {
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
              kind = kinds.Text,
              label = match_text,
              insertText = match_text,
            }

            if self.config.backend.customize_icon_highlight then
              items[match_text].kind_icon = "" -- magnifying glass icon
              items[match_text].kind_hl = RipgrepBackend.hl_group_name
              items[match_text].kind_name = RipgrepBackend.kind_name
            end
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
    rg:kill(9)
    if self.config.debug then
      require("blink-ripgrep.debug").add_debug_message(
        "killed previous RipgrepBackend invocation"
      )
    end
  end
end

return RipgrepBackend
