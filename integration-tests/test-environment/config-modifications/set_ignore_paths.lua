---@param paths string[]
function _G.set_ignore_paths(paths)
  require("blink-ripgrep").setup({
    ignore_paths = paths,
  })
end
