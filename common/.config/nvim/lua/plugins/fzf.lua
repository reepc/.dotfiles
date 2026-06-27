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
		},

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
