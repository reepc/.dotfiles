return {
	"vyfor/cord.nvim",
	build = ":Cord update", -- downloads/builds the Rust server binary
	event = "VeryLazy", -- load after startup so it doesn't slow launch
	opts = {
		editor = {
			tooltip = "Neovim", -- hover text on the editor image
		},
		display = {
			theme = "default",
			flavor = "dark",
		},
		timestamp = {
			enabled = true, -- show elapsed time
			reset_on_idle = false,
		},
		idle = {
			enabled = true,
			timeout = 300000, -- 5 min
			show_status = true,
			details = "Idling",
		},
		text = {
			editing = function(opts)
				return "Editing " .. opts.filename
			end,
			viewing = function(opts)
				return "Viewing " .. opts.filename
			end,
			file_browser = "Browsing files",
			workspace = function(opts)
				return "In " .. opts.workspace
			end,
		},
	},
}
