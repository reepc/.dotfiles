-- lua/plugins/breadcrumbs.lua
-- VSCode-style breadcrumbs: a winbar across the TOP of each editor window showing
-- where the cursor is in the file's structure, e.g.  file › MyClass › my_method.
-- Two plugins cooperate:
--   nvim-navic  — asks the LSP "what symbol is the cursor inside?" and formats it
--   barbecue    — renders navic's answer into the winbar (with a file path prefix)
--
-- Why attach navic ourselves (attach_navic = false below): on Python buffers you
-- run THREE servers (basedpyright + ty + ruff). If barbecue auto-attached, navic
-- would try to bind to each one and warn "attaching more than one server". We
-- instead attach exactly the server that provides document symbols, in the
-- LspAttach autocmd in lua/plugins/lsp.lua.

return {
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "SmiteshP/nvim-navic",         -- the LSP-driven "where am I" engine
      "nvim-tree/nvim-web-devicons", -- file/symbol icons (needs a Nerd Font)
    },
    opts = {
      attach_navic = false, -- we attach navic ourselves (see lsp.lua LspAttach)
      show_modified = true, -- mark the winbar when the buffer has unsaved changes
      theme = "auto",       -- follow the active colorscheme
      -- Don't draw the bar in special buffers (neo-tree, alpha, oil, trouble…)
      -- where a code path makes no sense.
      exclude_filetypes = { "netrw", "toggleterm", "alpha", "oil", "neo-tree", "trouble" },
    },
  },
}
