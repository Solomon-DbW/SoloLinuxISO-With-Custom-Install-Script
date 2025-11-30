return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        opts = {
            auto_install = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            -- ✅ Correctly require the cmp_nvim_lsp module
            local cmp_nvim_lsp = require("cmp_nvim_lsp") 
            
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_nvim_lsp.default_capabilities()
            )

            -- Add folding capability (uncommented for completeness if needed)
            -- capabilities.textDocument.foldingRange = {
            --    dynamicRegistration = false,
            --    lineFoldingOnly = true,
            -- }

            -- ❌ DEPRECATED: local lspconfig = require("lspconfig")
            -- ✅ MIGRATED: Setup server configs directly using vim.lsp.config
            
            -- tailwindcss
            vim.lsp.config("tailwindcss",{
                capabilities = capabilities,
            })
            
            -- hls (Haskell)
            vim.lsp.config("hls", {
                filetypes = { 'haskell', 'lhaskell' },
                settings = {
                    haskell = {
                        formattingProvider = "ormolu", -- or "fourmolu" / "stylish-haskell"
                        plugin = {
                            hlint = { globalOn = true },
                        },
                    },
                },
            })
            
            -- texlab
            vim.lsp.config("texlab", {})
            
            -- lua_ls
            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
            })
            
            -- pyright
            vim.lsp.config("pyright", {
                capabilities = capabilities,
            })

            -- --- Diagnostic virtual text setup
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "󱈸", -- change to whatever you like
                    spacing = 2,
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            -- --- Keymaps
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Show documentation" })
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "LSP: Go to definition" })
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "LSP: Find references" })
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code action" })
            vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "LSP: Format document" })
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename symbol" }) -- Uncommented and added description
        end,
    },
}
