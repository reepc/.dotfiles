-- lua/plugins/markdown.lua
-- In-editor markdown preview. This does NOT open a browser — it re-renders the
-- markdown right inside the nvim buffer: headings get styled, bullets get nice
-- icons, code blocks get a background, tables get drawn with box lines, etc.
-- It's "live" in the sense that it re-renders as you edit, and it cleverly shows
-- the raw markdown again on whichever line your cursor is sitting (so you can
-- still edit the source easily).
--
-- Needs the `markdown` and `markdown_inline` treesitter parsers (added in
-- lua/plugins/treesitter.lua) and an icon font for the nice glyphs (we already
-- have nvim-web-devicons via the editor/lualine setup).

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    -- Only load for markdown-ish files, so it costs nothing the rest of the time.
    ft = { "markdown", "markdown_inline" },
    opts = {},
    config = function(_, opts)
      require("render-markdown").setup(opts)
      -- Quick toggle between the pretty render and the plain raw markdown.
      vim.keymap.set("n", "<leader>mp", "<cmd>RenderMarkdown toggle<cr>", {
        desc = "Markdown: toggle preview",
      })
    end,
  },
}
