local ripgrep_parser = require("blink-ripgrep.backends.ripgrep.ripgrep_parser")
local assert = require("luassert")

describe("ripgrep_parser", function()
  local ripgrep_output_lines =
    vim.fn.readfile("spec/blink-ripgrep/rg-output.jsonl")

  it("can parse according to the expected schema", function()
    local result = ripgrep_parser.parse(ripgrep_output_lines, "/home/user")
    local filename = "integration-tests/cypress/e2e/cmp-rg/basic_spec.cy.ts"

    assert.is_not_nil(result.files)
    assert.is_not_nil(result.files[filename])
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
end)
