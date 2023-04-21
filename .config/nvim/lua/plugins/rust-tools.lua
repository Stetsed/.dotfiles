return {
  {
    "simrat39/rust-tools.nvim",
    opts = function(_, _)
      require("rust-tools").setup({})
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",
      },
    },
  },
}
