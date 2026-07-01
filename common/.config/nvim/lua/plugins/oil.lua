-- lua/plugins/oil.lua
-- Oil edits your filesystem like a normal text buffer. It complements neo-tree:
--   neo-tree (<leader>fe) = the glanceable sidebar for browsing project structure
--   oil (-)               = fast create / delete / rename / move via vim motions
--
-- How oil works (this is the whole mental model):
--   - Press `-` to open the directory of the current file *in the current window*.
--   - The directory shows up as an editable buffer, one file per line.
--   - To CREATE a file:   open a new line (`o`), type a name, `:w`.
--   - To CREATE a folder: type a name ending in `/`, `:w`.
--   - To RENAME:          edit the filename text on its line, `:w`.
--   - To DELETE:          delete the line (`dd`), `:w`.
--   - To MOVE/COPY:       cut/yank lines and paste them in another oil buffer, `:w`.
--   - Nothing touches disk until you `:w` — and oil shows a confirmation of changes.
--   - Navigate INTO a folder with `<CR>` (Enter), go UP a level with `-`.
--   - `g?` inside oil lists every keybinding.

return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- file-type icons (needs a Nerd Font)
    -- Load at startup, not lazily: oil must register itself as the directory handler
    -- BEFORE you open any directory. With netrw disabled (see config/options.lua),
    -- this lets `nvim .` and `nvim somedir/` open in oil instead of the default explorer.
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory (oil)" },
      { "<leader>fo", "<cmd>Oil --float<CR>", desc = "Open oil in a floating window" },
    },
    opts = {
      -- Let oil take over when you open a directory (e.g. `nvim .`), replacing netrw.
      default_file_explorer = true,
      -- Confirm before applying changes when you :w — your safety net against typos.
      skip_confirm_for_simple_edits = false,
      -- Rename/move a file in oil → the LSP (ts_ls, rust_analyzer, basedpyright,
      -- clangd, …) rewrites every import that pointed at the old path. `enabled`
      -- is oil's default; the piece worth setting is autosave_changes, so files
      -- oil edited to fix imports get written to disk instead of left unsaved.
      -- "unmodified" = only auto-save buffers you hadn't already edited yourself,
      -- so it never silently writes over your in-progress changes.
      lsp_file_methods = {
        enabled = true,
        timeout_ms = 1000,
        autosave_changes = "unmodified",
      },
      view_options = {
        show_hidden = true, -- show dotfiles (you're literally editing a dotfiles repo)
      },
      -- A floating preview-style window feels closer to VSCode; tweak to taste.
      float = {
        padding = 4,
        max_width = 90,
        max_height = 0,
      },
    },
  },
}
-- Tip: inside oil, `<C-p>` previews the file under the cursor without opening it,
-- and `_` opens the current working directory. Press `g?` to discover the rest.
