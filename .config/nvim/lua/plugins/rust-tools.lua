return {
  {
    "simrat39/rust-tools.nvim",
    opts = function(_, _)
      require("rust-tools").setup({})
    end,
  },
}
