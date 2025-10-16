-- see :help :checkhealth
-- https://github.com/neovim/neovim/blob/b7779c514632f8c7f791c92203a96d43fffa57c6/runtime/doc/pi_health.txt#L17
return {
  check = function()
    vim.health.start("blink-ripgrep")

    if vim.fn.executable("rg") ~= 1 then
      vim.health.warn("rg (ripgrep) not found on PATH")
    else
      local rg_version = vim.fn.system("rg --version")
      if vim.v.shell_error ~= 0 then
        vim.health.warn("Failed to get rg version")
      else
        vim.health.ok("rg found: " .. rg_version)
      end
    end

    vim.health.ok("blink-ripgrep")
  end,
}
