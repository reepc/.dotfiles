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
        preset = "super-tab", -- <Tab> to accept, <Up>/<Down> or <C-p>/<C-n> to move, <C-space> to open
        -- <Tab> also jumps forward through snippet placeholders; <S-Tab> jumps back.
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
      -- Suggests commands, their arguments, file paths, etc.
      cmdline = {
        -- Keys for the `:` popup. We deliberately do NOT inherit super-tab here,
        -- because that would steal <Up>/<Down> for menu selection — and on the
        -- command line those arrows are Vim's command HISTORY (recall previous
        -- `:` commands), which we want to keep.
        --   <Tab>          accept the suggestion (selects the first item if none is)
        --   <C-n> / <C-p>  move down/up through the menu (from the cmdline preset)
        --   <Up> / <Down>  left unbound -> native command-line history
        --   <C-space>      open the menu manually
        keymap = {
          preset = "cmdline",
          ["<Tab>"] = { "select_and_accept", "fallback" },
        },
        completion = {
          menu = { auto_show = true },
        },
      },
    },
  },
}