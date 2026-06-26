-- lua/config/keymaps.lua
-- Your custom keybindings. The pattern is:
--   vim.keymap.set(mode, keys, action, { desc = "what it does" })
-- modes: "n" = normal, "i" = insert, "v" = visual, "t" = terminal
-- The `desc` shows up in which-key (the popup that lists available keys) — always add it.

local map = vim.keymap.set

-- Clear search highlight by pressing Esc in normal mode.
-- After a search, matches stay highlighted; this is the quick way to dismiss them.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Save and quit shortcuts (your VSCode Cmd+S muscle memory replacement).
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })

-- Window navigation with Ctrl + h/j/k/l instead of Ctrl-w then h/j/k/l.
-- Once you have splits open, this moves between them.
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Move selected lines up/down in visual mode (J/K). Handy for reordering code.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when jumping half-pages and through search results.
-- Small quality-of-life thing — your eyes don't lose the cursor.
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })

map("n", "U", "<C-r>", { desc = "Redo" })

-- Toggle focus between the neo-tree file explorer and your code with one key.
-- If you're IN the tree, jump back to the previous (code) window.
-- If you're in code, focus the tree — opening it first if it isn't visible.
map("n", "<leader>E", function()
	if vim.bo.filetype == "neo-tree" then
		vim.cmd.wincmd("p") -- back to the window you came from
	else
		vim.cmd("Neotree focus") -- open (if needed) and move cursor into the tree
	end
end, { desc = "Toggle focus: explorer <-> code" })

-- In visual mode, paste over a selection WITHOUT clobbering your yank register.
-- Normally pasting over text copies the deleted text; this keeps what you originally yanked.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking selection" })

