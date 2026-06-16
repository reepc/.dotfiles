-- lua/plugins/completion.lua
-- The autocomplete popup (like VSCode's IntelliSense). It pulls suggestions from
-- the LSP, open buffers, file paths, and snippets.
--
-- We use blink.cmp — it's the current community favorite for new configs: fast,
-- batteries-included, and much less wiring than the older nvim-cmp + 6 source plugins.
-- (nvim-cmp is still great and more configurable; blink is the "just works" choice.)

return {
  {
    "saghen/blink.cmp",
    version = "*", -- use the latest release tag
    dependencies = { "rafamadriz/friendly-snippets" }, -- a big library of ready-made snippets
    opts = {
      -- `opts` is shorthand: lazy.nvim passes this table to require("blink.cmp").setup(opts).
      keymap = {
        preset = "default", -- <C-y> to accept, <C-n>/<C-p> to cycle, <C-space> to open
        -- If you want Tab to accept (VSCode-like), change the preset to "enter" or
        -- define custom keys. Ask me and I'll wire your preferred style.
      },
      appearance = { nerd_font_variant = "mono" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        documentation = { auto_show = true }, -- show docs popup next to suggestions
      },
      -- Command-line completion: when you press `:` and start typing a command,
      -- show the same dropdown automatically (instead of only on <Tab>).
      -- Suggests commands, their arguments, file paths, etc. Same keys as above:
      -- <C-n>/<C-p> to move, <C-y> to accept.
      cmdline = {
        completion = {
          menu = { auto_show = true },
        },
      },
    },
  },
}