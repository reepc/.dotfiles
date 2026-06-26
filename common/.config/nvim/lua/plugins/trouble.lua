-- lua/plugins/trouble.lua
-- Trouble is a pretty, navigable list for everything your LSP complains about:
-- diagnostics (errors/warnings), references, symbols, the quickfix/location lists.
-- Think of it as the "Problems" panel from VSCode — a single buffer you can jump
-- around in, instead of squinting at inline virtual text.
--
-- The mental model:
--   - Open a view (e.g. <leader>xx) and a split lists every item.
--   - Move with j/k; <CR> jumps to the item in your code.
--   - The list updates live as you edit and diagnostics change.
--   - <leader>xx again (or q) closes it.
--   - `?` inside the Trouble window lists every keybinding.
--
-- This complements your existing LSP keys in lua/plugins/lsp.lua:
--   <leader>e / [d / ]d  = inspect/jump diagnostics one at a time
--   <leader>x*           = see them all at once, project- or buffer-wide

return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- icons (needs a Nerd Font)
    cmd = "Trouble", -- lazy-load the first time you run :Trouble or hit a key below
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols outline (Trouble)" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location list (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list (Trouble)" },
      { "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP refs/defs (Trouble)" },
    },
    opts = {}, -- defaults are sensible; everything above drives behavior via the keys
  },
}
-- Tip: inside the Trouble window, `o` jumps to an item and closes the list, while
-- `<CR>` jumps but keeps the list open. Press `?` to discover the rest.
