---@module "blink.cmp"

---@class blink-cmp-rg.Options
---@field prefix_min_len? number
---@field get_command? fun(context: blink.cmp.Context, prefix: string): string[]
---@field get_prefix? fun(context: blink.cmp.Context): string

---@class blink-cmp-rg.RgSource : blink.cmp.Source
---@field prefix_min_len number
---@field get_command fun(context: blink.cmp.Context, prefix: string): string[]
---@field get_prefix fun(context: blink.cmp.Context): string
---@field get_completions? fun(self: blink.cmp.Source, context: blink.cmp.Context, callback: fun(response: blink.cmp.CompletionResponse)): (fun(): nil) | nil
local RgSource = {}

---@param opts blink-cmp-rg.Options
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
        vim.fs.root(0, ".git") or vim.fn.getcwd(),
      }
    end,
    get_prefix = opts.get_prefix or function(_)
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local line = vim.api.nvim_get_current_line()
      local prefix = line:sub(1, col):match("[%w_-]+$") or ""
      return prefix
    end,
  }, { __index = RgSource })
end

function RgSource:get_completions(context, resolve)
  local prefix = self.get_prefix(context)

  if string.len(prefix) < self.prefix_min_len then
    resolve(
      -- TODO check https://github.com/Saghen/blink.cmp/pull/254
      {
        is_incomplete_forward = true,
        is_incomplete_backward = true,
        items = {},
        context = context,
      }
    )
    ---@diagnostic disable-next-line: missing-return-value
    return
  end

  vim.system(self.get_command(context, prefix), nil, function(result)
    if result.code ~= 0 then
      resolve(
        -- TODO check https://github.com/Saghen/blink.cmp/pull/254
        {
          is_incomplete_forward = true,
          is_incomplete_backward = true,
          items = {},
          context = context,
        }
      )
      return
    end

    local lines = vim.split(result.stdout, "\n")

    ---@type table<string, blink.cmp.CompletionItem>
    local items = {}
    for _, line in ipairs(lines) do
      local ok, item = pcall(vim.json.decode, line)
      item = ok and item or {}

      if item.type == "match" then
        assert(
          item.data.lines.text,
          "ripgrep output missing item.data.lines.text for item "
            .. vim.inspect(item)
        )
        assert(
          item.data.path.text,
          "ripgrep output missing item.data.path.text for item "
            .. vim.inspect(item)
        )
        ---@type string[]
        local documentation = {
          item.data.lines.text,
          " ", -- empty lines seem to do nothing, so just have something
          item.data.path.text,
        }

        for _, submatch in ipairs(item.data.submatches) do
          ---@diagnostic disable-next-line: missing-fields
          items[submatch.match.text] = {
            documentation = table.concat(documentation, "\n"),
            source_id = "blink-cmp-rg",
            label = submatch.match.text .. " (rg)",
            insertText = submatch.match.text,
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
    ---@diagnostic disable-next-line: missing-return
  end)
end

return RgSource
