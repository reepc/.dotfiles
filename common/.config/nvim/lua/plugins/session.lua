-- lua/plugins/session.lua
-- Session restore. Remembers the buffers/splits/layout you had open, PER directory,
-- and brings them back. This is what makes `nvim` (no args) reopen "where you left off".
--
-- How it fits with your alpha dashboard:
--   - Open `nvim` in a folder you've worked in before  -> your last session is restored.
--   - Open `nvim` in a folder with no saved session     -> the alpha dashboard shows.
--   - Open `nvim somefile.py` (with a file argument)    -> just that file; no restore.
--
-- Sessions are saved automatically when you quit, so there's nothing to remember to do.

return {
  {
    "folke/persistence.nvim",
    -- Load once you open a real file, so persistence is active and can save the
    -- session when you quit. (The auto-restore on empty startup is wired in `init`.)
    event = "BufReadPre",
    opts = {}, -- defaults are good: saved under stdpath("state")/sessions/, saved on exit

    -- Manual session controls, under <leader>s so they don't clash with <leader>q (quit).
    keys = {
      { "<leader>ss", function() require("persistence").load() end,                desc = "Session: restore (this dir)" },
      { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Session: restore last used" },
      { "<leader>sd", function() require("persistence").stop() end,                desc = "Session: stop saving (this one)" },
    },

    init = function()
      -- On startup with NO file argument, try to restore this directory's session.
      -- `load()` is a no-op when no saved session exists, so the alpha dashboard
      -- simply stays on screen in that case.
      vim.api.nvim_create_autocmd("VimEnter", {
        nested = true, -- allow the restored buffers to fire their own autocmds (LSP, etc.)
        callback = function()
          if vim.fn.argc() ~= 0 then return end -- a file was passed; don't override it
          local ok, persistence = pcall(require, "persistence")
          if ok then persistence.load() end
        end,
      })
    end,
  },
}
-- Note: restore is keyed to your current working directory. Launch nvim from a
-- project's root (e.g. `cd ~/myproject && nvim`) to get that project's session back.
