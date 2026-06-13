return {
  {
    "folke/noice.nvim",
    event = "VeryLazy", -- load after startup; UI polish isn't needed instantly
    dependencies = {
      "MunifTanjim/nui.nvim",   -- required: the floating-window rendering library
      "rcarriga/nvim-notify",   -- optional: nice notification popups (falls back to mini if absent)
    },
    opts = {
      presets = {
        -- These presets are the easy way to get common behaviors without hand-config.
        command_palette = true,      -- cmdline + completion together, centered (the "palette" look)
        bottom_search = true,        -- keep `/` search at the bottom (set false to float it too)
        long_message_to_split = true,-- send very long messages to a split instead of a popup
        lsp_doc_border = true,       -- add a border to LSP hover/signature popups
      },
    },
  },
}
