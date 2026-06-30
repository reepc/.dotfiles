-- lua/plugins/rainbow-delimiters.lua
-- Colors every matching {} () [] (and other delimiters treesitter knows about)
-- by NESTING DEPTH, cycling through a palette — like VSCode's "Bracket Pair
-- Colorization". This makes the start/end of each scope visually obvious: a
-- bracket and its partner share the same color, and deeper levels get a new one.
--
-- We point the brackets at the vivid `Rainbow*` highlight groups that indent.lua
-- defines in ibl's HIGHLIGHT_SETUP hook. Only 3 colors, cycling — gold → orchid →
-- blue → gold — to match VSCode's default bracket-pair colorization. KEEP this
-- list identical to bracket_hl's intent in indent.lua.

return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow = require("rainbow-delimiters")

      -- `vim.g.rainbow_delimiters` is the plugin's config table. The `['']` key is
      -- the default for any filetype with no specific override.
      vim.g.rainbow_delimiters = {
        strategy = {
          -- `global` recolors the whole buffer; for huge files `local` (only the
          -- brackets around the cursor) is lighter, but global reads best.
          [""] = rainbow.strategy["global"],
        },
        query = {
          [""] = "rainbow-delimiters",
        },
        -- 3-color cycle (defined in indent.lua's HIGHLIGHT_SETUP hook, colors
        -- pulled from the onedarkpro palette).
        highlight = {
          "RainbowOrange",
          "RainbowPurple",
          "RainbowBlue",
        },
      }
    end,
  },
}
