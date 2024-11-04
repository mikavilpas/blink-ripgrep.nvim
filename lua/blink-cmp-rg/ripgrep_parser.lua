local M = {}

---@class(exact) RipgrepOutput
---@field files table<string, RipgrepFile>

---@class RipgrepFile
---@field lines string[] the context preview for all the matches
---@field submatches RipgrepSubmatch[] the matches

---@class RipgrepSubmatch
---@field start number the start column of the match
---@field end_ number the end column of the match
---@field match {text: string} the matched text

---@param ripgrep_output string[] ripgrep output in jsonl format
---@param cwd string the current working directory
function M.parse(ripgrep_output, cwd)
  ---@type RipgrepOutput
  local output = { files = {} }

  for _, line in ipairs(ripgrep_output) do
    local ok, json = pcall(vim.json.decode, line)
    if ok then
      if json.type == "begin" then
        ---@type string
        local filename = json.data.path.text

        output.files[filename] = { lines = {}, submatches = {} }
      elseif json.type == "context" then
        ---@type string
        local filename = json.data.path.text
        local data = output.files[filename]

        data.lines[#data.lines + 1] = json.data.lines.text
      elseif json.type == "match" then
        ---@type string
        local filename = json.data.path.text
        local data = output.files[filename]

        data.lines[#data.lines + 1] = json.data.lines.text

        data.submatches[#data.submatches + 1] = {
          start = json.data.submatches[1].start,
          end_ = json.data.submatches[1]["end"],
          match = { text = json.data.submatches[1].match.text },
        }
      elseif json.type == "end" then
        ---@type string
        local filename = json.data.path.text
        local data = output.files[filename]

        if filename:sub(1, #cwd) == cwd then
          filename = filename:sub(#cwd + 2)
        end
        data.lines[#data.lines + 1] = " "
        data.lines[#data.lines + 1] = "> " .. filename
      end
    end
  end
  return output
end

return M
