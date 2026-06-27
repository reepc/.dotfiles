-- lua/config/indent.lua
-- Small helper for per-filetype indent overrides used by the ftplugin/ files.
-- The global default (4 spaces, expandtab) lives in lua/config/options.lua;
-- ftplugin/<ft>.lua calls this only where a language's convention differs.

local M = {}

-- Set buffer-local indent width. expandtab stays inherited from the global
-- default, so this only changes how wide one indent level is.
function M.set(width)
  vim.bo.shiftwidth = width  -- size of an indent step (>>, autoindent)
  vim.bo.tabstop = width     -- how wide a literal tab renders
  vim.bo.softtabstop = width -- how many spaces Tab/Backspace move over
end

return M
