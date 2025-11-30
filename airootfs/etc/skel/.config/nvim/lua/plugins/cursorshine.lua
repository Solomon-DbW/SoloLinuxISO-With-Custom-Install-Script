return {
	"rlychrisg/cursorshine.nvim",
	event = "CursorMoved", -- must be used to make sure colorscheme is loaded BEFORE hand
	config = function()
		require("cursorshine").setup({
			shine_line = "#263340", -- What color should the cursor line be
			shine_column = "#263340", -- What color should the cursor column be
			shine_duration = 1500, -- How long should the changes last (ms)
		})
	end,
}
