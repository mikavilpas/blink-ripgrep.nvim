---@module "blink-ripgrep.types.legacy_options"

local assert = require("luassert")
local blink_ripgrep = require("blink-ripgrep")

local original_config = vim.deepcopy(blink_ripgrep.config)

describe("reading the configuration", function()
  before_each(function()
    blink_ripgrep.config = original_config
  end)

  after_each(function()
    blink_ripgrep.config = original_config
  end)

  it("supports reading legacy options", function()
    -- before GitGrepBackend was introduced, the plugin only contained options
    -- for ripgrep at the top level of the configuration. After the
    -- introduction of GitGrepBackend, it was decided to split the options
    -- under a new structure that allowed different backends to have different
    -- options.
    --
    -- To make the transition easier for users, the legacy options are
    -- supported via this test. This allows for a non breaking change for some
    -- time until the user is ready to migrate to the new structure.
    ---@type blink-ripgrep.LegacyOptions
    local legacy_options = {
      additional_paths = { "/additional/path/" },
      additional_rg_options = { "--foo", "--bar" },
      context_size = 5,
      prefix_min_len = 3,
      mode = "on",
      project_root_fallback = true,
      fallback_to_regex_highlighting = true,
      ignore_paths = { "node_modules" },
      max_filesize = "3M",
      project_root_marker = ".git",
      search_casing = "--smart-case",
    }
    blink_ripgrep.setup(legacy_options)

    assert.same({
      use = "ripgrep",
      customize_icon_highlight = true,
      context_size = 5,
      ripgrep = {
        ignore_paths = { "node_modules" },
        project_root_fallback = true,
        additional_paths = { "/additional/path/" },
        search_casing = "--smart-case",
        max_filesize = "3M",
        additional_rg_options = { "--foo", "--bar" },
      },
    } --[[@as blink-ripgrep.BackendConfig]], blink_ripgrep.config.future_features.backend)
  end)
end)
