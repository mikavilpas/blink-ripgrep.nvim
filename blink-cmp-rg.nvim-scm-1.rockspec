---@diagnostic disable: lowercase-global
rockspec_format = "3.0"
package = "blink-cmp-rg.nvim"
version = "scm-1"
source = {
  url = "git+https://github.com/mikavilpas/blink-cmp-rg.nvim",
}
dependencies = {
  -- Add runtime dependencies here
  -- e.g. "plenary.nvim",
  -- blink is not available on luarocks (yet)
  -- "blink.nvim",
}
test_dependencies = {
  "nlua",
}
build = {
  type = "builtin",
  copy_directories = {
    -- Add runtimepath directories, like
    -- 'plugin', 'ftplugin', 'doc'
    -- here. DO NOT add 'lua' or 'lib'.
  },
}
