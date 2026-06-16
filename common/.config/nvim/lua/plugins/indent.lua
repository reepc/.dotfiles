-- lua/plugins/indent.lua
-- The faint vertical lines marking each indent level, like VSCode's indent guides.
-- Makes nested blocks (deep Python/Rust/JSX) much easier to scan. `ibl` is the
-- plugin's Lua module name (the repo is indent-blankline.nvim, v3).

return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },       -- the glyph used for the guide line
      scope = { enabled = true },    -- highlight the indent level the cursor is inside
    },
  },
}
