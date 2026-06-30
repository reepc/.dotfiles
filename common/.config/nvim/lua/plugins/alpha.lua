-- lua/plugins/alpha.lua
-- Minimal startup screen: a bongo-cat "text image" and nothing else (no file
-- list, no button menu). Like VSCode's empty editor, but cuter. Only shows when
-- there's nothing else to draw -- i.e. plain `nvim` in a folder with no saved
-- session (see session.lua). Open a file or restore a session and it's gone.
--
-- The art lives in assets/bongo-cat.txt (kept out of this file because it's a
-- big ASCII image). To swap in different art, replace that file. To regenerate
-- from a real image at a chosen width (needs `jp2a`, `brew install jp2a`):
--   jp2a --width=120 some-image.png > ~/.config/nvim/assets/bongo-cat.txt
-- Keep the width modest (~120) so it fits your terminal; alpha centers it.

return {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- Load the art. stdpath("config") resolves to ~/.config/nvim, where this
        -- repo's common/.config/nvim is stowed. Fall back to text if it's missing.
        local art_path = vim.fn.stdpath("config") .. "/assets/bongo-cat.txt"
        local header = vim.fn.filereadable(art_path) == 1 and vim.fn.readfile(art_path)
            or { "bongo!" }

        dashboard.section.header.val = header
        dashboard.section.header.opts.hl = "Comment" -- faded, like a dimmed icon

        -- Logo only: no shortcut menu, no recent-files list.
        dashboard.section.buttons.val = {}

        -- The art is tall, so just a little top padding; alpha centers each line.
        dashboard.config.layout = {
            { type = "padding", val = 1 },
            dashboard.section.header,
        }
        dashboard.opts.opts.noautocmd = true

        alpha.setup(dashboard.config)
    end,
}
