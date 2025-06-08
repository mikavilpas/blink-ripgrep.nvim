---@module "blink.cmp"

local M = {}

--- The pattern that is used to match the prefix of a search query. The prefix
--- is the text before the cursor that is used to search for matching words in
--- the project.
local word_pattern
do
  -- match an ascii character as well as unicode continuation bytes.
  -- Technically, unicode continuation bytes need to be applied in order to
  -- construct valid utf-8 characters, but right now we trust that the user
  -- only types valid utf-8 in their project.
  local char = vim.lpeg.R("az", "AZ", "09", "\128\255")

  local non_starting_word_character = vim.lpeg.P(1) - char
  local word_character = char + vim.lpeg.P("_") + vim.lpeg.P("-")
  local non_middle_word_character = vim.lpeg.P(1) - word_character

  word_pattern = vim.lpeg.Ct(
    (
      non_starting_word_character ^ 0
      * vim.lpeg.C(word_character ^ 1)
      * non_middle_word_character ^ 0
    ) ^ 0
  )
end

---@param text_before_cursor string "The text of the entire line before the cursor"
---@return string
function M.match_prefix(text_before_cursor)
  local matches = vim.lpeg.match(word_pattern, text_before_cursor)
  local last_match = matches and matches[#matches]
  return last_match or ""
end

---@param context blink.cmp.Context
---@return string
function M.default_get_prefix(context)
  local line = context.line
  local col = context.cursor[2]
  local text = line:sub(1, col)
  local prefix = M.match_prefix(text)
  return prefix
end

return M
