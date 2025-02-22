local documentation = require("blink-ripgrep.documentation")
local assert = require("luassert")

---@param lines string[]
local function create_test_file(lines)
  local target_file_path = vim.fn.tempname()
  local file = io.open(target_file_path, "w") -- Open or create the file in write mode
  assert(file, "Failed to create file " .. target_file_path)
  if file then
    for _, line in ipairs(lines) do
      file:write(line .. "\n")
    end
    file:close()
  end
  local stat = vim.uv.fs_stat(target_file_path)
  assert(stat)
  assert(stat.type == "file")

  return target_file_path
end

describe("get_context_preview", function()
  it("can display context around the match", function()
    -- the happy path case
    local lines = {
      "line 1",
      "line 2",
      "line 3",
      "line 4",
      "line 5",
      "line 6",
      "line 7",
      "line 8",
      "line 9",
      "line 10",
    }
    local file = create_test_file(lines)

    local matched_line = 4
    local context_size = 1
    local result =
      documentation.get_match_context(context_size, matched_line, file)

    assert.same(result, {
      { line_number = 3, text = "line 3" },
      { line_number = 4, text = "line 4" },
      { line_number = 5, text = "line 5" },
    })
  end)

  it("does not crash if context_size is too large", function()
    local lines = {
      "line 1",
    }
    local file = create_test_file(lines)

    local matched_line = 1
    local context_size = 10
    local result =
      documentation.get_match_context(context_size, matched_line, file)

    assert.same(result, {
      { line_number = 1, text = "line 1" },
    })
  end)

  it("does not crash if context_size is too small", function()
    local lines = {
      "line 1",
    }
    local file = create_test_file(lines)

    local matched_line = 1
    local context_size = 0
    local result =
      documentation.get_match_context(context_size, matched_line, file)

    assert.same(result, {
      { line_number = 1, text = "line 1" },
    })
  end)

  it("can display context around the match at the end of the file", function()
    local lines = {
      "line 1",
      "line 2",
      "line 3",
      "line 4",
      "line 5",
      "line 6",
      "line 7",
      "line 8",
      "line 9",
      "line 10",
    }
    local file = create_test_file(lines)

    local matched_line = 9
    local context_size = 1
    local result =
      documentation.get_match_context(context_size, matched_line, file)

    assert.same(result, {
      { line_number = 8, text = "line 8" },
      { line_number = 9, text = "line 9" },
      { line_number = 10, text = "line 10" },
    })
  end)
end)
