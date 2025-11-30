return {
	"tanvirtin/monokai.nvim",
	config = function()
		vim.cmd("colorscheme monokai") -- Apply the Monokai color scheme
		local orange = "#FFC700"

		vim.api.nvim_set_hl(0, "@string", { fg = "#FFFFFF" })
		vim.api.nvim_set_hl(0, "@variable", { fg = orange })
		vim.api.nvim_set_hl(0, "@type", { fg = "orange" })
		-- vim.api.nvim_set_hl(0, "@function", { fg = orange })
		-- vim.api.nvim_set_hl(0, "@function.call", { fg = orange })
		-- vim.api.nvim_set_hl(0, "@function.builtin", { fg = orange })
		-- vim.api.nvim_set_hl(0, "@method", { fg = orange })
	end,
}
