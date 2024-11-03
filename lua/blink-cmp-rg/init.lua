---@module "blink.cmp"

---@class blink-cmp-rg.Options
---@field prefix_min_len? number
---@field get_command? fun(self: blink.cmp.Context, prefix: string): string[]
---@field get_prefix? fun(self: blink.cmp.Context): string

---@class blink-cmp-rg.RgSource : blink.cmp.Source
---@field prefix_min_len number
---@field get_command fun(self: blink.cmp.Context, prefix: string): string[]
---@field get_prefix fun(self: blink.cmp.Context): string
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
		resolve()
		return
	end

	vim.system(self.get_command(context, prefix), nil, function(result)
		if result.code ~= 0 then
			resolve()
			return
		end

		local items = {}
		local lines = vim.split(result.stdout, "\n")
		vim.iter(lines)
			:map(function(line)
				local ok, item = pcall(vim.json.decode, line)
				item = ok and item or {}
				if item.type == "match" then
					return item.data.submatches
				else
					return {}
				end
			end)
			:flatten()
			:each(function(submatch)
				---@type blink.cmp.CompletionItem
				---@diagnostic disable-next-line: missing-fields
				items[submatch.match.text] = {
					label = submatch.match.text,
					kind = vim.lsp.protocol.CompletionItemKind.Text,
					insertText = submatch.match.text,
				}
			end)

		resolve({
			is_incomplete_forward = false,
			is_incomplete_backward = false,
			items = vim.tbl_values(items),
		})
	end)
end

return RgSource
