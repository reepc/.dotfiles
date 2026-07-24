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
			-- Diagnostic gutter signs: swap the default E/W/I/H letters for Nerd Font
			-- icons (needs a Nerd Font in the terminal — we set have_nerd_font = true).
			---------------------------------------------------------------------------
			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.INFO] = "",
						[vim.diagnostic.severity.HINT] = "",
					},
				},
				-- Kill the inline message at the end of the line — we show it in a float
				-- (the CursorHold autocmd below) instead, so it reads like a hover popup.
				virtual_text = false,
				-- Keep the squiggly underline so you can still SEE where problems are.
				underline = true,
				float = {
					border = "rounded", -- match the gd/gr/hover popups
					source = true, -- show which linter/server raised it (ruff, basedpyright…)
					focusable = false, -- don't steal focus; it dismisses as you move
				},
			})

			---------------------------------------------------------------------------
			-- Auto-popup: when the cursor rests on a line (updatetime = 250ms, set in
			-- options.lua), show that line's diagnostics in a float. Moving the cursor
			-- dismisses it automatically. <leader>e still opens it on demand.
			---------------------------------------------------------------------------
			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					vim.diagnostic.open_float(nil, { scope = "cursor" })
				end,
			})

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

			-- Python split-brain setup (tuned for a large env on a CPU-limited remote):
			--   basedpyright -> completion / hover / go-to-def / rename  (mature, kept)
			--   ty           -> type-error diagnostics                   (Rust, fast)
			--   ruff         -> lint + format + import sort
			-- basedpyright's own type checking is turned OFF (typeCheckingMode = "off")
			-- because the whole-file/project type-check pass is what pins a CPU core on a
			-- big environment. ty does that job far faster, so basedpyright is left to do
			-- only the things it's still best at (completion/hover/navigation).
			--
			-- Remaining VSCode-mirrored settings:
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
							typeCheckingMode = "off", -- type checking delegated to ty; this kills the heavy pass
							autoImportCompletions = false,
							useLibraryCodeForTypes = false,
							inlayHints = {
								callArgumentNames = false,
								variableTypes = false, -- `self.x: SomeType` inline annotations
								functionReturnTypes = true, -- `-> ReturnType` on def lines
								genericTypes = false,
							},
						},
					},
				},
			})

			vim.lsp.config("ruff", {
				-- Force ruff onto the SAME position encoding as basedpyright (utf-16).
				-- basedpyright/pyright only speak utf-16; ruff defaults to utf-8. When two
				-- clients on one buffer disagree, position math desyncs after the first
				-- multibyte (e.g. CJK / accented / emoji) character, so completion and
				-- hover silently stop working in any file that contains non-ASCII text —
				-- while a fresh ASCII-only buffer works fine. `general.positionEncodings`
				-- is the LSP-standard negotiation key; the old clangd-style `offsetEncoding`
				-- below is kept only as a fallback (ruff ignores it).
				capabilities = {
					offsetEncoding = "utf-16",
					general = { positionEncodings = { "utf-16" } },
				},
				init_options = {
					settings = {
						-- By default ruff is "filesystemFirst": a project's pyproject.toml /
						-- ruff.toml WINS over anything set here, so lineLength below is ignored
						-- when a project config exists (that's why you still saw the 79 limit).
						-- "editorFirst" makes these editor settings take priority over the file;
						-- use "editorOnly" to ignore project config files completely.
						configurationPreference = "editorFirst",
						lineLength = 120, -- raise the ceiling, OR…
						lint = {
							ignore = { "E501" }, -- …silence the rule entirely
						},
					},
				},
			})

			-- ty (astral-sh/ty): the fast Rust type checker that REPLACES basedpyright's
			-- type-checking pass. Pin it to utf-16 for the same reason as ruff above — it
			-- shares Python buffers with basedpyright (utf-16 only), and a mismatch desyncs
			-- positions after the first multibyte char. ty is still preview-quality, so we
			-- keep basedpyright for completion/hover and only lean on ty for type errors.
			vim.lsp.config("ty", {
				capabilities = {
					general = { positionEncodings = { "utf-16" } },
				},
			})

			---------------------------------------------------------------------------
			-- Install + auto-enable servers for your stack.
			---------------------------------------------------------------------------
			require("mason-lspconfig").setup({
				ensure_installed = {
					"rust_analyzer", -- Rust (clippy lint is bundled in)
					"clangd", -- C / C++
					"vtsls",
					"basedpyright", -- Python: completion / hover / navigation (type checking OFF)
					"ty", -- Python: fast Rust type-error diagnostics (replaces pyright checking)
					"ruff", -- Python linting/formatting (delivered as an LSP server)
					"lua_ls", -- Lua (for editing this config)
					"bashls", -- shell scripts
					"eslint", -- uncomment for TS/React ESLint rules (you do React;
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
					map("gd", require("fzf-lua").lsp_definitions, "Go to definition")
					map("gr", require("fzf-lua").lsp_references, "Find references")
					-- Overrides nvim 0.11's built-in `gri` (which uses the quickfix list)
					-- with the fzf-lua picker, matching the gd/gr popup. Shows subclass
					-- overrides / concrete implementations of the symbol under the cursor.
					map("gri", require("fzf-lua").lsp_implementations, "Go to implementations")
					map("K", vim.lsp.buf.hover, "Hover docs")
					map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("<leader>e", vim.diagnostic.open_float, "Show line diagnostics")
					-- Copy the current line's diagnostic message(s) to the system clipboard.
					map("<leader>cd", function()
						local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
						local diags = vim.diagnostic.get(0, { lnum = lnum })
						if vim.tbl_isempty(diags) then
							vim.notify("No diagnostics on this line", vim.log.levels.INFO)
							return
						end
						local msgs = {}
						for _, d in ipairs(diags) do
							table.insert(msgs, d.message)
						end
						local text = table.concat(msgs, "\n")
						vim.fn.setreg("+", text) -- "+ = system clipboard
						vim.notify("Copied diagnostic:\n" .. text)
					end, "Copy line diagnostic(s)")
					-- Browse ALL diagnostics in the same centered fzf-lua popup as gd/gr.
					-- <leader>fd = file/buffer only; <leader>fD = whole workspace.
					map("<leader>fd", function()
						require("fzf-lua").diagnostics_document()
					end, "Diagnostics (buffer popup)")
					map("<leader>fD", require("fzf-lua").diagnostics_workspace, "Diagnostics (workspace popup)")
					map("[d", function()
						vim.diagnostic.jump({ count = -1 })
					end, "Previous diagnostic")
					map("]d", function()
						vim.diagnostic.jump({ count = 1 })
					end, "Next diagnostic")

					-- Inlay hints (VSCode-style inline types) — ON by default, toggle with
					-- <leader>uh. ty's inlay hints are buggy over SSH with multibyte (CJK)
					-- files — they land at columns past end-of-line and the renderer spams
					--   inlay_hint.lua: Invalid 'col': out of range (nvim_buf_set_extmark)
					-- so we drop ty's inlay-hint capability and let ONLY basedpyright's
					-- well-positioned hints render. Which hint categories show is controlled
					-- by basedpyright's inlayHints settings above (variable + return types).
					--
					-- ty ALSO advertises definition/references/implementation/hover/symbols,
					-- so it answers navigation requests too. fzf-lua's lsp_definitions /
					-- lsp_references / lsp_implementations fan out to EVERY attached client
					-- and merge results — with both basedpyright and ty replying, every gd/gr/
					-- gri location showed up twice. ty is diagnostics-only in this setup, so
					-- strip all of its non-diagnostic providers and let basedpyright own
					-- navigation/hover/symbols outright (no duplicates, single source of truth).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.name == "ty" then
						client.server_capabilities.inlayHintProvider = nil
						client.server_capabilities.definitionProvider = nil
						client.server_capabilities.typeDefinitionProvider = nil
						client.server_capabilities.declarationProvider = nil
						client.server_capabilities.implementationProvider = nil
						client.server_capabilities.referencesProvider = nil
						client.server_capabilities.hoverProvider = nil
						client.server_capabilities.documentSymbolProvider = nil
						client.server_capabilities.completionProvider = nil
					end

					-- Breadcrumbs (barbecue winbar) are driven by nvim-navic. navic supports
					-- only ONE server per buffer — and on Python BOTH basedpyright and ty
					-- advertise documentSymbol, so a naive attach makes the second one warn
					-- "Already attached to <other>". We attach the first symbol-capable
					-- client and then skip the rest via navic.is_available().
					if client and client.server_capabilities.documentSymbolProvider then
						local ok, navic = pcall(require, "nvim-navic")
						if ok and not navic.is_available(event.buf) then
							navic.attach(client, event.buf)
						end
					end
					if client and client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
					end
					map("<leader>uh", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
							{ bufnr = event.buf }
						)
					end, "Toggle inlay hints")
				end,
			})
		end,
	},
}
