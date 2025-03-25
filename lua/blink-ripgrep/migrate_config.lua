local M = {}

---@param options blink-ripgrep.Options
---@param new_options? blink-ripgrep.Options | blink-ripgrep.LegacyOptions
function M.migrate_config(options, new_options)
  options = vim.tbl_extend("force", {
    backend = {
      ripgrep = {},
      gitgrep = {},
    },
  } --[[@as blink-ripgrep.Options]], options)

  ---@type table<string,string>
  local migrations = {}

  ---@type blink-ripgrep.LegacyOptions | {}
  ---@diagnostic disable-next-line: assign-type-mismatch
  local legacy_options = new_options

  if legacy_options.ignore_paths ~= nil then
    options.backend.ripgrep.ignore_paths = legacy_options.ignore_paths
    migrations.ignore_paths = "backend.ripgrep.ignore_paths"
  end

  if legacy_options.project_root_fallback ~= nil then
    options.backend.ripgrep.project_root_fallback =
      legacy_options.project_root_fallback
    migrations.project_root_fallback = "backend.ripgrep.project_root_fallback"
  end

  if legacy_options.additional_paths ~= nil then
    options.backend.ripgrep.additional_paths = legacy_options.additional_paths
    migrations.additional_paths = "backend.ripgrep.additional_paths"
  end

  if legacy_options.search_casing ~= nil then
    options.backend.ripgrep.search_casing = legacy_options.search_casing
    migrations.search_casing = "backend.ripgrep.search_casing"
  end

  if legacy_options.max_filesize ~= nil then
    options.backend.ripgrep.max_filesize = legacy_options.max_filesize
    migrations.max_filesize = "backend.ripgrep.max_filesize"
  end

  if legacy_options.additional_rg_options ~= nil then
    options.backend.ripgrep.additional_rg_options =
      legacy_options.additional_rg_options
    migrations.additional_rg_options = "backend.ripgrep.additional_rg_options"
  end

  if legacy_options.context_size ~= nil then
    options.backend.context_size = legacy_options.context_size
    migrations.context_size = "backend.context_size"
  end

  if
    legacy_options.future_features and legacy_options.future_features.backend
  then
    if
      legacy_options.future_features.backend.customize_icon_highlight ~= nil
    then
      options.backend.customize_icon_highlight =
        legacy_options.future_features.backend.customize_icon_highlight
      migrations["future_features.backend.customize_icon_highlight"] =
        "backend.customize_icon_highlight"
    end

    if legacy_options.future_features.backend.use ~= nil then
      options.backend.use = legacy_options.future_features.backend.use
      migrations["future_features.backend.use"] = "backend.use"
    end
  end

  return options, migrations
end

return M
