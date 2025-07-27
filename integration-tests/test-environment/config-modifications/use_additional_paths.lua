-- tui-sandbox sets HOME to point to the root of the unique test environment
-- directory.
local path = vim.fn.resolve(vim.env.HOME .. "/additional-words-dir/words.txt")
assert(vim.fn.filereadable(path) == 1, path .. " is not readable")

require("blink-ripgrep").setup({
  backend = {
    ripgrep = {
      additional_paths = { path },
    },
  },
})
