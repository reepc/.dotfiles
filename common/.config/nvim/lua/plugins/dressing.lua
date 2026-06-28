-- lua/plugins/dressing.lua
-- Upgrades the two ugly built-in prompts Neovim shows for `vim.ui.select` and
-- `vim.ui.input` into clean floating windows:
--   vim.ui.select  — the menu you get from <leader>ca (code actions), and any
--                    plugin that asks you to pick from a list.
--   vim.ui.input   — the single-line prompt from <leader>rn (rename), etc.
-- By default these render as a cramped numbered list / bottom-line prompt; dressing
-- makes them look like the rest of your floating UI.
--
-- noice already prettifies the COMMAND line (`:`) and messages — it does NOT touch
-- ui.select/ui.input, so dressing fills that gap without overlapping noice.

return {
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      -- The single-line prompt (rename, etc.): a small float anchored at the cursor.
      input = {
        border = "rounded",   -- match your LSP hover / diagnostic float borders
        relative = "cursor",  -- pop up right where you're working, not screen-center
        prefer_width = 40,
        win_options = { winblend = 0 },
      },
      -- The picker (code actions, etc.): reuse fzf-lua so it looks identical to your
      -- gd / gr / diagnostics popups. Falls back to dressing's builtin float if
      -- fzf-lua isn't loaded for some reason.
      select = {
        backend = { "fzf_lua", "builtin" },
        fzf_lua = { winopts = { height = 0.40, width = 0.50 } },
      },
    },
  },
}
