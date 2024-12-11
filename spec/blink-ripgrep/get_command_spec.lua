local assert = require("luassert")
local blink_ripgrep = require("blink-ripgrep")

describe("get_command", function()
  it("allows passing additional_rg_options", function()
    local plugin = blink_ripgrep.new({
      additional_rg_options = { "--foo", "--bar" },
    })
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
end)
