return {
	-- Explorer
	"stevearc/oil.nvim",
	opts = {
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-v>"] = "actions.select_vsplit",
			["<C-s>"] = "actions.select_split",
			["<C-t>"] = "actions.select_tab",
			["<C-p>"] = "actions.preview",
			["<C-c>"] = "actions.close",
			["<R>"] = "actions.refresh",
			["-"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = "actions.tcd",
			["gs"] = "actions.change_sort",
			["gx"] = "actions.open_external",
			["g."] = "actions.toggle_hidden",
		},
		use_default_keymaps = false,
	},
	-- Optional dependencies
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
}
