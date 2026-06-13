-- lua/plugins/editor.lua
-- A small bundle of quality-of-life plugins. Each is independent — you can delete
-- any block you don't like. I've kept this deliberately short; we add more as you
-- feel specific gaps, rather than front-loading 20 plugins you won't understand.

return {
  -- which-key: a popup that shows what keys are available after you press <leader>.
  -- This is the single best plugin for LEARNING your own config — press Space and wait,
  -- and it lists every shortcut. Invaluable while the bindings aren't muscle memory yet.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Auto-pairs: typing ( or { or " auto-inserts the closing one.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- load when you first enter insert mode
    opts = {},
  },

  -- Git signs in the gutter: shows added/changed/removed lines, like VSCode's git decorations.
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = buf, desc = "Git: " .. desc })
        end
        map("]c", gs.next_hunk, "Next change")
        map("[c", gs.prev_hunk, "Previous change")
        map("<leader>gp", gs.preview_hunk, "Preview change")
        map("<leader>gb", gs.blame_line, "Blame line")
      end,
    },
  },

  -- Statusline: the info bar at the bottom (mode, file, git branch, diagnostics).
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto", -- changes colors based on colorscheme; see `:h lualine-theme` for built-in themes
        globalstatus = true, -- use a single statusline at the bottom of the screen instead of one per window
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = {
            { "filename", path = 1 }
        },
        lualine_x = { "diagnostics", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Comment toggling. Neovim 0.10+ has basic native commenting (gcc), but this adds
  -- better language awareness. `gcc` toggles a line, `gc` in visual mode toggles selection.
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
