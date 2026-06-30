-- lua/plugins/matchparen.lua
-- Highlights the () [] {} pair the cursor is INSIDE — like VSCode's active
-- bracket-pair highlight. Neovim's built-in matchparen only lights up a bracket
-- when the cursor sits directly ON it; sentiment.nvim instead searches outward
-- from the cursor to find the nearest enclosing pair, so the surrounding brackets
-- glow while you're anywhere between them.
--
-- This is separate from rainbow-delimiters.lua: that colors every bracket by
-- nesting depth (always on), this adds the cursor-follows emphasis on top.
-- sentiment paints with the `MatchParen` group, so we redefine it to a
-- BACKGROUND box only (no fg) — the bracket keeps its rainbow color and just gets
-- highlighted, instead of being recolored. Set in a ColorScheme autocmd so it
-- survives theme reloads, then applied once now.
local function set_matchparen()
  -- bg-only: a subtle box behind the bracket, fg untouched so the rainbow shows.
  vim.api.nvim_set_hl(0, "MatchParen", { bg = "#3e4451", bold = true })
end

return {
  {
    "utilyre/sentiment.nvim",
    version = "*", -- pin to release tags rather than bleeding-edge main
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      -- Turn off the built-in matchparen so the two don't double-highlight /
      -- fight over the same `MatchParen` group. Must run before sentiment loads.
      vim.g.loaded_matchparen = 1
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_matchparen })
      set_matchparen()
    end,
    opts = {
      -- defaults are good: pairs = ( ) [ ] { }, 50ms settle delay, 100-line
      -- search window. Bump `limit` if you want it to find very distant pairs.
    },
  },
}
