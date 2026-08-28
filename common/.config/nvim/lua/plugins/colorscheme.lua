-- lua/plugins/colorscheme.lua
-- A plugin spec is just a Lua table that returns plugin definitions.
-- The first string is the GitHub "owner/repo". lazy.nvim downloads it for you.

return {
	{
		"olimorris/onedarkpro.nvim",
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("onedarkpro").setup({
				options = {
					cursorline = true,
					-- Let Ghostty's `background-opacity` show through. Neovim otherwise
					-- paints an opaque bg over the entire terminal grid, so the window
					-- goes solid the moment you open a file — the transparency would
					-- only ever be visible at a bare shell prompt.
					transparency = true,
				},
				styles = {
					-- Italicize function/method parameters, like VSCode's One Dark Pro.
					comments = "italic",
					parameters = "italic",
				},
				-- onedarkpro captures import module names as `@odp.import_module` at
				-- treesitter priority 126 — ABOVE LSP semantic tokens (125) — and colors
				-- them the plain foreground (gray). That high priority means the gray
				-- always wins, so imports never pick up the language server's coloring.
				-- Clearing the group (empty table = a real `nvim_set_hl(0, name, {})`)
				-- makes it contribute NO foreground, so the color falls through to the
				-- semantic token underneath — i.e. the LSP colors imports (a class import
				-- gold, a namespace its own color, etc.). We clear both the base group and
				-- the language-suffixed `.python`, since neovim looks the suffixed one up
				-- first and it would otherwise shadow the base. Set via `highlights` (not a
				-- ColorScheme autocmd) because onedarkpro applies these LAST, after its own
				-- filetype defaults — so there's no ordering race.
				highlights = {
					["@odp.import_module"] = {},
					["@odp.import_module.python"] = {},
					-- Python namespaces (e.g. `os` in `os.path`) render RED by default,
					-- which reads like a variable. basedpyright tags them as an LSP
					-- `namespace` token, but onedarkpro links `@lsp.type.namespace` to the
					-- `@namespace` group — which is EMPTY (no fg). An empty semantic-token
					-- group contributes nothing, so the treesitter layer underneath wins:
					-- a bare identifier is `@variable` -> red. We instead link the namespace
					-- token to `@module` (onedarkpro's canonical namespace group, yellow) so
					-- namespaces match classes. Scoped to `.python` via the filetype suffix,
					-- which neovim looks up before the base group.
					["@lsp.type.namespace.python"] = { link = "@module" },

					-- `transparency` blanks NormalFloat/FloatBorder too, which leaves
					-- hover docs, fzf popups and which-key reading straight over the
					-- desktop. Floats are meant to sit ABOVE the buffer, so give them
					-- back a solid background. `${float_bg}` is the theme's OWN generated
					-- float shade (onedarkpro substitutes `${...}` from its palette), so
					-- this restores the stock look rather than inventing a new color.
					-- Pmenu is already opaque under transparency and needs no override.
					NormalFloat = { bg = "${float_bg}" },
					FloatBorder = { bg = "${float_bg}", fg = "${gray}" },

					-- nvim-notify (via noice) defaults `background_colour` to the
					-- NotifyBackground group, which ships only as `hi default link
					-- NotifyBackground Normal`. Transparent Normal means that lookup finds
					-- no bg, so notify warns on every session and falls back to pure black
					-- — wrong for this theme. Defining the group here beats the `default`
					-- link and keeps notifications matching the other floats.
					NotifyBackground = { bg = "${float_bg}" },
				},
			})

			-- (Import-module coloring is handled in `highlights` above — we clear the
			-- group so the LSP colors imports instead of onedarkpro's gray override.)
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "onedark*",
				callback = function()
					-- Diagnostics: use a straight underline instead of a wavy
					-- undercurl — undercurl doesn't render over SSH/plain terminals,
					-- and a straight line is the preferred look anyway. We keep each
					-- group's existing color (sp) and just flip underline on.
					for _, group in ipairs({
						"DiagnosticUnderlineError",
						"DiagnosticUnderlineWarn",
						"DiagnosticUnderlineInfo",
						"DiagnosticUnderlineHint",
					}) do
						local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
						hl.undercurl = false
						hl.underline = true
						vim.api.nvim_set_hl(0, group, hl)
					end
				end,
			})
		end,
	},

	{
		"catppuccin/nvim",
		name = "catppuccin",
		-- lazy = false,
		opts = {
			flavour = "macchiato", -- latte, frappe, macchiato, mocha
		},
	},
}
