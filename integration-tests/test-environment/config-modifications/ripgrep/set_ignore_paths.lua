---@param paths string[]
function _G.set_ignore_paths(paths)
  require("blink-ripgrep").setup({
    backend = {
      ripgrep = {
        ignore_paths = paths,
      },
    },
  })
end
