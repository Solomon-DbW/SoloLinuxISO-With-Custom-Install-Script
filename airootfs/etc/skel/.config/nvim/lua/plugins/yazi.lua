return {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = {
        "folke/snacks.nvim",
    },
    config = function()
        vim.keymap.set("n", "<leader>yz", ":Yazi<CR>")
    end,
}
