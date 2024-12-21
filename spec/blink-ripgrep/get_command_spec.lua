local assert = require("luassert")
local blink_ripgrep = require("blink-ripgrep")

describe("get_command", function()
  local default_config = vim.tbl_deep_extend("error", {}, blink_ripgrep.config)

  before_each(function()
    blink_ripgrep.config = default_config
  end)

  it("allows passing additional_rg_options", function()
    local plugin = blink_ripgrep.new({
      additional_rg_options = { "--foo", "--bar" },
    })
    ---@diagnostic disable-next-line: missing-fields
    local cmd = plugin.get_command({}, "hello")

    -- don't compare the last item (the directory) as that changes depending on
    -- the test environment (such as individual developers' machines or ci)
    table.remove(cmd)
    assert.are_same(cmd, {
      "rg",
      "--no-config",
      "--json",
      "--context=5",
      "--word-regexp",
      "--max-filesize=1M",
      "--ignore-case",
      "--foo",
      "--bar",
      "--",
      "hello[\\w_-]+",
    })
  end)

  it("allows configuring the context size", function()
    local plugin = blink_ripgrep.new({ context_size = 9 })
    ---@diagnostic disable-next-line: missing-fields
    local cmd = plugin.get_command({}, "hello")

    table.remove(cmd)
    assert.are_same(cmd, {
      "rg",
      "--no-config",
      "--json",
      "--context=9",
      "--word-regexp",
      "--max-filesize=1M",
      "--ignore-case",
      "--",
      "hello[\\w_-]+",
    })
  end)

  it("allows configuring the max_filesize", function()
    local plugin = blink_ripgrep.new({ max_filesize = "2M" })
    ---@diagnostic disable-next-line: missing-fields
    local cmd = plugin.get_command({}, "hello")

    table.remove(cmd)
    assert.are_same(cmd, {
      "rg",
      "--no-config",
      "--json",
      "--context=5",
      "--word-regexp",
      "--max-filesize=2M",
      "--ignore-case",
      "--",
      "hello[\\w_-]+",
    })
  end)

  it("allows configuring the casing", function()
    local plugin = blink_ripgrep.new({ search_casing = "--smart-case" })
    ---@diagnostic disable-next-line: missing-fields
    local cmd = plugin.get_command({}, "hello")

    table.remove(cmd)
    assert.are_same(cmd, {
      "rg",
      "--no-config",
      "--json",
      "--context=5",
      "--word-regexp",
      "--max-filesize=1M",
      "--smart-case",
      "--",
      "hello[\\w_-]+",
    })
  end)
end)
