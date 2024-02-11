local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- Custom lsp configs

lspconfig.volar.setup {
  init_options = {
    typescript = {
      tsdk = "./node_modules/typescript/lib",
      -- Alternative location if installed as root:
      -- tsdk = '/usr/local/lib/node_modules/typescript/lib'
    },
  },
  on_attach = on_attach,
  capabilities = capabilities,
}

lspconfig.gopls.setup {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      completeUnimported = true,
      usePlaceholders = true,
      gofumpt = true,
    },
  },
  cmd = { "gopls" },
  on_attach = on_attach,
  capabilities = capabilities,
}
