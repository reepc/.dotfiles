-- lua/plugins/bufferline.lua
-- The row of tabs across the TOP of the screen — one per open buffer, like VSCode's
-- editor tabs. (Your lualine at the bottom is the status bar; this is different.)
--
-- Note: this rebinds Shift+h / Shift+l. By default those jump to the top/bottom of
-- the visible screen (H/L). Here they cycle buffers instead — a very common remap,
-- but if you use H/L for screen jumps, tell me and I'll move these to other keys.

return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "<leader>bd", "<cmd>bdelete<CR>",               desc = "Close buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>",   desc = "Pin/unpin buffer" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",          -- show LSP error/warn counts on each tab
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        -- Indent the tabs so they don't sit on top of the neo-tree sidebar.
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            separator = true,
            text_align = "left",
          },
        },
      },
    },
  },
}
-- Tip: `:BufferLinePick` (no default key — ask me to bind one) lets you jump to a
-- tab by typing a letter, like VSCode's Ctrl+number but for the buffer you can see.
