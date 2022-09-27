return {
  ["kyazdani42/nvim-tree.lua"] = {
    event = "VimEnter",
    override_options = {
      open_on_setup = true,
      git = {
        enable = true,
        ignore = false,
      },
      renderer = {
        highlight_git = true,
        icons = {
          show = {
            git = false,
          },
        },
      },
      view = {
        adaptive_size = false,
        side = "left",
        width = 30,
      },
    },
  },
  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
  },
  ["nvim-treesitter/nvim-treesitter"] = {
    override_options = {
      ensure_installed = {
        "vim",
        "html",
        "css",
        "javascript",
        "json",
        "toml",
        "markdown",
        "bash",
        "lua",
        "vue"
      },
    },
  },
  ["williamboman/mason.nvim"] = {
    override_options = {
      ensure_installed = {
        -- lua stuff
        "lua-language-server",
        "stylua",

        -- web dev
        "css-lsp",
        "html-lsp",
        "typescript-language-server",
        "emmet-ls",
        "json-lsp",
        "vue-language-server",
        "eslint-lsp",

        -- shell
        "shellcheck",
      },
    },
  },

  --------------------------------------------- custom plugins ----------------------------------------------

  -- autoclose tags in html, jsx only
  ["windwp/nvim-ts-autotag"] = {
    ft = { "html", "vue" },
    after = "nvim-treesitter",
    config = function()
      local present, autotag = pcall(require, "nvim-ts-autotag")

      if present then
        autotag.setup()
      end
    end,
  },

  -- format & linting
  ["jose-elias-alvarez/null-ls.nvim"] = {
    after = "nvim-lspconfig",
    config = function()
      require "custom.plugins.null-ls"
    end,
  },
}
