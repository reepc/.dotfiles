-- lua/plugins/indent.lua
-- The faint vertical lines marking each indent level, like VSCode's indent guides.
-- Makes nested blocks (deep Python/Rust/JSX) much easier to scan. `ibl` is the
-- plugin's Lua module name (the repo is indent-blankline.nvim, v3).
--
-- indent-rainbowline.nvim layers VSCode "indent-rainbow"-style colors on top: it
-- tints the whole indent *whitespace background* per depth (blocks, not just the
-- line glyph), cycling through `colors`. It produces ibl opts, so it has to wrap
-- ibl's opts via make_opts rather than run on its own.

return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "TheGLander/indent-rainbowline.nvim" },
    opts = function(_, opts)
      opts.indent = { char = " " }     -- blank glyph: only the rainbow blocks, no guide line
      opts.scope = { enabled = false } -- no "box" (left line + over/underline) around the current scope
      return require("indent-rainbowline").make_opts(opts, {
        -- 0 = invisible, 1 = solid block. Low value = faint VSCode-like bands.
        color_transparency = 0.1,
        -- 24-bit hex tints blended into the background, cycled per indent depth.
        colors = { 0xffff40, 0x79ff79, 0xff79ff, 0x4fecec },
      })
    end,
  },
}
