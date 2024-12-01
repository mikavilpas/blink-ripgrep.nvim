---@module "blink.cmp"

---@class blink-ripgrep.Options
---@field prefix_min_len? number
---@field get_command? fun(context: blink.cmp.Context, prefix: string): string[] # Changing this might break things - if you need some customization, please open and issue 🙂
---@field get_prefix? fun(context: blink.cmp.Context): string
---@field context_size? number # The number of lines to show around each match
---@field max_filesize? number # The maximum file size that ripgrep should include in its search. Examples: "1024" (bytes by default), "200K", "1M", "1G"

---@class blink-ripgrep.RgSource : blink.cmp.Source
---@field prefix_min_len number
---@field get_command fun(context: blink.cmp.Context, prefix: string): string[]
---@field get_prefix fun(context: blink.cmp.Context): string
---@field get_completions? fun(self: blink.cmp.Source, context: blink.cmp.Context, callback: fun(response: blink.cmp.CompletionResponse | nil)):  nil
local RgSource = {}

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
function RgSource.match_prefix(text_before_cursor)
  local matches = vim.lpeg.match(word_pattern, text_before_cursor)
  local last_match = matches and matches[#matches]
  return last_match or ""
end

---@param context blink.cmp.Context
---@return string
local function default_get_prefix(context)
  local line = context.line
  local col = context.cursor[2]
  local text = line:sub(1, col)
  local prefix = RgSource.match_prefix(text)
  return prefix
end

---@param opts blink-ripgrep.Options
function RgSource.new(opts)
  opts = opts or {}

  return setmetatable({
    prefix_min_len = opts.prefix_min_len or 3,
    get_command = opts.get_command or function(_, prefix)
      return {
        "rg",
        "--no-config",
        "--json",
        "--context=" .. (opts.context_size or 5),
        "--word-regexp",
        "--max-filesize=" .. (opts.max_filesize or "1M"),
        "--ignore-case",
        "--",
        prefix .. "[\\w_-]+",
        -- NOTE: 2024-11-28 the logic is documented in the README file, and
        -- should be kept up to date
        vim.fn.fnameescape(vim.fs.root(0, ".git") or vim.fn.getcwd()),
      }
    end,
    get_prefix = opts.get_prefix or default_get_prefix,
  }, { __index = RgSource })
end

function RgSource:get_completions(context, resolve)
  local prefix = self.get_prefix(context)

  if string.len(prefix) < self.prefix_min_len then
    resolve()
    return
  end

  vim.system(self.get_command(context, prefix), nil, function(result)
    if result.code ~= 0 then
      resolve()
      return
    end

    local lines = vim.split(result.stdout, "\n")
    local cwd = vim.uv.cwd() or ""

    local parsed = require("blink-ripgrep.ripgrep_parser").parse(lines, cwd)

    ---@type table<string, blink.cmp.CompletionItem>
    local items = {}
    for _, file in pairs(parsed.files) do
      for _, match in ipairs(file.submatches) do
        local matchkey = match.match.text

        -- PERF: only register the match once - right now there is no useful
        -- way to display the same match multiple times
        if not items[matchkey] then
          local label = match.match.text .. " (rg)"
          -- the implementation for render_detail_and_documentation:
          -- ../../integration-tests/test-environment/.repro/data/nvim/lazy/blink.cmp/lua/blink/cmp/windows/lib/docs.lua
          ---@diagnostic disable-next-line: missing-fields
          items[matchkey] = {
            documentation = {
              kind = "markdown",
              value = table.concat(file.lines, "\n"),
            },
            detail = file.relative_to_cwd,
            source_id = "blink-ripgrep",
            label = label,
            insertText = matchkey,
          }
        end
      end
    end

    resolve({
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = vim.tbl_values(items),
      context = context,
    })
  end)
end

return RgSource
