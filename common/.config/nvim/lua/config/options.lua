-- lua/config/options.lua
-- Editor behavior. `vim.opt.X = Y` is the Lua way of writing the old `:set X=Y`.
-- Every line here is something you'd otherwise toggle manually. Read the comments —
-- this file is where you'll tweak the "feel" of the editor most often.

local opt = vim.opt
vim.g.have_nerd_font = true -- for statusline icons; set to false if you don't have a nerd font installed

-- === Line numbers ===
opt.number = true            -- show absolute line number on the current line
opt.relativenumber = true    -- show relative numbers on other lines.
                             -- This is a Vim superpower: it lets you do `5j` to jump
                             -- down 5 lines, `8dd` to delete 8 lines, etc. without counting.
                             -- If it confuses you at first, set this to false.

-- === Indentation ===
opt.tabstop = 4              -- a tab character displays as 4 spaces wide
opt.shiftwidth = 4           -- one indent level = 4 spaces
opt.expandtab = true         -- pressing Tab inserts spaces, not a tab character
opt.smartindent = true       -- auto-indent new lines based on context
-- Note: for JS/TS/React, 2 spaces is the community norm. Treesitter + the LSP
-- formatter usually handle per-language indent; we can add filetype overrides later.

-- === Search ===
opt.ignorecase = true        -- searching is case-insensitive...
opt.smartcase = true         -- ...UNLESS you type a capital letter, then it's case-sensitive
opt.hlsearch = true          -- highlight all matches (clear them with the keymap we set later)
opt.incsearch = true         -- jump to matches as you type the search

-- === Appearance ===
opt.termguicolors = true     -- enable 24-bit color. CRITICAL over SSH/tmux or themes look washed out.
opt.signcolumn = "yes"       -- always show the left gutter (for git signs, diagnostics)
                             -- so text doesn't jump around when signs appear
opt.cursorline = true        -- highlight the line the cursor is on
opt.scrolloff = 8            -- keep 8 lines visible above/below cursor when scrolling
opt.wrap = false             -- don't wrap long lines (toggle later if you prefer wrapping)

-- === Editing behavior ===
opt.mouse = "a"              -- enable mouse — yes, even though you're learning motions.
                             -- It's a safety net, not a crutch. Remove it later if you want to force yourself.
-- === Clipboard (OSC52) ===
-- `unnamedplus` makes y / d / p use the system clipboard (the `+` register), so
-- copy & paste "just work" like a normal editor.
opt.clipboard = "unnamedplus"
-- Over SSH there's no local clipboard to reach. OSC52 is an escape sequence that
-- tells YOUR terminal emulator to copy text into your real machine's clipboard.
-- Neovim 0.10+ ships this provider built-in. We only swap the provider in when
-- inside an SSH session; locally nvim already uses pbcopy/wl-copy/xclip.
-- Paste reads from Neovim's own register (not the terminal) to avoid the hangs
-- some terminals cause when queried — to paste FROM your local clipboard over
-- SSH, use the terminal's own paste (Cmd/Ctrl+V) in insert mode.
if os.getenv("SSH_TTY") then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
opt.undofile = true          -- persist undo history to disk — undo even after closing a file
opt.swapfile = false         -- no swap files (they cause "file already open" annoyances)

-- === Splits (where new windows open) ===
opt.splitright = true        -- vertical splits open to the right
opt.splitbelow = true        -- horizontal splits open below

-- === Timing ===
opt.updatetime = 250         -- faster response for diagnostics/hover (default 4000ms is sluggish)
opt.timeoutlen = 400         -- how long to wait for a multi-key mapping (e.g. leader sequences)