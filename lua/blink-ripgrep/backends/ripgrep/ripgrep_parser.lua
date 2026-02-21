local M = {}

---@class(exact) blink-ripgrep.RipgrepOutput
---@field files table<string, blink-ripgrep.RipgrepFile>

---@class blink-ripgrep.RipgrepFile
---@field type "ripgrep"
---@field language string the treesitter language of the file, used to determine what grammar to highlight the preview with
---@field matches table<string,blink-ripgrep.Match>
---@field path string the path of the file

---@class blink-ripgrep.Match
---@field line_number number
---@field start_col number
---@field end_col number
---@field match {text: string} the matched text

---@param json unknown
---@param output blink-ripgrep.RipgrepOutput
local function get_file_context(json, output)
  ---@type string
  local filename = json.data.path.text
  local file = output.files[filename]
  local line_number = json.data.line_number

  return file, line_number
end

-- When ripgrep is run with the `--json` flag, it outputs a stream of jsonl
-- (json lines) objects. They show what matched the search as well as lines
-- surrounding each match.
-- This function converts the jsonl stream into a table.
--
---@param ripgrep_output string[] ripgrep output in jsonl format
---@param cwd string the current working directory
function M.parse(ripgrep_output, cwd)
  ---@type blink-ripgrep.RipgrepOutput
  local output = { files = {} }

  -- parse the output and collect the matches and context
  for _, line in ipairs(ripgrep_output) do
    local ok, json = pcall(vim.json.decode, line)
    if ok then
      if json.type == "begin" then
        ---@type string
        local filename = json.data.path.text

        local relative_filename = filename
        if filename:sub(1, #cwd) == cwd then
          relative_filename = filename:sub(#cwd + 2)
        end

        local ft = vim.filetype.match({ filename = filename })
        local ext = vim.fn.fnamemodify(filename, ":e")
        local language = ft
          or vim.treesitter.language.get_lang(ext or "text")
          or ext

        output.files[filename] = {
          type = "ripgrep",
          language = language,
          matches = {},
          path = relative_filename,
        }
      elseif json.type == "match" then
        local file, line_number = get_file_context(json, output)

        for _, submatch in ipairs(json.data.submatches) do
          local text = submatch.match.text
          if not file.matches[text] then
            file.matches[text] = {
              start_col = submatch.start,
              end_col = submatch["end"],
              match = { text = text },
              line_number = line_number,
            }
          end
        end
      end
    end
  end
  return output
end

return M
