-- lua/plugins/neoscroll.lua
-- neoscroll.nvim — animates scrolling so the screen glides instead of jumping.
-- Turns <C-d>/<C-u> (half-page), <C-f>/<C-b> (full-page) and the zt/zz/zb
-- recenters into smooth motions. Your eyes keep their place because the view
-- slides rather than teleporting.
--
-- These mappings REPLACE the plain `<C-d>zz` / `<C-u>zz` ones that used to live
-- in lua/config/keymaps.lua: neoscroll keeps the cursor at the same screen row
-- while scrolling, so it stays centered on its own — no explicit `zz` needed.

return {
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy", -- nothing to animate until you're editing
    config = function()
      local neoscroll = require("neoscroll")
      neoscroll.setup({
        easing = "sine", -- ease in/out so motion starts/stops gently (not linear)
        -- `performance_mode = true` strips syntax highlight during the scroll on
        -- very large files if you ever find it choppy; off by default.
      })

      -- Durations in ms. Shorter = snappier, longer = more glide. Tune to taste.
      local map = {
        ["<C-u>"] = function() neoscroll.ctrl_u({ duration = 120 }) end,
        ["<C-d>"] = function() neoscroll.ctrl_d({ duration = 120 }) end,
        ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 200 }) end,
        ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 200 }) end,
        ["zt"] = function() neoscroll.zt({ half_win_duration = 100 }) end,
        ["zz"] = function() neoscroll.zz({ half_win_duration = 100 }) end,
        ["zb"] = function() neoscroll.zb({ half_win_duration = 100 }) end,
      }
      for key, fn in pairs(map) do
        vim.keymap.set({ "n", "v", "x" }, key, fn, { silent = true })
      end
    end,
  },
}
