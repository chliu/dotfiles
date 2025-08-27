require("nvchad.configs.lspconfig").defaults()

local servers = { "clangd", "clang-format", "html", "cssls", "typescript", "javascript", "jsonls", "tailwindcss", "eslint_d", "tsserver", "jdtls" }

vim.lsp.enable(servers)

vim.api.nvim_create_autocmd("BufWritePre", {
  -- pattern = "*",
  pattern = "*.cpp,*.hpp,*.cxx,*.hxx", -- Apply to C++ file types
  callback = function(args)
    vim.lsp.buf.format { bufnr = args.buf }
  end,
})
-- read :h vim.lsp.config for changing options of lsp servers
