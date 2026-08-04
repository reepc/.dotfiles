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
        -- 3s, not the 1s default: on a large project (and a CPU-limited remote)
        -- the server has to scan the whole tree for references before it can
        -- return the import edits, and 1s times out before it finishes.
        timeout_ms = 3000,
        autosave_changes = "unmodified",
      },
      view_options = {
        show_hidden = true, -- show dotfiles (you're literally editing a dotfiles repo)
      },
      -- Side preview like fzf-lua: a split shows the content of the entry under
      -- the cursor. update_on_cursor_moved makes it follow as you move up/down,
      -- so browsing an oil buffer feels like scrolling an fzf-lua picker.
      -- The window itself is auto-opened on enter by the OilEnter autocmd below;
      -- fast_scratch loads content without fully attaching LSP/plugins, so moving
      -- the cursor stays snappy on big files.
      preview_win = {
        update_on_cursor_moved = true,
        preview_method = "fast_scratch",
        -- Don't try to preview huge/binary files — keeps cursor movement instant.
        disable_preview = function(name)
          return name:match("%.png$") or name:match("%.jpe?g$") or name:match("%.gif$") or name:match("%.pdf$")
        end,
      },
      -- fzf-lua-style floating picker: a big centered frame, list on the left,
      -- preview on the right. Key facts about how oil lays this out (see
      -- oil/init.lua open_preview + oil/layout.lua split_window):
      --   * max_width/max_height cap the WHOLE float (list + preview together).
      --     A float 0<x<1 means a fraction of the editor, so 0.9 = 90% of screen
      --     — that's what makes it large instead of the old fixed 90 columns.
      --   * The two panes are always split 50/50 (oil has no ratio option).
      --   * `padding` is reused as the GAP between the two panes, so keeping it
      --     small (2) closes the wide black strip we had down the middle.
      --   * `border` frames each pane; with a small padding the two rounded
      --     panels sit side by side and read as one picker instead of two boxes.
      --   * preview_split = "right" pins the preview to the right of the list
      --     regardless of your 'splitright' setting.
      float = {
        padding = 2,
        max_width = 0.9,
        max_height = 0.9,
        border = "rounded",
        preview_split = "right",
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)

      -- Auto-open the side preview whenever you enter an oil buffer, so the
      -- content panel is always there (fzf-lua style) instead of only after
      -- pressing <C-p>. OilEnter fires on the initial open and on every cd into
      -- a subdir; schedule_wrap defers so the cursor entry is resolved. We skip
      -- directories (../ etc.) because there's nothing to preview — once open,
      -- update_on_cursor_moved above keeps the panel in sync as you move.
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilEnter",
        callback = vim.schedule_wrap(function(args)
          local oil = require("oil")
          if vim.api.nvim_get_current_buf() ~= args.data.buf then
            return
          end
          local entry = oil.get_cursor_entry()
          if entry and entry.type ~= "directory" and not require("oil.util").get_preview_win() then
            oil.open_preview()
          end
        end),
      })
    end,
  },
}
-- Tip: inside oil, `<C-p>` previews the file under the cursor without opening it,
-- and `_` opens the current working directory. Press `g?` to discover the rest.
