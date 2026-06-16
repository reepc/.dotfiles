-- lua/plugins/lsp.lua
-- The IDE brain: go-to-definition, hover docs, rename, diagnostics, code actions.
-- Three pieces work together:
--   1. mason.nvim        — installs the language SERVER binaries
--   2. mason-lspconfig   — bridges mason package names <-> nvim server names, auto-enables
--   3. nvim-lspconfig    — ships per-server default configs nvim consumes natively
--
-- Modern pattern (nvim 0.11+): configure servers with vim.lsp.config() and let
-- mason-lspconfig auto-enable them. The old setup_handlers pattern is deprecated.

return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim", config = true },
            "mason-org/mason-lspconfig.nvim",
        },
        config = function()
            ---------------------------------------------------------------------------
            -- Per-server settings via the native API.RRR
            ---------------------------------------------------------------------------

            -- Lua: teach it the `vim` global so it stops warning in your config files.
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                    },
                },
            })

            -- Python (basedpyright) — mirrored from your VSCode settings.json:
            --   python.analysis.typeCheckingMode            -> "basic"
            --   python.analysis.autoImportCompletions       -> true
            --   python.analysis.useLibraryCodeForTypes      -> true
            --   python.analysis.inlayHints.functionReturnTypes -> true (only this hint,
            --     matching your config; parameter/variable hints stay off)
            --
            -- NOTE: basedpyright resolves imports against whatever Python interpreter is
            -- active when nvim launches. Activate your conda env BEFORE starting nvim
            -- (or launch from within it). There is no "interpreter path" setting here —
            -- that VSCode line (python.defaultInterpreterPath) has no LSP equivalent.
            vim.lsp.config("basedpyright", {
                settings = {
                    basedpyright = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoImportCompletions = true,
                            useLibraryCodeForTypes = true,
                            inlayHints = {
                                callArgumentNames = false,
                                variableTypes = false,
                                functionReturnTypes = true,
                                genericTypes = false,
                            },
                        },
                    },
                },
            })

            vim.lsp.config("ruff", {
                init_options = {
                    settings = {
                        lineLength = 120,        -- raise the ceiling, OR…
                        lint = {
                            ignore = { "E501" }, -- …silence the rule entirely
                        },
                    },
                },
            })

            ---------------------------------------------------------------------------
            -- Install + auto-enable servers for your stack.
            ---------------------------------------------------------------------------
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "rust_analyzer", -- Rust (clippy lint is bundled in)
                    "clangd",        -- C / C++
                    "ts_ls",         -- TypeScript / TSX / JS
                    "basedpyright",  -- Python (semantic intelligence + type checking)
                    "ruff",          -- Python linting/formatting (delivered as an LSP server)
                    "lua_ls",        -- Lua (for editing this config)
                    "bashls",        -- shell scripts
                    -- "eslint",      -- uncomment for TS/React ESLint rules (you do React;
                    --   add when you want lint rules firing in .tsx files)
                },
                -- automatic_enable defaults to true: installed servers start automatically.
            })

            ---------------------------------------------------------------------------
            -- LSP keymaps — only active in buffers where a server has attached.
            ---------------------------------------------------------------------------
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local map = function(keys, fn, desc)
                        vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
                    end
                    map("gd", require('telescope.builtin').lsp_definitions, "Go to definition")
                    map("gr", require('telescope.builtin').lsp_references, "Find references")
                    map("K", vim.lsp.buf.hover, "Hover docs")
                    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("<leader>e", vim.diagnostic.open_float, "Show line diagnostics")
                    map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
                    map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")

                    -- Inlay hints: VSCode showed function return types inline. This turns the
                    -- nvim equivalent ON for any server that supports it (basedpyright does).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client:supports_method("textDocument/inlayHint") then
                        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
                    end
                end,
            })
        end,
    },
}
