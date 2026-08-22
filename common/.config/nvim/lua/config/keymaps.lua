-- lua/config/keymaps.lua
-- Your custom keybindings. The pattern is:
--   vim.keymap.set(mode, keys, action, { desc = "what it does" })
-- modes: "n" = normal, "i" = insert, "v" = visual, "t" = terminal
-- The `desc` shows up in which-key (the popup that lists available keys) — always add it.

local map = vim.keymap.set

-- Neutralize a bare <Space>. <Space> is the leader, but on its own it's also a
-- default motion (move cursor right). Without this, any INCOMPLETE leader
-- sequence falls through to that motion — e.g. <Space>rn before an LSP has
-- attached becomes "move right, then `r` replace-char with `n`", silently
-- mangling the file. <Nop> makes the worst case "nothing happens" instead.
map("n", "<Space>", "<Nop>", { silent = true })

-- Global rename fallback. The real <leader>rn is set buffer-locally on
-- LspAttach (lua/plugins/lsp.lua), so during basedpyright's cold start it
-- doesn't exist yet. This global mapping covers that gap: with no rename-capable
-- client it just prints "No matching language servers" instead of doing damage.
-- The buffer-local map still wins once the server attaches.
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })

-- Clear search highlight by pressing Esc in normal mode.
-- After a search, matches stay highlighted; this is the quick way to dismiss them.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Save and quit shortcuts (your VSCode Cmd+S muscle memory replacement).
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })

-- Window navigation with Ctrl + h/j/k/l is provided by vim-tmux-navigator
-- (lua/plugins/tmux-navigator.lua), so the same keys also cross into tmux panes.

-- Move selected lines up/down in visual mode (J/K). Handy for reordering code.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when jumping through search results so your eyes don't
-- lose it. (Half-page <C-d>/<C-u> centering is handled by neoscroll.nvim now —
-- it keeps the cursor at the same screen row while it animates the scroll.)
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

-- Indent / outdent the selection with Tab / Shift-Tab (VSCode muscle memory).
-- `gv` reselects the same block afterward so you can press Tab repeatedly.
map("v", "<Tab>", ">gv", { desc = "Indent selection" })
map("v", "<S-Tab>", "<gv", { desc = "Outdent selection" })

-- In visual mode, paste over a selection WITHOUT clobbering your yank register.
-- Normally pasting over text copies the deleted text; this keeps what you originally yanked.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking selection" })

-- Copy file path
map("n", "<leader>pa", '<cmd>let @+ = expand("%:p")<cr>', { desc = "Copy absolute path" })
map("n", "<leader>pr", '<cmd>let @+ = expand("%")<cr>', { desc = "Copy relative path" })
map("n", "<leader>pf", '<cmd>let @+ = expand("%:t")<cr>', { desc = "Copy file name" })
