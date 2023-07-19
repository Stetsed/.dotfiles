return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        svelte = {},
        tsserver = {},
        html = {},
        cssls = {},
        astro = {},
      },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        svelte = true,
      },
    },
  },
}
