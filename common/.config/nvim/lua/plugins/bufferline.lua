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
      { "<leader>bj", "<cmd>BufferLinePick<CR>",        desc = "Pick buffer (type letter)" },
      { "<leader>bd", "<cmd>bdelete<CR>",               desc = "Close buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>",   desc = "Pin/unpin buffer" },
    },
    -- Blend the tab-bar fill into the editor's Normal background so the bottom edge
    -- of the bufferline doesn't show a seam against the buffer below it. Re-applied
    -- on every ColorScheme load because onedarkpro otherwise overwrites these groups.
    config = function(_, opts)
      require("bufferline").setup(opts)
      local function blend_fill()
        -- Tab-bar fill matches the editor background (removes the bottom-edge seam).
        vim.api.nvim_set_hl(0, "BufferLineFill", { link = "Normal" })
        -- The neo-tree offset block and the window separator both sit on the left
        -- boundary of the file explorer. Link them to WinSeparator so they read as
        -- one subtle line instead of a dark block overlapping the corner.
        vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator", { link = "WinSeparator" })
        -- Keep a thin, visible divider between the file explorer and the buffer,
        -- but a muted grey one — not the dark contrasting block we had before.
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#3b4048" })
      end
      vim.api.nvim_create_autocmd("ColorScheme", { callback = blend_fill })
      blend_fill()
    end,
    opts = {
      options = {
        diagnostics = "nvim_lsp",          -- show LSP error/warn counts on each tab
        always_show_bufferline = true,
        -- Hide the empty, unnamed scratch buffer Vim always opens at startup, so it
        -- doesn't sit as a stray "[No Name]" tab next to the alpha dashboard. A buffer
        -- earns a tab once it has a filename, unsaved edits, or any real content.
        custom_filter = function(buf)
          if vim.api.nvim_buf_get_name(buf) ~= "" then return true end -- has a file
          if vim.bo[buf].modified then return true end                 -- unsaved edits
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          return not (#lines <= 1 and (lines[1] or "") == "")          -- has content
        end,
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
-- Tip: <leader>bj runs `:BufferLinePick` — every tab gets a letter overlay, press
-- the letter to jump straight to that buffer, like VSCode's Ctrl+number.
