-- Hide the LazyVim splash logo (header)
return {
	{
		"folke/snacks.nvim",
		opts = {
			dashboard = {
				preset = {
					header = "",
				},
			},
		},
	},
}
