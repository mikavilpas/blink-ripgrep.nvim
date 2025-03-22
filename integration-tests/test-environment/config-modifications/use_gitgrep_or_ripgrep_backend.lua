require("blink-ripgrep").setup({
  future_features = {
    backend = {
      use = "gitgrep-or-ripgrep",
    },
  },
})
