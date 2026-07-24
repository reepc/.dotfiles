-- lua/plugins/tmux-navigator.lua
-- vim-tmux-navigator — one set of keys (Ctrl + h/j/k/l) to move between BOTH
-- Neovim splits and tmux panes. When the cursor is at the edge of a nvim split
-- and you keep going, the same keystroke crosses seamlessly into the adjacent
-- tmux pane (and back). No more mental context switch between "vim windows" and
-- "tmux panes" — it's all just h/j/k/l.
--
-- Needs the matching tmux side (see ~/.config/tmux/tmux.conf: the
-- `christoomey/vim-tmux-navigator` tpm plugin) so tmux knows to forward the
-- keys to nvim instead of stealing them.

return {
  {
    "christoomey/vim-tmux-navigator",
    -- Load only when one of the navigate commands/keys is first used.
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left window/pane" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower window/pane" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper window/pane" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right window/pane" },
    },
  },
}
