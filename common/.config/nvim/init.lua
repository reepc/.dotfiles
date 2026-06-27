-- init.lua — the entry point. Keep this tiny.
-- It just loads things in order. Everything real lives in lua/config/ and lua/plugins/.

-- Cache compiled Lua modules to disk so startup (and every require) is faster.
-- Built into Neovim 0.9+; pure win, nothing to configure.
vim.loader.enable()

-- Set the leader key BEFORE loading lazy, or some plugin keymaps bind to the wrong key.
-- The leader is your "prefix" key for custom shortcuts. Space is the popular choice
-- because it's easy to hit and does nothing on its own in normal mode.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options") -- editor settings
require("config.keymaps") -- your key bindings
require("config.lazy") -- bootstraps lazy.nvim and loads everything in lua/plugins/
vim.cmd.colorscheme("onedark") -- set the colorscheme after loading plugins
