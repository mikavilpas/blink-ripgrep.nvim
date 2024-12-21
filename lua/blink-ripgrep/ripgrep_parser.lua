local M = {}

---@class(exact) blink-ripgrep.RipgrepOutput
---@field files table<string, blink-ripgrep.RipgrepFile>

---@class blink-ripgrep.RipgrepFile
---@field language string the treesitter language of the file, used to determine what grammar to highlight the preview with
---@field lines table<number, string> the context preview, shared for all the matches in this file so that they can display a subset
---@field matches table<string,blink-ripgrep.RipgrepMatch>
---@field relative_to_cwd string the relative path of the file to the current working directory

---@class blink-ripgrep.RipgrepMatch
---@field line_number number
---@field start_col number
---@field end_col number
---@field match {text: string} the matched text
---@field context_preview string[] the preview of this match

---@param json unknown
---@param output blink-ripgrep.RipgrepOutput
local function get_file_context(json, output)
  ---@type string
  local filename = json.data.path.text
  local file = output.files[filename]
  local line_number = json.data.line_number
  -- assert(line_number)
  -- assert(not file.lines[line_number])

  return file, line_number
end

-- When ripgrep is run with the `--json` flag, it outputs a stream of jsonl
-- (json lines) objects. They show what matched the search as well as lines
-- surrounding each match.
-- This function converts the jsonl stream into a table.
--
---@param ripgrep_output string[] ripgrep output in jsonl format
---@param cwd string the current working directory
---@param context_size number the number of lines of context to include in the output
function M.parse(ripgrep_output, cwd, context_size)
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

        local ext = vim.fn.fnamemodify(filename, ":e")

        local ft = vim.filetype.match({ filename = filename })
        local language = ft
          or vim.treesitter.language.get_lang(ext or "text")
          or ext

        output.files[filename] = {
          language = language,
          lines = {},
          matches = {},
          relative_to_cwd = relative_filename,
        }
      elseif json.type == "context" then
        local file, line_number = get_file_context(json, output)
        file.lines[line_number] = json.data.lines.text
      elseif json.type == "match" then
        local file, line_number = get_file_context(json, output)
        file.lines[line_number] = json.data.lines.text

        local text = json.data.submatches[1].match.text

        if not file.matches[text] then
          file.matches[text] = {
            start_col = json.data.submatches[1].start,
            end_col = json.data.submatches[1]["end"],
            match = { text = text },
            line_number = line_number,
            context_preview = {},
          }
        end
      elseif json.type == "end" then
        -- Right now, we have collected the necessary lines for the context in
        -- previous steps. Get the context preview for each match.
        local filename = json.data.path.text
        local file = output.files[filename]

        for _, match in pairs(file.matches) do
          match.context_preview =
            M.get_context_preview(file.lines, match.line_number, context_size)
        end

        -- clear the lines to save memory
        file.lines = {}
      end
    end
  end
  return output
end

---@param lines table<number, string>
---@param matched_line number the line number the match was found on
---@param context_size number how many lines of context to include before and after the match
function M.get_context_preview(lines, matched_line, context_size)
  ---@type string[]
  local context_preview = {}

  local start_line = matched_line - context_size
  local end_line = matched_line + context_size

  for i = start_line, end_line do
    local line = lines[i]
    if line then
      context_preview[#context_preview + 1] = lines[i]:gsub("%s*$", "")
    end
  end

  return context_preview
end

return M
