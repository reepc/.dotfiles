-- lua/plugins/indent.lua
-- VSCode-style, two independent 3-color cycles:
--   * Indent: a BACKGROUND rainbow — each indent level's whitespace BLOCK is
--     tinted (no visible guide line), cycling 3 subtle colors by depth. Like the
--     "indent-rainbow" VSCode extension.
--   * Brackets: 3 VIVID colors by nesting depth (gold / orchid / blue), handled
--     by rainbow-delimiters.lua.
--
-- How the background bands work: ibl renders each indent level as a char cell
-- plus filler whitespace. We blank the char (char = " ") and give BOTH
-- `indent.highlight` and `whitespace.highlight` the same 3 background groups, so
-- the whole level fills with one tint. ibl cycles the list per depth.
--
-- All color groups are (re)created in the HIGHLIGHT_SETUP hook so they survive a
-- colorscheme change. The vivid Rainbow* groups are also used by
-- rainbow-delimiters.lua — keep those names in sync.

-- Same 3 groups for the char cell and the filler so each level is a solid band.
local indent_hl = { "IndentRainbow1", "IndentRainbow2", "IndentRainbow3" }
-- Active-scope line: a SINGLE fg-only group (no bg, no per-depth cycling). It
-- only recolors the guide LINE of the block the cursor is in — it never sets a
-- background, so the rainbow band is never touched and there's no scope-index /
-- band-index alignment to get wrong. Robust regardless of code structure.
local scope_hl = "IndentScopeLine"

return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "HiPhish/rainbow-delimiters.nvim" },
		opts = function(_, opts)
			local hooks = require("ibl.hooks")

			-- Make a block's KEYWORD line highlight its OWN block (for/if/try),
			-- not the parent function. ibl's scope lookup resolves the node from
			-- COLUMN 0 of the cursor line (ibl.scope.get_cursor_range), and column 0
			-- sits in the parent's indentation — so on a `for`/`if` header line you
			-- get the enclosing function instead of the for/if. We override that one
			-- function to start the range at the line's FIRST NON-BLANK column, so
			-- the header resolves to its own statement node. (Runtime monkey-patch;
			-- ibl's get_cursor_range is tiny and stable, but revisit on ibl updates.)
			local sok, scope = pcall(require, "ibl.scope")
			if sok and scope then
				scope.get_cursor_range = function(win)
					local pos = vim.api.nvim_win_get_cursor(win)
					local row, col = pos[1] - 1, pos[2]
					local line = (vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), row, row + 1, false) or {})[1] or ""
					local first = line:find("%S")
					local start_col = first and first - 1 or col
					return { row, start_col, row, math.max(col, start_col) }
				end
			end

			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				-- Bracket colors pulled straight from the onedarkpro palette, so they
				-- track the active theme/flavor. pcall + hex fallback in case the helper
				-- isn't available. Swap the palette keys (red/orange/yellow/green/cyan/
				-- blue/purple) to recolor.
				local ok, helpers = pcall(require, "onedarkpro.helpers")
				local p = (ok and helpers.get_colors()) or {}
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = p.orange or "#d19a66" })
				vim.api.nvim_set_hl(0, "RainbowPurple", { fg = p.purple or "#c678dd" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = p.blue or "#61afef" })
				-- Indent guides: a faint guide LINE (fg) sitting on a subtle BACKGROUND
				-- band (bg) per depth. The fg shows on the ▏ char; on the filler spaces
				-- it's invisible, so the same group works for both indent + whitespace.
				-- bg tints = each hue blended ~12% over the editor background (#282c34).
				local line = p.gray or "#5c6370" -- inactive guide line (dim)
				local active = p.comment or "#7f848e" -- active-scope line (a bit lighter, not white)
				vim.api.nvim_set_hl(0, "IndentRainbow1", { fg = line, bg = "#42402e" }) -- gold band
				vim.api.nvim_set_hl(0, "IndentRainbow2", { fg = line, bg = "#3d3448" }) -- orchid band
				vim.api.nvim_set_hl(0, "IndentRainbow3", { fg = line, bg = "#263a4c" }) -- blue band
				-- Active-scope line: fg only, NO bg — lights up the line without
				-- recoloring the band. bold for a touch more presence (drop if unwanted).
				vim.api.nvim_set_hl(0, "IndentScopeLine", { fg = active, bold = true })
			end)

			opts.indent = {
				char = "▏", -- guide line, drawn in each band's fg color
				highlight = indent_hl,
			}
			opts.whitespace = {
				highlight = indent_hl, -- tint the filler whitespace too, so the band is solid
				remove_blankline_trail = false, -- keep the band on blank lines inside a block
			}

			-- Scope ON: only the guide LINE of the active block changes color
			-- (fg-only highlight, no bg), so the rainbow band is never recolored.
			-- No start/end underline. No scope-index trickery needed.
			opts.scope = {
				enabled = true,
				char = "▏",
				highlight = scope_hl,
				show_start = false,
				show_end = false,
				-- By default ibl's scope is SEMANTIC (functions/blocks), so it skips
				-- past a multi-line ( ) [ ] { } grouping and highlights the enclosing
				-- block instead. Include the grouping node types so the highlight
				-- stops at the bracket you're actually inside. Names are treesitter
				-- node types — this list covers the installed languages; add more if a
				-- language's grouping node has a different name.
				include = {
					node_type = {
						["*"] = {
							"argument_list",
							"arguments",
							"parameter_list",
							"parameters",
							"formal_parameters",
							"parenthesized_expression",
							"array",
							"array_expression",
							"list",
							"tuple",
							"tuple_expression",
							"table_constructor",
							"dictionary",
							"object",
							"set",
							"initializer_list",
							-- Indentation-only blocks (python for / if / else / while /
							-- try, no braces). We use the STATEMENT nodes, NOT the body
							-- `block`: ibl draws the scope guide one level deeper than where
							-- the scope node starts, and these nodes start at the keyword
							-- (correct level). The body `block` starts at the indented body
							-- itself, which made the guide land a level too deep (on the
							-- for/try body instead of below `def`).
							"if_statement",
							"elif_clause",
							"else_clause",
							"for_statement",
							"while_statement",
							"with_statement",
							"try_statement",
							"except_clause",
							"finally_clause",
							"match_statement",
							"case_clause",
							"switch_statement",
						},
					},
				},
			}

			return opts
		end,
	},
}
