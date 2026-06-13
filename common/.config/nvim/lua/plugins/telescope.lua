-- lua/plugins/telescope.lua
-- Telescope is your fuzzy finder — this replaces VSCode's Cmd+P (find file),
-- Cmd+Shift+F (find in files), and Cmd+T (find symbol) all in one tool.
-- It's probably the single plugin you'll use most coming from VSCode.

return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim", -- a utility library Telescope depends on
      {
        -- Native C sorter — makes filtering much faster on big projects.
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make", -- requires `make` and a C compiler on the machine (you have these)
      },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          preview = {
            treesitter = false,
          }
        }
      })
      pcall(telescope.load_extension, "fzf")

      local builtin = require("telescope.builtin")
      -- The big four. Note <leader> is Space (set in init.lua).
      vim.keymap.set("n", "<leader>ff", builtin.find_files,  { desc = "Find files (same as Cmd+P)" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep,   { desc = "Find in files (grep)" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers,     { desc = "Find open buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags,   { desc = "Search help docs" })
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find symbols in file" })
    end,
  },
}
-- Note: live_grep needs ripgrep (`rg`) installed on the system/server.
-- On the remote: `sudo apt install ripgrep`. On mac: `brew install ripgrep`.