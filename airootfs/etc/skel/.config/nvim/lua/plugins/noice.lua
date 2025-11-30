return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- add any options here
	},
	config = function()
		require("noice").setup({
			views = {
				cmdline_popup = {
					position = {
						row = "50%",
                        -- row = 5,
						col = "50%",
					},
					size = {
						width = 60,
						height = "auto",
					},
				},
				popupmenu = {
					relative = "editor",
					position = {
						-- row = 8,
                        row = "78%",
						col = "50%",
					},
					size = {
						width = 60,
						height = 10,
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
					},
				},
			},
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				long_message_to_split = true, -- long messages will be sent to a split
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
			routes = {
				{
					view = "notify",
					filter = { event = "msg_showmode" },
				},
			},
		})
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = "#69ACDB" }) -- blue background, white text
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#69ACDB" }) -- border to match
	end,
	-- dependencies = {
	-- 	"MunifTanjim/nui.nvim",
		-- {
		-- 	"rcarriga/nvim-notify",
		-- 	config = function()
		-- 		require("notify").setup({
		-- 			background_colour = "#000000",
		-- 		})
		-- 	end,
	-- 	},
	-- },
}
