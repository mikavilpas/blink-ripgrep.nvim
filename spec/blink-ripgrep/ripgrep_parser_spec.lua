local ripgrep_parser = require("blink-ripgrep.ripgrep_parser")
local assert = require("luassert")

describe("ripgrep_parser", function()
  local ripgrep_output_lines =
    vim.fn.readfile("spec/blink-ripgrep/rg-output.jsonl")

  it("can parse according to the expected schema", function()
    local result = ripgrep_parser.parse(ripgrep_output_lines, "/home/user", 1)
    local filename = "integration-tests/cypress/e2e/cmp-rg/basic_spec.cy.ts"

    assert.is_not_nil(result.files)
    assert.is_not_nil(result.files[filename])
    assert.is_truthy(#result.files[filename].lines == 0)
    assert.same(#result.files[filename].matches, 3)
    assert.same(result.files[filename].relative_to_cwd, filename)

    for _, file in ipairs(result.files) do
      assert.is_not_nil(file.language)
    end

    for _, submatch in ipairs(result.files[filename].matches) do
      assert.is_not_nil(submatch.match.text)
      assert.is_not_nil(submatch.context_preview)
      assert.is_not_nil(submatch.line_number)
      assert.is_not_nil(submatch.start_col)
      assert.is_not_nil(submatch.end_col)
    end
  end)

  describe("get_context_preview", function()
    it("can display context around the match", function()
      -- the happy path case
      local lines = {
        [1] = "line 1",
        [2] = "line 2",
        [3] = "line 3",
        [4] = "line 4",
        [5] = "line 5",
        [6] = "line 6",
        [7] = "line 7",
        [8] = "line 8",
        [9] = "line 9",
        [10] = "line 10",
      }

      local matched_line = 4
      local context_size = 1
      local result =
        ripgrep_parser.get_context_preview(lines, matched_line, context_size)

      assert.same(result, {
        "line 3",
        "line 4",
        "line 5",
      })
    end)

    it("does not crash if context_size is too large", function()
      local lines = { "line 1" }

      local matched_line = 1
      local context_size = 10
      local result =
        ripgrep_parser.get_context_preview(lines, matched_line, context_size)

      assert.same(result, lines)
    end)

    it("does not crash if context_size is too small", function()
      local lines = { "line 1" }

      local matched_line = 1
      local context_size = 0
      local result =
        ripgrep_parser.get_context_preview(lines, matched_line, context_size)

      assert.same(result, lines)
    end)

    it("can display context around the match at the end of the file", function()
      local lines = {
        [7] = "line 7",
        [8] = "line 8",
        [9] = "line 9",
        [10] = "line 10",
      }

      local matched_line = 9
      local context_size = 1
      local result =
        ripgrep_parser.get_context_preview(lines, matched_line, context_size)

      assert.same(result, {
        "line 8",
        "line 9",
        "line 10",
      })
    end)
  end)
end)
