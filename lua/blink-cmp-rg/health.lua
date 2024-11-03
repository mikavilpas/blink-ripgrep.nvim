-- see :help :checkhealth
-- https://github.com/neovim/neovim/blob/b7779c514632f8c7f791c92203a96d43fffa57c6/runtime/doc/pi_health.txt#L17
return {
  check = function()
    vim.health.start("blink-cmp-rg")

    if vim.fn.executable("rg") ~= 1 then
      vim.health.warn("rg (ripgrep) not found on PATH")
    end

    vim.health.ok("blink-cmp-rg")
  end,
}
