return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true, },
          grep = {
            hidden = true,
            args = {
              "--hidden",
              "--glob=!**/.git/**",
              "--glob=!**/node_modules/**",
            },
            exclude = {
              ".git",
              "node_modules",
            },
          },
        },
      },
    },
  },
}
