-- lua/plugins/flash.lua
-- flash.nvim — jump anywhere on screen in ~3 keystrokes. This is the big
-- "navigate fast" plugin: instead of mashing j/k/w/b to crawl across a file,
-- you press `s`, type 2 characters near where you want to go, then press the
-- one-letter label flash paints next to each match. Cursor teleports there.
--
-- It also quietly upgrades f/F/t/T and / search with the same labels, so even
-- your existing motions get faster without learning anything new.

return {
  {
    "folke/flash.nvim",
    event = "VeryLazy", -- load lazily; nothing to do until you actually jump
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      -- `s` + two chars: jump to any visible match by its label.
      -- (Default `s` is "substitute char" — but `cl` does the same thing, so
      -- handing `s` to flash is the near-universal choice and well worth it.)
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },

      -- `S`: treesitter jump — labels whole syntax nodes (functions, blocks,
      -- args). Great for "select this whole if-statement" without counting lines.
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },

      -- `r` in operator-pending (e.g. after d/y): "remote" — act on a far-away
      -- spot, then snap back. e.g. `yr` then jump = yank there without moving.
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },

      -- `R`: treesitter search in visual/operator mode — grow the selection
      -- node by node to a labelled target.
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },

      -- While in a `/` or `?` search, toggle flash labels on the matches.
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
}
