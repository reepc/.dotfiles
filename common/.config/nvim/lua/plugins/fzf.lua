-- lua/plugins/fzf.lua
-- fzf-lua is your fuzzy finder — this replaces VSCode's Cmd+P (find file),
-- Cmd+Shift+F (find in files), and Cmd+T (find symbol) all in one tool.
-- It wraps the external `fzf` binary, so it stays fast even on huge projects.

return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- file-type icons in the picker

		-- By default `fd` (file finder) and `rg` (grep) skip dotfiles. We pass
		-- `--hidden` so files/dirs starting with `.` show up, while still excluding
		-- the `.git` directory so the picker isn't flooded with git internals.
		opts = {
			files = {
				fd_opts = [[--color=never --type f --type l --hidden --follow --exclude .git]],
				rg_opts = [[--color=never --files --hidden --follow -g "!.git"]],
			},
			grep = {
				rg_opts = [[--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g "!.git" -e]],
			},
			buffers = {
				-- Drop the buffer you're already in from the list, so the top entry is
				-- the buffer you were in last — one <CR> flips you back to it (alt-tab feel).
				ignore_current_buffer = true,
			},
		},

		-- LSP pickers (gd/gr/gri) only encode file:line:col, so the preview would
		-- normally highlight a single character at the start of the word. We re-derive
		-- the word's end column from the previewed buffer and stash it as `end_col` so
		-- fzf-lua highlights the whole identifier (like a grep match).
		config = function(_, opts)
			local fzf = require("fzf-lua")
			fzf.setup(opts)

			local previewer = require("fzf-lua.previewer.builtin")
			local orig_set_cursor_hl = previewer.buffer_or_file.set_cursor_hl
			previewer.buffer_or_file.set_cursor_hl = function(self, entry)
				if
					entry
					and entry.line
					and entry.line > 0
					and entry.col
					and entry.col > 0
					and not entry.end_col
					and self.preview_bufnr
				then
					local line = vim.api.nvim_buf_get_lines(
						self.preview_bufnr,
						entry.line - 1,
						entry.line,
						false
					)[1]
					if line then
						-- Find the identifier that starts exactly at the cursor column.
						local s, e = line:find("[%w_]+", entry.col)
						if s == entry.col and e then
							entry.end_col = e + 1 -- previewer maps this to an exclusive range
							entry.hlgroup = "FzfLuaSearch" -- match the grep word-highlight look
						end
					end
				end
				return orig_set_cursor_hl(self, entry)
			end
		end,

		keys = {
			{
				"<leader>ff",
				function()
					require("fzf-lua").files()
				end,
				desc = "Find files (same as Cmd+P)",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Find in files (grep)",
			},
			{
				"<leader>fb",
				function()
					require("fzf-lua").buffers()
				end,
				desc = "Find open buffers",
			},
			{
				"<leader>fh",
				function()
					require("fzf-lua").helptags()
				end,
				desc = "Search help docs",
			},
			{
				"<leader>fs",
				function()
					require("fzf-lua").lsp_document_symbols()
				end,
				desc = "Find symbols in file",
			},
		},
	},
}
-- Note: live_grep needs ripgrep (`rg`) installed, and the picker itself needs
-- the `fzf` binary on the system/server.
-- On the remote: `sudo apt install ripgrep fzf`. On mac: `brew install ripgrep fzf`.
