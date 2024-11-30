return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- General Config
      -- diagnostics = { virtual_text = false },
      -- Language Servers
      servers = {
        -- Script Dev
        bashls = {},
        -- Web Dev
        svelte = {},
        tsserver = {},
        html = {},
        cssls = {},
        astro = {},
        rust_analyzer = {
          mason = false,
        },
      },
    },
  },
}
