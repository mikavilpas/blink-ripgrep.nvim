require("blink-ripgrep").setup({
  backend = {
    ripgrep = {
      search_casing = "--smart-case",
    },
  },
})
