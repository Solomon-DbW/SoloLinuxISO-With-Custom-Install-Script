vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set softtabstop=2")
vim.cmd("set autoindent")
vim.cmd("set number")
vim.cmd("set smartindent")
vim.cmd("set relativenumber")
vim.cmd("set splitright")

vim.g.vimtex_view_method = "zathura"

-- FOR LOADING HTML IN BRAVE --
vim.api.nvim_create_user_command("OpenInBrave", function()
	local file = vim.fn.expand("%:p")
	if file:match("%.html$") then
		vim.fn.jobstart({ "brave", file }, { detach = true })
	else
		print("Not an HTML file")
	end
end, {})

-- Keybinding: Press <leader>o to open in Brave
vim.api.nvim_set_keymap("n", "<leader>o", ":OpenInBrave<CR>", { noremap = true, silent = true })

-- Keybinding: Changing tabs with barbar
vim.keymap.set("n", "<leader>,", ":BufferPrevious<CR>")
vim.keymap.set("n", "<leader>.", ":BufferNext<CR>")
