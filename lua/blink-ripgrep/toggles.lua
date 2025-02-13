local toggles = {}

toggles.initialized = false

---@param config blink-ripgrep.Options
function toggles.init_once(config)
  if toggles.initialized then
    return
  end
  assert(config.future_features.toggles)

  local on_off = config.future_features.toggles.on_off
  if not on_off then
    return
  end

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
    :map(on_off, { mode = { "n" } })
  toggles.initialized = true
end

return toggles
