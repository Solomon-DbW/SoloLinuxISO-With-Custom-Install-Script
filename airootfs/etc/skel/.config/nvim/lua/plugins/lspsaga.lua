return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  config = function()
    require("lspsaga").setup({
      symbol_in_winbar = {
        enable = true,
        separator = "  ",  -- breadcrumb separator icon
        hide_keyword = true,
        show_file = true,
        folder_level = 2,
        color_mode = true,
      },
    })
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "neovim/nvim-lspconfig",
  },
}

