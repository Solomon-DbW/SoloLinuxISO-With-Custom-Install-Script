-- return {
-- 	"lervag/vimtex",
-- 	lazy = false, -- we don't want to lazy load VimTeX
-- 	-- tag = "v2.15", -- uncomment to pin to a specific release
-- 	init = function()
-- 		-- VimTeX configuration goes here, e.g.
-- 		vim.g.vimtex_view_method = "zathura"
-- 	end,
-- }

return {
	"lervag/vimtex",
	lazy = false, -- We don't want to lazy load VimTeX
	-- tag = "v2.15", -- uncomment to pin to a specific release

	init = function()
		-- Set the viewer method to Zathura.
		vim.g.vimtex_view_method = "zathura"

		-- Compiler Backend: Using 'latexrun' as specified.
		-- vim.g.vimtex_compiler_method = "latexrun"
		vim.g.vimtex_compiler_method = "latexmk"

		-- Local Leader: Setting the local leader for VimTeX mappings to comma (,).
		vim.g.maplocalleader = ","

		-- The following options are generally NOT needed in modern Neovim
		-- setups using a plugin manager, but they are included here for
		-- completeness if you find that features are missing:
		-- vim.cmd('filetype plugin indent on')
		vim.cmd('syntax enable')

		-- Okular Generic Interface (Uncomment these if you want to use Okular instead of Zathura)
		-- vim.g.vimtex_view_general_viewer = 'okular'
		-- vim.g.vimtex_view_general_options = '--unique file:@pdf#src:@line@tex'
	end,
}
