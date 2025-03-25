function Enable_customization()
  require("blink-ripgrep").config.backend.customize_icon_highlight = true
end

function Customize_highlights()
  local colors = require("catppuccin.palettes.macchiato")

  vim.api.nvim_set_hl(
    0,
    "BlinkCmpKindRipgrepGit",
    { default = false, fg = colors.flamingo }
  )

  vim.api.nvim_set_hl(
    0,
    "BlinkCmpKindRipgrepRipgrep",
    { default = false, fg = colors.flamingo }
  )
end
