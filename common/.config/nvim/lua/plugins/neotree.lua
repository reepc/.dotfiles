-- lua/plugins/neotree.lua
-- The file explorer sidebar — your VSCode left panel. Toggle it with <leader>fe.
-- Honest note: many Vim users barely use a tree and rely on Telescope's find-files
-- instead. Try both; keep what fits. The tree is comforting coming from VSCode.

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- file-type icons (needs a Nerd Font in your terminal)
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree", -- lazy-load: only load when the Neotree command is first used
    keys = {
      -- `keys` also triggers lazy-loading — pressing this loads the plugin then runs it.
      { "<leader>fe", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
    },
    opts = {
      -- Neo-tree, unlike oil, has no built-in LSP integration: renaming/moving a
      -- file here won't touch imports on its own. It DOES fire `file_renamed` /
      -- `file_moved` events carrying { source, destination }, so we hook those and
      -- ask every attached server to update references via workspace/willRenameFiles
      -- (supported by ts_ls, rust_analyzer, basedpyright, clangd, …). This mirrors
      -- what oil does for free (see oil.lua's lsp_file_methods).
      event_handlers = {
        {
          event = "file_renamed",
          handler = function(args)
            require("config.lsp_rename").on_rename(args.source, args.destination)
          end,
        },
        {
          event = "file_moved",
          handler = function(args)
            require("config.lsp_rename").on_rename(args.source, args.destination)
          end,
        },
      },
      filesystem = {
        follow_current_file = { enabled = true }, -- highlight the file you're editing
        use_libuv_file_watcher = true,            -- auto-refresh when files change on disk
        filtered_items = {
          visible = true,          -- show filtered items instead of hiding them
          hide_dotfiles = false,   -- show files/dirs starting with `.` (.config, .gitignore, …)
          hide_gitignored = false, -- show git-ignored files too
          hide_hidden = false,     -- (Windows) show OS-hidden files
        },
      },
      window = { width = 32 },
    },
  },
}
-- Inside the tree: `a` add file, `d` delete, `r` rename, `Enter` open, `?` shows all keys.