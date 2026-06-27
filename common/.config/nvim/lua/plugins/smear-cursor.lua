-- lua/plugins/smear-cursor.lua
-- smear-cursor.nvim — draws a short trail behind the cursor as it moves, so big
-- jumps (G, gg, flash labels, %, search) animate into place instead of blinking
-- across the screen. Pure Lua, works in the terminal — no GUI required.
--
-- Relies on `termguicolors` (already on in options.lua). If the trail color ever
-- looks off against your theme, set `cursor_color` in opts to a hex value.

return {
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      smear_between_buffers = true, -- animate when jumping between windows too
      smear_between_neighbor_lines = true, -- trail even for small j/k moves
      -- Lower = trail fades faster (snappier); higher = longer tail.
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5, -- stop animating once this close to target
    },
  },
}
