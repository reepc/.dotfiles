-- lua/plugins/textobjects.lua
-- nvim-treesitter-textobjects — syntax-aware text objects and motions. Lets you
-- operate on whole functions / classes / parameters by structure instead of by
-- counting lines, and jump between them.
--
-- IMPORTANT: like nvim-treesitter itself, this plugin moved to a `main` branch
-- with a NEW API (the old `master`-branch `textobjects = { select = {...} }`
-- block inside treesitter.setup does NOT work here). The setup below is the
-- current main-branch form: configure once, then bind keys yourself.

return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main", -- must match the branch nvim-treesitter is on (see treesitter.lua)
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          -- Jump cursor to the start/end of the matched object when selecting.
          lookahead = true,
        },
        move = {
          -- Add jumps to the jumplist so Ctrl-o brings you back.
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      -- === Select objects (use after v / d / y / c) ===
      -- `if` = inner function, `af` = around function (incl. signature),
      -- `ic`/`ac` = inner/around class, `ia`/`aa` = inner/around argument.
      local function sel(key, query)
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "TS select " .. query })
      end
      sel("if", "@function.inner")
      sel("af", "@function.outer")
      sel("ic", "@class.inner")
      sel("ac", "@class.outer")
      sel("ia", "@parameter.inner")
      sel("aa", "@parameter.outer")

      -- === Move between objects ===
      -- `]f` / `[f` next/prev function start, `]c` is taken by gitsigns so we
      -- use `]C` / `[C` for class to avoid the clash.
      vim.keymap.set({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function start" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev function start" })
      vim.keymap.set({ "n", "x", "o" }, "]C", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next class start" })
      vim.keymap.set({ "n", "x", "o" }, "[C", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Prev class start" })
    end,
  },
}
