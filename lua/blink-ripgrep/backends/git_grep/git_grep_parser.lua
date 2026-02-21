local GitGrepParser = {}

-- TODO these types are just copies of the Ripgrep types, they should be shared

---@class(exact) blink-ripgrep.GitgrepOutput
---@field files table<string, blink-ripgrep.GitgrepFile>

---@class(exact) blink-ripgrep.GitgrepFile
---@field type "gitgrep"
---@field language string the treesitter language of the file, used to determine what grammar to highlight the preview with
---@field matches table<string,blink-ripgrep.Match>
---@field path string the path of the file

---@param lines string[]
---@param cwd string
function GitGrepParser.parse_output(lines, cwd)
  ---@type blink-ripgrep.GitgrepOutput
  local output = { files = {} }

  for _, line in ipairs(lines) do
    -- selene: allow(empty_if)
    if line == "" or not line then
      -- ignore
    else
      -- example line:
      -- other-file.lua\\0003\\00014\\0Hippopotamus234
      local parts = vim.split(line, "\0")
      assert(#parts == 4, "Unexpected parts in line: " .. line)
      local filename = parts[1]
      local line_number = assert(tonumber(parts[2]))
      local start_col = assert(tonumber(parts[3])) - 1
      local text = parts[4]

      local relative_filename = filename
      if filename:sub(1, #cwd) == cwd then
        relative_filename = filename:sub(#cwd + 2)
      end

      local file = output.files[relative_filename]
      if not file then
        local ft = vim.filetype.match({ filename = filename })
        local ext = vim.fn.fnamemodify(filename, ":e")
        local language = ft
          or vim.treesitter.language.get_lang(ext or "text")
          or ext

        file = {
          type = "gitgrep",
          language = language,
          matches = {},
          path = relative_filename,
        }
        output.files[relative_filename] = file
      end
      if not file.matches[text] then
        file.matches[text] = {
          match = { text = text },
          start_col = start_col,
          end_col = start_col + #text,
          line_number = line_number,
        }
      end
    end
  end

  return output
end

return GitGrepParser
