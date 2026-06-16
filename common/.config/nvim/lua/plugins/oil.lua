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
    -- Load eagerly-ish: oil wants to register itself as the directory handler before
    -- you open any directory, so we lazy-load only on the keymap + the Oil command.
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory (oil)" },
      { "<leader>fo", "<cmd>Oil --float<CR>", desc = "Open oil in a floating window" },
    },
    opts = {
      -- Let oil take over when you open a directory (e.g. `nvim .`), replacing netrw.
      default_file_explorer = true,
      -- Confirm before applying changes when you :w — your safety net against typos.
      skip_confirm_for_simple_edits = false,
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
