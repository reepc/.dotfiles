-- lua/plugins/colorscheme.lua
-- A plugin spec is just a Lua table that returns plugin definitions.
-- The first string is the GitHub "owner/repo". lazy.nvim downloads it for you.

return {
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("onedarkpro").setup({
        cursorline = true,
      })

      -- onedarkpro gives import module names their own group (priority 126), so
      -- they DON'T match the gold of class/type names. It defines the LANGUAGE-
      -- SUFFIXED group `@odp.import_module.python` directly, which neovim looks up
      -- BEFORE the base `@odp.import_module` — so we must override the suffixed
      -- name too, or it shadows our change. We re-link AFTER the theme applies,
      -- on every (re)load of an onedark* scheme so it survives `:colorscheme`.
      -- Result: imports are colored like in VSCode/Zed's One Dark.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "onedark*",
        callback = function()
          local link = { link = "@type" }
          for _, group in ipairs({
            "@odp.import_module",
            "@odp.import_module.python",
          }) do
            vim.api.nvim_set_hl(0, group, link)
          end
        end,
      })
    end,
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
