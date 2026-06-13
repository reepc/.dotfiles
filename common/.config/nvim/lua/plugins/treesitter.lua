-- lua/plugins/treesitter.lua
-- Treesitter gives you proper syntax highlighting and code-aware features.
-- It parses your code into a real syntax tree instead of guessing with regex,
-- so highlighting is accurate and you get things like smart selection.
--
-- IMPORTANT: nvim-treesitter's old `master` branch was archived in April 2026.
-- The current branch is `main`, which has a DIFFERENT setup API than most
-- older tutorials show. The config below uses the current `main`-branch approach.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- the current branch (the old `master` is archived)
    lazy = false,
    build = ":TSUpdate", -- recompile parsers after install/update
    config = function()
      require("nvim-treesitter").setup()

      -- Install the parsers for your languages. On the `main` branch you install
      -- via the .install() function rather than the old `ensure_installed` table.
      require("nvim-treesitter").install({
        "rust",
        "c",
        "cpp",
        "typescript",
        "tsx",
        "javascript",
        "jsx",
        "python",
        "bash",
        "lua",
        "vimdoc",   -- for nvim help files
        "json",
        "yaml",
        "toml",
        "markdown",
      })

      -- On the main branch, highlighting is enabled per-buffer via an autocmd
      -- rather than a global `highlight = { enable = true }` flag.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          -- pcall = "protected call" — won't error out on filetypes with no parser
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}