---@module "blink.cmp"

---@class blink-ripgrep.Options
---@field prefix_min_len? number
---@field get_command? fun(context: blink.cmp.Context, prefix: string): string[]
---@field get_prefix? fun(context: blink.cmp.Context): string

---@class blink-ripgrep.RgSource : blink.cmp.Source
---@field prefix_min_len number
---@field get_command fun(context: blink.cmp.Context, prefix: string): string[]
---@field get_prefix fun(context: blink.cmp.Context): string
---@field get_completions? fun(self: blink.cmp.Source, context: blink.cmp.Context, callback: fun(response: blink.cmp.CompletionResponse | nil)):  nil
local RgSource = {}

---@param context blink.cmp.Context
---@return string
local function default_get_prefix(context)
  local line = context.line
  local col = context.cursor[2]
  local prefix = line:sub(1, col):match("[%w_-]+$") or ""
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
        "--word-regexp",
        "--ignore-case",
        "--",
        prefix .. "[\\w_-]+",
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
        local label = match.match.text .. " (rg)"
        -- the implementation for render_detail_and_documentation:
        -- ../../integration-tests/test-environment/.repro/data/nvim/lazy/blink.cmp/lua/blink/cmp/windows/lib/docs.lua
        ---@diagnostic disable-next-line: missing-fields
        items[match.match.text] = {
          documentation = {
            kind = "markdown",
            value = table.concat(file.lines, "\n"),
          },
          detail = match.match.text .. ".",
          source_id = "blink-ripgrep",
          label = label,
          insertText = match.match.text,
        }
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
