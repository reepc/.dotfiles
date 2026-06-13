-- lua/config/lazy.lua
-- This bootstraps lazy.nvim (downloads it on first run) and tells it where your plugins live.
-- You should rarely need to touch this file after setup.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Now hand control to lazy. `import = "plugins"` means:
-- "load every .lua file in lua/plugins/ and treat each one as a plugin spec."
-- That's the magic that makes adding a plugin = dropping in a new file.
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  -- Check for plugin updates periodically but don't auto-install them.
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})