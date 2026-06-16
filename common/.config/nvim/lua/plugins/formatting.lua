-- lua/plugins/formatting.lua
-- Format-on-save, the VSCode "editor.formatOnSave" equivalent.
-- conform.nvim runs a dedicated formatter per filetype on :w. Where no external
-- formatter is configured/installed, it falls back to the LSP's own formatting
-- (rust_analyzer, clangd, ruff all format via LSP), so this works immediately and
-- gets better as you install the standalone tools.
--
-- Installing the external formatters: open `:Mason`, search, and press `i` on:
--   stylua (Lua), prettier (JS/TS/JSON/YAML/Markdown), shfmt (shell),
--   clang-format (C/C++). rustfmt ships with Rust; ruff you already have.
-- Until a tool is installed, that filetype just uses LSP formatting instead.

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- load right before the first save
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer/selection",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        -- ruff_format = formatting, ruff_organize_imports = sort imports (like isort)
        python = { "ruff_format", "ruff_organize_imports" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        sh = { "shfmt" },
      },
      -- Format on save, with two escape hatches (toggled by the commands below).
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        -- lsp_format = "fallback": if the filetype's external formatter isn't
        -- installed, use the LSP formatter instead of doing nothing.
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
    },
    config = function(_, opts)
      require("conform").setup(opts)

      -- :FormatDisable        -> turn off format-on-save globally
      -- :FormatDisable!       -> turn it off for just this buffer
      -- :FormatEnable         -> turn it back on
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = "Disable format-on-save", bang = true })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable format-on-save" })
    end,
  },
}
