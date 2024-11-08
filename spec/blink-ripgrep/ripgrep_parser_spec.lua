local ripgrep_parser = require("blink-ripgrep.ripgrep_parser")
local assert = require("luassert")

describe("ripgrep_parser", function()
  local ripgrep_output_lines =
    vim.fn.readfile("spec/blink-ripgrep/rg-output.jsonl")

  it("can parse according to the expected schema", function()
    local result = ripgrep_parser.parse(ripgrep_output_lines, "/home/user")
    local filename = "integration-tests/cypress/e2e/cmp-rg/basic_spec.cy.ts"

    assert.is_not_nil(result.files)
    assert.is_not_nil(result.files[filename])
    assert.is_truthy(#result.files[filename].lines > 19)
    assert.same(#result.files[filename].submatches, 3)
    assert.same(result.files[filename].relative_to_cwd, filename)

    for _, submatch in ipairs(result.files[filename].submatches) do
      assert.is_not_nil(submatch.start)
      assert.is_not_nil(submatch.end_)
      assert.is_not_nil(submatch.match.text)
    end
  end)
end)
