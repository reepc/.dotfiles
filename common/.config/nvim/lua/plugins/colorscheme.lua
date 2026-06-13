-- lua/plugins/colorscheme.lua
-- A plugin spec is just a Lua table that returns plugin definitions.
-- The first string is the GitHub "owner/repo". lazy.nvim downloads it for you.

return {
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      cursorline = true
    }
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    -- lazy = false,
    opts = {
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
    },
  },
}
