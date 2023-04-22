return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        svelte = {},
        tsserver = {},
        html = {},
        cssls = {},
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
