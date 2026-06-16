-- lua/plugins/terminal.lua
-- An integrated terminal you can pop open without leaving Neovim — your VSCode
-- Ctrl+` equivalent. toggleterm manages the terminal buffer/window for you.
--
-- Default keys (set via open_mapping below):
--   <C-\>            toggle a floating terminal
-- Inside the terminal, press <C-\> again to hide it, or type `exit` to close it.
-- To get from terminal mode back to normal mode (to scroll/copy), press <C-\><C-n>.

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { [[<C-\>]], desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>",      desc = "Terminal (float)" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Terminal (below)" },
      -- lazygit in a full-screen floating terminal (needs `lazygit` installed).
      {
        "<leader>gg",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" }):toggle()
        end,
        desc = "Lazygit",
      },
    },
    opts = {
      open_mapping = [[<c-\>]], -- the toggle key (works in normal AND terminal mode)
      direction = "float",      -- "float" | "horizontal" | "vertical" | "tab"
      float_opts = { border = "curved" },
      shade_terminals = true,
    },
  },
}
