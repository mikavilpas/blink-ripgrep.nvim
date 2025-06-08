local toggles = {}

toggles.initialized = false

---@param config blink-ripgrep.Options
function toggles.init_once(config)
  if toggles.initialized then
    return
  end
  assert(config.toggles)

  local on_off_keymap = config.toggles.on_off
  local debug_keymap = config.toggles.debug

  if on_off_keymap then
    require("snacks.toggle")
      .new({
        id = "blink-ripgrep-manual-mode",
        name = "blink-ripgrep",
        get = function()
          return config.mode == "on"
        end,
        set = function(state)
          if state then
            config.mode = "on"
          else
            config.mode = "off"
          end
        end,
      })
      :map(on_off_keymap, { mode = { "n" } })
  end

  if debug_keymap then
    require("snacks.toggle")
      .new({
        id = "blink-ripgrep-debug",
        name = "blink-ripgrep-debug",
        get = function()
          return config.debug
        end,
        set = function(state)
          if state then
            config.debug = true
          else
            config.debug = false
          end
        end,
      })
      :map(debug_keymap, { mode = { "n" } })
  end

  toggles.initialized = true
end

return toggles
