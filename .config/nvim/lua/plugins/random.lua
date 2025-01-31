return {
  { "catppuccin/nvim" },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
  { "folke/todo-comments.nvim", enabled = false },
  { "folke/which-key.nvim", opts = { preset = "modern" } },
  {
    "stevearc/overseer.nvim",
    opts = {},
  },
}
